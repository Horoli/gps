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

  @override
  void initState() {
    super.initState();
    initForegroundTask();
  }

  Future<void> initForegroundTask() async {
    print('foreground step 4');
    await ForegroundTaskHandler.initTask();
    print('foreground step 5');
    await ForegroundTaskHandler.startService();
  }

  @override
  void dispose() {
    if (useForeground) {
      FlutterForegroundTask.removeTaskDataCallback(
          ForegroundTaskHandler.onReceiveTaskData);
    }
    super.dispose();
  }
}
