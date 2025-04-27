part of gps_test;

class MWorkList extends CommonModel<MWorkList> {
  final List<MWorkData> works;
  final List<String> step;
  final String date;

  MWorkList({
    required this.works,
    required this.step,
    required this.date,
  });

  // JSON에서 MWorkList 객체로 변환하는 팩토리 생성자
  factory MWorkList.fromMap(Map<String, dynamic> item) {
    return MWorkList(
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
    return {
      'workList': works.map((work) => work.toJson()).toList(),
      'step': step,
      'date': date,
    };
  }

  @override
  MWorkList copyWith({
    List<MWorkData>? works,
    List<String>? step,
    String? date,
  }) {
    return MWorkList(
      works: works ?? this.works,
      step: step ?? this.step,
      date: date ?? this.date,
    );
  }

  @override
  String toString() {
    return 'MWorkList(works: $works, step: $step, description: $date)';
  }

  // 날짜를 DateTime으로 변환
  DateTime getDate() {
    return DateTime.parse(date);
  }
}
