part of gps_test;

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

  Future<void> setLocationListener() async {
    if (isConnected) {
      await disconnected();
    }
    if (_subject.value == null) {
      Position currentPosition = await Geolocator.getCurrentPosition();
      _subject.add(currentPosition);
    }
    subscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    )).listen((Position? position) {
      debugPrint('positionStream $position');
      _subject.add(position);
      isConnected = true;
    });
  }

  Future<void> disconnected() async {
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
