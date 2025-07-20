part of FlightSteps;

class ViewCreateGroup extends ViewCreateAbstract {
  const ViewCreateGroup({super.key});

  @override
  State<ViewCreateGroup> createState() => ViewCreateGroupState();
}

class ViewCreateGroupState extends ViewCreateAbstractState<ViewCreateGroup> {
  // final TextEditingController searchController = TextEditingController();
  // List<MMember> setMembers = [];
  // List<MMember> setFilteredMembers = [];
  // bool isLoading = true;

  bool isShift = false;

  @override
  Widget buildContent() {
    return isLoading
        ? StreamExceptionWidgets.waiting(context: context)
        : setMembers.isEmpty
            ? StreamExceptionWidgets.noData(
                title: '멤버가 없습니다',
                context: context,
              )
            : StreamBuilder<List<MMember>>(
                stream: GServiceMember.stream,
                builder: (context, snapshot) {
                  final List<MMember> selectedMember = snapshot.data ?? [];
                  return ListView.separated(
                    separatorBuilder: (context, index) => SIZE.DIVIDER,
                    itemCount: setFilteredMembers.length,
                    itemBuilder: (context, index) {
                      final MMember member = setFilteredMembers[index];

                      print(selectedMember);

                      final bool isSelected = GServiceMember.isSelected(member);

                      return MemberListTile(
                        member: member,
                        isSelected: isSelected,
                        onPressed: () async {
                          await GServiceMember.select(member: member);
                        },
                      );
                    },
                  );
                },
              );
  }

  @override
  void initState() {
    super.initState();
    searchController.addListener(filterMembers);
    loadData();
  }

  @override
  // TODO : replacement가 아니라, 2단계 이전의 route만 제거가 돼야함
  Widget buildNavButton() {
    if (isShift) {
      return buildNavigationButton(
        context: context,
        title: '교대',
        useReplacement: true,
        routerName: PATH.ROUTE_WORK_DETAIL,
        onPressed: () async {
          List<MMember> members = GServiceMember.selectedMember ?? [];

          print('shift button step 1');
          await GServiceWork.shift(
            members: members.map((e) => e.uuid).toList(),
            works: [GServiceWorklist.selectedUuidLastValue],
          );
          print('shift button step 2');

          // await GServiceWorklist.get();

          print('shift button step 3');
          dynamic getWork = GServiceWorklist.getWorkByDivision(
              uuid: GServiceWorklist.selectedUuidLastValue);

          print('shift button step 4 $getWork');
          if (getWork == null) return;

          // GServiceWorklist.select(getWork);
          GServiceWorklist.selectWorkId(GServiceWorklist.selectedUuidLastValue);
        },
      );
    }

    return buildNavigationButton(
      context: context,
      title: '완료',
      useReplacement: true,
      routerName: PATH.ROUTE_WORK_DETAIL,
      onPressed: () async {
        List<MMember> members = GServiceMember.selectedMember ?? [];

        List<MCurrentWork?> results = await GServiceWork.create(
            members: members.map((e) => e.uuid).toList());
        print('GServiceWork step 3 $results');

        if (results.isEmpty) return;

        // GServiceWorklist.select(results[0]!);
        GServiceWorklist.selectWorkId(results[0]!.uuid);
      },
    );
  }

  @override
  Future<void> loadData() async {
    setState(() {
      isLoading = true;
      print('GServiceWork.selectedWorks ${GServiceWork.selectedWorks}');
      isShift = GServiceWork.selectedWorks.isEmpty ? true : false;
      print('isShift $isShift');
    });

    try {
      final List<MMember> members = await GServiceMember.get();

      setState(() {
        setMembers = members;
        setFilteredMembers = members;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  // 검색어 필터링
  void filterMembers() {
    final String query = searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        setFilteredMembers = setMembers;
      } else {
        setFilteredMembers = setMembers.where((member) {
          return member.username.toLowerCase().contains(query) ||
              member.phoneNumber.contains(query);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
