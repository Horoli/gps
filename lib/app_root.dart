part of gps_test;

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => AppRootState();
}

class AppRootState extends State<AppRoot> {
  @override
  Widget build(BuildContext context) {
    Map<String, Widget Function(BuildContext)> routes = {
      PATH.ROUTE_LOGIN: (BuildContext context) => const ViewLogin(),
      PATH.ROUTE_CHECKLIST: (BuildContext context) => const ViewChecklist(),
      PATH.ROUTE_WORKLIST: (BuildContext context) => const ViewWorklist(),
      PATH.ROUTE_CREATE_GROUP: (BuildContext context) =>
          const ViewCreateGroup(),
      PATH.ROUTE_WORK_DETAIL: (BuildContext context) => const ViewWorkDetail(),
      PATH.ROUTE_PREFERENCES: (BuildContext context) => const ViewPreferences(),
    };

    return MaterialApp(
      title: 'Flutter Demo',
      navigatorKey: GNavigationKey,
      navigatorObservers: [AppRouteObserver()],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      initialRoute: PATH.ROUTE_LOGIN,
      routes: routes,
    );
  }
}
