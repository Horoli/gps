part of gps_test;

class ServiceWorklist extends CommonService {
  static ServiceWorklist? _instance;
  factory ServiceWorklist.getInstance() =>
      _instance ??= ServiceWorklist._internal();

  ServiceWorklist._internal();

  final BehaviorSubject<MWorkList?> _subject =
      BehaviorSubject<MWorkList?>.seeded(null);

  Stream<MWorkList?> get stream => _subject.stream;

  // MWorkList? get currentWork => _subject.valueOrNull;

  Future<MWorkList> get() async {
    Completer<MWorkList> completer = Completer<MWorkList>();

    final Dio dio = Dio();
    final List<String> cookies = await CookieManager.loadCookies();

    dio.options.extra['withCredentials'] = true;
    final Map<String, dynamic> headers = DioConnector.headersByCookie(cookies);

    // final Map<String, dynamic> headers = {
    //   'Content-Type': 'application/json',
    // };
    // if (cookies.isNotEmpty) {
    //   headers['cookie'] = cookies.join('; ');
    // }

    final Response response = await dio.get(
      '${URL.BASE_URL}/${URL.WORK_LIST}',
      options: Options(
        extra: {'withCredentials': true},
        headers: headers,
      ),
    );

    if (!completer.isCompleted) {
      final Map<String, dynamic> data = response.data as Map<String, dynamic>;

      // workList 파싱
      final List<MWorkData> works = (data['workList'] as List<dynamic>)
          .map(
              (workItem) => MWorkData.fromMap(workItem as Map<String, dynamic>))
          .toList();

      // step 파싱
      final List<String> steps = (data['step'] as List<dynamic>)
          .map((step) => step.toString())
          .toList();

      // date 파싱
      final String date = data['date'] as String;

      // MWorkListData 객체 생성
      final MWorkList result = MWorkList(
        works: works,
        step: steps,
        date: date,
      );

      _subject.add(result);
      completer.complete(result);
    }

    return completer.future;
  }
}
