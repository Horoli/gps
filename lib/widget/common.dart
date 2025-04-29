part of gps_test;

PreferredSizeWidget CommonAppBar({
  required String title,
  bool useTrailing = true,
}) {
  List<Widget> actions = useTrailing
      ? [
          IconButton(
            onPressed: () async {
              Navigator.of(GNavigationKey.currentState!.context)
                  .pushNamed(PATH.ROUTE_PREFERENCES);
            },
            icon: const Icon(Icons.settings),
          )
        ]
      : [];
  return AppBar(
    title: Text(title),
    centerTitle: true,
    actions: actions,
  );
}

Widget buildNavigationButtonWithDialog({
  required String title,
  bool useReplacement = false,
  VoidCallback? onPressed,
}) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
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

Widget buildTextField(TextEditingController controller, String hint) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
      ),
    ),
  );
}
