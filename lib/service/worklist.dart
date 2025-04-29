part of gps_test;

class ServiceWorklist extends CommonService {
  static ServiceWorklist? _instance;
  factory ServiceWorklist.getInstance() =>
      _instance ??= ServiceWorklist._internal();

  ServiceWorklist._internal();

  final BehaviorSubject<MWorkList?> _subject =
      BehaviorSubject<MWorkList?>.seeded(null);

  Stream<MWorkList?> get stream => _subject.stream;

  MWorkList? get lastValue => _subject.valueOrNull;

  Future<MWorkList> get() async {
    Completer<MWorkList> completer = Completer<MWorkList>();
    final List<String> cookies = await CookieManager.loadCookies();

    print('cookies $cookies');

    final Map<String, dynamic> headers = DioConnector.headersByCookie(cookies);
    dio.options.extra['withCredentials'] = true;

    final Response response = await dio.get(
      '${URL.BASE_URL}/${URL.GET_WORK_LIST}',
      options: Options(
        extra: {'withCredentials': true},
        headers: headers,
      ),
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
          print('현재 작업 파싱 성공: ${currentWork.uuid}');
        } catch (e) {
          print('현재 작업 파싱 오류: $e');
          // 파싱 오류가 있어도 전체 결과에는 영향을 주지 않도록 함
          currentWork = null;
        }
      }
      print('currentWork $currentWork');

      // workList 파싱
      final List<MWorkData> works = (data['workList'] as List<dynamic>)
          .map(
              (workItem) => MWorkData.fromMap(workItem as Map<String, dynamic>))
          .toList();
      print('works $works');

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

      _subject.add(result);
      completer.complete(result);
    }

    return completer.future;
  }

  // 현재 작업 완료 함수
  // 현재 작업 완료 처리 후 화면을 갱신해야 하기 때문에 get()을 실행
  Future<void> completeProcedure() async {
    final List<String> cookies = await CookieManager.loadCookies();
    final Map<String, dynamic> headers = DioConnector.headersByCookie(cookies);
    dio.options.extra['withCredentials'] = true;

    // 현재 시간을 ISO 8601 형식의 문자열로 변환
    String uuid = lastValue!.currentWork!.uuid;
    Position position = await Geolocator.getCurrentPosition();
    final String timestamp = DateTime.now().toIso8601String();

    final Response response = await dio.post(
      '${URL.BASE_URL}/api/user/work/$uuid/procedure/complete',
      data: {
        "lng": position.longitude,
        "lat": position.latitude,
        "description": '',
        "timestamp": timestamp
      },
      options: Options(
        extra: {'withCredentials': true},
        headers: headers,
      ),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      await get();
    } else {
      throw Exception('작업 완료 요청 실패 :${response.statusCode}');
    }
  }
}
