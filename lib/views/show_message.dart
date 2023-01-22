import 'package:flutter/material.dart';


/// shows a dialog to notify user about an error. 
Future<void> showMessage(String msg, BuildContext context) {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("error"),
          content: Text(msg),
        );
      });
}
