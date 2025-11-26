part of FlightSteps;

class RouterManager {
  static final RouterManager _instance = RouterManager._internal();
  factory RouterManager() => _instance;
  RouterManager._internal();

  String _currentRouteName = '';

  String get currentRouteName => _currentRouteName;

  Future setCurrentRoute(String routeName) async {
    _currentRouteName = routeName;
    _checkUserPermission(routeName);
    _handleWorklistInitialization(routeName);

    // WORKLIST 화면이 활성화되었을 때 실행
    // if (_currentRouteName == PATH.ROUTE_WORKLIST) {
    //   GServiceWork.clearSelection();
    //   GServiceMember.clearSelection();
    //   GServiceWorklist.clearSelection();
    //   GServiceSSE.disconnect();
    //   GServiceWorklist.get();
    //   procedureMap = {};
    //   createGroupType = '';

    //   print('WORKLIST 화면 활성화 - clearSelection 실행됨');
    // }
  }

  /// 사용자 권한('work') 체크 및 리다이렉트 로직
  void _checkUserPermission(String routeName) {
    final MUser? user = GServiceUser.currentUser;

    // 1. 로그인이 안 된 상태면 권한 체크 패스
    if (user == null) return;

    // 2. 권한 체크를 건너뛸 라우트 정의 (로그인, 환경설정 등)
    // 이미 환경설정 화면이거나 로그인 화면이라면 체크하지 않음
    if (routeName == PATH.ROUTE_PREFERENCES || routeName == PATH.ROUTE_LOGIN) {
      return;
    }

    // 3. 'work' 권한 확인
    // MUser 모델에 추가한 getter(functionEnabled) 사용
    final bool hasWork = user.functionEnabled.contains('work');

    // 4. 권한이 '없으면' 환경설정 화면으로 이동 (요청하신 로직)
    if (!hasWork) {
      print('Work 권한 없음: Preferences로 이동합니다.');
      // 빌드/네비게이션 충돌 방지를 위해 프레임 이후 실행
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // 중복 이동 방지
        if (_currentRouteName != PATH.ROUTE_PREFERENCES) {
          CustomNavigator.pushReplacementNamed(PATH.ROUTE_PREFERENCES);
        }
      });
    }
  }

  void _handleWorklistInitialization(String routeName) {
    if (routeName == PATH.ROUTE_WORKLIST) {
      print('WORKLIST 화면 활성화 - 초기화 실행');

      GServiceWork.clearSelection();
      GServiceMember.clearSelection();
      GServiceWorklist.clearSelection();
      GServiceSSE.disconnect();
      GServiceWorklist.get();

      // 전역 변수 초기화 (가능하면 클래스 내부 상태로 관리하는 것이 좋음)
      procedureMap = {};
      createGroupType = '';
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
