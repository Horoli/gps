part of gps_test;

late ServiceUser GServiceUser;
late ServiceChecklist GServiceChecklist;
late ServiceWorklist GServiceWorklist;
late ServiceWork GServiceWork;
late ServiceMember GServiceMember;
late ServiceSSE GServiceSSE;
late ServiceGPSInterval GServiceGPSInterval;
late RouterManager GServiceRouterManager;

bool useForeground = true;

const String tmpNumber = "01041850688";
const String tmpID = 'devel';

final GlobalKey<NavigatorState> GNavigationKey = GlobalKey();

/**
 * 임시로 global에다 생성
 */
class DioConnector {
  static Map<String, dynamic> headersByCookie(List<String> cookies) {
    final Map<String, dynamic> headers = {
      'Content-Type': 'application/json',
      // 'Accept-Encoding': 'br, gzip, deflate',
      // 'Accept': 'application/json'
    };
    if (cookies.isNotEmpty) {
      headers['cookie'] = cookies.join('; ');
    }
    return headers;
  }

  static Map<String, dynamic> streamHeadersByCookie(List<String> cookies) {
    final Map<String, dynamic> headers = {
      'Accept': 'text/event-stream',
      'Cache-Control': 'no-cache',
      'Connection': 'keep-alive',
      'Content-Type': 'application/json',
    };
    if (cookies.isNotEmpty) {
      headers['cookie'] = cookies.join('; ');
    }
    return headers;
  }

  static Future<Response> get({
    required Dio dio,
    required String url,
    List<String>? cookies,
  }) async {
    Map<String, dynamic> headers = {
      'Content-Type': 'application/json',
    };
    if (cookies != null) {
      headers = DioConnector.headersByCookie(cookies);
    }

    dio.options.extra['withCredentials'] = true;

    final Response response = await dio
        .get(url,
            options: Options(
              extra: {'withCredentials': true},
              headers: headers,
            ))
        .then((result) {
      print('$url get result : ${result.data}');
      return result;
    }).catchError((e) {
      print('$url get error : ${e}');
    });
    return response;
  }

  static Future<Response> post({
    required Dio dio,
    required String url,
    List<String>? cookies,
    Map<String, dynamic>? data,
  }) async {
    Map<String, dynamic> headers = {
      'Content-Type': 'application/json',
    };

    if (cookies != null) {
      headers = DioConnector.headersByCookie(cookies);
    }

    dio.options.extra['withCredentials'] = true;

    final Response response = await dio
        .post(url,
            data: data ?? {},
            options: Options(
              extra: {'withCredentials': true},
              headers: headers,
            ))
        .then((result) {
      print('$url post result : ${result.data}');
      return result;
    }).catchError((e) {
      print('$url post error : ${e}');
    });
    return response;
  }

  static Future<Response> stream({
    required Dio dio,
    required String url,
    List<String>? cookies,
  }) async {
    Map<String, dynamic> headers = {
      'Content-Type': 'application/json',
    };

    if (cookies != null) {
      headers = DioConnector.streamHeadersByCookie(cookies);
    }

    dio.options.extra['withCredentials'] = true;

    print('$url stream headers : $headers');

    final Response response = await dio
        .get(url,
            options: Options(
              responseType: ResponseType.stream,
              extra: {'withCredentials': true},
              headers: headers,
            ))
        .then((result) {
      print('$url stream result : $result');
      return result;
    }).catchError((e) {
      print('$url stream error : $e');

      throw e;
    });
    // .timeout(const Duration(seconds: 10), onTimeout: () {
    //   print('sse timeout');
    //   return Response(
    //     requestOptions: RequestOptions(),
    //     statusCode: 503,
    //     statusMessage: 'SSE connection timeout',
    //   );
    //   // throw TimeoutException('SSE connection time out');
    // });
    return response;
  }
}
