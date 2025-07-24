part of FlightSteps;
// 사용자 모델

// 현재 작업 모델 (메인 모델)
class MCurrentWork extends CommonModel<MCurrentWork> {
  final String uuid;
  final List<MUser> users;
  final MAircraftInCurrentWork? aircraft; // only default
  final MExtraWorkData? extra; // only extra
  final String type;
  final String plateNumber;
  final List<MProcedure> procedures;
  final String description;
  final DateTime date;

  MCurrentWork({
    required this.uuid,
    required this.users,
    this.aircraft,
    this.extra,
    required this.type,
    required this.procedures,
    required this.plateNumber,
    required this.description,
    required this.date,
  });

  factory MCurrentWork.fromMap(Map<String, dynamic> item) {
    print('aaaaaaaaaaaaaaaa');
    print('${item['extra']}');
    print('aaaaaaaaaaaaaaaa');
    return MCurrentWork(
      uuid: item['uuid'] as String,
      users: (item['users'] as List<dynamic>)
          .map((e) => MUser.fromMap(e as Map<String, dynamic>))
          .toList(),
      aircraft: MAircraftInCurrentWork.fromMap(item['aircraft'] ?? {}),
      extra: MExtraWorkData.fromMap(item['extra'] ?? {}),
      type: item['type'] as String,
      plateNumber: item['plateNumber'] as String,
      procedures: (item['procedures'] as List<dynamic>)
          .map((e) => MProcedure.fromMap(e as Map<String, dynamic>))
          .toList(),
      description: item['description'] as String,
      date: DateTime.parse(item['date'] as String),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'users': users.map((e) => e.toMap()).toList(),
      'aircraft': aircraft ?? {},
      'extra': extra ?? {},
      'type': type,
      'plateNumber': plateNumber,
      'procedures': procedures.map((e) => e.toMap()).toList(),
      'description': description,
      'date': date.toIso8601String(),
    };
  }

  @override
  MCurrentWork copyWith({
    String? uuid,
    List<MUser>? users,
    MAircraftInCurrentWork? aircraft,
    String? type,
    String? plateNumber,
    List<MProcedure>? procedures,
    String? description,
    MExtraWorkData? extra,
    DateTime? date,
  }) {
    return MCurrentWork(
      uuid: uuid ?? this.uuid,
      users: users ?? this.users,
      aircraft: aircraft ?? this.aircraft,
      type: type ?? this.type,
      plateNumber: plateNumber ?? this.plateNumber,
      procedures: procedures ?? this.procedures,
      description: description ?? this.description,
      date: date ?? this.date,
      extra: extra ?? this.extra,
    );
  }

  @override
  String toString() {
    return 'CurrentWork(uuid: $uuid, users: $users, aircraft: $aircraft, type: $type, procedures: $procedures, description: $description, date: $date, plateNumber: $plateNumber, extra: $extra)';
  }
}

class MUserInCurrentWork extends CommonModel<MUserInCurrentWork> {
  final String uuid;
  final String username;
  final String phoneNumber;
  final String employeeId;
  final List<String> groups;

  MUserInCurrentWork({
    required this.uuid,
    required this.username,
    required this.phoneNumber,
    required this.employeeId,
    required this.groups,
  });

  factory MUserInCurrentWork.fromMap(Map<String, dynamic> item) {
    return MUserInCurrentWork(
      uuid: item['uuid'] as String,
      username: item['username'] as String,
      phoneNumber: item['phoneNumber'] as String,
      employeeId: item['employeeId'] as String,
      groups: List<String>.from(item['groups'] as List),
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
    };
  }

  @override
  MUserInCurrentWork copyWith({
    String? uuid,
    String? username,
    String? phoneNumber,
    String? employeeId,
    List<String>? groups,
  }) {
    return MUserInCurrentWork(
      uuid: uuid ?? this.uuid,
      username: username ?? this.username,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      employeeId: employeeId ?? this.employeeId,
      groups: groups ?? this.groups,
    );
  }

  @override
  String toString() {
    return 'MUserInCurrentWork(uuid: $uuid, username: $username, phoneNumber: $phoneNumber, employeeId: $employeeId, groups: $groups)';
  }
}

// 항공기 모델
class MAircraftInCurrentWork extends CommonModel<MAircraftInCurrentWork> {
  final String name;
  final String departureTime;
  final String type;

  MAircraftInCurrentWork({
    required this.name,
    required this.departureTime,
    required this.type,
  });

  factory MAircraftInCurrentWork.fromMap(Map<String, dynamic> item) {
    return MAircraftInCurrentWork(
      name: item['name'] ?? "",
      departureTime: item['departureTime'] ?? "",
      type: item['type'] ?? "",
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'departureTime': departureTime,
      'type': type,
    };
  }

  @override
  MAircraftInCurrentWork copyWith({
    String? name,
    String? departureTime,
    String? type,
  }) {
    return MAircraftInCurrentWork(
      name: name ?? this.name,
      departureTime: departureTime ?? this.departureTime,
      type: type ?? this.type,
    );
  }

  @override
  String toString() {
    return 'Aircraft(name: $name, departureTime: $departureTime, type: $type)';
  }
}

// 절차 모델
class MProcedure extends CommonModel<MProcedure> {
  final String name;
  final DateTime? date;
  final List<double>? location;

  MProcedure({
    required this.name,
    this.date,
    this.location,
  });

  factory MProcedure.fromMap(Map<String, dynamic> item) {
    List<double>? locationList;

    if (item['location'] != null) {
      try {
        final locationData = item['location'];
        if (locationData is List) {
          locationList = locationData.map<double>((value) {
            // int나 double 모두 처리
            if (value is int) {
              return value.toDouble();
            } else if (value is double) {
              return value;
            } else if (value is String) {
              return double.parse(value);
            }
            return 0.0; // 기본값
          }).toList();
        }
      } catch (e) {
        debugPrint('Location 파싱 오류: $e');
        locationList = null;
      }
    }

    return MProcedure(
      name: item['name'] as String,
      date:
          item['date'] != null ? DateTime.parse(item['date'] as String) : null,
      location: locationList,
    );
  }

  @override
  MProcedure copyWith({
    String? name,
    DateTime? date,
    List<double>? location,
  }) {
    return MProcedure(
      name: name ?? this.name,
      date: date ?? this.date,
      location: location ?? this.location,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = {
      'name': name,
    };

    if (date != null) {
      data['date'] = date!.toIso8601String();
    } else {
      data['date'] = null;
    }

    data['location'] = location;

    return data;
  }

  @override
  String toString() {
    return 'Procedure(name: $name, date: $date, location: $location)';
  }
}
