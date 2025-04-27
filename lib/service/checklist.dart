part of gps_test;

class ServiceChecklist extends CommonService {
  static ServiceChecklist? _instance;
  factory ServiceChecklist.getInstance() =>
      _instance ??= ServiceChecklist._internal();

  ServiceChecklist._internal();

  // final BehaviorSubject<List<MChecklist>?> _subject =
  //     BehaviorSubject<List<MChecklist>?>.seeded(null);

  // Stream<List<MChecklist>?> get stream => _subject.stream;

  // List<MChecklist>? get currentUser => _subject.valueOrNull;

  Future<List<MChecklistData>> get() async {
    Completer<List<MChecklistData>> completer =
        Completer<List<MChecklistData>>();

    final Dio dio = Dio();
    final List<String> cookies = await CookieManager.loadCookies();

    dio.options.extra['withCredentials'] = true;
    final Map<String, dynamic> headers = {
      'Content-Type': 'application/json',
    };
    if (cookies.isNotEmpty) {
      headers['cookie'] = cookies.join('; ');
    }

    final Response response = await dio.get(
      '${URL.BASE_URL}/${URL.CHECK_LIST}',
      options: Options(
        extra: {'withCredentials': true},
        headers: headers,
      ),
    );

    print(response);

    if (!completer.isCompleted) {
      List<MChecklistData> getChecklists = List.from(response.data).map((data) {
        return MChecklistData.fromMap(data);
      }).toList();

      // _subject.add(getChecklists);

      completer.complete(getChecklists);
    }

    return completer.future;
  }
}
