part of FlightSteps;

class UserLoginManager {
  static const String title = 'user_login_data';

  static Future<bool> hasData(Map<String, dynamic> user) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? user = prefs.getString(title);
    if (user != null) {
      return true;
    }
    return false;
  }

  // 로그인 성공 시 user 정보를 SharedPreferences에 저장
  static Future<void> save(Map<String, dynamic> data) async {
    /**
     * employeeId : String
     * phoneNumber : String
     */
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(title, jsonEncode(data));
  }

  static Future<Map<String, dynamic>> load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? user = prefs.getString(title);
    if (user != null) {
      Map<String, dynamic> parsedData =
          jsonDecode(user) as Map<String, dynamic>;
      return parsedData;
    }
    debugPrint('UserManager: No user found');
    return {
      'employeeId': '',
      'phoneNumber': '',
    };
  }

  static Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(title);

      debugPrint('로그인 정보 삭제 완료');
    } catch (e) {
      debugPrint('로그인 정보 삭제 오류: $e');
    }
  }
}
