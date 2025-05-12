import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'gps_test.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initService();
  await foregroundInit();
  await checkAndRequestLocationPermission();
  runApp(const AppRoot());
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
  GServiceGPSInterval = ServiceGPSInterval.getInstance();
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
