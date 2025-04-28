part of gps_test;

class MMember extends CommonModel<MMember> {
  final String uuid;
  final String username;
  final String phoneNumber;

  MMember({
    required this.uuid,
    required this.username,
    required this.phoneNumber,
  });

  factory MMember.fromMap(Map<String, dynamic> item) {
    return MMember(
      uuid: item['uuid'] as String,
      username: item['username'] as String,
      phoneNumber: item['phoneNumber'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'username': username,
      'phoneNumber': phoneNumber,
    };
  }

  @override
  MMember copyWith({
    String? uuid,
    String? username,
    String? phoneNumber,
  }) {
    return MMember(
      uuid: uuid ?? this.uuid,
      username: username ?? this.username,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

  @override
  String toString() {
    return 'MMember(uuid: $uuid, username: $username, phoneNumber: $phoneNumber)';
  }
}
