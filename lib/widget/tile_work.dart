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
    bool isExtraWork = workData.type == '';
    String label = isExtraWork
        ? '${workData.name} ${workData.description}'
        : '${workData.name} (${workData.type})';
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
                  text: label,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
                const SizedBox(height: 8),
                // 출발 시간 행
                if (!isExtraWork)
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

    if (workData.state == STATE.WORKSTATE_WORKING
        //  && currentWork != null
        ) {
      return buildNavigationButton(
        context: context,
        title: '작업 진행 중',
        usePadding: false,
        routerName: PATH.ROUTE_WORK_DETAIL,
        onPressed: () async {
          // print('currentWork $currentWork');
          // print('workData ${workData}');
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
