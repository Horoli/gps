part of gps_test;

class MConfig extends CommonModel<MConfig> {
  final String name;
  final String description;
  final dynamic value;

  MConfig({
    required this.name,
    required this.description,
    required this.value,
  });

  factory MConfig.fromMap(Map<String, dynamic> item) {
    return MConfig(
      name: item['name'] as String,
      description: item['description'] as String,
      value: item['value'] as dynamic,
    );
  }

  // Agreement 객체를 JSON으로 변환하는 메서드
  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'value': value,
    };
  }

  // 동의 상태 업데이트 메서드
  @override
  MConfig copyWith({
    String? uuid,
    String? name,
    String? description,
    bool? value,
  }) {
    return MConfig(
      name: name ?? this.name,
      description: description ?? this.description,
      value: value ?? this.value,
    );
  }

  @override
  String toString() {
    return 'MChecklistData(name: $name, description: $description, value: $value)';
  }
}
