part of FlightSteps;

class ServiceExtraWork extends CommonService {
  static ServiceExtraWork? _instance;

  factory ServiceExtraWork.getInstance() =>
      _instance ??= ServiceExtraWork._internal();
  ServiceExtraWork._internal();

  final CustomStream<List<String>> selectedStream =
      CustomStream<List<String>>();

  Future<List<MCurrentWork?>> create({
    required List<String> members,
    required String plateNumber,
  }) async {
    try {
      final List<String> cookies = await CookieManager.load();
      debugPrint('cookies $cookies');
      final Map<String, dynamic> headers =
          HttpConnector.headersByCookie(cookies);
      dio.options.extra['withCredentials'] = true;
      Position? position = await Geolocator.getLastKnownPosition();
      position ??= await Geolocator.getCurrentPosition();

      if (selectedStream.lastValue == null) {
        debugPrint('ServiceExtraWork error : selectedStream is null');
        return [];
      }

      Map<String, dynamic> postData = {
        "members": members,
        "lng": position.longitude,
        "lat": position.latitude,
        "extra": selectedStream.lastValue,
        "plateNumber": plateNumber,
        "timestamp": DateTime.now().toIso8601String(),
        // "aircraftName": selectedWork!.name,
        // "aircraftDepartureTime": selectedWork!.departureTime,
      };

      print('extrawork postData : $postData');

      final Response response = await HttpConnector.post(
        dio: dio,
        url: '${URL.BASE_URL}/${URL.POST_WORK_EXTRA}',
        data: postData,
        cookies: cookies,
      );
// [{uuid: 1dfb66521c0a49e9b251c49671d2bfa0, users: [{uuid: cd8fc1a0c3b94bacbc01b092c5520b73, username: 박선하, phoneNumber: 01041850688, employeeId: devel, groups: [user, airline_meal]}], type: extra, extra: {uuid: 3c61ab2be5f44665825416b843da182a, name: 밀 운반, description: (인천 => 김포)}, plateNumber: 1234, procedures: [], description: , section: airline_meal, shiftHistory: [], date: 2025-07-23T01:49:02.284Z, expiredAt: 2026-01-25T01:49:02.284Z, createdAt: 2025-07-23T01:49:02.783Z, updatedAt: 2025-07-23T01:49:02.783Z, _id: 68803f8e73d5f719d9f76ac7}]

      final List<dynamic> data = response.data as List<dynamic>;
      print('extrawork response : $data');

      List<MCurrentWork> extraWorks =
          data.map((cur) => MCurrentWork.fromMap(cur)).toList();
      return extraWorks;
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          debugPrint('error statusCode : ${e.response?.statusCode}');
          debugPrint('error data : ${e.response?.data}');
        }
      }
      return [];
    }
  }
}
