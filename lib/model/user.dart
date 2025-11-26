part of FlightSteps;

class MUserConfig {
  final List<String> functionEnabled;

  MUserConfig({required this.functionEnabled});

  // 빈 설정 생성
  factory MUserConfig.empty() => MUserConfig(functionEnabled: []);

  factory MUserConfig.fromMap(Map<String, dynamic> map) {
    return MUserConfig(
      // JSON의 리스트는 List<dynamic>으로 오기 때문에 List<String>으로 안전하게 변환
      functionEnabled: List<String>.from(map['functionEnabled'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'functionEnabled': functionEnabled,
    };
  }

  @override
  String toString() => 'MConfig(functionEnabled: $functionEnabled)';

  // Config 동등성 비교
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MUserConfig &&
        listEquals(other.functionEnabled, functionEnabled);
  }

  @override
  int get hashCode => functionEnabled.hashCode;
}

class MUser extends CommonModel<MUser> {
  final String uuid;
  final String username;
  final String phoneNumber;
  final String? employeeId;
  final List<String>? groups;
  final MUserConfig config; // Map 대신 MConfig 객체 사용

  MUser({
    required this.uuid,
    required this.username,
    required this.phoneNumber,
    required this.employeeId,
    required this.groups,
    required this.config,
  });

  // 편의성을 위한 Getter (선택 사항)
  // user.config.functionEnabled 대신 user.functionEnabled로 바로 접근 가능
  List<String> get functionEnabled => config.functionEnabled;

  factory MUser.fromMap(Map<String, dynamic> item) {
    return MUser(
      uuid: item['uuid'] as String,
      username: item['username'] as String,
      phoneNumber: item['phoneNumber'] as String,
      employeeId: item['employeeId'], // null일 수 있으므로 그대로 둠 (필요시 ?? '' 처리)
      groups: List<String>.from(item['groups'] ?? []),
      // config가 null일 경우를 대비해 빈 객체 처리
      config: item['config'] != null
          ? MUserConfig.fromMap(item['config'] as Map<String, dynamic>)
          : MUserConfig.empty(),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'username': username,
      'phoneNumber': phoneNumber,
      'employeeId': employeeId,
      'groups': groups,
      'config': config.toMap(), // MConfig의 toMap 호출
    };
  }

  @override
  String toString() {
    return 'User(uuid: $uuid, username: $username, phoneNumber: $phoneNumber, employeeId: $employeeId, groups: $groups, config: $config)';
  }

  @override
  MUser copyWith({
    String? uuid,
    String? username,
    String? phoneNumber,
    String? employeeId,
    List<String>? groups,
    MUserConfig? config, // 타입 변경
  }) {
    return MUser(
      uuid: uuid ?? this.uuid,
      username: username ?? this.username,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      employeeId: employeeId ?? this.employeeId,
      groups: groups ?? this.groups,
      config: config ?? this.config,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MUser &&
        other.uuid == uuid &&
        other.username == username &&
        other.phoneNumber == phoneNumber &&
        other.employeeId == employeeId &&
        listEquals(other.groups, groups) &&
        other.config == config; // config 비교 추가
  }

  @override
  int get hashCode {
    return uuid.hashCode ^
        username.hashCode ^
        phoneNumber.hashCode ^
        employeeId.hashCode ^
        groups.hashCode ^
        config.hashCode; // config 해시코드 추가
  }
}

// listEquals는 기존 그대로 사용 (Flutter 환경이라면 foundation.dart import 권장)
bool listEquals<T>(List<T>? a, List<T>? b) {
  if (a == null) return b == null;
  if (b == null || a.length != b.length) return false;
  if (identical(a, b)) return true;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
