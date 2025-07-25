part of FlightSteps;

abstract class ViewCreateAbstract extends StatefulWidget {
  const ViewCreateAbstract({super.key});

  @override
  State<ViewCreateAbstract> createState();
}

class ViewCreateAbstractState<T extends ViewCreateAbstract> extends State<T> {
  final TextEditingController textController = TextEditingController();
  List<MMember> setMembers = [];
  List<MMember> setFilteredMembers = [];

  List<MWorkData> setWorks = [];
  List<MWorkData> setFilteredWorks = [];

  bool isLoading = true;
  String get textFieldValue => 'search';
  int get textFieldMaxLength => 20;

  String get appBarTitle =>
      throw UnimplementedError('title must be implemented in the subclass');

  late PreferredSizeWidget appBar = commonAppBar(title: appBarTitle);

  Widget buildContent() {
    throw UnimplementedError(
        'buildContent() must be implemented in the subclass');
  }

  void onSubmitted(String value) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          // 검색 입력 필드
          buildSearchTextField(
            controller: textController,
            hint: textFieldValue,
            maxLength: textFieldMaxLength,
            onSubmitted: (String value) => onSubmitted(value),
          ),
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
