import 'package:flight_steps/preset/msg.dart' as MSG;
import 'package:flight_steps/preset/title.dart' as TITLE;
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'flight_steps.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initService();
  await foregroundInit();
  await checkAndRequestLocationPermission();
  runApp(const AppRoot());

  bool insufficientPermissions = await checkPermissions();
  do {
    //
    debugPrint('step 1 condition: $insufficientPermissions');
    if (!insufficientPermissions) {
      return;
    }
    debugPrint('step 2 condition: $insufficientPermissions');

    bool openSettings = await showDialog(
          context: GNavigationKey.currentContext!,
          barrierDismissible: false,
          builder: (BuildContext context) => AlertDialog(
            title: const Text(TITLE.LOCATION_PERMISSION),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(MSG.LOCATION_PERMISSION_REQUEST),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  // if (locationPermission == LocationPermission.always ||
                  //     notificationPermission ==
                  //         NotificationPermission.granted) {

                  debugPrint('step 3 condition: $insufficientPermissions');
                  if (insufficientPermissions) {
                    return Navigator.of(context).pop(true);
                  }
                  return Navigator.of(context).pop(false);
                },
                child: insufficientPermissions
                    // locationPermission == LocationPermission.always
                    ? const Text(MSG.OPEN_SETTINGS)
                    : const Text(MSG.CLOSE),
              ),
            ],
          ),
        ) ??
        false;

    if (openSettings) {
      await Geolocator.openAppSettings(); // 앱 설정 페이지 열기
      debugPrint('step 4 condition: $insufficientPermissions');
      insufficientPermissions = await checkPermissions();
      debugPrint('step 5 condition: $insufficientPermissions');
    }
  } while (insufficientPermissions);
}

Future<bool> checkPermissions() async {
  NotificationPermission notificationPermission =
      await ForegroundTaskHandler.checkPermissions();
  LocationPermission locationPermission = await Geolocator.checkPermission();

  return notificationPermission != NotificationPermission.granted ||
      locationPermission != LocationPermission.always;
}

Future<void> foregroundInit() async {
  if (useForeground) {
    FlutterForegroundTask.initCommunicationPort();
    debugPrint('foreground step 1');
    FlutterForegroundTask.addTaskDataCallback(
        ForegroundTaskHandler.onReceiveTaskData);
    debugPrint('foreground step 2');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('foreground step 3');
      ForegroundTaskHandler.requestPermissions();
    });
  }
}

Future<void> initService() async {
  GServiceUser = ServiceUser.getInstance();
  GServiceChecklist = ServiceChecklist.getInstance();
  GServiceWorklist = ServiceWorklist.getInstance();
  GServiceWork = ServiceWork.getInstance();
  GServiceMember = ServiceMember.getInstance();
  GServiceSSE = ServiceSSE.getInstance();
  // GServiceGPSInterval = ServiceGPSInterval.getInstance();
  GServiceLocation = ServiceLocation.getInstance();
}

Future<LocationPermission> checkAndRequestLocationPermission() async {
  // 현재 권한 상태 확인
  LocationPermission permission = await Geolocator.checkPermission();

  if (permission != LocationPermission.always) {
    permission = await Geolocator.requestPermission();
  } else {
    permission = await Geolocator.requestPermission();
  }

  return permission;
}
