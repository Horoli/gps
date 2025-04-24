part of gps_test;

class MChecklist {
  final String uuid;
  final String name;
  final String description;
  bool? value; // null일 수 있으며, 사용자의 동의 여부를 나타냄

  MChecklist({
    required this.uuid,
    required this.name,
    required this.description,
    this.value,
  });

  factory MChecklist.fromMap(Map<String, dynamic> item) {
    return MChecklist(
      uuid: item['uuid'] as String,
      name: item['name'] as String,
      description: item['description'] as String,
      value: item['value'] as bool?,
    );
  }

  // Agreement 객체를 JSON으로 변환하는 메서드
  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'name': name,
      'description': description,
      'value': value,
    };
  }

  // 동의 상태 업데이트 메서드
  MChecklist copyWithValue(bool? newValue) {
    return MChecklist(
      uuid: uuid,
      name: name,
      description: description,
      value: newValue,
    );
  }

  @override
  String toString() {
    return 'Agreement(uuid: $uuid, name: $name, description: $description, value: $value)';
  }
}
