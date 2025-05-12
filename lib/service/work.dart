part of gps_test;

/**
 * selectedWork를 관리하는 service
 */
class ServiceWork extends CommonService {
  static ServiceWork? _instance;
  factory ServiceWork.getInstance() => _instance ??= ServiceWork._internal();

  ServiceWork._internal();

  final BehaviorSubject<MWorkData?> _subject =
      BehaviorSubject<MWorkData?>.seeded(null);

  Stream<MWorkData?> get stream => _subject.stream;

  MWorkData? get selectedWork => _subject.valueOrNull;

  Future<void> select({required MWorkData workData}) async {
    _subject.add(workData);
  }

  Future<void> create({
    required List<String> members,
  }) async {
    try {
      final List<String> cookies = await CookieManager.load();
      debugPrint('cookies $cookies');
      final Map<String, dynamic> headers =
          HttpConnector.headersByCookie(cookies);
      dio.options.extra['withCredentials'] = true;

      Position position = await Geolocator.getCurrentPosition();

      if (selectedWork == null) {
        return;
      }

      final Response response = await HttpConnector.post(
        dio: dio,
        url: '${URL.BASE_URL}/${URL.GET_WORK_LIST}',
        data: {
          "members": members,
          "lng": position.longitude,
          "lat": position.latitude,
          "aircraftName": selectedWork!.name,
          "aircraftDepartureTime": selectedWork!.departureTime,
          "timestamp": DateTime.now().toIso8601String(),
        },
        cookies: cookies,
      );
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          debugPrint('error statusCode : ${e.response?.statusCode}');
          debugPrint('error data : ${e.response?.data}');
        }
      }
    }
  }
}
