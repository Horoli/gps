part of FlightSteps;

class TileWork extends StatelessWidget {
  final MWorkData workItem;

  const TileWork({
    super.key,
    required this.workItem,
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
                Text(
                  '${workItem.name}(${workItem.type})',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                // 출발 시간 행
                Text(
                  '출발시간: ${workItem.departureTime}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
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
    if (workItem.state == STATE.WORKSTATE_NORMAL) {
      return buildNavigationButton(
          context: context,
          title: '작업시작',
          usePadding: false,
          routerName: PATH.ROUTE_CREATE_GROUP,
          onPressed: () async {
            await GServiceWork.select(workData: workItem);
          });
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: COLOR.SELECTED,
      alignment: Alignment.center,
      child: const Text(
        '작업완료',
        style: TextStyle(
          color: COLOR.WHITE,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
    // return Container(child: Text('${workItem.state}'));
  }
}
