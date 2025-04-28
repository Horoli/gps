part of gps_test;

class ShowDialogWidgets {
  static Future<void> error(BuildContext context, String message) async {
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
}
