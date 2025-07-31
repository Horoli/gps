part of FlightSteps;

class ViewCreateGroup extends ViewCreateAbstract {
  const ViewCreateGroup({super.key});

  @override
  State<ViewCreateGroup> createState() => ViewCreateGroupState();
}

class ViewCreateGroupState extends ViewCreateAbstractState<ViewCreateGroup> {
  @override
  String get appBarTitle => '${TITLE.CREATE_GROUP} - ${TITLE.GROUP_MEMEBERS}';

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
    textController.addListener(filterMembers);
    loadData();
  }

  @override
  Widget buildNavButton() {
    return buildNavigationButtonWithCustom(
      // context: context,
      title: '완료',
      // useReplacement: true,
      // routerName: PATH.ROUTE_CREATE_GROUP_PLATE,
      onPressed: () async {
        // if (GServiceMember.selectedMember!.isEmpty) {
        //   return ShowInformationWidgets.snackbar(
        //     context,
        //     '선택된 인원이 없습니다',
        //   );
        // }
        createGroupType = createGroupTypeMap['default'] ?? 'default';
        await CustomNavigator.pushNamed(
          PATH.ROUTE_CREATE_GROUP_PLATE,
        );
        // List<MMember> members = GServiceMember.selectedMember ?? [];

        // List<MCurrentWork?> results = await GServiceWork.create(
        //     members: members.map((e) => e.uuid).toList());
        // print('GServiceWork step 3 $results');

        // if (results.isEmpty) return;

        // GServiceWorklist.selectWorkId(results[0]!.uuid);
      },
    );
  }

  @override
  Future<void> loadData() async {
    setState(() {
      isLoading = true;
      print('GServiceWork.selectedWorks ${GServiceWork.selectedWorks}');
      // isShift = GServiceWork.selectedWorks.isEmpty ? true : false;
      // isExtraWork = GServiceExtraWork.selectedStream.hasValue;
      // print('isExtraWork $isExtraWork');
      // print(GServiceExtraWork.selectedStream.lastValue);
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
    final String query = textController.text.toLowerCase();
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
    textController.dispose();
    super.dispose();
  }
}
