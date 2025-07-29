part of FlightSteps;

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
      PATH.ROUTE_CREATE_GROUP_SHIFT: (BuildContext context) =>
          const ViewCreateGroupShift(),
      PATH.ROUTE_CREATE_GROUP_EXTRA: (BuildContext context) =>
          const ViewCreateGroupExtra(),
      PATH.ROUTE_CREATE_GROUP_AIRCRAFT: (BuildContext context) =>
          const ViewCreateAircraft(),
      PATH.ROUTE_CREATE_GROUP_PLATE: (BuildContext context) =>
          const ViewCreatePlate(),
      PATH.ROUTE_WORK_DETAIL: (BuildContext context) => const ViewWorkDetail(),
      PATH.ROUTE_PREFERENCES: (BuildContext context) => const ViewPreferences(),
    };

    return MaterialApp(
      title: TITLE.APP_TITLE,
      navigatorKey: GNavigationKey,
      navigatorObservers: [AppRouteObserver()],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: COLOR.BASE,
          onPrimary: COLOR.BASE,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: COLOR.BASE,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        // bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        //   backgroundColor: COLOR.BASE,
        //   selectedItemColor: Colors.white,
        //   unselectedItemColor: Colors.grey,
        // ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: COLOR.BASE,
            foregroundColor: COLOR.WHITE,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        useMaterial3: true,
      ),
      initialRoute: PATH.ROUTE_LOGIN,
      routes: routes,
    );
  }
}
