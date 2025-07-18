part of FlightSteps;

class ViewWorkDetail extends StatefulWidget {
  const ViewWorkDetail({super.key});

  @override
  State<ViewWorkDetail> createState() => ViewWorkDetailState();
}

class ViewWorkDetailState extends State<ViewWorkDetail> {
  int currentProcedureIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: commonAppBar(title: TITLE.WORK),
      body: StreamBuilder<MWorkList?>(
        stream: GServiceWorklist.stream,
        builder: (context, snapshot) {
          print('workDetail snapshot $snapshot');
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

          if (!snapshot.hasData) {
            return StreamExceptionWidgets.noData(
                context: context, title: '작업 정보가 없습니다');
          }

          final MCurrentWork? currentWork = GServiceWorklist.getCurrentWork(
            inputCurrentWork: snapshot.data!.currentWork,
          );

          if (currentWork == null) {
            return StreamExceptionWidgets.noData(
                context: context, title: '해당 작업 정보가 없습니다');
          }

          final List<MProcedureInCurrentWork> procedures =
              currentWork.procedures;

          // 현재 진행 중인 절차 찾기
          for (int index = 0; index < procedures.length; index++) {
            if (procedures[index].date == null ||
                procedures[index].date!.year == 1970) {
              // 기본값 날짜 체크
              currentProcedureIndex = index;
              break;
            }
          }

          procedureMap[currentWork.uuid] = currentProcedureIndex;

          int getProcedureIndexByWorkId = procedureMap[currentWork.uuid]!;

          // currentWork.users에 현재 user의 id가 포함되어 있으면 true
          bool workerHasUserId =
              currentWork.users.any((MUserInCurrentWork userFromWork) {
            print('userFromWork $userFromWork');
            print('userFromWork.getUuid ${GServiceUser.getUuid}');
            return userFromWork.uuid == GServiceUser.currentUser?.uuid;
          });
          print('userFromWork workerHasUserId $workerHasUserId');

          return Column(
            children: [
              buildWorkInfo(currentWork).flex(flex: 2),
              buildCurrentWork(procedures[getProcedureIndexByWorkId])
                  .flex(flex: 2),
              buildWorkHistory(procedures, getProcedureIndexByWorkId)
                  .flex(flex: 2),
              buildWorkers(currentWork).flex(flex: 3),
              //
              workerHasUserId
                  ? buildElevatedButton(
                      onPressed: () async {
                        await showConfirmationDialog(
                          context,
                          procedures[getProcedureIndexByWorkId].name,
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
                    )
                  : buildElevatedButton(
                      onPressed: () async {
                        // TODO : 현재 선택된 currentWork.uuid를
                        print(GServiceWorklist.selectedCurrentWorkLastValue);

                        // TODO : createGroupView로 이동
                        await Navigator.pushNamed(
                          GNavigationKey.currentContext!,
                          PATH.ROUTE_CREATE_GROUP,
                        );

                        // TODO : sse disconnect
                        // await GServiceSSE.disconnect();
                      },
                      child: const Text(
                        '교대하기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    )
            ],
          );
        },
      ),
    );
  }

  Widget buildWorkInfo(MCurrentWork currentWork) {
    return Padding(
      padding: SIZE.WORK_DETAIL_PADDING,
      child: Container(
        decoration: commonDecoration,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AutoSizeText(
              '작업 정보',
              minFontSize: SIZE.WORK_DETAIL_HEADER,
              textAlign: TextAlign.center,
              style: TextStyle(
                // fontSize: SIZE.WORK_DETAIL_HEADER,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ).expand(),
            // const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    buildFittedText(
                      text: '편명',
                      fontSize: SIZE.WORK_DETAIL_CHILD,
                      color: COLOR.GREY,
                    ).expand(),
                    buildFittedText(
                      text: currentWork.aircraft.name,
                      fontSize: SIZE.WORK_DETAIL_CHILD,
                      color: COLOR.GREY,
                    ).expand(),
                  ],
                ).expand(),
                Column(
                  children: [
                    buildFittedText(
                      text: '출발시간',
                      fontSize: SIZE.WORK_DETAIL_CHILD,
                      color: COLOR.GREY,
                    ).expand(),
                    buildFittedText(
                      text: currentWork.aircraft.departureTime,
                      fontSize: SIZE.WORK_DETAIL_CHILD,
                      color: COLOR.GREY,
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
      padding: SIZE.WORK_DETAIL_PADDING,
      child: Container(
        width: double.infinity,
        decoration: commonDecoration,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildFittedText(
              text: '현재 작업',
              fontSize: SIZE.WORK_DETAIL_HEADER,
              fontWeight: FontWeight.w500,
            ),
            buildFittedText(
              text: currentProcedure.name,
              fontSize: SIZE.WORK_DETAIL_CHILD,
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
      padding: SIZE.WORK_DETAIL_PADDING,
      child: Container(
        decoration: commonDecoration,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildFittedText(
              text: '작업 기록',
              fontSize: SIZE.WORK_DETAIL_HEADER,
              fontWeight: FontWeight.w500,
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
                        color: isCurrent ? COLOR.BASE : Colors.black,
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

  Widget buildWorkers(MCurrentWork currentWork) {
    return Padding(
      padding: SIZE.WORK_DETAIL_PADDING,
      child: Container(
        width: double.infinity,
        decoration: commonDecoration,
        child: Column(
          children: [
            // 작업자 정보
            buildFittedText(
              text: '작업자',
              fontSize: SIZE.WORK_DETAIL_HEADER,
              fontWeight: FontWeight.w500,
            ),
            ListView.separated(
              separatorBuilder: (context, index) => SIZE.DIVIDER,
              shrinkWrap: true,
              // physics: const NeverScrollableScrollPhysics(),
              itemCount: currentWork.users.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(currentWork.users[index].username),
                  subtitle: Text(
                    currentWork.users[index].phoneNumber,
                  ),
                );
              },
            ).expand(),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    await GServiceSSE.connect();
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
      // 작업 완료 API 호출
      debugPrint('완료 처리 ${DateTime.now().millisecondsSinceEpoch}');
      await GServiceWorklist.completeProcedure();
      // debugPrint(
      //     'GServiceWorklist.lastValue?.currentWork == null ${GServiceWorklist.lastValue?.currentWork == null}');
      MCurrentWork? getCurrentWork = GServiceWorklist.getCurrentWork();
      if (getCurrentWork == null) {
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
