part of FlightSteps;

class MMember extends CommonModel<MMember> {
  final String uuid;
  final String username;
  final String phoneNumber;
  final List works;

  MMember({
    required this.uuid,
    required this.username,
    required this.phoneNumber,
    required this.works,
  });

  factory MMember.fromMap(Map<String, dynamic> item) {
    return MMember(
        uuid: item['uuid'] as String,
        username: item['username'] as String,
        phoneNumber: item['phoneNumber'] as String,
        works: List.from(item['works'] ?? []));
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'username': username,
      'phoneNumber': phoneNumber,
      'works': works
    };
  }

  @override
  MMember copyWith(
      {String? uuid, String? username, String? phoneNumber, List? works}) {
    return MMember(
      uuid: uuid ?? this.uuid,
      username: username ?? this.username,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      works: works ?? this.works,
    );
  }

  @override
  String toString() {
    return 'MMember(uuid: $uuid, username: $username, phoneNumber: $phoneNumber, works: $works)';
  }
}
