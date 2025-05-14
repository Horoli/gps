part of FlightSteps;

class CookieManager {
  static const String title = 'auth_cookies';
  static const String headers = 'set-cookie';

  static Future<void> save(Response response) async {
    final prefs = await SharedPreferences.getInstance();

    if (response.headers.map.containsKey(headers)) {
      final List<String>? cookies = response.headers.map[headers];
      // subject.add(cookies);
      await prefs.setStringList(title, cookies ?? []);
      debugPrint('쿠키 저장됨: $cookies');
    }
  }

  static Future<List<String>> load() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getStringList(title) ?? [];
  }

  // SharedPreferences에서 쿠키 삭제
  static Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(title);
      // subject.add([]);

      debugPrint('쿠키 삭제 완료');
    } catch (e) {
      debugPrint('쿠키 삭제 오류: $e');
    }
  }
}
