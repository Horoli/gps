part of FlightSteps;

class RouterManager {
  static final RouterManager _instance = RouterManager._internal();
  factory RouterManager() => _instance;
  RouterManager._internal();

  String _currentRouteName = '';

  String get currentRouteName => _currentRouteName;

  Future setCurrentRoute(String routeName) async {
    _currentRouteName = routeName;

    // if (GServiceUser.currentUser != null) {
    //   if (GServiceUser.currentUser?.config != null &&
    //       _currentRouteName != PATH.ROUTE_PREFERENCES) {
    //     if (_currentRouteName != PATH.ROUTE_LOGIN) {
    //       print('aaaa ${GServiceUser.currentUser?.config['functionEnabled']}');
    //       WidgetsBinding.instance.addPostFrameCallback((_) {
    //         CustomNavigator.pushReplacementNamed(PATH.ROUTE_PREFERENCES);
    //       });
    //     }
    //   }
    // }

    // WORKLIST 화면이 활성화되었을 때 실행
    if (_currentRouteName == PATH.ROUTE_WORKLIST) {
      GServiceWork.clearSelection();
      GServiceMember.clearSelection();
      GServiceWorklist.clearSelection();
      GServiceSSE.disconnect();
      GServiceWorklist.get();
      procedureMap = {};
      createGroupType = '';

      print('WORKLIST 화면 활성화 - clearSelection 실행됨');
    }
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
    // _checkWorklistRoute(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute is PageRoute) {
      RouterManager().setCurrentRoute(previousRoute.settings.name ?? '');
    }

    super.didPop(route, previousRoute);

    // if (previousRoute != null) {
    //   _checkWorklistRoute(route);
    // }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute is PageRoute) {
      RouterManager().setCurrentRoute(newRoute.settings.name ?? '');
    }
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    // if (newRoute != null) {
    //   _checkWorklistRoute(newRoute);
    // }
  }

  // void _checkWorklistRoute(Route<dynamic> route) {
  //   if (route.settings.name == PATH.ROUTE_WORKLIST) {
  //     // WORKLIST 화면이 활성화되었을 때 실행
  //     GServiceMember.clearSelection();
  //     print('WORKLIST 화면 활성화 - clearSelection 실행됨');
  //   }
  // }
}
