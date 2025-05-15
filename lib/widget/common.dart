part of FlightSteps;

Widget buildIndicator({Color? color}) {
  return CircularProgressIndicator(color: color);
}

PreferredSizeWidget commonAppBar({
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
    backgroundColor: COLOR.BASE,
    title: Text(title),
    centerTitle: true,
    actions: actions,
  );
}

BoxDecoration get commonDecoration => BoxDecoration(
      border: Border.all(color: Colors.grey[300]!),
      borderRadius: BorderRadius.circular(8.0),
    );

Widget buildElevatedButton({
  VoidCallback? onPressed,
  bool usePadding = true,
  required Widget child,
}) {
  return Padding(
    padding: usePadding ? SIZE.BUTTON_PADDING : EdgeInsets.zero,
    child: SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: SIZE.BUTTON_STYLE,
        child: child,
      ),
    ),
  );
}

Widget buildNavigationButton({
  required BuildContext context,
  required String title,
  required String routerName,
  bool useReplacement = false,
  bool usePadding = true,
  VoidCallback? onPressed,
}) {
  return Padding(
    padding: usePadding ? SIZE.BUTTON_PADDING : EdgeInsets.zero,
    child: SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () async {
          if (onPressed != null) {
            onPressed();
          }

          useReplacement
              ? await Navigator.pushNamedAndRemoveUntil(
                  GNavigationKey.currentContext!,
                  routerName,
                  ModalRoute.withName(('/')))
              : await Navigator.pushNamed(
                  GNavigationKey.currentContext!, routerName);
        },
        style: ElevatedButton.styleFrom(
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

Widget buildNavigationButtonWithDialog({
  required String title,
  bool useReplacement = false,
  VoidCallback? onPressed,
}) {
  return Padding(
    padding: SIZE.BUTTON_PADDING,
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
