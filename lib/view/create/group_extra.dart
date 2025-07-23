part of FlightSteps;

class ViewCreateGroupExtra extends ViewCreateAbstract {
  const ViewCreateGroupExtra({super.key});

  @override
  State<ViewCreateGroupExtra> createState() => ViewCreateGroupExtraState();
}

class ViewCreateGroupExtraState
    extends ViewCreateAbstractState<ViewCreateGroupExtra> {
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
    return buildElevatedButton(
      child: Text('test'),
      onPressed: () async {
        List<MMember> members = GServiceMember.selectedMember ?? [];

        await GServiceExtraWork.create(
            members: members.map((e) => e.uuid).toList());
        // 무조건 빈값을 set해줘야 함
        GServiceExtraWork.selectedStream.sink([]);
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
