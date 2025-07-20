part of FlightSteps;

class ServiceMember extends CommonService {
  static ServiceMember? _instance;
  factory ServiceMember.getInstance() =>
      _instance ??= ServiceMember._internal();

  ServiceMember._internal();

  final BehaviorSubject<List<MMember>> _selectedSubject =
      BehaviorSubject<List<MMember>>.seeded([]);

  Stream<List<MMember>> get stream => _selectedSubject.stream;

  List<MMember>? get selectedMember => _selectedSubject.valueOrNull;

  Future<List<MMember>> get() async {
    Completer<List<MMember>> completer = Completer<List<MMember>>();
    final List<String> cookies = await CookieManager.load();

    final Response response = await HttpConnector.get(
      dio: dio,
      url: '${URL.BASE_URL}/${URL.MEMBER_LIST}',
      cookies: cookies,
    );

    if (!completer.isCompleted) {
      List<MMember> result = List.from(response.data).map((e) {
        return MMember.fromMap(e);
      }).toList();

      completer.complete(result);
    }

    return completer.future;
  }

  bool isSelected(MMember member) =>
      _selectedSubject.valueOrNull!.any((item) => item.uuid == member.uuid);
  // // String selected = '${item.}_${item.departureTime}';
  // // String now = '${workData.name}_${workData.departureTime}';
  // return selected == now;
  // ;

  Future<void> select({required MMember member}) async {
    print('isSelected ${isSelected(member)}');
    if (_selectedSubject.valueOrNull == null ||
        _selectedSubject.valueOrNull!.isEmpty) {
      // 선택된 항공편이 비어있다면 새로운 리스트로 초기화
      _selectedSubject.add([member]);
      debugPrint('member selected: ${member.uuid}');
      return;
    }

    // 이미 선택된 항공편이 있는 경우, 중복 체크
    if (isSelected(member)) {
      // 이미 선택된 항공편인 경우, 리스트에서 제거
      List<MMember> droppedList = _selectedSubject.valueOrNull!
          .where((item) => item.uuid != member.uuid)
          .toList();

      _selectedSubject.add(droppedList);
      return;
    }

    // 중복되지 않는 경우에만 추가
    _selectedSubject.add([..._selectedSubject.value, member]);
    debugPrint('_selectedSubject.valueOrNull ${_selectedSubject.valueOrNull}');
  }

  Future<void> clearSelection() async {
    _selectedSubject.add([]);
  }
}
