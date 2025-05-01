part of gps_test;

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
    final Dio newDio = Dio(BaseOptions(
      baseUrl: URL.BASE_URL,
      // connectTimeout: const Duration(seconds: 30),
      // receiveTimeout: const Duration(seconds: 30),
      // sendTimeout: const Duration(seconds: 30),
    ));

    return newDio;
  }

// 연결 상태를 추적하기 위한 변수들 추가
  bool _isConnected = false;
  DateTime? _lastEventTime;
  Timer? _healthCheckTimer;
  int _reconnectAttempts = 0;
  final int _maxReconnectAttempts = 5;
  final Duration _reconnectDelay = Duration(seconds: 2);
  final Duration _healthCheckInterval = Duration(seconds: 30);

  ServiceSSE._internal();

  late Stream eventStream;
  StreamSubscription? _eventSub;
  final StreamTransformer _transformer =
      StreamTransformer<Uint8List, Map<String, dynamic>>.fromHandlers(
    handleData: (data, sink) {
      try {
        final String rawData = utf8.decode(data);
        print('rawData $rawData');
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
            parsedData = json.decode(dataStr);
          } catch (e) {
            print('JSON parsing error: $e');
            parsedData = {'raw': dataStr};
          }

          sink.add(parsedData);
        }
      } catch (e) {
        print('SSE parsing error :$e');
      }

      // sink.add(utf8.decode((data)));
    },
    handleError: (error, stackTrace, sink) {
      print('error $error');
      sink.addError(error, stackTrace);
    },
  );

  // 테스트용으로 로그인 후 재연결 시도를 해 봄
  // 계정별로 1세션 / 1커넥션만 승인되는것 같음
  Future<void> innerTest({bool reconnect = true}) async {
    await GServiceUser.login(id: tmpID, phoneNumber: tmpNumber).then((user) {
      GServiceSSE.connect(reconnect: reconnect);
    });
  }

  Future<void> connect({bool reconnect = true}) async {
    try {
      _dio = _getNewDioInstance();
      final List<String> cookies = await CookieManager.loadCookies();
      print('cookies $cookies');
      final Map<String, dynamic> headers =
          DioConnector.streamHeadersByCookie(cookies);
      dio.options.extra['withCredentials'] = true;
      print('stream step 1');
      print('headers $headers');
      final Response response = await _dio!.get(
        '${URL.BASE_URL}/${URL.STREAM}',
        options: Options(
          responseType: ResponseType.stream,
          extra: {'withCredentials': true},
          headers: headers,
        ),
      );

      print('stream step 2');

      Stream tmpStream = response.data.stream as Stream;
      eventStream = tmpStream.transform(_transformer);
      print('stream step 3');

      _isConnected = true;
      _lastEventTime = DateTime.now();
      _eventSub?.cancel();
      _eventSub = eventStream.listen((dynamic data) async {
        print('event received : $data');
        _lastEventTime = DateTime.now();
        await GServiceWorklist.get();
        CurrentWork? getCurrentWork = GServiceWorklist.lastValue!.currentWork;

        print('in stream currentWork : $getCurrentWork');

        // stream을 구독하고 있으면서
        // currentWork를 갖고 있지만 WORK_DETAIL 화면이 아닌 user는
        // WORK_DETAIL 화면으로 이동
        if (getCurrentWork != null && !RouterManager().isWorkDetail()) {
          Navigator.of(GNavigationKey.currentState!.context)
              .pushReplacementNamed(PATH.ROUTE_WORK_DETAIL);
        }

        String uuid = data['uuid'];
        print('check uuid... ${getCurrentWork?.uuid == uuid}');
        if (getCurrentWork != null && getCurrentWork.uuid == uuid) {
          print('valid uuid');
          Map<String, dynamic> unflattenedData = unflatten(data['update']);

          print('unflattenedData $unflattenedData');
          if (unflattenedData.containsKey('procedures') &&
              unflattenedData['procedures'] is List) {
            List updatedProcedures = List.from(unflattenedData['procedures']);

            int getIndex = List.from(updatedProcedures).indexWhere((e) {
              return e != null;
            });
            print('getIndex $getIndex');
            print('work ${GServiceWorklist.lastValue!.currentWork}');
            if (getIndex < 4) {
              // 현재 작업 가져오기
              CurrentWork currentWork = getCurrentWork;

              // 현재 작업의 procedures 가져오기
              List<MProcedureInCurrentWork> currentProcedures =
                  currentWork.procedures;

              // 업데이트할 procedures 가져오기
              // 가져온 updatedProcedures[getIndex]를 포메팅해줘야함
              Map<String, dynamic> updatedProcedureData = {};
              if (updatedProcedures[getIndex] != null) {
                Map originalMap = updatedProcedures[getIndex] as Map;
                originalMap.forEach((key, value) {
                  updatedProcedureData[key.toString()] = value;
                });
              }

              print('updatedProcedureData $updatedProcedureData');

              // 기존 procedure가져오기
              MProcedureInCurrentWork existingProcedure =
                  currentProcedures[getIndex];

              DateTime? updatedDate = updatedProcedureData.containsKey('date')
                  ? updatedProcedureData['date'] == null
                      ? null // work가 최초 생성됐을 경우엔 null임
                      : DateTime.parse(updatedProcedureData['date'] as String)
                  : existingProcedure.date;

              List<double>? updatedLocation;
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
              } else {
                updatedLocation = existingProcedure.location;
              }

              // 업데이트된 procedure를 저장
              MProcedureInCurrentWork updatedProcedure =
                  existingProcedure.copyWith(
                date: updatedDate,
                location: updatedLocation,
              );

              // 현재 작업의 procedure에 업데이트된 procedure를 할당
              currentProcedures[getIndex] = updatedProcedure;

              // 현재 작업을 업데이트
              CurrentWork updatedCurrentWork =
                  currentWork.copyWith(procedures: currentProcedures);

              // 작업리스트를 업데이트
              MWorkList updatedWorkList = GServiceWorklist.lastValue!
                  .copyWith(currentWork: updatedCurrentWork);

              GServiceWorklist.subject.add(updatedWorkList);
              print('stream complete');
            }

            // 마지막 작업이 완료되면 getCurrentWork가 null이 되기 때문에
            // 마지막 작업이 완료되면 ViewWorklist로 이동
            if (getIndex == 4) {
              Navigator.of(GNavigationKey.currentState!.context)
                  .pushReplacementNamed(PATH.ROUTE_WORKLIST);
            }
          }
        }
      }, onError: (error) {
        print('SSE stream error : $error');
        _isConnected = false;
        if (reconnect) {
          healthCheck();
        }
      }, onDone: () {
        print('SSE stream closed');
        _isConnected = false;
        if (reconnect) {
          healthCheck();
        }
      });

      if (reconnect) {
        healthCheck();
      }
    } on DioException catch (e) {
      _isConnected = false;
      // rethrow;

      if (e.response != null) {
        ResponseBody errorBody = e.response?.data as ResponseBody;

        print('error statusCode : ${e.response?.statusCode}');
        print('error message : ${errorBody.statusMessage}');
        // throw errorBody;
        rethrow;
      }
      rethrow;
    }
  }

  // TODO : 재연결 관련 연결상태 체크
  Future<void> healthCheck() async {
    // 이미 타이머가 실행 중이면 중지
    _healthCheckTimer?.cancel();

    // 주기적으로 연결 상태 확인
    _healthCheckTimer = Timer.periodic(_healthCheckInterval, (timer) async {
      print('Performing SSE health check...');

      // 마지막 이벤트 수신 시간 확인
      final now = DateTime.now();
      final timeSinceLastEvent = _lastEventTime != null
          ? now.difference(_lastEventTime!)
          : Duration(hours: 1); // 초기값으로 큰 값 설정

      // 연결 상태 확인 조건:
      // 1. _isConnected가 false이거나
      // 2. 마지막 이벤트 수신 후 일정 시간(1분) 이상 지났거나
      // 3. _eventSub이 null이거나 closed 상태인 경우
      bool needsReconnect = !_isConnected ||
          timeSinceLastEvent > Duration(minutes: 1) ||
          _eventSub == null;

      // 재연결이 필요한 경우
      if (needsReconnect) {
        print('SSE connection needs reconnection. Attempting to reconnect...');

        // 기존 연결 해제
        // await _cleanupConnection();

        // 재연결 시도 횟수 제한 확인
        if (_reconnectAttempts < _maxReconnectAttempts) {
          _reconnectAttempts++;

          // 지수 백오프를 사용한 재연결 지연 시간 계산
          final delay = Duration(
              milliseconds: _reconnectDelay.inMilliseconds *
                  (1 << (_reconnectAttempts - 1)));
          print(
              'Reconnect attempt $_reconnectAttempts of $_maxReconnectAttempts after ${delay.inSeconds}s');

          // 지연 후 재연결 시도
          await Future.delayed(delay);
          try {
            await disconnect();
            await innerTest();
            // await connect(reconnect: true);
            _reconnectAttempts = 0; // 성공 시 재시도 횟수 초기화
            print('SSE reconnection successful');
          } catch (e) {
            print('SSE reconnection failed: $e');
            // 다음 healthCheck에서 다시 시도
          }
        } else {
          print(
              'Max reconnection attempts reached. Stopping reconnection attempts.');
          timer.cancel(); // 최대 시도 횟수 초과 시 타이머 중지
        }
      } else {
        print('SSE connection is healthy');
        _reconnectAttempts = 0; // 정상 상태면 재시도 횟수 초기화
      }
    });
  }

  // // 연결 정리 및 리소스 해제
  // Future<void> _cleanupConnection() async {
  //   try {
  //     await _eventSub?.cancel();

  //     _eventSub = null;
  //     _isConnected = false;
  //   } catch (e) {
  //     print('Error during connection cleanup: $e');
  //   }
  // }

  Future<void> disconnect() async {
    print('Performing full reset of SSE service...');

    try {
      // 1. 타이머 취소
      _healthCheckTimer?.cancel();
      _healthCheckTimer = null;

      // 2. 이벤트 구독 취소
      await _eventSub?.cancel();
      _eventSub = null;

      // 3. 상태 초기화
      _isConnected = false;
      _lastEventTime = null;
      _reconnectAttempts = 0;

      // 4. Dio 인스턴스 교체
      _dio = _getNewDioInstance();

      // 5. 잠시 대기
      await Future.delayed(Duration(seconds: 2));

      print('Full reset completed');
    } catch (e) {
      print('Error during full reset: $e');
    }
  }
}
