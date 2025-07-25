part of FlightSteps;

class ViewCreateGroupShift extends ViewCreateAbstract {
  const ViewCreateGroupShift({super.key});

  @override
  State<ViewCreateGroupShift> createState() => ViewCreateGroupShiftState();
}

class ViewCreateGroupShiftState
    extends ViewCreateAbstractState<ViewCreateGroupShift> {
  @override
  String get appBarTitle => '${TITLE.CREATE_GROUP} - ${TITLE.GROUP_SHIFT}';
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

                      print('selectedMember $selectedMember');

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
    textController.addListener(filteringQuery);
    loadData();
  }

  @override
  // TODO : replacement가 아니라, 2단계 이전의 route만 제거가 돼야함
  Widget buildNavButton() {
    return buildNavigationButtonWithCustom(
      title: '교대',
      useReplacement: true,
      onPressed: () async {
        createGroupType = createGroupTypeMap['shift'] ?? 'shift';

        MWorkingData getWork = GServiceWorklist.getWork as MWorkingData;

        List<MMember> alreadySelectedWorkers = GServiceMember.selectedMember!
            .where((user) => getWork.users!
                .any((workInUser) => user.uuid == workInUser.uuid))
            .toList();

        if (alreadySelectedWorkers.isNotEmpty) {
          ShowInformationWidgets.snackbar(context, '기존 작업자가 이미 존재합니다');
          return;
        }

        await Navigator.pushNamed(
          GNavigationKey.currentContext!,
          PATH.ROUTE_CREATE_GROUP_PLATE,
        );
      },
    );
  }

  @override
  Future<void> loadData() async {
    setState(() {
      isLoading = true;
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
  void filteringQuery() {
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
