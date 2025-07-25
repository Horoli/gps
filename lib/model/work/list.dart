part of FlightSteps;

class MWorkList extends CommonModel<MWorkList> {
  final List<MCurrentWork> currentWork;
  final List<MExtraWorkData> extraWorkList;
  final List<MWorkData> workList;
  final List<String> step;
  final String date;

  MWorkList({
    required this.currentWork,
    required this.extraWorkList,
    required this.workList,
    required this.step,
    required this.date,
  });

  // JSON에서 MWorkList 객체로 변환하는 팩토리 생성자
  factory MWorkList.fromMap(Map<String, dynamic> item) {
    // final MCurrentWork? parsedCurrentWork =
    //     item.containsKey('currentWork') && item['currentWork'] != null
    //         ? MCurrentWork.fromMap(item['currentWork'] as Map<String, dynamic>)
    //         : null;

    return MWorkList(
      currentWork: (item['currentWork'] as List<dynamic>)
          .map((currentWork) =>
              MCurrentWork.fromMap(currentWork as Map<String, dynamic>))
          .toList(),
      extraWorkList: (item['extraWorkList'] as List<dynamic>)
          .map((extraworkJson) =>
              MExtraWorkData.fromMap(extraworkJson as Map<String, dynamic>))
          .toList(),
      workList: (item['workList'] as List<dynamic>).map((workJson) {
        final workMap = workJson as Map<String, dynamic>;
        final state = workMap['state'] as String?;

        // state가 'working'인 경우 MWorkingData로 파싱
        if (state == 'working') {
          return MWorkingData.fromMap(workMap);
        } else {
          // 그 외의 경우 (normal, null 등) MWorkData로 파싱
          return MWorkData.fromMap(workMap);
        }
      }).toList(),
      // (workJson) => MWorkData.fromMap(workJson as Map<String, dynamic>))
      // .toList(),
      step: (item['step'] as List<dynamic>).map((e) => e as String).toList(),
      date: item['date'] as String,
    );
  }

  // MWorkList 객체를 JSON으로 변환하는 메서드
  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> result = {
      'currentWork': currentWork.map((cur) => cur.toMap()).toList(),
      'extraWorkList': extraWorkList.map((extra) => extra.toMap()).toList(),
      'workList': workList.map((work) => work.toMap()).toList(),
      'step': step,
      'date': date,
    };

    return result;
  }

  @override
  MWorkList copyWith({
    List<MCurrentWork>? currentWork,
    List<MExtraWorkData>? extraWorkList,
    List<MWorkData>? workList,
    List<String>? step,
    String? date,
  }) {
    return MWorkList(
      currentWork: currentWork ?? this.currentWork,
      extraWorkList: extraWorkList ?? this.extraWorkList,
      workList: workList ?? this.workList,
      step: step ?? this.step,
      date: date ?? this.date,
    );
  }

  @override
  String toString() {
    return 'MWorkList(extraWorkList: $extraWorkList, workList: $workList, step: $step, date: $date)';
  }

  // 날짜를 DateTime으로 변환
  DateTime getDate() {
    return DateTime.parse(date);
  }
}
