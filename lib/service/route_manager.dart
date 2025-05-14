part of FlightSteps;

class RouterManager {
  static final RouterManager _instance = RouterManager._internal();
  factory RouterManager() => _instance;
  RouterManager._internal();

  String _currentRouteName = '';

  String get currentRouteName => _currentRouteName;

  void setCurrentRoute(String routeName) {
    _currentRouteName = routeName;
  }

  bool isWorklist() {
    // ViewWorklist의 라우트 이름
    return _currentRouteName == PATH.ROUTE_WORKLIST;
  }

  bool isWorkDetail() {
    return _currentRouteName == PATH.ROUTE_WORK_DETAIL;
  }
}

class AppRouteObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is PageRoute) {
      RouterManager().setCurrentRoute(route.settings.name ?? '');
    }
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute is PageRoute) {
      RouterManager().setCurrentRoute(previousRoute.settings.name ?? '');
    }
    super.didPop(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute is PageRoute) {
      RouterManager().setCurrentRoute(newRoute.settings.name ?? '');
    }
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}
