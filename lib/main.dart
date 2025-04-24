import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'gps_test.dart';

Future<void> main() async {
  FlutterForegroundTask.initCommunicationPort();
  await initService();
  await init();

  runApp(const AppRoot());
}

Future<void> init() async {
  WidgetsFlutterBinding.ensureInitialized();
  // TODO : sharedPreferences 추가
}

Future<void> initService() async {
  GServiceUser = ServiceUser.getInstance();
  GServiceChecklist = ServiceChecklist.getInstance();
}

// TODO : 플랫폼 추가(device info plus)
Future<void> deviceCheck() async {}
