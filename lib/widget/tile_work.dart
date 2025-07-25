part of FlightSteps;

class TileWork extends StatelessWidget {
  final MWorkData workData;
  final MCurrentWork? currentWork;
  // final bool isWorking;

  const TileWork({
    super.key,
    required this.workData,
    this.currentWork,
    // required this.isWorking,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: commonDecoration,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Column(
              children: [
                // 항공편 정보 행
                buildFittedText(
                  text: '${workData.name} (${workData.type})',
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
                const SizedBox(height: 8),
                // 출발 시간 행
                buildFittedText(
                  text: '출발시간: ${workData.departureTime}',
                  color: Colors.grey,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                const SizedBox(height: 12),
                // 상태 버튼
                buildStartButton(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStartButton(BuildContext context) {
    if (workData.state == STATE.WORKSTATE_NORMAL) {
      return buildNavigationButton(
          context: context,
          title: '작업시작',
          usePadding: false,
          routerName: PATH.ROUTE_CREATE_GROUP_AIRCRAFT,
          onPressed: () async {
            await GServiceWork.select(workData: workData);
          });
    }

    if (workData.state == STATE.WORKSTATE_WORKING) {
      List<String> getUserNames = workData.users!.map((user) {
        return user.username;
      }).toList();

      int count = getUserNames.length > 1
          ? getUserNames.length - 1
          : getUserNames.length;

      String label = getUserNames.length > 1
          ? '작업 중(${getUserNames[0]} 외 $count명)'
          : '작업 중(${getUserNames[0]})';

      return buildNavigationButton(
        context: context,
        title: label,
        usePadding: false,
        routerName: PATH.ROUTE_WORK_DETAIL,
        backgroundColor:
            currentWork != null ? COLOR.MY_WORK : COLOR.NOT_MY_WORK,
        onPressed: () async {
          if (currentWork != null) {
            // GServiceWorklist.select(currentWork!);
            GServiceWorklist.selectWorkId(currentWork!.uuid);
          }
          // dynamic asd = GServiceWorklist.getWork(uuid: workData.uuid!);
          GServiceWorklist.selectWorkId(workData.uuid!);
        },
      );
    }

    return buildElevatedButton(
      onPressed: null,
      usePadding: false,
      child: const Text(
        '작업완료',
        style: TextStyle(
          fontSize: 16,
          // fontWeight: FontWeight.w500,
          // color: COLOR.WHITE,
        ),
      ),
    );
  }
}
