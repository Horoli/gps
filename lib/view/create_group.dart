part of gps_test;

class ViewCreateGroup extends StatefulWidget {
  const ViewCreateGroup({super.key});

  @override
  State<ViewCreateGroup> createState() => ViewCreateGroupState();
}

class ViewCreateGroupState extends State<ViewCreateGroup> {
  final TextEditingController searchController = TextEditingController();
  List<MMember> setMembers = [];
  List<MMember> setFilteredMembers = [];
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: TITLE.CREATE_GROUP),
      body: Column(
        children: [
          // 검색 입력 필드
          buildTextField(searchController, 'search'),

          isLoading
              ? StreamExceptionWidgets.waiting(context: context)
              : setMembers.isEmpty
                  ? StreamExceptionWidgets.noData(title: '멤버가 없습니다')
                  : StreamBuilder<MMember?>(
                      stream: GServiceMember.stream,
                      builder: (context, snapshot) {
                        final selectedMember = snapshot.data;
                        return ListView.builder(
                          itemCount: setFilteredMembers.length,
                          itemBuilder: (context, index) {
                            final MMember member = setFilteredMembers[index];
                            final bool isSelected =
                                selectedMember?.uuid == member.uuid;

                            print(member);
                            print(isSelected);

                            return MemberListTile(
                              member: member,
                              isSelected: isSelected,
                              onPressed: () async {
                                await GServiceMember.select(member: member);
                              },
                            );
                          },
                        );
                      }).expand(),

          buildNavigationButtonWithDialog(
            // context: context,
            title: '완료',
            onPressed: () async {
              // bool useReplacement = true;
              if (GServiceMember.selectedMember == null) {
                await ShowInfomationWidgets.errorDialog(
                  context,
                  '멤버를 선택하세요',
                );
                return;
              }

              // TODO : geolocation
              // Position position = await Geolocator.getCurrentPosition();
              // print(position.longitude);

              print(GServiceMember.selectedMember!.uuid);
              await GServiceWork.create(
                  members: [GServiceMember.selectedMember!.uuid]);

              await GServiceWorklist.get();

              // useReplacement
              // ?
              await Navigator.pushReplacementNamed(
                  context, PATH.ROUTE_WORK_DETAIL);
              // : await Navigator.pushNamed(context, PATH.ROUTE_WORK_DETAIL);
            },
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    searchController.addListener(filterMembers);
    getData();
  }

  Future<void> getData() async {
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
    GServiceMember.clearSelection();
    super.dispose();
  }
}
