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
// 항공기 정보
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '편명: ${currentWork.aircraft.name}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                // Text(
                //   '기종: ${currentWork.aircraft.departureTime}',
                //   style: const TextStyle(
                //     fontSize: 14,
                //     fontWeight: FontWeight.w500,
                //   ),
                // ),
              ],
            ),
            const SizedBox(height: 8),
            // 출발 시간
            Text(
              '출발시간: ${currentWork.aircraft.departureTime}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
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
            const Text(
              '작업 기록',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // 절차 단계 표시
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(procedures.length, (index) {
                final isCompleted = index < _currentProcedureIndex;
                final isCurrent = index == _currentProcedureIndex;

                return Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted
                            ? Colors.green
                            : (isCurrent
                                ? const Color(0xFF4B5EFC)
                                : Colors.grey.shade300),
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
            const SizedBox(height: 24),
            // 현재 작업
            const Text(
              '현재 작업',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // 현재 작업명
            Text(
              procedures[_currentProcedureIndex].name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4B5EFC),
              ),
              textAlign: TextAlign.center,
            ),

            // ElevatedButton(
            //     onPressed: () async {
            //       await GServiceSSE.innerTest();
            //     },
            //     child: Text('sse connect')),
            // ElevatedButton(
            //     onPressed: () async {
            //       await GServiceSSE.disconnect();
            //     },
            //     child: Text('sse disconnect')),

            const Spacer(),
            // 현재 작업 완료 버튼
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  showConfirmationDialog(
                      context, procedures[_currentProcedureIndex].name);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4B5EFC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: const Text(
                  '현재 작업 완료',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ]);
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    await GServiceWorklist.get();
  }

  void showConfirmationDialog(BuildContext context, String procedureName) {
    showDialog(
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
                  onPressed: () {
                    Navigator.of(context).pop(); // 다이얼로그 닫기
                    completeProcedure(); // 작업 완료 처리
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
  void completeProcedure() async {
    // 여기에 작업 완료 API 호출 로직 구현
    try {
      // 현재 위치 가져오기
      // Position position = await Geolocator.getCurrentPosition();

      // 작업 완료 API 호출
      await GServiceWorklist.completeProcedure();
      if (GServiceWorklist.lastValue?.currentWork == null) {
        await Navigator.pushReplacementNamed(context, PATH.ROUTE_WORKLIST);
      }

      // 성공 메시지
      if (mounted) {
        ShowInfomationWidgets.snackbar(context, '작업이 완료되었습니다');
      }

      // 작업 목록 새로고침
    } catch (e) {
      if (mounted) {
        ShowInfomationWidgets.snackbar(context, '작업 완료 처리 중 오류가 발생했습니다: $e');
      }
    }
  }
}
