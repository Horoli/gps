part of FlightSteps;

/**
 * selectedWork를 관리하는 service
 */
class ServiceWork extends CommonService {
  static ServiceWork? _instance;
  factory ServiceWork.getInstance() => _instance ??= ServiceWork._internal();

  ServiceWork._internal();

  final BehaviorSubject<List<MWorkData>> _availableSubject =
      BehaviorSubject<List<MWorkData>>.seeded([]);
  Stream<List<MWorkData>> get availableStream => _availableSubject.stream;

  final BehaviorSubject<List<MWorkData>> _selectedSubject =
      BehaviorSubject<List<MWorkData>>.seeded([]);
  Stream<List<MWorkData>> get selectedStream => _selectedSubject.stream;
  List<MWorkData> get selectedWorks => _selectedSubject.valueOrNull ?? [];

  bool isSelected(MWorkData workData) =>
      _selectedSubject.valueOrNull!.any((item) {
        String selected = '${item.name}_${item.departureTime}';
        String now = '${workData.name}_${workData.departureTime}';
        return selected == now;
      });

  Future<void> clearSelection() async {
    _selectedSubject.add([]);
  }

  Future<void> select({required MWorkData workData}) async {
    // 선택된 항공편이 비어있는 경우
    print('isSelected ${isSelected(workData)}');
    if (_selectedSubject.valueOrNull == null ||
        _selectedSubject.valueOrNull!.isEmpty) {
      // 선택된 항공편이 비어있다면 새로운 리스트로 초기화
      _selectedSubject.add([workData]);
      debugPrint('Work selected: ${workData.name}');
      return;
    }

    // 이미 선택된 항공편이 있는 경우, 중복 체크
    if (isSelected(workData)) {
      // 이미 선택된 항공편인 경우, 리스트에서 제거
      List<MWorkData> droppedList = _selectedSubject.valueOrNull!.where((item) {
        String selected = '${item.name}_${item.departureTime}';
        String now = '${workData.name}_${workData.departureTime}';
        return selected != now;
      }).toList();

      _selectedSubject.add(droppedList);
      return;
    }

    // 중복되지 않는 경우에만 추가
    _selectedSubject.add([..._selectedSubject.value, workData]);
    debugPrint('_selectedSubject.valueOrNull ${_selectedSubject.valueOrNull}');
  }

  Future<List<MWorkData>> getAvailableWorks() async {
    Completer<List<MWorkData>> completer = Completer<List<MWorkData>>();
    final List<String> cookies = await CookieManager.load();
    dio.options.extra['withCredentials'] = true;
    debugPrint('cookies $cookies');

    final Response response = await HttpConnector.get(
      dio: dio,
      url: '${URL.BASE_URL}/${URL.AVAILABLE_WORKS}',
      cookies: cookies,
    );

    if (!completer.isCompleted) {
      final List<dynamic> data = response.data ?? [];
      List<MWorkData> availableWorks = data
          .map((item) => MWorkData.fromMap(item as Map<String, dynamic>))
          .toList();

      _availableSubject.add(availableWorks);
      print('availableWorks $availableWorks');
      completer.complete(availableWorks);
    }

    return completer.future;
  }

  // 화면을 갱신하기 위한 함수
  Future refreshAvailableWorks() async {
    _availableSubject.add(_availableSubject.valueOrNull!);
  }

  Future<void> create({
    required List<String> members,
  }) async {
    try {
      if (selectedWorks.isEmpty) {
        debugPrint('selectedWork is null');
        return;
      }
      final List<String> cookies = await CookieManager.load();
      debugPrint('cookies $cookies');
      final Map<String, dynamic> headers =
          HttpConnector.headersByCookie(cookies);
      dio.options.extra['withCredentials'] = true;

      // Position position = await Geolocator.getCurrentPosition();
      // Position position = GServiceLocation.currentPosition!;
      // print('position $position');
      Position? position = await Geolocator.getLastKnownPosition();
      position ??= await Geolocator.getCurrentPosition();

      List<Map<String, dynamic>> aircraft = selectedWorks
          .map((work) => {
                'name': work.name,
                'departureTime': work.departureTime,
              })
          .toList();

      Map<String, dynamic> postData = {
        "members": jsonEncode(members),
        "lng": position.longitude,
        "lat": position.latitude,
        "aircraft": aircraft,
        "plateNumber": "1234".toString(),
        "timestamp": DateTime.now().toIso8601String(),
        // "aircraftName": selectedWork!.name,
        // "aircraftDepartureTime": selectedWork!.departureTime,
      };

      print('postData $postData');

      final Response response = await HttpConnector.post(
        dio: dio,
        url: '${URL.BASE_URL}/${URL.POST_WORK_AIRCRAFT}',
        data: postData,
        cookies: cookies,
      );
      return;
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
