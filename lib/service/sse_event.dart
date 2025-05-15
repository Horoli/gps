part of FlightSteps;

class SSEEvent {
  final String id;
  final String event;
  final Map<String, dynamic> data;

  SSEEvent({required this.id, required this.event, required this.data});

  @override
  String toString() => 'SSEEvent(id: $id, event: $event, data: $data)';
}

class ServiceSSE extends CommonService {
  static ServiceSSE? _instance;
  factory ServiceSSE.getInstance() => _instance ??= ServiceSSE._internal();

  Dio? _dio;

  Dio _getNewDioInstance() {
    Dio newDio = Dio(BaseOptions(
      // baseUrl: URL.BASE_URL,
      connectTimeout: const Duration(seconds: 10),
      // receiveTimeout: null,
      // sendTimeout: const Duration(seconds: 30),
    ));

    newDio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        options.extra['startTime'] = DateTime.now().microsecondsSinceEpoch;
        debugPrint('Starting request to ${options.path}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        final int startTime = response.requestOptions.extra['startTime'] as int;
        final int endTime = DateTime.now().millisecondsSinceEpoch;
        final int duration = endTime - startTime;
        debugPrint(
            'Request to ${response.requestOptions.path} took ${duration}ms');
        debugPrint('Received response from ${response.requestOptions.path}');
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        final int startTime = e.requestOptions.extra['startTime'] as int;
        final int endTime = DateTime.now().millisecondsSinceEpoch;
        final int duration = endTime - startTime;
        debugPrint(
            'Failed request to ${e.requestOptions.path} took ${duration}ms');
        debugPrint(
            'Error in request to ${e.requestOptions.path}: ${e.message}');
        return handler.next(e);
      },
    ));

    newDio.interceptors.add(LogInterceptor(
      request: true,
      responseBody: true,
      requestBody: true,
      error: true,
      logPrint: (message) {
        debugPrint('Dio Log: $message');
      },
    ));

    return newDio;
  }

