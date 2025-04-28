part of gps_test;

class TileWork extends StatelessWidget {
  final MWorkData workItem;
  final bool isFirst;

  const TileWork({
    super.key,
    required this.workItem,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            children: [
              // 항공편 정보 행
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '편명: ${workItem.name}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '기종: ${workItem.type}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // 출발 시간 행
              Text(
                '출발시간: ${workItem.departureTime}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),

              // 상태 버튼
              // _buildStatusButton(context),
              buildNavigationButton(
                  context: context,
                  title: '작업시작',
                  routerName: PATH.ROUTE_CREATE_GROUP,
                  onPressed: () async {
                    await GServiceWork.select(workData: workItem);
                  })
            ],
          ),
        ),
        // 구분선
        const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
      ],
    );
  }
}
