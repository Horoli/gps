part of gps_test;

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => AppRootState();
}

class AppRootState extends State<AppRoot> {
  @override
  Widget build(BuildContext context) {
    Map<String, Widget Function(BuildContext)> routes = {
      PATH.ROUTE_LOGIN: (BuildContext context) => const ViewLogin(),
      PATH.ROUTE_CHECKLIST: (BuildContext context) => const ViewChecklist(),
      PATH.ROUTE_WORKLIST: (BuildContext context) => const ViewWorklist(),
      PATH.ROUTE_CREATE_GROUP: (BuildContext context) =>
          const ViewCreateGroup(),
      PATH.ROUTE_WORK_DETAIL: (BuildContext context) => const ViewWorkDetail(),
    };

    return MaterialApp(
      title: 'Flutter Demo',
      navigatorKey: GNavigationKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      initialRoute: PATH.ROUTE_LOGIN,
      routes: routes,
    );
  }
}

// class MyHomePage extends StatefulWidget {
//   MyHomePage({super.key});

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
// //  with WidgetsBindingObserver {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Row(
//           children: [
//             ElevatedButton(
//               child: Text('gps'),
//               onPressed: () async {
//                 LocationPermission permission =
//                     await checkAndRequestLocationPermission();
//                 print('permission $permission');

//                 if (permission == LocationPermission.always) {
//                   Position position = await Geolocator.getCurrentPosition();
//                   print(position.accuracy);
//                 }
//               },
//             ),
//             ElevatedButton(
//               child: Text('start'),
//               onPressed: () async {
//                 await startService();
//               },
//             ),
//             ElevatedButton(
//               child: Text('end'),
//               onPressed: () async {
//                 await endService();
//               },
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   Future<LocationPermission> checkAndRequestLocationPermission() async {
//     // 현재 권한 상태 확인
//     LocationPermission permission = await Geolocator.checkPermission();

//     // 권한이 영구적으로 거부된 경우
//     if (permission == LocationPermission.deniedForever) {
//       // 사용자에게 설정 화면으로 이동하도록 안내하는 다이얼로그 표시
//       bool goToSettings = await showDialog(
//             context: context,
//             builder: (BuildContext context) => AlertDialog(
//               title: Text('위치 권한 필요'),
//               content: Text('이 앱은 위치 정보가 필요합니다. 설정에서 위치 권한을 허용해주세요.'),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.of(context).pop(false),
//                   child: Text('취소'),
//                 ),
//                 TextButton(
//                   onPressed: () => Navigator.of(context).pop(true),
//                   child: Text('설정으로 이동'),
//                 ),
//               ],
//             ),
//           ) ??
//           false;

//       // 사용자가 설정으로 이동하기로 선택한 경우
//       if (goToSettings) {
//         await Geolocator.openAppSettings(); // 앱 설정 페이지 열기
//         // 또는 Geolocator.openLocationSettings(); // 위치 설정 페이지 열기
//       }
//     }
//     // 권한이 거부되었지만 영구적으로 거부되지 않은 경우
//     else if (permission == LocationPermission.denied) {
//       // 권한 요청
//       permission = await Geolocator.requestPermission();
//     }

//     // 권한이 항상 허용되지 않은 경우 (whileInUse 상태인 경우)
//     if (permission == LocationPermission.whileInUse) {
//       // 항상 허용 권한을 요청하는 다이얼로그 표시
//       bool requestAlways = await showDialog(
//             context: context,
//             builder: (BuildContext context) => AlertDialog(
//               title: Text('백그라운드 위치 권한'),
//               content: Text('앱이 백그라운드에서도 위치 정보를 사용할 수 있도록 허용하시겠습니까?'),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.of(context).pop(false),
//                   child: Text('아니오'),
//                 ),
//                 TextButton(
//                   onPressed: () async {
//                     Navigator.of(context).pop();
//                     await Geolocator.openAppSettings(); // 앱 설정 페이지 열기
//                   },
//                   child: Text('예'),
//                 ),
//               ],
//             ),
//           ) ??
//           false;

//       // 사용자가 항상 허용을 선택한 경우
//       if (requestAlways) {
//         permission = await Geolocator.requestPermission();
//       }
//     }
//     return permission;
//   }

//   @override
//   void initState() {
//     super.initState();
//     // WidgetsBinding.instance.addObserver(this);
//     FlutterForegroundTask.addTaskDataCallback(onReceiveTaskData);
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       ForegroundTaskHandler.requestPermissions();
//       ForegroundTaskHandler.initTask();
//     });
//   }

//   Future<ServiceRequestResult> startService() async {
//     if (await FlutterForegroundTask.isRunningService) {
//       return FlutterForegroundTask.restartService();
//     } else {
//       return FlutterForegroundTask.startService(
//         serviceId: 256,
//         notificationTitle: 'Foreground Service is running',
//         notificationText: 'Tap to return to the app',
//         notificationIcon: null,
//         notificationButtons: [
//           const NotificationButton(id: 'btn_hello', text: 'end location share'),
//         ],
//         notificationInitialRoute: '/',
//         callback: startCallback,
//       );
//     }
//   }

//   Future endService() async {
//     if (await FlutterForegroundTask.isRunningService) {
//       print('stop service');
//       FlutterForegroundTask.stopService();
//     } else {
//       return;
//     }
//   }

//   void onReceiveTaskData(Object data) {
//     if (data is Map<String, dynamic>) {
//       final dynamic timestampMillis = data["timestampMillis"];
//       if (timestampMillis != null) {
//         final DateTime timestamp =
//             DateTime.fromMillisecondsSinceEpoch(timestampMillis, isUtc: true);
//         print('timestamp: ${timestamp.toString()}');
//       }
//     }
//   }

//   // @override
//   // void didChangeAppLifecycleState(AppLifecycleState state) {
//   //   print(state);
//   //   if (state == AppLifecycleState.detached) {
//   //     print('detached');
//   //   }
//   // }

//   @override
//   void dispose() {
//     FlutterForegroundTask.removeTaskDataCallback(onReceiveTaskData);
//     super.dispose();
//   }
// }
