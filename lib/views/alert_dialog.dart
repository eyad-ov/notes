import 'package:flutter/material.dart';

Future<bool> showAlertDialog(BuildContext context, String action) async {
  return await showDialog<bool?>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Are you sure, you want to $action"),
              content: Row(
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    child: const Text("yes"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    child: const Text("cancel"),
                  ),
                ],
              ),
            );
          }) ??
      false;
}
