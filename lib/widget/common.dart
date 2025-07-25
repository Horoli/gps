part of FlightSteps;

Widget buildIndicator({Color? color}) {
  return CircularProgressIndicator(color: color);
}

Widget buildFittedBox({
  required Widget child,
  BoxFit fit = BoxFit.scaleDown,
}) {
  return FittedBox(
    fit: fit,
    child: child,
  );
}

Widget buildFittedText({
  required String text,
  TextAlign textAlign = TextAlign.center,
  double fontSize = 16.0,
  FontWeight? fontWeight,
  Color? color,
}) {
  return FittedBox(
    fit: BoxFit.scaleDown,
    child: Text(
      text,
      style: TextStyle(
        color: color ?? Colors.black,
        fontSize: fontSize,
        fontWeight: fontWeight ?? FontWeight.normal,
      ),
      textAlign: textAlign,
    ),
  );
}

PreferredSizeWidget commonAppBar({
  required String title,
  bool useTrailing = true,
  bool automaticallyImplyLeading = true,
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
    automaticallyImplyLeading: automaticallyImplyLeading,
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
  Future<void> Function()? onPressed,
  Color? backgroundColor,
}) {
  return Padding(
    padding: usePadding ? SIZE.BUTTON_PADDING : EdgeInsets.zero,
    child: SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () async {
          if (onPressed != null) {
            try {
              await onPressed();
            } catch (e) {
              print('Error in onPressed: $e');
              return;
            }
          }

          useReplacement
              ? await Navigator.pushNamedAndRemoveUntil(
                  GNavigationKey.currentContext!, routerName, (route) {
                  return route.settings.name == PATH.ROUTE_WORKLIST;
                })
              // ModalRoute.withName(('/')))
              : await Navigator.pushNamed(
                  GNavigationKey.currentContext!, routerName);
        },
        style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            backgroundColor: backgroundColor ?? COLOR.BASE),
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

Widget buildNavigationButtonWithCustom({
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

Widget buildSearchTextField({
  required TextEditingController controller,
  String? hint,
  int? maxLength,
  void Function(String)? onSubmitted,
}) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: TextField(
      // onSubmitted: (String value) => onSubmitted,
      onSubmitted: onSubmitted,
      maxLength: maxLength,
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Colors.grey,
        ),
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
      ),
    ),
  );
}
