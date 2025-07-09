part of FlightSteps;

abstract class ViewCreateAbstract extends StatefulWidget {
  const ViewCreateAbstract({super.key});

  @override
  State<ViewCreateAbstract> createState();
}

class ViewCreateAbstractState<T extends ViewCreateAbstract> extends State<T> {
  final TextEditingController searchController = TextEditingController();
  List<MMember> setMembers = [];
  List<MMember> setFilteredMembers = [];

  bool isLoading = true;

  PreferredSizeWidget appBar = commonAppBar(title: TITLE.CREATE_GROUP);

  Widget buildContent() {
    throw UnimplementedError(
        'buildContent() must be implemented in the subclass');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: Column(
        children: [
          // 검색 입력 필드
          buildTextField(searchController, 'search'),
          buildContent().expand(),
          buildNavButton(),
          // buildNavigationButtonWithDialog(
          //   // context: context,
          //   title: '완료',
          //   onPressed: () async {
          //     // 완료 버튼 클릭 시 동작 구현
          //   },
          // ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // 초기 데이터 로딩
    loadData();
  }

  Widget buildNavButton() {
    throw UnimplementedError('navigationButton must be implemented');
  }

  // 데이터 로딩 로직 구현
  // 예: setMembers = await fetchMembers();
  Future<void> loadData() async {
    throw UnimplementedError('loadData() must be implemented in the subclass');
  }
}
