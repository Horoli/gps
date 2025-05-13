part of gps_test;

class ViewWorklist extends StatefulWidget {
  const ViewWorklist({super.key});

  @override
  State<ViewWorklist> createState() => ViewWorklistState();
}

class ViewWorklistState extends State<ViewWorklist> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: TITLE.WORKLIST),
      body: StreamBuilder<MWorkList?>(
        stream: GServiceWorklist.stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return StreamExceptionWidgets.hasError(
              context: context,
              refreshPressed: () async {
                getData();
              },
            );
          }

          // 데이터 없음 처리
          if (!snapshot.hasData) {
            return StreamExceptionWidgets.noData(
              context: context,
              title: '작업리스트가 없습니다',
            );
          }

          // 데이터가 있지만 works 리스트가 비어있는 경우
          final MWorkList worklist = snapshot.data!;
          final List<MWorkData> works = worklist.works;

          if (works.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.work_off,
                    color: Colors.grey,
                    size: 60,
                  ),
                  SizedBox(height: 16),
                  Text(
                    '오늘의 작업이 없습니다',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            color: COLOR.WHITE,
            backgroundColor: COLOR.BASE,
            onRefresh: getData,
            child: ListView.builder(
              itemCount: works.length,
              itemBuilder: (BuildContext context, int index) {
                return TileWork(workItem: works[index]);
              },
            ),
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    GServiceLocation.checkAndRequestLocationPermission();
    getData();
  }

  Future<void> getData() async {
    await GServiceWorklist.get();

    // currentWork가 있으면 자동으로 WORK_VIEW로 이동
    // await GServiceWorklist.navigatorWithHasCurrentWork();

    if (GServiceWorklist.lastValue?.currentWork != null) {
      await Navigator.pushReplacementNamed(context, PATH.ROUTE_WORK_DETAIL);
    }
  }
}
