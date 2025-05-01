part of gps_test;

class ViewChecklist extends StatefulWidget {
  const ViewChecklist({super.key});

  @override
  State<ViewChecklist> createState() => ViewChecklistState();
}

class ViewChecklistState extends State<ViewChecklist> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: TITLE.CHECKLIST),
      body: SafeArea(
        child: Column(
          children: [
            FutureBuilder(
                future: GServiceChecklist.get(),
                builder: (
                  BuildContext context,
                  AsyncSnapshot<List<MChecklistData>> snapshot,
                ) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return StreamExceptionWidgets.waiting(
                      context: context,
                    );
                  }

                  if (snapshot.hasError) {
                    return StreamExceptionWidgets.hasError(
                      context: context,
                      refreshPressed: () {
                        setState(() {});
                      },
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return StreamExceptionWidgets.noData(
                      context: context,
                      title: '체크리스트가 없습니다',
                    );
                  }

                  final List<MChecklistData> checklists = snapshot.data!;

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: checklists.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, int index) {
                      final MChecklistData item = checklists[index];
                      return buildChecklistItem(item, index + 1);
                    },
                  );
                }).expand(),
            buildNavigationButton(
              context: context,
              title: TITLE.CONFIRM,
              routerName: PATH.ROUTE_WORKLIST,
              useReplacement: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildChecklistItem(MChecklistData item, int number) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 체크리스트 제목
          Text(
            '체크리스트 $number',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // 체크리스트 설명
          Text(
            item.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 16),
          // 동의 스위치
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '동의합니다',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Switch(
                value: item.value ?? false,
                onChanged: (value) {},
                activeColor: const Color.fromARGB(255, 21, 25, 61),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<LocationPermission> checkAndRequestLocationPermission() async {
    // 현재 권한 상태 확인
    LocationPermission permission = await Geolocator.checkPermission();

    // 권한이 영구적으로 거부된 경우
    if (permission == LocationPermission.deniedForever) {
      // 사용자에게 설정 화면으로 이동하도록 안내하는 다이얼로그 표시
      bool goToSettings = await showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: Text('위치 권한 필요'),
              content: Text('이 앱은 위치 정보가 필요합니다. 설정에서 위치 권한을 허용해주세요.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('취소'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('설정으로 이동'),
                ),
              ],
            ),
          ) ??
          false;

      // 사용자가 설정으로 이동하기로 선택한 경우
      if (goToSettings) {
        await Geolocator.openAppSettings(); // 앱 설정 페이지 열기
        // 또는 Geolocator.openLocationSettings(); // 위치 설정 페이지 열기
      }
    }
    // 권한이 거부되었지만 영구적으로 거부되지 않은 경우
    else if (permission == LocationPermission.denied) {
      // 권한 요청
      permission = await Geolocator.requestPermission();
    }

    // 권한이 항상 허용되지 않은 경우 (whileInUse 상태인 경우)
    if (permission == LocationPermission.whileInUse) {
      // 항상 허용 권한을 요청하는 다이얼로그 표시
      bool requestAlways = await showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: Text('백그라운드 위치 권한'),
              content: Text('앱이 백그라운드에서도 위치 정보를 사용할 수 있도록 허용하시겠습니까?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('아니오'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await Geolocator.openAppSettings(); // 앱 설정 페이지 열기
                  },
                  child: Text('예'),
                ),
              ],
            ),
          ) ??
          false;

      // 사용자가 항상 허용을 선택한 경우
      if (requestAlways) {
        permission = await Geolocator.requestPermission();
      }
    }
    return permission;
  }

  @override
  void initState() {
    super.initState();
    checkAndRequestLocationPermission();

    if (useForeground) {
      FlutterForegroundTask.addTaskDataCallback(
          ForegroundTaskHandler.onReceiveTaskData);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ForegroundTaskHandler.requestPermissions();
        ForegroundTaskHandler.initTask();
      });
      ForegroundTaskHandler.startService();
    }
  }

  // Future<ServiceRequestResult> startService() async {
  //   if (await FlutterForegroundTask.isRunningService) {
  //     return FlutterForegroundTask.restartService();
  //   } else {
  //     return FlutterForegroundTask.startService(
  //       serviceId: 256,
  //       notificationTitle: 'Foreground Service is running',
  //       notificationText: 'Tap to return to the app',
  //       notificationIcon: null,
  //       notificationButtons: [
  //         const NotificationButton(id: 'btn_hello', text: 'end location share'),
  //       ],
  //       notificationInitialRoute: '/',
  //       callback: startCallback,
  //     );
  //   }
  // }

  // Future endService() async {
  //   if (await FlutterForegroundTask.isRunningService) {
  //     print('stop service');
  //     FlutterForegroundTask.stopService();
  //   } else {
  //     return;
  //   }
  // }

  // void onReceiveTaskData(Object data) {
  //   if (data is Map<String, dynamic>) {
  //     final dynamic timestampMillis = data["timestampMillis"];
  //     if (timestampMillis != null) {
  //       final DateTime timestamp =
  //           DateTime.fromMillisecondsSinceEpoch(timestampMillis, isUtc: true);
  //       print('timestamp: ${timestamp.toString()}');
  //     }
  //   }
  // }

  @override
  void dispose() {
    if (useForeground) {
      FlutterForegroundTask.removeTaskDataCallback(
          ForegroundTaskHandler.onReceiveTaskData);
    }
    super.dispose();
  }
}
