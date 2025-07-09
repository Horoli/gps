part of FlightSteps;

class ViewCreateAircraft extends ViewCreateAbstract {
  const ViewCreateAircraft({super.key});

  @override
  State<ViewCreateAircraft> createState() => ViewCreateAircraftState();
}

class ViewCreateAircraftState
    extends ViewCreateAbstractState<ViewCreateAircraft> {
  @override
  Widget buildContent() {
    return StreamBuilder<List<MWorkData>>(
      stream: GServiceWork.availableStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return StreamExceptionWidgets.noData(
            title: 'No available aircrafts',
            context: context,
          );
        }

        final List<MWorkData> aircrafts = snapshot.data!;

        return ListView.builder(
          itemCount: aircrafts.length,
          itemBuilder: (context, index) {
            final MWorkData aircraft = aircrafts[index];
            bool isSelected = GServiceWork.isSelected(aircraft);
            return ListTile(
              title:
                  buildFittedText(text: '${aircraft.name}(${aircraft.type})'),
              textColor: isSelected ? COLOR.BASE : null,
              subtitle: Text('Departure Time: ${aircraft.departureTime}'),
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
  Widget buildNavigationButton() {
    return buildNavigationButtonWithDialog(
      // context: context,
      title: '완료',
      onPressed: () async {
        // 완료 버튼 클릭 시 동작 구현
      },
    );
  }

  @override
  Future<void> loadData() async {
    await GServiceWork.getAvailableWorks();
  }

  @override
  void dispose() {
    // GServiceWork.dispose();
    super.dispose();
  }
}
