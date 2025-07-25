part of FlightSteps;

/**
 * selectedWork를 관리하는 service
 */
class ServiceWork extends CommonService {
  static ServiceWork? _instance;
  factory ServiceWork.getInstance() => _instance ??= ServiceWork._internal();

  ServiceWork._internal();

  final CustomStream<List<MWorkData>> availableSubject =
      CustomStream<List<MWorkData>>();

  // 작업을 선택하는 시점에서의 workData는 uuid가 없음
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

      // _availableSubject.add(availableWorks);
      availableSubject.sink(availableWorks);
      print('availableWorks $availableWorks');
      completer.complete(availableWorks);
    }

    return completer.future;
  }

  // 화면을 갱신하기 위한 함수
  Future refreshAvailableWorks() async {
    // _availableSubject.add(_availableSubject.valueOrNull!);

    availableSubject.refresh();
  }

  Future<List<MCurrentWork?>> create({
    required List<String> members,
    required String plateNumber,
  }) async {
    try {
      if (selectedWorks.isEmpty) {
        debugPrint('selectedWork is null');
        return [];
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
        "members": members,
        "lng": position.longitude,
        "lat": position.latitude,
        "aircraft": aircraft,
        "plateNumber": plateNumber,
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
      print('GServiceWork create response : $response');
      // List<dynamic> data = List.from(jsonDecode(response.data) ?? []);

      final List<dynamic> data = response.data as List<dynamic>;

      print('GServiceWork step 1');
      List<MCurrentWork> currentWorks =
          data.map((cur) => MCurrentWork.fromMap(cur)).toList();
      print('GServiceWork step 2 ${currentWorks}');

      // String uuid = List.from(jsonDecode(response.data) ?? [])[0].uuid;
      return currentWorks;

      // return uuid;
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          debugPrint('error statusCode : ${e.response?.statusCode}');
          debugPrint('error data : ${e.response?.data}');
        }
      }
    }
    return [];
  }

//   {
//   "members": [
//     "string"
//   ],
//   "lng": 0,
//   "lat": 0,
//   "works": [
//     "string"
//   ],
//   "plateNumber": "string",
//   "timestamp": "string"
// }

// response
// {"insertedCount":0,"matchedCount":1,"modifiedCount":1,"deletedCount":0,"upsertedCount":0,"upsertedIds":{},"insertedIds":{}}

  Future<void> shift({
    required List<String> members,
    required List<String> works,
    required String plateNumber,
  }) async {
    try {
      print('shift step 1');
      final List<String> cookies = await CookieManager.load();
      debugPrint('cookies $cookies');
      print('shift step 2');
      // final Map<String, dynamic> headers =
      //     HttpConnector.headersByCookie(cookies);
      dio.options.extra['withCredentials'] = true;

      Position? position = await Geolocator.getLastKnownPosition();
      position ??= await Geolocator.getCurrentPosition();

      Map<String, dynamic> postData = {
        "members": members,
        "lng": position.longitude,
        "lat": position.latitude,
        "works": works,
        "plateNumber": plateNumber,
        "timestamp": DateTime.now().toIso8601String(),
      };

      print('shift postData $postData');

      final Response response = await HttpConnector.post(
        dio: dio,
        url: '${URL.BASE_URL}/${URL.POST_WORK_SHIFT}',
        data: postData,
        cookies: cookies,
      );
      print('GServiceWork shift response : $response');
      // List<dynamic> data = List.from(jsonDecode(response.data) ?? []);

      final List<dynamic> data = response.data as List<dynamic>;

      // print('GServiceWork step 1');
      // List<MCurrentWork> currentWorks =
      //     data.map((cur) => MCurrentWork.fromMap(cur)).toList();
      // print('GServiceWork step 2');

      // String uuid = List.from(jsonDecode(response.data) ?? [])[0].uuid;
      return;

      // return uuid;
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          debugPrint('error statusCode : ${e.response?.statusCode}');
          debugPrint('error data : ${e.response?.data}');
        }
      }
    }
    return;
  }
}
