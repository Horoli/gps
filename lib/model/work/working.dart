part of FlightSteps;

class MWorkingData extends MWorkData {
  final String plateNumber;

  MWorkingData({
    required this.plateNumber,
    super.procedures,
    required super.name,
    super.uuid,
    super.users,
    super.type,
    super.state,
    required super.departureTime,
    super.description,
  });

  // JSON에서 MWorkingData 객체로 변환하는 팩토리 생성자
  factory MWorkingData.fromMap(Map<String, dynamic> item) {
    return MWorkingData(
        uuid: item['uuid'] ?? '',
        plateNumber: item['plateNumber'] as String,
        procedures: List.from(item['procedures'] ?? [])
            .map((p) => MProcedure.fromMap(p))
            .toList(),
        name: item['name'] as String,
        users: item['users'] != null
            ? List.from(item['users']).map((u) => MUser.fromMap(u)).toList()
            : null,
        type: item['type'] ?? '',
        state: item['state'] ?? '',
        departureTime: item['departureTime'] ?? '',
        description: item['description'] ?? '');
  }

  // MWorkingData 객체를 JSON으로 변환하는 메서드
  @override
  Map<String, dynamic> toMap() {
    final baseJson = super.toMap();
    baseJson.addAll({
      'plateNumber': plateNumber,
      // 'procedures': procedures?.map((p) => p.toMap()).toList(),
    });
    return baseJson;
  }

  // 객체 복사 및 일부 필드 변경을 위한 copyWith 메서드
  @override
  MWorkingData copyWith({
    String? uuid,
    String? plateNumber,
    List<MProcedure>? procedures,
    String? name,
    String? type,
    List<MUser>? users,
    String? state,
    String? departureTime,
    String? description,
  }) {
    return MWorkingData(
        uuid: uuid ?? this.uuid,
        plateNumber: plateNumber ?? this.plateNumber,
        procedures: procedures ?? this.procedures,
        name: name ?? this.name,
        type: type ?? this.type,
        users: users ?? this.users,
        state: state ?? this.state,
        departureTime: departureTime ?? this.departureTime,
        description: description ?? this.description);
  }

  @override
  String toString() {
    return 'MWorkingData(uuid: $uuid, plateNumber: $plateNumber, procedures: $procedures, name: $name, type: $type, users: $users, state: $state, departureTime: $departureTime, description : $description)';
  }
}
