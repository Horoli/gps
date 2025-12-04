part of FlightSteps;

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(ForegroundTaskHandler());
}

class ForegroundTaskHandler extends TaskHandler {
  StreamSubscription<Position>? subscription;

  static Future<NotificationPermission> checkPermissions() async {
    final NotificationPermission notificationPermission =
        await FlutterForegroundTask.checkNotificationPermission();

    return notificationPermission;
  }

  static Future<void> requestPermissions() async {
    final NotificationPermission notificationPermission =
        await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermission != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }

    if (Platform.isAndroid) {
      // Android 12+, there are restrictions on starting a foreground service.
      //
      // To restart the service on device reboot or unexpected problem, you need to allow below permission.
      if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
        // This function requires `android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` permission.
        await FlutterForegroundTask.requestIgnoreBatteryOptimization();
      }

      // Use this utility only if you provide services that require long-term survival,
      // such as exact alarm service, healthcare service, or Bluetooth communication.
      //
      // This utility requires the "android.permission.SCHEDULE_EXACT_ALARM" permission.
      // Using this permission may make app distribution difficult due to Google policy.
      // if (!await FlutterForegroundTask.canScheduleExactAlarms) {
      // When you call this function, will be gone to the settings page.
      // So you need to explain to the user why set it.
      //   await FlutterForegroundTask.openAlarmsAndRemindersSettings();
      // }
    }
  }

  // foregroundTask를 시작하는 함수
  static Future<ServiceRequestResult> startService() async {
    if (await FlutterForegroundTask.isRunningService) {
      return FlutterForegroundTask.restartService();
    } else {
      return FlutterForegroundTask.startService(
        serviceId: 256,
        notificationTitle: TITLE.APP_TITLE,
        notificationText: MSG.FOREGROUND_NOTIFICATION_TEXT,
        notificationIcon: null,
        notificationButtons: [
          const NotificationButton(
              id: ID.NOTIFICATION_ID_FIRST,
              text: MSG.FOREGROUND_NOTIFICATION_TEXT_STOP),
        ],
        notificationInitialRoute: '/',
        callback: startCallback,
      );
    }
  }

  static Future<void> onReceiveTaskData(Object data) async {
    debugPrint('onReceiveTaskData: $data');
    if (data == 'stop') {
      debugPrint('App Exit Process Initiated');
      await FlutterForegroundTask.stopService();
      SystemNavigator.pop();
      exit(0);
    }

    if (data is Map<String, dynamic>) {
      final dynamic timestampMillis = data["timestampMillis"];
      if (timestampMillis != null) {
        final DateTime timestamp =
            DateTime.fromMillisecondsSinceEpoch(timestampMillis, isUtc: true);
        debugPrint('timestamp: ${timestamp.toString()}');
      }
    }
  }

  static final Dio _dio = Dio();

  static Future<void> initTask() async {
    // MConfig intervalResult = result[0];
    // int intervalValue = int.parse(intervalResult.value.toString());

    // int intervalToMiliseconds = intervalValue * 1000;

    // debugPrint('initTask interval $intervalValue : ${intervalToMiliseconds}');

    FlutterForegroundTask.init(
        androidNotificationOptions: AndroidNotificationOptions(
          showWhen: false, // timeStamp
          channelId: 'Foreground Notification',
          channelName: 'Foreground Notification',
          channelDescription:
              'This notification appears when the foreground service is running.',
          // OS의 noti bar에 지워지지 않는 알림이 생기는데 안보이게 하기 위해서 NONE설정
          channelImportance: NotificationChannelImportance.NONE,
          priority: NotificationPriority.LOW,
        ),
        iosNotificationOptions: const IOSNotificationOptions(
          showNotification: false,
          playSound: false,
        ),
        foregroundTaskOptions: ForegroundTaskOptions(
          eventAction: ForegroundTaskEventAction.once(),
        )
        // foregroundTaskOptions: ForegroundTaskOptions(
        //   eventAction: ForegroundTaskEventAction.repeat(
        //     intervalToMiliseconds,
        //     // 10000,
        //   ),
        // ),
        );
  }

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    debugPrint('onStart : $timestamp');
  }

  /// 해당 코드 수정 시 [ServiceLocation]의 setLocationListener() 코드도 같이 수정해야함
  @override
  void onRepeatEvent(DateTime timestamp) async {
    final Response response = await HttpConnector.get(
      dio: _dio,
      url: '${URL.BASE_URL}/${URL.CONFIG_GPS}',
    );

    debugPrint('initTask response ${response.data}');

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

    // TODO : platform에 따라 accuracy 설정
    // 현재는 androidAccuracy만 사용하고, iosAccuracy는 사용하지 않음

    LocationAccuracy accuracy =
        accuracyMap[androidAccuracy.value] ?? LocationAccuracy.high; // 기본값 설정

    debugPrint('initTask accuracy $accuracy');
    debugPrint('initTask distanceFilter $distanceFilter');

    subscription ??= Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter.value,
      ),
    ).listen(
      (Position position) async {
        debugPrint('foreground position $position');
        bool internetAvailable = await isInternetAvailable();
        final List<String> cookies = await CookieManager.load();
        _dio.options.extra['withCredentials'] = true;

        Map<String, dynamic> data = {
          "lng": position.longitude,
          "lat": position.latitude,
          "timestamp": timestamp.toIso8601String()
        };

        if (!internetAvailable) {
          debugPrint('인터넷 연결이 없습니다.');
          await LocationManager.save(data);
          return;
        }

        await LocationManager.hasData().then((hasData) async {
          if (hasData) {
            // localStorage에 저장된 datas가 있으면, 서버에 모두 post
            List<Map<String, dynamic>> locationData =
                await LocationManager.load();

            debugPrint('locationData $locationData');
            for (Map<String, dynamic> item in locationData) {
              final Response response = await HttpConnector.post(
                dio: _dio,
                url: '${URL.BASE_URL}/${URL.USER_LOCATION}',
                cookies: cookies,
                data: item,
              );
              // 응답 확인
              if (response.statusCode == 200) {
                debugPrint('위치 전송 성공 : $response');
              } else {
                // TODO : 서버에 전송 실패 시, localstorage에 저장된 datas는 그대로 유지
                debugPrint('위치 전송 실패: ${response}');
                return;
              }
            }
            // 서버에 전송 완료 시, localstorage에 저장된 datas 삭제
            await LocationManager.clear();
          }
        });

        final Response response = await HttpConnector.post(
          dio: _dio,
          url: '${URL.BASE_URL}/${URL.USER_LOCATION}',
          data: data,
          cookies: cookies,
        );

        if (response.statusCode == 200) {
          debugPrint('위치 전송 성공 : $response');
        } else {
          debugPrint('위치 전송 실패: ${response}');
          return;
        }
      },
      onError: (e) {
        debugPrint('foreground onRepeatEvent error $e');
      },
    );
    return;
  }

  // void onRepeatEvent()async{

  //  network 사용 가능 확인
  // bool internetAvailable = await isInternetAvailable();

  // debugPrint('internetAvailable $internetAvailable');

  // FlutterForegroundTask.sendDataToMain('check');
  // Position position = await Geolocator.getCurrentPosition();
  // final List<String> cookies = await CookieManager.load();
  // debugPrint('repeat $timestamp : $cookies');

  // Map<String, dynamic> data = {
  //   "lng": position.longitude,
  //   "lat": position.latitude,
  //   "timestamp": timestamp.toIso8601String()
  // };

  // // network 사용 불가능 시, localStorage에 datas를 저장(array로 저장)
  // if (internetAvailable == false) {
  //   debugPrint('network unavailable, save to localStorage $data');
  //   await LocationManager.save(data);
  //   return;
  // }

  // // network 사용 가능 시, localStorage에 저장된 datas가 있는지 확인
  // await LocationManager.hasData().then((hasData) async {
  //   if (hasData) {
  //     // localStorage에 저장된 datas가 있으면, 서버에 모두 post
  //     List<Map<String, dynamic>> locationData = await LocationManager.load();

  //     debugPrint('locationData $locationData');
  //     for (Map<String, dynamic> item in locationData) {
  //       final Response response = await HttpConnector.post(
  //         dio: _dio,
  //         url: '${URL.BASE_URL}/${URL.USER_LOCATION}',
  //         cookies: cookies,
  //         data: item,
  //       );
  //       // 응답 확인
  //       if (response.statusCode == 200) {
  //         debugPrint('위치 전송 성공 : $response');
  //       } else {
  //         // TODO : 서버에 전송 실패 시, localstorage에 저장된 datas는 그대로 유지
  //         debugPrint('위치 전송 실패: ${response}');
  //         return;
  //       }
  //     }
  //     // 서버에 전송 완료 시, localstorage에 저장된 datas 삭제
  //     await LocationManager.clear();
  //   }
  // });

  // network 사용 가능 시, localStorage에 저장된 datas가 없으면 현재 data를 서버에 post
  // final Response response = await HttpConnector.post(
  //   dio: _dio,
  //   url: '${URL.BASE_URL}/${URL.USER_LOCATION}',
  //   cookies: cookies,
  //   data: data,
  // );

  // // 응답 확인
  // if (response.statusCode == 200) {
  //   debugPrint('위치 전송 성공 : $response');
  // } else {
  //   debugPrint('위치 전송 실패: ${response}');
  // }
  // }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    FlutterForegroundTask.stopService();
    await unsubscribe();
    debugPrint('on destory : $timestamp');
  }

  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp("/resume-route");
  }

  @override
  Future<void> onNotificationButtonPressed(String id) async {
    debugPrint('onNotificationButtonPressed id: $id');
    if (id == ID.NOTIFICATION_ID_FIRST &&
        await FlutterForegroundTask.isRunningService) {
      FlutterForegroundTask.sendDataToMain('stop');
    }
  }

  Future<void> unsubscribe() async {
    if (subscription != null) {
      try {
        subscription!.pause();
        await subscription!.cancel();
      } catch (e) {
        debugPrint('Error canceling location subscription: $e');
      }

      subscription = null;
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
}
