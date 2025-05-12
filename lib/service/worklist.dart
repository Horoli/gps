part of gps_test;

class ServiceWorklist extends CommonService {
  static ServiceWorklist? _instance;
  factory ServiceWorklist.getInstance() =>
      _instance ??= ServiceWorklist._internal();

  ServiceWorklist._internal();

  final BehaviorSubject<MWorkList?> subject =
      BehaviorSubject<MWorkList?>.seeded(null);

  Stream<MWorkList?> get stream => subject.stream;

  MWorkList? get lastValue => subject.valueOrNull;

  Future<MWorkList> get() async {
    Completer<MWorkList> completer = Completer<MWorkList>();
    final List<String> cookies = await CookieManager.load();

    debugPrint('cookies $cookies');

    final Response response = await HttpConnector.get(
      dio: dio,
      url: '${URL.BASE_URL}/${URL.GET_WORK_LIST}',
      cookies: cookies,
    );

    if (!completer.isCompleted) {
      final Map<String, dynamic> data = response.data as Map<String, dynamic>;

      // currentWork 파싱 (null일 수 있음)
      CurrentWork? currentWork;
      if (data.containsKey('currentWork') && data['currentWork'] != null) {
        try {
          final Map<String, dynamic> currentWorkData =
              data['currentWork'] as Map<String, dynamic>;
          currentWork = CurrentWork.fromMap(currentWorkData);
          debugPrint('현재 작업 파싱 성공: ${currentWork.uuid}');
        } catch (e) {
          debugPrint('현재 작업 파싱 오류: $e');
          // 파싱 오류가 있어도 전체 결과에는 영향을 주지 않도록 함
          currentWork = null;
        }
      }
      debugPrint('currentWork $currentWork');

      // workList 파싱
      final List<MWorkData> works = (data['workList'] as List<dynamic>)
          .map(
              (workItem) => MWorkData.fromMap(workItem as Map<String, dynamic>))
          .toList();
      debugPrint('works $works');

      // step 파싱
      final List<String> steps = (data['step'] as List<dynamic>)
          .map((step) => step.toString())
          .toList();

      // date 파싱
      final String date = data['date'] as String;

      // MWorkListData 객체 생성
      final MWorkList result = MWorkList(
        currentWork: currentWork,
        works: works,
        step: steps,
        date: date,
      );

      subject.add(result);
      completer.complete(result);
    }

    return completer.future;
  }

  // 현재 작업 완료 함수
  Future<void> completeProcedure() async {
    try {
      final List<String> cookies = await CookieManager.load();
      // final Map<String, dynamic> headers =
      //     HttpConnector.headersByCookie(cookies);
      dio.options.extra['withCredentials'] = true;
      debugPrint('cookies $cookies');

      // 현재 시간을 ISO 8601 형식의 문자열로 변환
      String uuid = lastValue!.currentWork!.uuid;
      // Position? position = await Geolocator.getLastKnownPosition();
      Position? position = GServiceLocation._subject.valueOrNull;
      if (position == null) {
        return ShowInformationWidgets.errorDialog(
            GNavigationKey.currentState!.context, 'GPS 값을 찾을 수 없습니다');
      }
      final String timestamp = DateTime.now().toIso8601String();
      debugPrint(
          '중간 : gps값 갱신 lat ${position.latitude} / lng ${position.longitude} ${DateTime.now().millisecondsSinceEpoch}');

      final Response response = await HttpConnector.post(
          dio: dio,
          url: '${URL.BASE_URL}/api/user/work/$uuid/procedure/complete',
          cookies: cookies,
          data: {
            "lng": position.longitude,
            "lat": position.latitude,
            "description": '',
            "timestamp": timestamp
          });
    } on DioException catch (e) {
      if (e.response != null) {
        ResponseBody errorBody = e.response?.data as ResponseBody;

        debugPrint('error statusCode : ${e.response?.statusCode}');
        debugPrint('error message : ${errorBody.statusMessage}');
        throw errorBody;
      }
    }
  }
}
