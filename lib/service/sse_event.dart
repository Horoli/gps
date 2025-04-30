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

  ServiceSSE._internal();

  late Stream eventStream;
  StreamSubscription? _eventSub;
  final StreamTransformer _transformer =
      StreamTransformer<Uint8List, Map<String, dynamic>>.fromHandlers(
    handleData: (data, sink) {
      try {
        final String rawData = utf8.decode(data);
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

  Future<void> connect({bool reconnect = true}) async {
    try {
      // TODO :reconnect 관련 코드 추가
      final List<String> cookies = await CookieManager.loadCookies();
      print('cookies $cookies');
      final Map<String, dynamic> headers =
          DioConnector.streamHeadersByCookie(cookies);
      dio.options.extra['withCredentials'] = true;
      final Response response = await dio.get(
        '${URL.BASE_URL}/${URL.STREAM}',
        options: Options(
          responseType: ResponseType.stream,
          extra: {'withCredentials': true},
          headers: headers,
        ),
      );

      Stream tmpStream = response.data.stream as Stream;
      eventStream = tmpStream.transform(_transformer);
      _eventSub?.cancel();
      _eventSub = eventStream.listen((dynamic data) {
        CurrentWork? getCurrentWork = GServiceWorklist.lastValue!.currentWork;

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

              // 기존 procedure가져오기
              MProcedureInCurrentWork existingProcedure =
                  currentProcedures[getIndex];

              DateTime? updatedDate = updatedProcedureData.containsKey('date')
                  ? DateTime.parse(updatedProcedureData['date'] as String)
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
      });
    } on DioException catch (e) {
      if (e.response != null) {
        ResponseBody errorBody = e.response?.data as ResponseBody;

        print('error statusCode : ${e.response?.statusCode}');
        print('error message : ${errorBody.statusMessage}');
        throw errorBody;
      }
    }
  }

  // TODO : 로그아웃 시 disconnect 실행
  Future<void> disconnect() async {}

  // TODO : 재연결 관련 연결상태 체크
  Future<void> healthCheck() async {}
}
