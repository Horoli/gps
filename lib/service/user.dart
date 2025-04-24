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

    final Dio dio = Dio();

    dio.options.extra['withCredentials'] = true;

    final Response response =
        await dio.post('${URL.BASE_URL}/${URL.USER_LOGIN}',
            data: {
              'phoneNumber': phoneNumber,
              'employeeId': id,
            },
            options: Options(
              extra: {'withCredentials': true},
              headers: {
                'Content-Type': 'application/json',
              },
            ));

    if (!completer.isCompleted) {
      MUser getUser = MUser.fromMap(response.data);
      _subject.add(getUser);

      completer.complete(getUser);
    }

    return completer.future;
  }
}
