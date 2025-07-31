part of FlightSteps;

class CustomNavigator {
  static Future<void> pushNamedAndRemoveUntilToWorkList() async {
    await Navigator.pushNamedAndRemoveUntil(
        GNavigationKey.currentContext!, PATH.ROUTE_WORK_DETAIL, (route) {
      return route.settings.name == PATH.ROUTE_WORKLIST;
    });
  }

  static Future<void> pushReplacementNamed(String routerName) async {
    await Navigator.pushReplacementNamed(
        GNavigationKey.currentContext!, routerName);
  }

  static Future<void> pushNamed(String routerName) async {
    await Navigator.pushNamed(GNavigationKey.currentContext!, routerName);
  }
}
