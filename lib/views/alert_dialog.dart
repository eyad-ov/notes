import 'package:flutter/material.dart';

/// shows a dialog to user to let him choose what to do
Future<bool> showAlertDialog(BuildContext context, String action) async {
  return await showDialog<bool?>(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Colors.red.shade100,
              title: Text(
                "Are you sure, you want to $action",
                style: const TextStyle(color: Colors.black),
              ),
              content: Row(
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    child: const Text(
                      "yes",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    child: const Text(
                      "cancel",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            );
          }) ??
      false;
}
