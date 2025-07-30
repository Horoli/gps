part of FlightSteps;

class ViewWorklist extends StatefulWidget {
  const ViewWorklist({super.key});

  @override
  State<ViewWorklist> createState() => ViewWorklistState();
}

class ViewWorklistState extends State<ViewWorklist> {
  int currentIndex = 0;
  late PageController pageController;

  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus() // 키보드 내리기
      ,
      child: Scaffold(
        appBar: commonAppBar(
          title: TITLE.WORKLIST,
          automaticallyImplyLeading: false,
        ),
        bottomNavigationBar: buildBottomNavigationBar(),
        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: pageController,
          onPageChanged: (index) {},
          children: [
            buildWorkListPage(state: STATE.WORKSTATE_NORMAL),
            buildExtraListPage(),
            buildWorkListPage(state: STATE.WORKSTATE_WORKING),
            buildWorkListPage(state: STATE.WORKSTATE_COMPLETE),
          ],
        ),
      ),
    );
  }

  Widget buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      backgroundColor: COLOR.BASE,
      selectedItemColor: COLOR.WHITE,
      unselectedItemColor: Colors.grey.withOpacity(0.6),
      onTap: (index) {
        setState(() {
          currentIndex = index;
        });
        pageController.animateToPage(
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
          icon: Icon(Icons.local_shipping),
          label: '작업 중',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.check),
          label: '작업완료',
        ),
      ],
    );
  }

  Widget buildWorkListPage({
    required String state,
  }) {
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

        final MWorkList worklist = snapshot.data!;
        List<MWorkData> works = worklist.workList.where((work) {
          return work.state == state;
        }).toList();

        if (searchController.text.isNotEmpty) {
          works = works.where((work) {
            final String searchLower = searchController.text.toLowerCase();
            String replaceDepartureTime =
                work.departureTime.replaceAll(':', '');
            return work.name.toLowerCase().contains(searchLower) ||
                replaceDepartureTime.toLowerCase().contains(searchLower);
          }).toList();
        }

        return Column(
          children: [
            buildSearchTextField(
              controller: searchController,
              hint: '검색(작업명, 출발시간)',
              onChanged: (value) {
                setState(() {
                  // 필터링 로직 추가
                  works.retainWhere((work) => work.name.contains(value));
                });
              },
            ),
            // 데이터가 있지만 works 리스트가 비어있는 경우
            works.isEmpty
                ? buildEmptyState().expand()
                : RefreshIndicator(
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
                  ).expand(),
          ],
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
        List<MExtraWorkData> works = worklist.extraWorkList;

        if (searchController.text.isNotEmpty) {
          works = works.where((work) {
            final String searchLower = searchController.text.toLowerCase();
            return work.name.toLowerCase().contains(searchLower) ||
                work.description.toLowerCase().contains(searchLower);
          }).toList();
        }

        return Column(
          children: [
            buildSearchTextField(
              controller: searchController,
              hint: '검색(작업명, 작업내용)',
              onChanged: (value) {
                setState(() {
                  // 필터링 로직 추가
                  works.retainWhere((work) => work.name.contains(value));
                });
              },
            ),
            works.isEmpty
                ? buildEmptyState().expand()
                : RefreshIndicator(
                    color: COLOR.WHITE,
                    backgroundColor: COLOR.BASE,
                    onRefresh: getData,
                    child: ListView.builder(
                      itemCount: works.length,
                      itemBuilder: (BuildContext context, int index) {
                        return TileExtraWork(extraWorkItem: works[index]);
                      },
                    ),
                  ).expand(),
          ],
        );
      },
    );
  }

  Widget buildEmptyState() {
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
            '작업이 없습니다',
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    searchController.addListener(() {});
    getData();
  }

  Future<void> getData() async {
    await GServiceWorklist.get();
    await GServiceWork.getAvailableWorks();
  }
}
