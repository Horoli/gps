part of gps_test;

class CookieManager {
  static Future<void> saveCookies(Response response) async {
    final prefs = await SharedPreferences.getInstance();

    if (response.headers.map.containsKey('set-cookie')) {
      final cookies = response.headers.map['set-cookie'];
      await prefs.setStringList('auth_cookies', cookies ?? []);
      print('쿠키 저장됨: $cookies');
    }
  }

  static Future<List<String>> loadCookies() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('auth_cookies') ?? [];
  }

  // SharedPreferences에서 쿠키 삭제
  static Future<void> clearCookies() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_cookies');

      print('쿠키 삭제 완료');
    } catch (e) {
      print('쿠키 삭제 오류: $e');
    }
  }
}
