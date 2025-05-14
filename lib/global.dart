part of FlightSteps;

late ServiceUser GServiceUser;
late ServiceChecklist GServiceChecklist;
late ServiceWorklist GServiceWorklist;
late ServiceWork GServiceWork;
late ServiceMember GServiceMember;
late ServiceSSE GServiceSSE;
late ServiceGPSInterval GServiceGPSInterval;
late ServiceLocation GServiceLocation;
late RouterManager GServiceRouterManager;

bool useForeground = true;

const String tmpNumber = "01041850688";
const String tmpID = 'devel';

final GlobalKey<NavigatorState> GNavigationKey = GlobalKey();

/**
 * 임시로 global에다 생성
 */
class HttpConnector {
  static Map<String, dynamic> _defaultHeaders = {
    'Content-Type': 'application/json',
  };
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
    Map<String, dynamic> headers = _defaultHeaders;
    if (cookies != null) {
      headers = headersByCookie(cookies);
    }

    dio.options.extra['withCredentials'] = true;

    final Response response = await dio
        .get(url,
            options: Options(
              extra: {'withCredentials': true},
              headers: headers,
            ))
        .then((result) {
      debugPrint('$url get result : ${result.data}');
      return result;
    }).catchError((e) {
      debugPrint('$url get error : ${e}');
    });
    return response;
  }

  static Future<Response> post({
    required Dio dio,
    required String url,
    List<String>? cookies,
    Map<String, dynamic>? data,
  }) async {
    Map<String, dynamic> headers = _defaultHeaders;

    if (cookies != null) {
      headers = headersByCookie(cookies);
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
      debugPrint('$url post result : ${result.data}');
      return result;
    }).catchError((e) {
      debugPrint('$url post error : ${e}');
    });
    return response;
  }

  // static Future<EventSource> eventStream({
  //   required EventSource eventSource,
  //   required String url,
  //   List<String>? cookies,
  // }) async {
  //   Map<String, dynamic> headers = _defaultHeaders;

  //   if (cookies != null) {
  //     headers = HttpConnector.streamHeadersByCookie(cookies);
  //   }

  //   Map<String, String> convertHeaders = headers.map((k, v) {
  //     return MapEntry(k, v.toString());
  //   });

  //   return await eventSource.connect(
  //     url,
  //     headers: convertHeaders,
  //   );
  // }

  static Future<Response> stream({
    required Dio dio,
    required String url,
    List<String>? cookies,
  }) async {
    Map<String, dynamic> headers = _defaultHeaders;

    if (cookies != null) {
      headers = HttpConnector.streamHeadersByCookie(cookies);
    }

    dio.options.extra['withCredentials'] = true;

    debugPrint('$url stream headers : $headers');

    debugPrint('dio.options ${dio.options.baseUrl}');

    final Response response = await dio
        .get(url,
            options: Options(
              responseType: ResponseType.stream,
              extra: {'withCredentials': true},
              headers: headers,
            ))
        .then((result) {
      debugPrint('$url stream result : $result');
      return result;
    }).catchError((e) {
      debugPrint('sse connect error');
      debugPrint('$url stream error : $e');

      throw e;
    });
    // .onError((e, stackTrace) {
    //   debugPrint('connect error');
    //   debugPrint('$url stream error : $e');
    //   throw Error();
    // });
    // .timeout(const Duration(seconds: 10), onTimeout: () {
    //   debugPrint('sse timeout');
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
