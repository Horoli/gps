// part of FlightSteps;

// class MAvailableWork extends CommonModel<MAvailableWork> {
//   final String name; // 항공편 번호 (예: LJ221)
//   final String departureTime; // 출발 시간 (예: 0715)

//   MAvailableWork({
//     required this.name,
//     required this.departureTime,
//   });

//   // JSON에서 Work 객체로 변환하는 팩토리 생성자
//   factory MAvailableWork.fromMap(Map<String, dynamic> item) {
//     return MAvailableWork(
//       name: item['name'] as String,
//       departureTime: item['departureTime'] as String,
//     );
//   }

//   // Work 객체를 JSON으로 변환하는 메서드
//   @override
//   Map<String, dynamic> toJson() {
//     return {
//       'name': name,
//       'departureTime': departureTime,
//     };
//   }

//   // 객체 복사 및 일부 필드 변경을 위한 copyWith 메서드
//   @override
//   MAvailableWork copyWith({
//     String? name,
//     String? departureTime,
//   }) {
//     return MAvailableWork(
//       name: name ?? this.name,
//       departureTime: departureTime ?? this.departureTime,
//     );
//   }

//   @override
//   String toString() {
//     return 'Work(name: $name, departureTime: $departureTime)';
//   }
// }
