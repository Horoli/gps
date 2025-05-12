part of gps_test;

class ViewWorkDetail extends StatefulWidget {
  const ViewWorkDetail({super.key});

  @override
  State<ViewWorkDetail> createState() => ViewWorkDetailState();
}

class ViewWorkDetailState extends State<ViewWorkDetail> {
  @override
  Widget build(BuildContext context) {
    // 현재 선택된 절차 인덱스
    int _currentProcedureIndex = 0;

    return Scaffold(
      appBar: CommonAppBar(title: TITLE.WORK),
      body: StreamBuilder<MWorkList?>(
        stream: GServiceWorklist.stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return StreamExceptionWidgets.waiting(context: context);
          }

          if (snapshot.hasError) {
            return StreamExceptionWidgets.hasError(
              context: context,
              refreshPressed: () async {
                await GServiceWorklist.get();
              },
            );
          }

          if (!snapshot.hasData || snapshot.data?.currentWork == null) {
            // GServiceWorklist.navigatorWithHasCurrentWork();
            return StreamExceptionWidgets.noData(
                context: context, title: '작업 정보가 없습니다');
          }

          final CurrentWork currentWork = snapshot.data!.currentWork!;
          final List<MProcedureInCurrentWork> procedures =
              currentWork.procedures;

          // 현재 진행 중인 절차 찾기
          for (int i = 0; i < procedures.length; i++) {
            if (procedures[i].date == null ||
                procedures[i].date!.year == 1970) {
              // 기본값 날짜 체크
              _currentProcedureIndex = i;
              break;
            }
          }
          return Column(children: [
            buildWorkInfo(currentWork).expand(),
            buildCurrentWork(procedures[_currentProcedureIndex]).expand(),
            buildWorkHistory(procedures, _currentProcedureIndex).expand(),
            // 작업자 정보
            const Text(
              '작업자',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // 작업자 목록
            Text(
              currentWork.users.map((u) => u.username).join(', '),
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // 작업 기록

            // 현재 작업 완료 버튼
            buildElevatedButton(
              onPressed: () async {
                await showConfirmationDialog(
                  context,
                  procedures[_currentProcedureIndex].name,
                );
              },
              child: const Text(
                '현재 작업 완료',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ]);
        },
      ),
    );
  }

  Widget buildWorkInfo(CurrentWork currentWork) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: commonDecoration,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '작업 정보',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: SIZE.WORK_DETAIL_HEADER,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    const Text(
                      '편명',
                      style: TextStyle(
                        fontSize: SIZE.WORK_DETAIL_CHILD,
                        color: COLOR.GREY,
                      ),
                    ),
                    Text(
                      currentWork.aircraft.name,
                      style: const TextStyle(
                        fontSize: SIZE.WORK_DETAIL_CHILD,
                        color: COLOR.GREY,
                      ),
                    ).expand(),
                  ],
                ).expand(),
                Column(
                  children: [
                    const Text(
                      '출발시간',
                      style: TextStyle(
                        fontSize: SIZE.WORK_DETAIL_CHILD,
                        color: COLOR.GREY,
                      ),
                    ),
                    Text(
                      currentWork.aircraft.departureTime,
                      style: const TextStyle(
                        fontSize: SIZE.WORK_DETAIL_CHILD,
                        color: COLOR.GREY,
                      ),
                    ).expand(),
                  ],
                ).expand(),
              ],
            ).expand(),
          ],
        ),
      ),
    );
  }

  Widget buildCurrentWork(MProcedureInCurrentWork currentProcedure) {
    // 현재 작업명
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        width: double.infinity,
        decoration: commonDecoration,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '현재 작업',
              style: TextStyle(
                fontSize: SIZE.WORK_DETAIL_HEADER,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              currentProcedure.name,
              style: const TextStyle(
                fontSize: SIZE.WORK_DETAIL_CHILD,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildWorkHistory(
    List<MProcedureInCurrentWork> procedures,
    int currentProcedureIndex,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: commonDecoration,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '작업 기록',
              style: TextStyle(
                fontSize: SIZE.WORK_DETAIL_HEADER,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // 절차 단계 표시
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(procedures.length, (index) {
                final bool isCompleted = index < currentProcedureIndex;
                final bool isCurrent = index == currentProcedureIndex;

                return Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted
                            ? COLOR.SELECTED
                            : (isCurrent ? COLOR.BASE : Colors.grey.shade300),
                      ),
                      child: Icon(
                        isCompleted ? Icons.check : null,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      procedures[index].name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isCurrent ? FontWeight.bold : FontWeight.normal,
                        color:
                            isCurrent ? const Color(0xFF4B5EFC) : Colors.black,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildWorkers() {
    return Container();
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    await GServiceWorklist.get();
  }

  Future<void> showConfirmationDialog(
      BuildContext context, String procedureName) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            '작업 완료',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            '$procedureName 작업을 완료하시겠습니까?',
            textAlign: TextAlign.center,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // 다이얼로그 닫기
                  },
                  child: const Text(
                    '아니오',
                    style: TextStyle(color: Colors.black),
                  ),
                ).expand(),
                Container(
                  width: 1,
                  height: 24,
                  color: Colors.grey.shade300,
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop(); // 다이얼로그 닫기
                    await completeProcedure(); // 작업 완료 처리
                  },
                  child: const Text(
                    '네',
                    style: TextStyle(color: Color(0xFF4B5EFC)),
                  ),
                ).expand(),
              ],
            ),
          ],
          actionsPadding: EdgeInsets.zero,
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        );
      },
    );
  }

  // 작업 완료 처리
  Future<void> completeProcedure() async {
    // 여기에 작업 완료 API 호출 로직 구현
    try {
      // 현재 위치 가져오기
      // Position position = await Geolocator.getCurrentPosition();

      // 작업 완료 API 호출

      debugPrint('완료 처리 ${DateTime.now().millisecondsSinceEpoch}');
      await GServiceWorklist.completeProcedure();
      debugPrint(
          'GServiceWorklist.lastValue?.currentWork == null ${GServiceWorklist.lastValue?.currentWork == null}');
      if (GServiceWorklist.lastValue?.currentWork == null) {
        await Navigator.of(context).pushReplacementNamed(PATH.ROUTE_WORKLIST);
      }

      // 성공 메시지
      if (mounted) {
        ShowInformationWidgets.snackbar(context, '작업이 완료되었습니다');
      }

      // 작업 목록 새로고침
    } catch (e) {
      if (mounted) {
        ShowInformationWidgets.snackbar(context, '작업 완료 처리 중 오류가 발생했습니다: $e');
      }
    }
  }
}
