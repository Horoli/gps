part of FlightSteps;

class ViewWorklist extends StatefulWidget {
  const ViewWorklist({super.key});

  @override
  State<ViewWorklist> createState() => ViewWorklistState();
}

class ViewWorklistState extends State<ViewWorklist> {
  int _currentIndex = 0;
  late PageController _pageController;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: commonAppBar(
        title: TITLE.WORKLIST,
        automaticallyImplyLeading: false,
      ),
      bottomNavigationBar: buildBottomNavigationBar(),
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _pageController,
        onPageChanged: (index) {},
        children: [
          buildWorkListPage(state: STATE.WORKSTATE_NORMAL),
          buildExtraListPage(),
          buildWorkListPage(state: STATE.WORKSTATE_WORKING),
          buildWorkListPage(state: STATE.WORKSTATE_COMPLETE),
        ],
      ),
    );
  }

  Widget buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      type: BottomNavigationBarType.fixed,
      backgroundColor: COLOR.BASE,
      selectedItemColor: COLOR.WHITE,
      unselectedItemColor: Colors.grey.withOpacity(0.6),
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      items: const [
        BottomNavigationBarItem(
          // backgroundColor: COLOR.BASE,
          icon: Icon(Icons.airplanemode_active),
          label: '항공편 연계작업',
        ),
        BottomNavigationBarItem(
          // backgroundColor: Colors.red,
          icon: Icon(Icons.work),
          label: '비 연계 작업',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.fire_truck),
          label: '작업 중',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.check),
          label: '작업완료',
        ),
      ],
    );
  }

  Widget buildWorkListPage({required String state}) {
    return StreamBuilder<MWorkList?>(
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
        final List<MWorkData> works = worklist.workList.where((work) {
          return work.state == state;
          // if (state == WORKSTATE_WORKING) {
          //   return work.state == WORKSTATE_WORKING;
          // } else if (state == WORKSTATE_COMPLETE) {
          //   return work.state == WORKSTATE_COMPLETE;
          // }
          // return work.state == WORKSTATE_NORMAL;
        }).toList();

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
              final MWorkData workData = works[index];

              final MCurrentWork? matchingCurrentWork =
                  worklist.currentWork.where(
                (currentWork) {
                  String workString =
                      '${workData.name}_${workData.departureTime}_${workData.type}';
                  String currentString =
                      '${currentWork.aircraft!.name}_${currentWork.aircraft!.departureTime}_${currentWork.aircraft!.type}';
                  return workString == currentString;
                },
              ).firstOrNull; // firstOrNull 사용
              return TileWork(
                workData: workData,
                currentWork: matchingCurrentWork,
              );
            },
          ),
        );
      },
    );
  }

  Widget buildExtraListPage() {
    return StreamBuilder<MWorkList?>(
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
        final List<MExtraWorkData> works = worklist.extraWorkList;

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
              return TileExtraWork(extraWorkItem: works[index]);
            },
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // GServiceLocation.checkAndRequestLocationPermission();
    // print('view/worklist.dart initState');
    getData();
  }

  Future<void> getData() async {
    await GServiceWorklist.get();
    await GServiceWork.getAvailableWorks();
    // currentWork가 있으면 자동으로 WORK_VIEW로 이동
    // await GServiceWorklist.navigatorWithHasCurrentWork();

    // if (GServiceWorklist.lastValue?.currentWork != null) {
    //   await Navigator.pushReplacementNamed(context, PATH.ROUTE_WORK_DETAIL);
    // }
  }
}
