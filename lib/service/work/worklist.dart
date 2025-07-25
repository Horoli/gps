part of FlightSteps;

class ServiceWorklist extends CommonService {
  static ServiceWorklist? _instance;
  factory ServiceWorklist.getInstance() =>
      _instance ??= ServiceWorklist._internal();

  ServiceWorklist._internal();

  final BehaviorSubject<MWorkList?> subject =
      BehaviorSubject<MWorkList?>.seeded(null);
  Stream<MWorkList?> get stream => subject.stream;
  MWorkList? get workListLastValue => subject.valueOrNull;

  final BehaviorSubject<String> selectedUuidSubject =
      BehaviorSubject<String>.seeded('');
  String get selectedUuidLastValue => selectedUuidSubject.value;

  Future<void> selectWorkId(String uuid) async {
    selectedUuidSubject.add(uuid);
  }

  //   MCurrentWork? getCurrentWorkInProgress() {
  //   return getWorkByDivision(uuid: selectedUuidLastValue) as MCurrentWork?;
  // }
  //   MWorkData? getCompletedWork() {
  //   final work = getWorkByDivision(uuid: selectedUuidLastValue);
  //   return work is MWorkData ? work : null;
  // }
  dynamic get getWork => getWorkByDivision(uuid: selectedUuidLastValue);

  dynamic getWorkByDivision({required String uuid}) {
    print('getWorkByDivision step 0 : $uuid');
    print('getWorkByDivision step 1 : ${workListLastValue?.currentWork}');

    MCurrentWork? inCurrentWork = workListLastValue!.currentWork
        .where((cur) => cur.uuid == uuid)
        .toList()
        .firstOrNull;
    print('getWorkByDivision step 2 : $inCurrentWork');

    if (inCurrentWork != null) return inCurrentWork;

    MWorkData? inWorkList = workListLastValue!.workList
        .where((MWorkData work) => work.uuid == uuid)
        .toList()
        .firstOrNull;

    print('getWorkByDivision step 3 : $inWorkList');

    return inWorkList;
  }

  Future<void> clearSelection() async {
    selectedUuidSubject.add('');
  }

  Future<MWorkList> get() async {
    Completer<MWorkList> completer = Completer<MWorkList>();
    final List<String> cookies = await CookieManager.load();

    debugPrint('cookies $cookies');

    final Response response = await HttpConnector.get(
      dio: dio,
      url: '${URL.BASE_URL}/${URL.GET_WORK_LIST}',
      cookies: cookies,
    );

    debugPrint('response ${response}');

    if (!completer.isCompleted) {
      final Map<String, dynamic> data = response.data as Map<String, dynamic>;

      final MWorkList result = MWorkList.fromMap(data);

      print('step 4 : ${result.currentWork}');

      subject.add(result);
      completer.complete(result);
    }

    return completer.future;
  }

  // 현재 작업 완료 함수
  Future<void> completeProcedure({
    required String uuid,
    String? description,
  }) async {
    try {
      final List<String> cookies = await CookieManager.load();
      // final Map<String, dynamic> headers =
      //     HttpConnector.headersByCookie(cookies);
      dio.options.extra['withCredentials'] = true;
      debugPrint('cookies $cookies');

      // 현재 시간을 ISO 8601 형식의 문자열로 변환
      // String uuid = selectedCurrentWorkLastValue!.uuid;
      // String uuid = selectedUuidLastValue;
      // print('completeProcedure $uuid');
      // Position? position = await Geolocator.getLastKnownPosition();
      Position? position = GServiceLocation._subject.valueOrNull;
      if (position == null) {
        return ShowInformationWidgets.errorDialog(
            GNavigationKey.currentState!.context, 'GPS 값을 찾을 수 없습니다');
      }
      final String timestamp = DateTime.now().toIso8601String();
      debugPrint(
          '중간 : gps값 갱신 lat ${position.latitude} / lng ${position.longitude} ${DateTime.now().millisecondsSinceEpoch}');

      final Response response = await HttpConnector.post(
          dio: dio,
          url: '${URL.BASE_URL}/api/user/work/$uuid/procedure/complete',
          cookies: cookies,
          data: {
            "lng": position.longitude,
            "lat": position.latitude,
            "description": description ?? '',
            "timestamp": timestamp
          });
    } on DioException catch (e) {
      if (e.response != null) {
        ResponseBody errorBody = e.response?.data as ResponseBody;

        debugPrint('error statusCode : ${e.response?.statusCode}');
        debugPrint('error message : ${errorBody.statusMessage}');
        throw errorBody;
      }
    }
  }
}
