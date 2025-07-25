part of FlightSteps;

class ViewCreatePlate extends ViewCreateAbstract {
  const ViewCreatePlate({super.key});

  @override
  State<ViewCreatePlate> createState() => ViewCreatePlateState();
}

class ViewCreatePlateState extends ViewCreateAbstractState<ViewCreatePlate> {
  CustomStream<List<String>> streamController =
      CustomStream<List<String>>(initValue: []);

  String selectedPlate = '';

  @override
  String get textFieldValue => '차량번호 입력';

  @override
  int get textFieldMaxLength => 4;

  @override
  String get appBarTitle => '${TITLE.CREATE_GROUP} - ${TITLE.GROUP_PLATE}';

  @override
  void onSubmitted(String value) {
    setState(() {
      selectedPlate = value;
    });
  }

  @override
  Widget buildContent() {
    return StreamBuilder<List<String>>(
      stream: streamController.browse,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return StreamExceptionWidgets.noData(
            title: 'No available plates',
            context: context,
            useToWorkList: false,
          );
        }

        final List<String> plates = snapshot.data!;

        return ListView.separated(
          separatorBuilder: (context, index) => const Divider(),
          itemCount: plates.length,
          itemBuilder: (context, index) {
            final String plate = plates[index];
            bool isSelected = plate == selectedPlate;

            return ListTile(
              onTap: () {
                setState(() {
                  selectedPlate = plate;
                  textController.text = plate;
                });
              },
              title: Text(plate),
              textColor: isSelected ? COLOR.BASE : null,
            );
          },
        );
      },
    );
  }

  @override
  Widget buildNavButton() {
    return buildNavigationButton(
        context: context,
        title: '작업시작',
        useReplacement: true,
        routerName: PATH.ROUTE_WORK_DETAIL,
        onPressed: () async {
          List<MMember> members = GServiceMember.selectedMember ?? [];

          List<MCurrentWork?> results = [];

          if (createGroupType == createGroupTypeMap['shift']) {
            await createShift(members);
            await setPreferences();
            return;
          }

          if (createGroupType == createGroupTypeMap['default']) {
            results = await createDefault(members);
          } else if (createGroupType == createGroupTypeMap['extra']) {
            results = await createExtra(members);
          }

          if (results.isEmpty) return;

          GServiceWorklist.selectWorkId(results[0]!.uuid);
          await setPreferences();
        });
  }

  Future<List<MCurrentWork?>> createDefault(List<MMember> members) async {
    return await GServiceWork.create(
      members: members.map((e) => e.uuid).toList(),
      plateNumber: textController.text,
    );
  }

  Future<void> createShift(List<MMember> members) async {
    await GServiceWork.shift(
      members: members.map((e) => e.uuid).toList(),
      works: [GServiceWorklist.selectedUuidLastValue],
      plateNumber: textController.text,
    );

    dynamic getWork = GServiceWorklist.getWorkByDivision(
        uuid: GServiceWorklist.selectedUuidLastValue);

    if (getWork == null) return;

    GServiceWorklist.selectWorkId(GServiceWorklist.selectedUuidLastValue);
  }

  Future<List<MCurrentWork?>> createExtra(List<MMember> members) async {
    return await GServiceExtraWork.create(
      members: members.map((e) => e.uuid).toList(),
      plateNumber: textController.text,
    );
  }

  Future<void> setPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> plates = prefs.getStringList('plates') ?? [];

    plates.add(textController.text);
    final List<String> platesResult = Set<String>.from(plates).toList();

    await prefs.setStringList('plates', platesResult);
    streamController.sink(platesResult);
    textController.text = '';
  }

  @override
  Future<void> loadData() async {
    // TODO : localStorage에서 plate list를 불러와서
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> plates = prefs.getStringList('plates') ?? [];

    streamController.sink(plates);

    if (createGroupType == createGroupTypeMap['shift']) {
      MWorkingData getWorkingData = GServiceWorklist.getWork as MWorkingData;
      // Shift 작업을 위한 초기화
      setState(() {
        textController.text = getWorkingData.plateNumber;
        selectedPlate = getWorkingData.plateNumber;
      });
    }
  }

  @override
  void dispose() {
    streamController.dispose();
    textController.dispose();
    super.dispose();
  }
}
