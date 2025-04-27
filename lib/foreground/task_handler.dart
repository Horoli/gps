part of gps_test;

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(ForegroundTaskHandler());
}

class ForegroundTaskHandler extends TaskHandler {
  static int interval = 1000;

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

  static void initTask() {
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
          interval,
        ),
      ),
    );
  }

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {}

  // Called every [interval] milliseconds in [ForegroundTaskOptions].
  @override
  void onRepeatEvent(DateTime timestamp) async {
    print('$timestamp');
    FlutterForegroundTask.sendDataToMain('check');
    Position position = await Geolocator.getCurrentPosition();
    final List<String> cookies = await CookieManager.loadCookies();

    final Dio dio = Dio();
    dio.options.extra['withCredentials'] = true;

    final Map<String, dynamic> headers = {
      'Content-Type': 'application/json',
    };
    if (cookies.isNotEmpty) {
      headers['cookie'] = cookies.join('; ');
    }

    final Response response = await dio
        .post('${URL.BASE_URL}/${URL.USER_LOCATION}',
            data: {
              "lng": position.longitude,
              "lat": position.latitude,
              "timestamp": timestamp.toIso8601String()
            },
            options: Options(
              extra: {'withCredentials': true},
              headers: headers,
            ))
        .catchError((e) {
      return Response(
        requestOptions:
            RequestOptions(path: '${URL.BASE_URL}/${URL.USER_LOCATION}'),
        statusCode: 500,
        data: {'error': e.toString()},
      );
    });

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
    }
  }
}
