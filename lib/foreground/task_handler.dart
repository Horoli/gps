part of gps_test;

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(ForegroundTaskHandler());
}

class ForegroundTaskHandler extends TaskHandler {
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
        notificationTitle: 'Foreground Service is running',
        notificationText: 'Tap to return to the app',
        notificationIcon: null,
        notificationButtons: [
          const NotificationButton(id: 'btn_hello', text: 'end location share'),
        ],
        notificationInitialRoute: '/',
        callback: startCallback,
      );
    }
  }

  static void onReceiveTaskData(Object data) {
    if (data is Map<String, dynamic>) {
      final dynamic timestampMillis = data["timestampMillis"];
      if (timestampMillis != null) {
        final DateTime timestamp =
            DateTime.fromMillisecondsSinceEpoch(timestampMillis, isUtc: true);
        print('timestamp: ${timestamp.toString()}');
      }
    }
  }

  static final Dio _dio = Dio();

  static Future<void> initTask() async {
    // int interval = await IntervalManager.load();
    // int intervalToMiliseconds = interval * 1000;
    // print('initTask $interval : ${intervalToMiliseconds}');

    final Response response = await HttpConnector.get(
      dio: _dio,
      url: '${URL.BASE_URL}/${URL.GPS_INTERVAL}',
    );

    List<MConfig> result = List.from(response.data ?? [])
        .map((item) => MConfig.fromMap(item))
        .toList();

    MConfig intervalResult = result[0];
    int intervalValue = int.parse(intervalResult.value.toString());

    int intervalToMiliseconds = intervalValue * 1000;

    print('initTask interval $intervalValue : ${intervalToMiliseconds}');

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
        eventAction: ForegroundTaskEventAction.repeat(
          intervalToMiliseconds,
        ),
      ),
    );
  }

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {}

  // Called every [interval] milliseconds in [ForegroundTaskOptions].
  @override
  void onRepeatEvent(DateTime timestamp) async {
    FlutterForegroundTask.sendDataToMain('check');
    Position position = await Geolocator.getCurrentPosition();
    final List<String> cookies = await CookieManager.loadCookies();
    print('repeat $timestamp : $cookies');

    Map<String, dynamic> data = {
      "lng": position.longitude,
      "lat": position.latitude,
      "timestamp": timestamp.toIso8601String()
    };

    // TODO : network 사용 가능 확인

    // TODO : network 사용 불가능 시, localStorage에 datas를 저장(array로 저장)

    // TODO : network 사용 가능 시, localStorage에 저장된 datas가 있는지 확인

    // TODO : localStorage에 저장된 datas가 있으면, 서버에 모두 post

    // TODO : 서버에 전송 완료 시, localstorage에 저장된 datas 삭제

    // TODO : 서버에 전송 실패 시, localstorage에 저장된 datas는 그대로 유지

    // TODO : network 사용 가능 시, localStorage에 저장된 datas가 없으면 현재 data를 서버에 post

    final Response response = await HttpConnector.post(
      dio: _dio,
      url: '${URL.BASE_URL}/${URL.USER_LOCATION}',
      cookies: cookies,
      data: data,
    );

    // 응답 확인
    if (response.statusCode == 200) {
      print('위치 전송 성공 : $response');
    } else {
      print('위치 전송 실패: ${response}');
    }
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    FlutterForegroundTask.stopService();
    print('on destory : $timestamp');
  }

  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp("/resume-route");
  }

  @override
  Future<void> onNotificationButtonPressed(String id) async {
    if (id == 'btn_hello' && await FlutterForegroundTask.isRunningService) {
      FlutterForegroundTask.sendDataToMain('stop');
      FlutterForegroundTask.stopService();
      print('stopService : $id');
    }
  }
}
