part of FlightSteps;

class MExtraWorkData extends CommonModel<MExtraWorkData> {
  final String uuid;
  final String name;
  final String description; // 기본값으로 '추가 작업' 설정
  String? state;
  final List<String> step;

  MExtraWorkData({
    required this.uuid,
    required this.name,
    required this.description,
    required this.step,
    this.state,
  });

  factory MExtraWorkData.fromMap(Map<String, dynamic> item) {
    return MExtraWorkData(
      uuid: item['uuid'] ?? '',
      name: item['name'] ?? '',
      description: item['description'] ?? '',
      // step: (item['step'] ?? []).map((e) => e as String).toList(),
      step: List.from(item['step'] ?? []),
      state: item['state'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> result = {
      'uuid': uuid,
      'name': name,
      'description': description,
      'step': step,
      'state': state,
    };
    return result;
  }

  @override
  MExtraWorkData copyWith({
    String? uuid,
    String? name,
    String? description,
    List<String>? step,
    String? state,
  }) {
    return MExtraWorkData(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      description: description ?? this.description,
      step: step ?? this.step,
      state: state ?? this.state,
    );
  }

  @override
  String toString() {
    return 'MExtraWork(uuid: $uuid, name: $name, description: $description, step: $step, state: $state)';
  }
}
