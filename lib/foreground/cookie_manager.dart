part of gps_test;

class CookieManager {
  // static final BehaviorSubject<List<String>?> subject =
  //     BehaviorSubject<List<String>?>.seeded(null);

  // static Stream<List<String>?> get stream => subject.stream;

  static Future<void> save(Response response) async {
    final prefs = await SharedPreferences.getInstance();

    if (response.headers.map.containsKey('set-cookie')) {
      final List<String>? cookies = response.headers.map['set-cookie'];
      // subject.add(cookies);
      await prefs.setStringList('auth_cookies', cookies ?? []);
      print('쿠키 저장됨: $cookies');
    }
  }

  static Future<List<String>> load() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getStringList('auth_cookies') ?? [];
  }

  // SharedPreferences에서 쿠키 삭제
  static Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_cookies');
      // subject.add([]);

      print('쿠키 삭제 완료');
    } catch (e) {
      print('쿠키 삭제 오류: $e');
    }
  }
}
