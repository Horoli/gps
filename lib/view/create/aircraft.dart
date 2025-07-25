part of FlightSteps;

class ViewCreateAircraft extends ViewCreateAbstract {
  const ViewCreateAircraft({super.key});

  @override
  State<ViewCreateAircraft> createState() => ViewCreateAircraftState();
}

class ViewCreateAircraftState
    extends ViewCreateAbstractState<ViewCreateAircraft> {
  @override
  String get appBarTitle => '${TITLE.CREATE_GROUP} - ${TITLE.GROUP_AIRCRAFT}';
  @override
  Widget buildContent() {
    return StreamBuilder<List<MWorkData>>(
      stream: GServiceWork.availableSubject.browse,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return StreamExceptionWidgets.noData(
            title: 'No available aircrafts',
            context: context,
          );
        }

        // final List<MWorkData> aircrafts = snapshot.data ?? [];

        return ListView.separated(
          separatorBuilder: (context, index) => const Divider(),
          itemCount: setFilteredWorks.length,
          itemBuilder: (context, index) {
            final MWorkData aircraft = setFilteredWorks[index];
            bool isSelected = GServiceWork.isSelected(aircraft);
            return ListTile(
              // title: buildFittedText(
              //   text: '${aircraft.name}(${aircraft.type})',
              //   textAlign: TextAlign.left,
              // ),
              title: Text('${aircraft.name}(${aircraft.type})'),
              textColor: isSelected ? COLOR.BASE : null,
              subtitle: Text('출발시간: ${aircraft.departureTime}',
                  style: const TextStyle(color: Colors.grey)),
              trailing: Checkbox(
                activeColor: COLOR.BASE,
                checkColor: COLOR.WHITE,
                value: isSelected,
                onChanged: (value) async {
                  await GServiceWork.select(workData: aircraft);
                  await GServiceWork.refreshAvailableWorks();
                },
              ),
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
  Widget buildNavButton() {
    return buildNavigationButton(
      context: context,
      title: '완료',
      routerName: PATH.ROUTE_CREATE_GROUP,
      // onPressed: () {},
    );
  }

  @override
  Future<void> loadData() async {
    List<MWorkData> works = await GServiceWork.getAvailableWorks();
    setState(() {
      setWorks = works;
      setFilteredWorks = works;
    });
  }

  void filteringQuery() {
    final String query = textController.text.toUpperCase();
    setState(() {
      if (query.isEmpty) {
        setFilteredWorks = setWorks;
      } else {
        setFilteredWorks = setWorks.where((work) {
          return work.name.toUpperCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    // GServiceWork.dispose();
    super.dispose();
  }
}
