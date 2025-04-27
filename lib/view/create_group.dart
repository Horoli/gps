part of gps_test;

class ViewCreateGroup extends StatefulWidget {
  const ViewCreateGroup({super.key});

  @override
  State<ViewCreateGroup> createState() => ViewCreateGroupState();
}

class ViewCreateGroupState extends State<ViewCreateGroup> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: TITLE.CREATE_GROUP),
      body: Column(
        children: [
          Center(child: Text('selected : ${GServiceWork.selectedWork}')),
          ListView.separated(
            separatorBuilder: (context, index) => const Divider(),
            itemCount: 50,
            itemBuilder: (context, index) {
              return Container(
                child: Text('$index'),
              );
            },
          ).expand(),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> get() async {
    print(GServiceWork.selectedWork);
  }
}