// 연결 상태를 추적하기 위한 변수들 추가
  bool _isConnected = false;
  DateTime? _lastEventTime;
  Timer? _healthCheckTimer;
  int _reconnectAttempts = 0;
  final int _maxReconnectAttempts = 5;
  final Duration _reconnectDelay = const Duration(seconds: 2);

  final Duration _healthCheckInterval = const Duration(seconds: 120);

  ServiceSSE._internal();

  late Stream eventStream;
  StreamSubscription? _eventSub;
  StreamSubscription? connectivitySubscription;
  bool _hasNetworkConnection = true;

  final StreamTransformer _transformer =
      StreamTransformer<Uint8List, Map<String, dynamic>>.fromHandlers(
    handleData: (data, sink) {
      try {
        final String rawData = utf8.decode(data);
        debugPrint('rawData $rawData');
        final List<String> splitData = rawData.split('\n');
        String id = '';
        String event = '';
        String dataStr = '';

        for (String line in splitData) {
          if (line.startsWith('id:')) {
            id = line.substring(3).trim();
          } else if (line.startsWith('event:')) {
            event = line.substring(6).trim();
          } else if (line.startsWith('data:')) {
            dataStr = line.substring(5).trim();
          }
        }

        if (dataStr.isNotEmpty) {
          Map<String, dynamic> parsedData = {};
          try {
            debugPrint('dataStr $dataStr');
            parsedData = json.decode(dataStr);
          } catch (e) {
            debugPrint('JSON parsing error: $e');
            parsedData = {
              'id': id,
              'event': event,
              'raw': dataStr,
            };
          }

          sink.add(parsedData);
        }
      } catch (e) {
        debugPrint('SSE parsing error :$e');
      }

      // sink.add(utf8.decode((data)));
    },
    handleError: (error, stackTrace, sink) {
      debugPrint('error $error');
      sink.addError(error, stackTrace);
    },
  );

  void setNetworkListener() {
    connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) async {
      debugPrint('network listener $result');

      if (result.contains(ConnectivityResult.none)) {
        debugPrint('network is not connected');
        _hasNetworkConnection = false;
        await disconnect(ignoreErrors: true);
      } else {
        debugPrint('network is connected');
        _hasNetworkConnection = true;
        await connect();
      }
    });
  }

  Future<void> connect({bool reconnect = true}) async {
    if (_isConnected) {
      await disconnect(ignoreErrors: true);
    }
    if (connectivitySubscription == null) {
      setNetworkListener();
    }

    _dio = _getNewDioInstance();

    final List<String> cookies = await CookieManager.load();

    debugPrint('stream step 1');
    final Response response = await HttpConnector.stream(
      dio: _dio!,
      url: '${URL.BASE_URL}/${URL.STREAM}',
      cookies: cookies,
    );

    debugPrint('stream step 2');

    Stream tmpStream = response.data.stream as Stream;
    eventStream = tmpStream.transform(_transformer);
    debugPrint('stream step 3');

    _isConnected = true;
    _lastEventTime = DateTime.now();
    debugPrint('stream step 4');

    await _eventSub?.cancel();
    _eventSub = eventStream.listen((data) async {
      final Stopwatch stopwatch = Stopwatch()..start();

      debugPrint('stopwatch start : ${DateTime.now().millisecondsSinceEpoch}');
      try {
        debugPrint('event received : ${data}');
        if (data['event'] == 'sid') {
          debugPrint('first connection event received : ${data}');
          return;
        }

        _lastEventTime = DateTime.now();
        // await GServiceWorklist.get();
        CurrentWork? getCurrentWork = GServiceWorklist.lastValue?.currentWork;

        // stream을 구독하고 있으면서
        // currentWork를 갖고 있지만 WORK_DETAIL 화면이 아닌 user는
        // WORK_DETAIL 화면으로 이동
        if (getCurrentWork != null && getCurrentWork.uuid == data['uuid']) {
          if (!RouterManager().isWorkDetail()) {
            Navigator.of(GNavigationKey.currentState!.context)
                .pushReplacementNamed(PATH.ROUTE_WORK_DETAIL);
          }
        }

        _processWorkUpdate(data, getCurrentWork!);
      } finally {
        stopwatch.stop();
        debugPrint('stopwatch end : ${DateTime.now().millisecondsSinceEpoch}');
        debugPrint('stopwatch : ${stopwatch.elapsedMilliseconds}');
      }
    }, onError: (error) async {
      debugPrint('SSE stream error : $error');
      _isConnected = false;
      if (reconnect) {
        await disconnect(ignoreErrors: true);
      }
    }, onDone: () async {
      debugPrint('SSE stream closed');
      _isConnected = false;
      if (reconnect) {
        await disconnect(ignoreErrors: true);
      }
    });

    if (reconnect) {
      debugPrint('processing healthChecker');
      healthCheckWithTimer();
    }
  }

  Future<int> now() async {
    return DateTime.now().millisecondsSinceEpoch;
  }

  // 이벤트 데이터 처리 로직을 별도 메서드로 분리
  void _processWorkUpdate(Map<String, dynamic> data, CurrentWork currentWork) {
    // unflatten 작업은 비용이 큰 작업이므로 필요한 경우에만 수행
    if (!data.containsKey('update')) return;

    Map<String, dynamic> unflattenedData = unflatten(data['update']);
    debugPrint('unflattenedData $unflattenedData');

    // procedures 데이터가 없으면 처리 중단
    if (!unflattenedData.containsKey('procedures') ||
        !(unflattenedData['procedures'] is List)) {
      return;
    }

    List updatedProcedures = List.from(unflattenedData['procedures']);

    // 빠른 인덱스 찾기
    int getIndex = -1;
    for (int i = 0; i < updatedProcedures.length; i++) {
      if (updatedProcedures[i] != null) {
        getIndex = i;
        break;
      }
    }

    if (getIndex < 0) return; // 유효한 인덱스가 없으면 중단

    // 마지막 작업 완료 처리 (이동 로직)
    if (getIndex == 4) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(GNavigationKey.currentState!.context)
            .pushReplacementNamed(PATH.ROUTE_WORKLIST);
      });
      return;
    }

    // 작업 업데이트 처리 (getIndex < 4)
    if (getIndex < 4) {
      _updateProcedureData(currentWork, updatedProcedures, getIndex);
    }
  }

