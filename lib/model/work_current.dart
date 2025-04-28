part of gps_test;
// 사용자 모델

// 현재 작업 모델 (메인 모델)
class CurrentWork extends CommonModel<CurrentWork> {
  final String uuid;
  final List<MUserInCurrentWork> users;
  final MAircraftInCurrentWork aircraft;
  final List<MProcedureInCurrentWork> procedures;
  final String description;
  final DateTime date;

  CurrentWork({
    required this.uuid,
    required this.users,
    required this.aircraft,
    required this.procedures,
    required this.description,
    required this.date,
  });

  factory CurrentWork.fromMap(Map<String, dynamic> item) {
    return CurrentWork(
      uuid: item['uuid'] as String,
      users: (item['users'] as List<dynamic>)
          .map((e) => MUserInCurrentWork.fromMap(e as Map<String, dynamic>))
          .toList(),
      aircraft: MAircraftInCurrentWork.fromMap(
          item['aircraft'] as Map<String, dynamic>),
      procedures: (item['procedures'] as List<dynamic>)
          .map(
              (e) => MProcedureInCurrentWork.fromMap(e as Map<String, dynamic>))
          .toList(),
      description: item['description'] as String,
      date: DateTime.parse(item['date'] as String),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'users': users.map((e) => e.toJson()).toList(),
      'aircraft': aircraft.toJson(),
      'procedures': procedures.map((e) => e.toJson()).toList(),
      'description': description,
      'date': date.toIso8601String(),
    };
  }

  @override
  CurrentWork copyWith({
    String? uuid,
    List<MUserInCurrentWork>? users,
    MAircraftInCurrentWork? aircraft,
    List<MProcedureInCurrentWork>? procedures,
    String? description,
    DateTime? date,
  }) {
    return CurrentWork(
      uuid: uuid ?? this.uuid,
      users: users ?? this.users,
      aircraft: aircraft ?? this.aircraft,
      procedures: procedures ?? this.procedures,
      description: description ?? this.description,
      date: date ?? this.date,
    );
  }

  @override
  String toString() {
    return 'CurrentWork(uuid: $uuid, users: $users, aircraft: $aircraft, procedures: $procedures, description: $description, date: $date)';
  }
}

class MUserInCurrentWork extends CommonModel<MUserInCurrentWork> {
  final String username;
  final String phoneNumber;

  MUserInCurrentWork({
    required this.username,
    required this.phoneNumber,
  });

  factory MUserInCurrentWork.fromMap(Map<String, dynamic> item) {
    return MUserInCurrentWork(
      username: item['username'] as String,
      phoneNumber: item['phoneNumber'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'phoneNumber': phoneNumber,
    };
  }

  @override
  MUserInCurrentWork copyWith({
    String? username,
    String? phoneNumber,
  }) {
    return MUserInCurrentWork(
      username: username ?? this.username,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

  @override
  String toString() {
    return 'User(username: $username, phoneNumber: $phoneNumber)';
  }
}

// 항공기 모델
class MAircraftInCurrentWork extends CommonModel<MAircraftInCurrentWork> {
  final String name;
  final String departureTime;

  MAircraftInCurrentWork({
    required this.name,
    required this.departureTime,
  });

  factory MAircraftInCurrentWork.fromMap(Map<String, dynamic> item) {
    return MAircraftInCurrentWork(
      name: item['name'] as String,
      departureTime: item['departureTime'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'departureTime': departureTime,
    };
  }

  @override
  MAircraftInCurrentWork copyWith({
    String? name,
    String? departureTime,
  }) {
    return MAircraftInCurrentWork(
      name: name ?? this.name,
      departureTime: departureTime ?? this.departureTime,
    );
  }

  @override
  String toString() {
    return 'Aircraft(name: $name, departureTime: $departureTime)';
  }
}

// 절차 모델
class MProcedureInCurrentWork extends CommonModel<MProcedureInCurrentWork> {
  final String name;
  final DateTime? date;
  final List<double>? location;

  MProcedureInCurrentWork({
    required this.name,
    this.date,
    this.location,
  });

  factory MProcedureInCurrentWork.fromMap(Map<String, dynamic> item) {
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
        print('Location 파싱 오류: $e');
        locationList = null;
      }
    }

    return MProcedureInCurrentWork(
      name: item['name'] as String,
      date:
          item['date'] != null ? DateTime.parse(item['date'] as String) : null,
      location: locationList,
    );
  }

  @override
  MProcedureInCurrentWork copyWith({
    String? name,
    DateTime? date,
    List<double>? location,
  }) {
    return MProcedureInCurrentWork(
      name: name ?? this.name,
      date: date ?? this.date,
      location: location ?? this.location,
    );
  }

  @override
  Map<String, dynamic> toJson() {
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
