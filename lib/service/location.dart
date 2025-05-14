part of FlightSteps;

class ServiceLocation extends CommonService {
  static ServiceLocation? _instance;
  factory ServiceLocation.getInstance() =>
      _instance ??= ServiceLocation._internal();

  ServiceLocation._internal();

  StreamSubscription<Position>? subscription;
  bool isConnected = false;

  final BehaviorSubject<Position?> _subject =
      BehaviorSubject<Position?>.seeded(null);

  Stream<Position?> get stream => _subject.stream;

  /// 해당 코드는 foreground에서 사용할 수없어서 해당 코드 수정 시
  /// [ForegroundTaskHandler]의 onRepeatEvent() 코드도 같이 수정해야함
  Future<void> setLocationListener() async {
    final Response response = await HttpConnector.get(
      dio: dio,
      url: '${URL.BASE_URL}/${URL.GPS_INTERVAL}',
    );

    List<MConfig> result = List.from(response.data ?? [])
        .map((item) => MConfig.fromMap(item))
        .toList();

    MConfig androidAccuracy =
        result.firstWhere((item) => item.name == 'accuracy.android');

    MConfig iosAccuracy =
        result.firstWhere((item) => item.name == 'accuracy.ios');

    MConfig distanceFilter =
        result.firstWhere((item) => item.name == 'distance');
    debugPrint('initTask androidAccuracy $androidAccuracy');

    Map<String, dynamic> accuracyMap = {
      // android
      'high': LocationAccuracy.high,
      'medium': LocationAccuracy.medium,
      'low': LocationAccuracy.low,
      'lowest': LocationAccuracy.lowest,

      // ios
      'best': LocationAccuracy.best,
      'navigation': LocationAccuracy.bestForNavigation,
      'reduced': LocationAccuracy.reduced,
    };

    LocationAccuracy accuracy =
        accuracyMap[androidAccuracy.value] ?? LocationAccuracy.high; // 기본값 설정

    debugPrint('initTask accuracy $accuracy');
    debugPrint('initTask distanceFilter $distanceFilter');

    if (isConnected) {
      await disconnect();
    }
    if (_subject.value == null) {
      Position currentPosition = await Geolocator.getCurrentPosition();
      _subject.add(currentPosition);
    }
    subscription ??= Geolocator.getPositionStream(
        locationSettings: LocationSettings(
      accuracy: accuracy,
      distanceFilter: distanceFilter.value,
    )).listen((Position? position) {
      debugPrint('positionStream $position');
      _subject.add(position);
      isConnected = true;
    });
  }

  Future<void> foregroundPost(Position position) async {
    bool internetAvailable = await isInternetAvailable();

    if (!internetAvailable) {
      debugPrint('인터넷 연결이 없습니다.');
    }

    print(position);

    final List<String> cookies = await CookieManager.load();
    debugPrint('cookies $cookies');
    dio.options.extra['withCredentials'] = true;

    final Response response = await HttpConnector.post(
      dio: dio,
      url: '${URL.BASE_URL}/${URL.USER_LOCATION}',
      data: {
        "lng": position.longitude,
        "lat": position.latitude,
        "timestamp": DateTime.now().toIso8601String(),
      },
      cookies: cookies,
    );

    if (response.statusCode == 200) {
      debugPrint('위치 전송 성공 : $response');
    } else {
      // TODO : 서버에 전송 실패 시, localstorage에 저장된 datas는 그대로 유지
      debugPrint('위치 전송 실패: ${response}');
      return;
    }
  }

  Future<bool> isInternetAvailable() async {
    final List<ConnectivityResult> connectivityResult =
        await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      return false;
    }
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  Future<void> disconnect() async {
    if (subscription != null) {
      try {
        subscription!.pause();
        await subscription!.cancel();
      } catch (e) {
        debugPrint('Error canceling location subscription: $e');
      }

      subscription = null;
      isConnected = false;
    }
  }

  Future<LocationPermission> checkAndRequestLocationPermission() async {
    // 현재 권한 상태 확인
    LocationPermission permission = await Geolocator.checkPermission();

    // 권한이 영구적으로 거부된 경우
    if (permission == LocationPermission.deniedForever) {
      // 사용자에게 설정 화면으로 이동하도록 안내하는 다이얼로그 표시
      bool goToSettings = await showDialog(
            context: GNavigationKey.currentContext!,
            builder: (BuildContext context) => AlertDialog(
              title: Text('위치 권한 필요'),
              content: Text('이 앱은 위치 정보가 필요합니다. 설정에서 위치 권한을 허용해주세요.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('취소'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('설정으로 이동'),
                ),
              ],
            ),
          ) ??
          false;

      // 사용자가 설정으로 이동하기로 선택한 경우
      if (goToSettings) {
        await Geolocator.openAppSettings(); // 앱 설정 페이지 열기
        // 또는 Geolocator.openLocationSettings(); // 위치 설정 페이지 열기
      }
    }
    // 권한이 거부되었지만 영구적으로 거부되지 않은 경우
    else if (permission == LocationPermission.denied) {
      // 권한 요청
      permission = await Geolocator.requestPermission();
    }

    // 권한이 항상 허용되지 않은 경우 (whileInUse 상태인 경우)
    if (permission == LocationPermission.whileInUse) {
      // 항상 허용 권한을 요청하는 다이얼로그 표시
      bool requestAlways = await showDialog(
            context: GNavigationKey.currentContext!,
            builder: (BuildContext context) => AlertDialog(
              title: Text('백그라운드 위치 권한'),
              content: Text('앱이 백그라운드에서도 위치 정보를 사용할 수 있도록 허용하시겠습니까?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('아니오'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await Geolocator.openAppSettings(); // 앱 설정 페이지 열기
                  },
                  child: Text('예'),
                ),
              ],
            ),
          ) ??
          false;

      // 사용자가 항상 허용을 선택한 경우
      if (requestAlways) {
        permission = await Geolocator.requestPermission();
      }
    }
    return permission;
  }
}
