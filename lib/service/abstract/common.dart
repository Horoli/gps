part of gps_test;

abstract class CommonService {
  Uri uriSetter({
    String scheme = 'https',
    required String path,
    String? query,
    Map<String, dynamic>? queryParameters,
  }) =>
      Uri(
        scheme: scheme,
        host: '',
        port: 0,
        query: query,
        queryParameters: queryParameters,
      );

  final Dio dio = Dio();
}
