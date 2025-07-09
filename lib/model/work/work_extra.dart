part of FlightSteps;

class MExtraWorkData extends CommonModel<MExtraWorkData> {
  final String uuid;
  final String name;
  final String description; // 기본값으로 '추가 작업' 설정
  final List<String> step;

  MExtraWorkData({
    required this.uuid,
    required this.name,
    required this.description,
    required this.step,
  });

  factory MExtraWorkData.fromMap(Map<String, dynamic> item) {
    return MExtraWorkData(
      uuid: item['uuid'] as String,
      name: item['name'] as String,
      description: item['description'] as String,
      step: (item['step'] as List<dynamic>).map((e) => e as String).toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = {
      'uuid': uuid,
      'name': name,
      'description': description,
      'step': step,
    };
    return result;
  }

  @override
  MExtraWorkData copyWith({
    String? uuid,
    String? name,
    String? description,
    List<String>? step,
  }) {
    return MExtraWorkData(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      description: description ?? this.description,
      step: step ?? this.step,
    );
  }

  @override
  String toString() {
    return 'MExtraWork(uuid: $uuid, name: $name, description: $description, step: $step)';
  }
}
