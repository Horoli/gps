part of gps_test;

PreferredSizeWidget CommonAppBar({
  required String title,
  bool useTrailing = true,
}) {
  List<Widget> actions = useTrailing ? [] : [];
  return AppBar(
    title: Text(title),
    centerTitle: true,
    actions: actions,
  );
}
