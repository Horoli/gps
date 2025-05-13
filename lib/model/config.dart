part of gps_test;

class MConfig extends CommonModel<MConfig> {
  final String name;
  final String description;
  final dynamic value;
  final dynamic? options;

  MConfig({
    required this.name,
    required this.description,
    required this.value,
    this.options,
  });

  factory MConfig.fromMap(Map<String, dynamic> item) {
    return MConfig(
      name: item['name'] as String,
      description: item['description'] as String,
      value: item['value'] as dynamic,
      options: item['options'] as dynamic,
    );
  }

  // Agreement 객체를 JSON으로 변환하는 메서드
  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'value': value,
      'options': options,
    };
  }

  // 동의 상태 업데이트 메서드
  @override
  MConfig copyWith({
    String? uuid,
    String? name,
    String? description,
    String? options,
    bool? value,
  }) {
    return MConfig(
      name: name ?? this.name,
      description: description ?? this.description,
      value: value ?? this.value,
      options: options ?? this.options,
    );
  }

  @override
  String toString() {
    return 'MConfig(name: $name, description: $description, value: $value, options: $options)';
  }
}
