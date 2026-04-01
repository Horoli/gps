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
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: commonAppBar(title: TITLE.WORK),
        resizeToAvoidBottomInset: true,
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
            String type = '';
            String aircraftDepartureTime = '';
            String aircraftName = '';
            String extraName = '';
            String extraDescription = '';
            String plateNumber = '';
            List<MUser> users = [];

            bool isMyWork = selectedWork.runtimeType == MCurrentWork;

            if (isMyWork) {
              selectedWork as MCurrentWork;
              aircraftName = selectedWork.aircraft!.name;
              type = selectedWork.type;
              isExtra = type == 'extra';
              aircraftDepartureTime = selectedWork.aircraft!.departureTime;
              plateNumber = selectedWork.plateNumber;
              users = selectedWork.users;
              if (isExtra) {
                extraName = selectedWork.extra?.name ?? '-';
                extraDescription = selectedWork.extra?.description ?? '-';
              }
            } else if (selectedWork.runtimeType == MWorkingData) {
              selectedWork as MWorkingData;
              aircraftName = selectedWork.name;
              aircraftDepartureTime = selectedWork.departureTime;
              plateNumber = selectedWork.plateNumber;
              users = selectedWork.users!;
              isExtra = type == 'extra';
            }

            final List<MProcedure> procedures = selectedWork.procedures ?? [];

            if (procedures.isEmpty) {
              return Container();
            }

            for (int index = 0; index < procedures.length; index++) {
              if (procedures[index].date == null ||
                  procedures[index].date!.year == 1970) {
                currentProcedureIndex = index;
                break;
              }
            }

            procedureMap[selectedWork.uuid] = currentProcedureIndex;
            int getProcedureIndexByWorkId = procedureMap[selectedWork.uuid]!;

            return Column(
              children: [
                // 1. 상단 정보 (유동적 높이)
                isExtra
                    ? buildExtraWorkInfo(extraName, extraDescription)
                    : buildWorkInfo(
                        name: aircraftName,
                        departureTime: aircraftDepartureTime,
                        plateNumber: plateNumber,
                      ),

                // 2. 현재 작업 및 기록 (유동적 높이)
                // if (currentProcedureIndex < 4) ...[
                buildCurrentWork(procedures[getProcedureIndexByWorkId]),
                buildWorkHistory(procedures, getProcedureIndexByWorkId),
                // ],

                // // 3. 특이사항 입력 필드 (가변 영역: 공간 차지)
                // if (currentProcedureIndex == 4)
                //   Expanded(child: buildDescriptionField()),

                // 4. 작업자 리스트 (가변 영역: 공간 차지)
                Expanded(child: buildWorkers(users)),

                // 5. 하단 버튼 (고정)
                SafeArea(
                  top: false,
                  child: isMyWork
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
                            await CustomNavigator.pushNamed(
                              PATH.ROUTE_CREATE_GROUP_SHIFT,
                            );
                          },
                          child: const Text(
                            '교대하기',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget buildDescriptionField() {
    return Padding(
      padding: SIZE.WORK_DETAIL_PADDING,
      child: Container(
        decoration: commonDecoration,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                '특이사항 / 비고',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            const Divider(indent: 10, endIndent: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  controller: descriptionTextController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                    hintText: '내용을 작성해주세요.',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildWorkInfo({
    required String name,
    required String departureTime,
    required String plateNumber,
  }) {
    return Padding(
      padding: SIZE.WORK_DETAIL_PADDING,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: commonDecoration,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '작업 정보',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoColumn('편명', name),
                _buildInfoColumn('STD', departureTime),
                _buildInfoColumn('차량번호', plateNumber),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(color: COLOR.GREY, fontSize: 13)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      ],
    );
  }

  Widget buildExtraWorkInfo(String name, String description) {
    return Padding(
      padding: SIZE.WORK_DETAIL_PADDING,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: commonDecoration,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '작업 정보',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoColumn('작업명', name),
                _buildInfoColumn('상세', description),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCurrentWork(MProcedure currentProcedure) {
    return Padding(
      padding: SIZE.WORK_DETAIL_PADDING,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: commonDecoration,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '현재 작업',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              currentProcedure.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildWorkHistory(
      List<MProcedure> procedures, int currentProcedureIndex) {
    return Padding(
      padding: SIZE.WORK_DETAIL_PADDING,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: commonDecoration,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '작업 기록',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(procedures.length, (index) {
                  final bool isCompleted = index < currentProcedureIndex;
                  final bool isCurrent = index == currentProcedureIndex;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCompleted
                                ? COLOR.SELECTED
                                : (isCurrent
                                    ? COLOR.BASE
                                    : Colors.grey.shade300),
                          ),
                          child: Icon(
                            isCompleted ? Icons.check : null,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          procedures[index].name,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight:
                                isCurrent ? FontWeight.bold : FontWeight.normal,
                            color: isCurrent ? COLOR.BASE : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
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
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                '작업자',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.only(bottom: 8),
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    dense: true,
                    title: Text(users[index].username,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(users[index].phoneNumber),
                    // leading: const CircleAvatar(
                    //   radius: 14,
                    //   child: Icon(Icons.person, size: 16),
                    // ),
                  );
                },
              ),
            ),
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
          title: const Text('작업 완료',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold)),
          content:
              Text('$procedureName 작업을 완료하시겠습니까?', textAlign: TextAlign.center),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('아니오',
                        style: TextStyle(color: Colors.black)),
                  ),
                ),
                Container(width: 1, height: 24, color: Colors.grey.shade300),
                Expanded(
                  child: TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await completeProcedure();
                    },
                    child: const Text('네',
                        style: TextStyle(color: Color(0xFF4B5EFC))),
                  ),
                ),
              ],
            ),
          ],
          actionsPadding: EdgeInsets.zero,
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        );
      },
    );
  }

  Future<void> completeProcedure() async {
    try {
      String selectedWorkId = GServiceWorklist.selectedUuidLastValue;
      await GServiceWorklist.completeProcedure(
        uuid: selectedWorkId,
        description: descriptionTextController.text,
      );
      if (mounted) {
        ShowInformationWidgets.snackbar(context, '작업이 완료되었습니다');
      }
    } catch (e) {
      if (mounted) {
        ShowInformationWidgets.snackbar(context, '작업 완료 처리 중 오류가 발생했습니다: $e');
      }
    }
  }
}
