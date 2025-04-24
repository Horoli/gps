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
          1000,
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
    print(await Geolocator.getCurrentPosition());
    http.Response asd = await http.get(Uri.parse("https://google.com"));
    print(asd.body);
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
