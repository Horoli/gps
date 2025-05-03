import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'gps_test.dart';

Future<void> main() async {
  await initService();
  WidgetsFlutterBinding.ensureInitialized();
  await foregroundInit();
  runApp(const AppRoot());
}

Future<void> foregroundInit() async {
  if (useForeground) {
    FlutterForegroundTask.initCommunicationPort();
    print('foreground step 1');
    FlutterForegroundTask.addTaskDataCallback(
        ForegroundTaskHandler.onReceiveTaskData);
    print('foreground step 2');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('foreground step 3');
      ForegroundTaskHandler.requestPermissions();
      print('foreground step 4');
      ForegroundTaskHandler.initTask();
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
}

// TODO : 플랫폼 추가(device info plus)
Future<void> deviceCheck() async {}
