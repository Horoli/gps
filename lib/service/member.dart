part of gps_test;

class ServiceMember extends CommonService {
  static ServiceMember? _instance;
  factory ServiceMember.getInstance() =>
      _instance ??= ServiceMember._internal();

  ServiceMember._internal();

  final BehaviorSubject<MMember?> _subject =
      BehaviorSubject<MMember?>.seeded(null);

  Stream<MMember?> get stream => _subject.stream;

  MMember? get selectedMember => _subject.valueOrNull;

  Future<List<MMember>> get() async {
    Completer<List<MMember>> completer = Completer<List<MMember>>();
    final List<String> cookies = await CookieManager.load();

    final Response response = await HttpConnector.get(
      dio: dio,
      url: '${URL.BASE_URL}/${URL.MEMBER_LIST}',
      cookies: cookies,
    );

    if (!completer.isCompleted) {
      List<MMember> result = List.from(response.data).map((e) {
        return MMember.fromMap(e);
      }).toList();

      completer.complete(result);
    }

    return completer.future;
  }

  Future<void> select({required MMember member}) async {
    _subject.add(member);
  }

  Future<void> clearSelection() async {
    _subject.add(null);
  }
}
