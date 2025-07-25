part of FlightSteps;

class MWorkData extends CommonModel<MWorkData> {
  final String? uuid;
  final String name; // 항공편 번호 (예: LJ221)
  final List<MProcedure>? procedures;
  final List<MUser>? users;
  final String? type; // 항공기 타입 (예: 738)
  final String? state; // 상태 (예: normal)
  final String departureTime; // 출발 시간 (예: 0715)
  final String? description;

  MWorkData({
    this.uuid,
    required this.name,
    this.procedures,
    this.users,
    this.type,
    this.state,
    required this.departureTime,
    this.description,
  });

  // JSON에서 Work 객체로 변환하는 팩토리 생성자
  factory MWorkData.fromMap(Map<String, dynamic> item) {
    return MWorkData(
        uuid: item['uuid'] ?? '',
        name: item['name'] as String,
        procedures: List.from(item['procedures'] ?? [])
            .map((p) => MProcedure.fromMap(p))
            .toList(),
        users: List.from(item['users'] ?? [])
            .map((u) => MUser.fromMap(u))
            .toList(),
        type: item['type'] ?? '',
        state: item['state'] ?? '',
        departureTime: item['departureTime'] ?? '',
        description: item['description'] ?? '');
  }

  // Work 객체를 JSON으로 변환하는 메서드
  @override
  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'name': name,
      'procedures': procedures?.map((p) => p.toMap()).toList(),
      'users': users,
      'type': type,
      'state': state,
      'departureTime': departureTime,
      'description': description,
    };
  }

  // 객체 복사 및 일부 필드 변경을 위한 copyWith 메서드
  @override
  MWorkData copyWith({
    String? uuid,
    String? name,
    String? type,
    List<MProcedure>? procedures,
    List<MUser>? users,
    String? state,
    String? departureTime,
    String? description,
  }) {
    return MWorkData(
      uuid: uuid ?? this.uuid,
      procedures: procedures ?? this.procedures,
      name: name ?? this.name,
      type: type ?? this.type,
      users: users ?? this.users,
      state: state ?? this.state,
      departureTime: departureTime ?? this.departureTime,
      description: description ?? this.description,
    );
  }

  @override
  String toString() {
    return 'Work(uuid: $uuid, name: $name, type: $type, users: $users, state: $state, departureTime: $departureTime, procedures: $procedures, description: $description)';
  }
}
