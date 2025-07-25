part of FlightSteps;

class TileExtraWork extends StatelessWidget {
  final MExtraWorkData extraWorkItem;

  const TileExtraWork({
    super.key,
    required this.extraWorkItem,
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
                buildFittedText(
                  text: extraWorkItem.name,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
                const SizedBox(height: 8),
                buildFittedText(
                  text: extraWorkItem.description,
                  color: Colors.grey,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                const SizedBox(height: 12),
                buildStartButton(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStartButton(BuildContext context) {
    if (extraWorkItem.state == '') {
      return buildNavigationButton(
        context: context,
        title: '작업시작',
        usePadding: false,
        routerName: PATH.ROUTE_CREATE_GROUP_EXTRA,
        onPressed: () async {
          print('extraWorkItem $extraWorkItem');
          GServiceExtraWork.selectedStream.sink([extraWorkItem.uuid]);
        },
      );
    }

    if (extraWorkItem.state == STATE.WORKSTATE_WORKING) {
      print('extraWorkItem $extraWorkItem');

      List<String> getUserNames = extraWorkItem.users!.map((user) {
        return user.username;
      }).toList();

      List<MUser> myWorks = extraWorkItem.users!.where((e) {
        return e.uuid == GServiceUser.getUuid;
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
        backgroundColor: myWorks.isNotEmpty ? COLOR.MY_WORK : COLOR.NOT_MY_WORK,
        routerName: PATH.ROUTE_WORK_DETAIL,
        onPressed: () async {
          GServiceWorklist.selectWorkId(extraWorkItem.uuid);
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
