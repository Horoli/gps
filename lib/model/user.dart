part of FlightSteps;

class MUser extends CommonModel<MUser> {
  final String uuid;
  final String username;
  final String phoneNumber;
  final String? employeeId;
  final List<String>? groups;

  MUser({
    required this.uuid,
    required this.username,
    required this.phoneNumber,
    required this.employeeId,
    required this.groups,
  });

  // JSON에서 User 객체로 변환하는 팩토리 생성자
  factory MUser.fromMap(Map<String, dynamic> item) {
    return MUser(
      uuid: item['uuid'] as String,
      username: item['username'] as String,
      phoneNumber: item['phoneNumber'] as String,
      employeeId: item['employeeId'] ?? '',
      groups: List<String>.from(item['groups'] ?? []),
    );
  }

  // User 객체를 JSON으로 변환하는 메서드
  @override
  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'username': username,
      'phoneNumber': phoneNumber,
      'employeeId': employeeId,
      'groups': groups,
    };
  }

  // 디버깅을 위한 toString 메서드
  @override
  String toString() {
    return 'User(uuid: $uuid, username: $username, phoneNumber: $phoneNumber, employeeId: $employeeId, groups: $groups)';
  }

  // 객체 복사 및 일부 필드 변경을 위한 copyWith 메서드
  @override
  MUser copyWith({
    String? uuid,
    String? username,
    String? phoneNumber,
    String? employeeId,
    List<String>? groups,
  }) {
    return MUser(
      uuid: uuid ?? this.uuid,
      username: username ?? this.username,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      employeeId: employeeId ?? this.employeeId,
      groups: groups ?? this.groups,
    );
  }

  // 동등성 비교를 위한 equals 및 hashCode 오버라이드
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MUser &&
        other.uuid == uuid &&
        other.username == username &&
        other.phoneNumber == phoneNumber &&
        other.employeeId == employeeId &&
        listEquals(other.groups, groups);
  }

  @override
  int get hashCode {
    return uuid.hashCode ^
        username.hashCode ^
        phoneNumber.hashCode ^
        employeeId.hashCode ^
        groups.hashCode;
  }
}

// listEquals 함수 정의 (flutter/foundation.dart에서 import 가능)
bool listEquals<T>(List<T>? a, List<T>? b) {
  if (a == null) return b == null;
  if (b == null || a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
