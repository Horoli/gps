part of FlightSteps;

class MExtraWorkData extends CommonModel<MExtraWorkData> {
  final String uuid;
  final String name;
  final List<String> step;

  MExtraWorkData({
    required this.uuid,
    required this.name,
    required this.step,
  });

  factory MExtraWorkData.fromMap(Map<String, dynamic> item) {
    return MExtraWorkData(
      uuid: item['uuid'] as String,
      name: item['name'] as String,
      step: (item['step'] as List<dynamic>).map((e) => e as String).toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = {
      'uuid': uuid,
      'name': name,
      'step': step,
    };
    return result;
  }

  @override
  MExtraWorkData copyWith({
    String? uuid,
    String? name,
    List<String>? step,
  }) {
    return MExtraWorkData(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      step: step ?? this.step,
    );
  }

  @override
  String toString() {
    return 'MExtraWork(uuid: $uuid, name: $name, step: $step)';
  }
}