// 프로시저 데이터 업데이트 로직 분리
  void _updateProcedureData(
      CurrentWork currentWork, List updatedProcedures, int index) {
    // 현재 작업의 procedures 가져오기
    List<MProcedureInCurrentWork> currentProcedures = currentWork.procedures;

    // 인덱스 유효성 검사
    if (index >= currentProcedures.length) return;

    // 업데이트할 데이터 변환 - 캐싱 최적화
    Map<String, dynamic> updatedProcedureData = {};
    if (updatedProcedures[index] != null) {
      Map originalMap = updatedProcedures[index] as Map;
      originalMap.forEach((key, value) {
        updatedProcedureData[key.toString()] = value;
      });
    } else {
      return; // 업데이트할 데이터가 없으면 중단
    }

    // 기존 procedure 가져오기
    MProcedureInCurrentWork existingProcedure = currentProcedures[index];

    // 날짜 처리 최적화
    DateTime? updatedDate = existingProcedure.date;
    if (updatedProcedureData.containsKey('date')) {
      final dateValue = updatedProcedureData['date'];
      updatedDate =
          dateValue == null ? null : DateTime.parse(dateValue as String);
    }

    // 위치 처리 최적화
    List<double>? updatedLocation = existingProcedure.location;
    if (updatedProcedureData.containsKey('location') &&
        updatedProcedureData['location'] is List) {
      List locationList = updatedProcedureData['location'];
      if (locationList.length >= 2) {
        updatedLocation = [
          locationList[0] is double
              ? locationList[0]
              : (locationList[0] as num).toDouble(),
          locationList[1] is double
              ? locationList[1]
              : (locationList[1] as num).toDouble()
        ];
      }
    }

    // 변경사항이 없으면 업데이트 스킵
    if (updatedDate == existingProcedure.date &&
        _areLocationsEqual(updatedLocation, existingProcedure.location)) {
      return;
    }

    // 업데이트된 procedure 생성
    MProcedureInCurrentWork updatedProcedure = existingProcedure.copyWith(
      date: updatedDate,
      location: updatedLocation,
    );

    // 현재 작업의 procedure에 업데이트된 procedure를 할당
    currentProcedures[index] = updatedProcedure;

    // 현재 작업을 업데이트
    CurrentWork updatedCurrentWork =
        currentWork.copyWith(procedures: currentProcedures);

    // 작업리스트를 업데이트
    MWorkList updatedWorkList =
        GServiceWorklist.lastValue!.copyWith(currentWork: updatedCurrentWork);

    // 상태 업데이트
    GServiceWorklist.subject.add(updatedWorkList);
    debugPrint('SSE stream completed');
  }

