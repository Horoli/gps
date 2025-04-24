part of gps_test;

class ServiceChecklist extends CommonService {
  static ServiceChecklist? _instance;
  factory ServiceChecklist.getInstance() =>
      _instance ??= ServiceChecklist._internal();

  ServiceChecklist._internal();

  final BehaviorSubject<List<MChecklist>?> _subject =
      BehaviorSubject<List<MChecklist>?>.seeded(null);

  Stream<List<MChecklist>?> get stream => _subject.stream;

  List<MChecklist>? get currentUser => _subject.valueOrNull;

  Future<List<MChecklist>> get() async {
    Completer<List<MChecklist>> completer = Completer<List<MChecklist>>();

    final Dio dio = Dio();

    dio.options.extra['withCredentials'] = true;

    final Response response = await dio.get(
      '${URL.BASE_URL}/${URL.CHECK_LIST}',
      options: Options(
        extra: {'withCredentials': true},
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    if (!completer.isCompleted) {
      List<MChecklist> getChecklists = List.from(response.data).map((data) {
        return MChecklist.fromMap(data);
      }).toList();

      _subject.add(getChecklists);

      completer.complete(getChecklists);
    }

    return completer.future;
  }
}
