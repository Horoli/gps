part of FlightSteps;

class ViewWorkDetail extends StatefulWidget {
  const ViewWorkDetail({super.key});

  @override
  State<ViewWorkDetail> createState() => ViewWorkDetailState();
}

class ViewWorkDetailState extends State<ViewWorkDetail> {
  TextEditingController descriptionTextController = TextEditingController();
  int currentProcedureIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: commonAppBar(title: TITLE.WORK),
      resizeToAvoidBottomInset: false,
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

          if (!snapshot.hasData) {
            return StreamExceptionWidgets.noData(
                context: context, title: '작업 정보가 없습니다');
          }

          dynamic selectedWork = GServiceWorklist.getWorkByDivision(
              uuid: GServiceWorklist.selectedUuidLastValue);

          if (selectedWork == null) {
            return StreamExceptionWidgets.noData(
                context: context, title: '해당 작업 정보가 없습니다');
          }

          bool isExtra = false;

          // TODO : 분기코드 전체적으로 손 봐야함
          String type = '';
          String aircraftDepartureTime = '';
          String aircraftName = '';
          String extraName = '';
          String extraDescription = '';
          List<MUser> users = [];

          bool isMyWork = selectedWork.runtimeType == MCurrentWork;

          if (isMyWork) {
            selectedWork as MCurrentWork;
            print('selectedWork step 1 $selectedWork');
            aircraftName = selectedWork.aircraft!.name;
            type = selectedWork.type;
            isExtra = type == 'extra';
            aircraftDepartureTime = selectedWork.aircraft!.departureTime;
            users = selectedWork.users;
            if (isExtra) {
              extraName = selectedWork.extra?.name ?? '-';
              extraDescription = selectedWork.extra?.description ?? '-';
            }
          }
          if (selectedWork.runtimeType == MWorkingData) {
            selectedWork as MWorkingData;
            aircraftName = selectedWork.name;
            aircraftDepartureTime = selectedWork.departureTime;
            users = selectedWork.users!;
            isExtra = type == 'extra';
          }

          final List<MProcedure> procedures = selectedWork.procedures ?? [];
          print('procedures $procedures');

          if (procedures.isEmpty) {
            return Container();
          }

          // 현재 진행 중인 절차 찾기
          for (int index = 0; index < procedures.length; index++) {
            if (procedures[index].date == null ||
                procedures[index].date!.year == 1970) {
              // 기본값 날짜 체크
              currentProcedureIndex = index;
              break;
            }
          }

          procedureMap[selectedWork.uuid] = currentProcedureIndex;

          int getProcedureIndexByWorkId = procedureMap[selectedWork.uuid]!;

          print('selectedWork $selectedWork');
          print('selectedWork ${snapshot.data?.currentWork}');

          List<Widget> isWorkingWidgets = [
            buildCurrentWork(procedures[getProcedureIndexByWorkId])
                .flex(flex: 2),
            buildWorkHistory(procedures, getProcedureIndexByWorkId)
                .flex(flex: 2),
          ];

          List<Widget> isLastProdcedureWidgets = [
            buildDescriptionField().flex(flex: 4),
          ];

          return Column(
            children: [
              isExtra
                  ? buildExtraWorkInfo(extraName, extraDescription)
                      .flex(flex: 2)
                  : buildWorkInfo(
                          name: aircraftName,
                          departureTime: aircraftDepartureTime)
                      .flex(flex: 2),
              if (currentProcedureIndex < 4) ...isWorkingWidgets,
              if (currentProcedureIndex == 4) ...isLastProdcedureWidgets,

              //
              buildWorkers(users).flex(flex: 3),

              //
              isMyWork
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
                        // print(GServiceWorklist.selectedCurrentWorkLastValue);
                        // TODO : createGroupView로 이동
                        await Navigator.pushNamed(
                          GNavigationKey.currentContext!,
                          PATH.ROUTE_CREATE_GROUP_SHIFT,
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

  Widget buildDescriptionField() {
    return Padding(
      padding: SIZE.WORK_DETAIL_PADDING,
      child: Container(
        decoration: commonDecoration,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AutoSizeText(
              '특이사항 / 비고',
              minFontSize: SIZE.WORK_DETAIL_HEADER,
              textAlign: TextAlign.center,
              style: TextStyle(
                // fontSize: SIZE.WORK_DETAIL_HEADER,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const Divider(
              indent: 10,
              endIndent: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: descriptionTextController,
                maxLines: 20,
                decoration: const InputDecoration(
                  hintText: '내용을 작성해주세요.',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ).expand(),
          ],
        ),
      ),
    );
  }

  Widget buildWorkInfo({required String name, required String departureTime}) {
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
                      text: name,
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
                      text: departureTime,
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

  Widget buildExtraWorkInfo(
    String name,
    String description,
  ) {
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
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    buildFittedText(
                      text: '작업명',
                      fontSize: SIZE.WORK_DETAIL_CHILD,
                      color: COLOR.GREY,
                    ).expand(),
                    buildFittedText(
                      text: name,
                      fontSize: SIZE.WORK_DETAIL_CHILD,
                      color: COLOR.GREY,
                    ).expand(),
                  ],
                ).expand(),
                Column(
                  children: [
                    buildFittedText(
                      text: '상세',
                      fontSize: SIZE.WORK_DETAIL_CHILD,
                      color: COLOR.GREY,
                    ).expand(),
                    buildFittedText(
                      text: description,
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

  Widget buildCurrentWork(MProcedure currentProcedure) {
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
    List<MProcedure> procedures,
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

  Widget buildWorkers(List<MUser> users) {
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
              itemCount: users.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(users[index].username),
                  subtitle: Text(
                    users[index].phoneNumber,
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

  @override
  void dispose() {
    super.dispose();
    sseDisconnect();
  }

  Future<void> getData() async {
    await GServiceSSE.connect();
    await GServiceWorklist.get();
  }

  Future<void> sseDisconnect() async {
    // await GServiceSSE.disconnect();
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
      String selectedWorkId = GServiceWorklist.selectedUuidLastValue;
      await GServiceWorklist.completeProcedure(
        uuid: selectedWorkId,
        description: descriptionTextController.text,
      );
      debugPrint(
          'GServiceWorklist.lastValue?.currentWork == null ${GServiceWorklist.workListLastValue?.currentWork == null}');
      // MCurrentWork? getCurrentWork = GServiceWorklist.getCurrentWork;
      // if (getCurrentWork == null) {
      //   if (mounted && Navigator.canPop(context)) {
      //     await Navigator.pushNamedAndRemoveUntil(
      //         context, PATH.ROUTE_WORKLIST, (route) => false);
      //   }

      // Future.delayed(const Duration(seconds: 2), () {
      //   GServiceSSE._ignoreNavigationEvents = false;
      // });
      // }

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
