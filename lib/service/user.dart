part of gps_test;

class ServiceUser extends CommonService {
  static ServiceUser? _instance;
  factory ServiceUser.getInstance() => _instance ??= ServiceUser._internal();

  ServiceUser._internal();

  final BehaviorSubject<MUser?> _subject = BehaviorSubject<MUser?>.seeded(null);

  Stream<MUser?> get stream => _subject.stream;

  MUser? get currentUser => _subject.valueOrNull;

  Future<MUser> login({
    required String phoneNumber,
    required String id,
  }) async {
    Completer<MUser> completer = Completer<MUser>();

    dio.options.extra['withCredentials'] = true;

    final Response response = await HttpConnector.post(
      dio: dio,
      url: '${URL.BASE_URL}/${URL.USER_LOGIN}',
      data: {
        'phoneNumber': phoneNumber,
        'employeeId': id,
      },
    );

    if (!completer.isCompleted) {
      // TODO : ForegroundTask에서 사용하기 위해 쿠키를 저장
      await CookieManager.saveCookies(response);
      MUser getUser = MUser.fromMap(response.data);
      _subject.add(getUser);

      completer.complete(getUser);
    }

    return completer.future;
  }

  /// TODO : foreground service종료
  /// TODO : localStorage user정보 및 쿠키 제거
  ///
  Future<void> logout() async {}

  Future<void> location({
    required double lng,
    required double lat,
    required DateTime timestamp,
  }) async {
    Completer completer = Completer();

    final Response response = await HttpConnector.post(
      dio: dio,
      url: '${URL.BASE_URL}/${URL.USER_LOCATION}',
      data: {
        "lng": lng,
        "lat": lat,
        "timestamp": timestamp.toIso8601String(),
      },
    );

    if (!completer.isCompleted) {
      print('gps complete $response');
      completer.complete(response);
    }

    return completer.future;
  }
}
