part of gps_test;

class LocationManager {
  static const String title = 'location';

  static Future<bool> hasData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? location = prefs.getStringList(title);
    if (location != null) {
      return true;
    }
    return false;
  }

  static Future<void> save(Map<String, dynamic> data) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final List<String>? location = prefs.getStringList(title);
    if (location != null) {
      // location이 null이 아닌 경우, 기존 리스트에 추가

      location.add(jsonEncode(data));
      print('LocationManager save: $location');
      await prefs.setStringList(title, location);
      return;
    }
    // location이 null인 경우, 새로운 리스트를 생성하여 저장
    await prefs.setStringList(title, [jsonEncode(data)]);
  }

  static Future<List<Map<String, dynamic>>> load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? location = prefs.getStringList(title);
    if (location != null) {
      List<Map<String, dynamic>> parsedData = location
          .map((String data) => jsonDecode(data) as Map<String, dynamic>)
          .toList();
      return parsedData;
    }
    print('LocationManager: No location found');

    return [];
  }

  static Future<void> clear() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(title);
      print('LocationManager: location 삭제 완료');
    } catch (e) {
      print('LocationManager: location 삭제 오류: $e');
    }
  }
}
