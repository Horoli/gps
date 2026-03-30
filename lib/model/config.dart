part of FlightSteps;

class MConfig extends CommonModel<MConfig> {
  final String name;
  final String description;
  final String value;
  final String? options;

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
      value: item['value'].toString(),
      options: item['options']?.toString(),
    );
  }

  // Agreement 객체를 JSON으로 변환하는 메서드
  @override
  Map<String, dynamic> toMap() {
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
    String? value,
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
