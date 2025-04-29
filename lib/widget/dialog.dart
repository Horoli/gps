part of gps_test;

class ShowInfomationWidgets {
  static Future<void> errorDialog(BuildContext context, String message) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(message),
        );
      },
    );
  }

  static Future<void> confirm(BuildContext context) async {}

  static Future<void> snackbar(BuildContext context, String message) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
