part of FlightSteps;

class MWorkList extends CommonModel<MWorkList> {
  final CurrentWork? currentWork;
  final List<MWorkData> works;
  final List<String> step;
  final String date;

  MWorkList({
    this.currentWork,
    required this.works,
    required this.step,
    required this.date,
  });

  // JSON에서 MWorkList 객체로 변환하는 팩토리 생성자
  factory MWorkList.fromMap(Map<String, dynamic> item) {
    final CurrentWork? parsedCurrentWork =
        item.containsKey('currentWork') && item['currentWork'] != null
            ? CurrentWork.fromMap(item['currentWork'] as Map<String, dynamic>)
            : null;
    return MWorkList(
      currentWork: parsedCurrentWork,
      works: (item['workList'] as List<dynamic>)
          .map(
              (workJson) => MWorkData.fromMap(workJson as Map<String, dynamic>))
          .toList(),
      step: (item['step'] as List<dynamic>).map((e) => e as String).toList(),
      date: item['date'] as String,
    );
  }

  // MWorkList 객체를 JSON으로 변환하는 메서드
  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = {
      'workList': works.map((work) => work.toJson()).toList(),
      'step': step,
      'date': date,
    };

    if (currentWork != null) {
      result['currentWork'] = currentWork!.toJson();
    }

    return result;
  }

  @override
  MWorkList copyWith({
    CurrentWork? currentWork,
    List<MWorkData>? works,
    List<String>? step,
    String? date,
  }) {
    return MWorkList(
      currentWork: currentWork ?? this.currentWork,
      works: works ?? this.works,
      step: step ?? this.step,
      date: date ?? this.date,
    );
  }

  @override
  String toString() {
    return 'MWorkList(currentWork: $currentWork, works: $works, step: $step, date: $date)';
  }

  // 날짜를 DateTime으로 변환
  DateTime getDate() {
    return DateTime.parse(date);
  }
}
