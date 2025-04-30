import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'gps_test.dart';

Future<void> main() async {
  await initService();
  await initPlatformInfo();

  FlutterForegroundTask.initCommunicationPort();
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
  GServiceWorklist = ServiceWorklist.getInstance();
  GServiceWork = ServiceWork.getInstance();
  GServiceMember = ServiceMember.getInstance();
  GServiceSSE = ServiceSSE.getInstance();
}

Future<void> initPlatformInfo() async {
  packageInfo = await PackageInfo.fromPlatform();
}

// TODO : 플랫폼 추가(device info plus)
Future<void> deviceCheck() async {}
