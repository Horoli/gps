part of gps_test;

class ServiceSSE extends CommonService {
  static ServiceSSE? _instance;
  factory ServiceSSE.getInstance() => _instance ??= ServiceSSE._internal();

  ServiceSSE._internal();

  late Stream eventStream;
  StreamSubscription? _eventSub;
  final StreamTransformer _transformer =
      StreamTransformer<Uint8List, String>.fromHandlers(
    handleData: (data, sink) {
      print('stream $data');
      sink.add(utf8.decode((data)));
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
        print('ddddddddddddddddddd ');
        print('data $data');
        print(data.runtimeType);
        print(jsonDecode(data));
        // Map asd = unflatten(data);
        // print(asd);
        print('zzzzzzzzzzzz');
        Navigator.of(GNavigationKey.currentState!.context)
            .pushReplacementNamed(PATH.ROUTE_WORK_DETAIL);
      });
    } on DioException catch (e) {
      if (e.response != null) {
        ResponseBody errorBody = e.response?.data as ResponseBody;

        print('error statusCode : ${e.response?.statusCode}');
        print('error message : ${errorBody.statusMessage}');
      }
    }
  }

  // TODO : 로그아웃 시 disconnect 실행
  Future<void> disconnect() async {}

  // TODO : 재연결 관련 연결상태 체크
  Future<void> healthCheck() async {}
}
