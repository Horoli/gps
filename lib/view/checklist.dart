part of FlightSteps;

class ViewChecklist extends StatefulWidget {
  const ViewChecklist({super.key});

  @override
  State<ViewChecklist> createState() => ViewChecklistState();
}

class ViewChecklistState extends State<ViewChecklist> {
  List<BehaviorSubject<bool>> subjects = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: commonAppBar(title: TITLE.CHECKLIST),
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
                  subjects = [];
                  checklists.map((item) {
                    subjects.add(
                      BehaviorSubject<bool>.seeded(false),
                    );
                  }).toList();

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: checklists.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, int index) {
                      final MChecklistData item = checklists[index];
                      return buildChecklistItem(item, index);
                    },
                  );
                }).expand(),
            buildNavigationButtonWithCustom(
              title: '확인',
              onPressed: () async {
                bool falseInSubjects = await getSubjectResult();
                if (falseInSubjects) {
                  return await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('동의가 필요합니다'),
                        content: const Text('모든 체크리스트에 동의해야 합니다.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('확인'),
                          ),
                        ],
                      );
                    },
                  );
                }

                await Navigator.of(context).pushNamedAndRemoveUntil(
                    PATH.ROUTE_WORKLIST, (route) => false);
              },
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
            '체크리스트 ${number + 1}',
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
              StreamBuilder<bool>(
                stream: subjects[number],
                builder: (context, snapshot) {
                  return Switch(
                    value: snapshot.data ?? false,
                    onChanged: (value) {
                      print('value: $value');
                      subjects[number].add(value);
                    },
                    activeColor: const Color.fromARGB(255, 21, 25, 61),
                  );
                },
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
    // GServiceLocation.checkAndRequestLocationPermission();
    mounted;
  }

  Future<void> initForegroundTask() async {
    debugPrint('foreground step 4');
    await ForegroundTaskHandler.initTask();
    debugPrint('foreground step 5');
    await ForegroundTaskHandler.startService();
  }

  Future<bool> getSubjectResult() async {
    List<bool> results = [];

    for (var subject in subjects) {
      results.add(subject.value);
    }
    print('results: $results');
    return results.contains(false);
  }

  Future<void> subjectDispose() async {
    for (var subject in subjects) {
      await subject.close();
    }
    subjects.clear();
    subjects = [];
  }

  @override
  void dispose() {
    if (useForeground) {
      FlutterForegroundTask.removeTaskDataCallback(
          ForegroundTaskHandler.onReceiveTaskData);
    }
    subjectDispose();
    super.dispose();
  }
}
