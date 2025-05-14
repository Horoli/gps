part of FlightSteps;

class MChecklistData extends CommonModel<MChecklistData> {
  final String uuid;
  final String name;
  final String description;
  bool? value; // null일 수 있으며, 사용자의 동의 여부를 나타냄

  MChecklistData({
    required this.uuid,
    required this.name,
    required this.description,
    this.value,
  });

  factory MChecklistData.fromMap(Map<String, dynamic> item) {
    return MChecklistData(
      uuid: item['uuid'] as String,
      name: item['name'] as String,
      description: item['description'] as String,
      value: item['value'] as bool?,
    );
  }

  // Agreement 객체를 JSON으로 변환하는 메서드
  @override
  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'name': name,
      'description': description,
      'value': value,
    };
  }

  // 동의 상태 업데이트 메서드
  @override
  MChecklistData copyWith({
    String? uuid,
    String? name,
    String? description,
    bool? value,
  }) {
    return MChecklistData(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      description: description ?? this.description,
      value: value ?? this.value,
    );
  }

  @override
  String toString() {
    return 'MChecklistData(uuid: $uuid, name: $name, description: $description, value: $value)';
  }
}
