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

Widget buildNavigationButton({
  required BuildContext context,
  required String title,
  required String routerName,
  bool useReplacement = false,
  VoidCallback? onPressed,
}) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () async {
          if (onPressed != null) {
            onPressed();
          }
          useReplacement
              ? await Navigator.pushReplacementNamed(context, routerName)
              : await Navigator.pushNamed(context, routerName);
        },
        style: ElevatedButton.styleFrom(
          // backgroundColor: const Color(0xFF4B5EFC), // 파란색 버튼
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
  );
}
