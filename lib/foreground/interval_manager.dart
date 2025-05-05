part of gps_test;

// class IntervalManager {
//   static String title = 'interval';
//   static int defaultInterval = 300;
//   static Future<void> save(int? interval) async {
//     final prefs = await SharedPreferences.getInstance();

//     await prefs.setInt(title, interval ?? defaultInterval);
//     print('SharedPreferences : interval 저장됨 $interval');
//   }

//   static Future<int> load() async {
//     final prefs = await SharedPreferences.getInstance();
//     int result = prefs.getInt(title) ?? defaultInterval;
//     print('interval load result $result');

//     return result;
//   }

//   static Future<void> clear() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.remove(title);

//       print('SharedPreferences : interval 삭제 완료');
//     } catch (e) {
//       print('SharedPreferences : interval 삭제 오류: $e');
//     }
//   }
// }
