part of gps_test;

late ServiceUser GServiceUser;
late ServiceChecklist GServiceChecklist;
late ServiceWorklist GServiceWorklist;
late ServiceWork GServiceWork;
late ServiceMember GServiceMember;

bool useForeground = false;

/**
 * 임시로 global에다 생성
 */
class DioConnector {
  static Map<String, dynamic> headersByCookie(List<String> cookies) {
    final Map<String, dynamic> headers = {
      'Content-Type': 'application/json',
      // 'Accept-Encoding': 'br, gzip, deflate',
      // 'Accept': 'application/json'
    };
    if (cookies.isNotEmpty) {
      headers['cookie'] = cookies.join('; ');
    }
    return headers;
  }
}