// 위치 비교 헬퍼 함수
  bool _areLocationsEqual(List<double>? loc1, List<double>? loc2) {
    if (loc1 == null && loc2 == null) return true;
    if (loc1 == null || loc2 == null) return false;
    if (loc1.length != loc2.length) return false;

    for (int i = 0; i < loc1.length; i++) {
      if (loc1[i] != loc2[i]) return false;
    }

    return true;
  }

  // TODO : 재연결 관련 연결상태 체크
  Future<void> healthCheckWithTimer() async {
    // 이미 타이머가 실행 중이면 중지
    _healthCheckTimer?.cancel();

    // 주기적으로 연결 상태 확인
    _healthCheckTimer = Timer.periodic(_healthCheckInterval, (timer) async {
      debugPrint('Performing SSE health check...');

      // 마지막 이벤트 수신 시간 확인
      final now = DateTime.now();
      final timeSinceLastEvent = _lastEventTime != null
          ? now.difference(_lastEventTime!)
          : const Duration(hours: 1); // 초기값으로 큰 값 설정

      // 연결 상태 확인 조건:
      // 1. _isConnected가 false이거나
      // 2. 마지막 이벤트 수신 후 일정 시간(2분) 이상 지났거나
      // 3. _eventSub이 null이거나 closed 상태인 경우
      // 4. _hasNetworkConnection이 false인 경우
      bool needsReconnect = !_isConnected ||
          timeSinceLastEvent > _healthCheckInterval ||
          _eventSub == null ||
          _hasNetworkConnection == false;

      // 재연결이 필요한 경우
      if (needsReconnect) {
        debugPrint(
            'SSE connection needs reconnection. Attempting to reconnect...');

        // 재연결 시도 횟수 제한 확인
        if (_reconnectAttempts < _maxReconnectAttempts) {
          _reconnectAttempts++;

          // 지수 백오프를 사용한 재연결 지연 시간 계산
          final delay = Duration(
              milliseconds: _reconnectDelay.inMilliseconds *
                  (1 << (_reconnectAttempts - 1)));
          debugPrint(
              'Reconnect attempt $_reconnectAttempts of $_maxReconnectAttempts after ${delay.inSeconds}s');

          // 지연 후 재연결 시도
          await Future.delayed(delay);
          try {
            await connect();
            _reconnectAttempts = 0; // 성공 시 재시도 횟수 초기화
            debugPrint('SSE reconnection successful');
          } catch (e) {
            debugPrint('SSE reconnection failed: $e');
            // 다음 healthCheck에서 다시 시도
          }
        } else {
          debugPrint(
              'Max reconnection attempts reached. Stopping reconnection attempts.');
          timer.cancel(); // 최대 시도 횟수 초과 시 타이머 중지
        }
      } else {
        debugPrint('SSE connection is healthy');
        _reconnectAttempts = 0; // 정상 상태면 재시도 횟수 초기화
      }
    });
  }

  Future<void> disconnect({bool ignoreErrors = false}) async {
    debugPrint('Performing full reset of SSE service...');

    try {
      // 1. 타이머 취소
      if (_healthCheckTimer != null) {
        _healthCheckTimer!.cancel();
        _healthCheckTimer = null;
        debugPrint('Health check timer canceled');
      }

      // 2. 이벤트 구독 강제 취소
      if (_eventSub != null) {
        try {
          _eventSub!.pause();
          await _eventSub!.cancel();
          debugPrint('Event subscription canceled');
          await Future.delayed(const Duration(milliseconds: 300));
        } catch (e) {
          debugPrint('Error canceling event subscription: $e');
        }
        _eventSub = null;
      }

      // 3. Dio 인스턴스 강제 종료
      if (_dio != null) {
        try {
          _dio!.close(force: true);
          _dio!.interceptors.clear();
          debugPrint('Dio instance closed (force: true)');
          _dio = null;
          // 5. 잠시 대기
          await Future.delayed(const Duration(milliseconds: 300));
        } catch (e) {
          debugPrint('Error closing Dio instance: $e');
        }
      }

      // 4. 연결 상태 구독 강제 취소
      // if (connectivitySubscription != null) {
      //   try {
      //     await connectivitySubscription!.cancel();
      //     debugPrint('Connectivity subscription canceled');
      //   } catch (e) {
      //     debugPrint('Error canceling connectivity subscription: $e');
      //   }
      //   connectivitySubscription = null;
      // }

      // 4. 상태 초기화
      _isConnected = false;
      _lastEventTime = null;
      _reconnectAttempts = 0;
      // 추가 대기 시간
      await Future.delayed(const Duration(seconds: 2));
      debugPrint('Full reset completed');
    } catch (e) {
      debugPrint('Error during full reset: $e');
      if (!ignoreErrors) rethrow;
    }
  }
}
