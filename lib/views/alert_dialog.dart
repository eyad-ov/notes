import 'package:flutter/material.dart';

Future<bool> showAlertDialog(BuildContext context) async {
  return await showDialog<bool?>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Are you sure, you want to sign out"),
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
                    child: const Text("no"),
                  ),
                ],
              ),
            );
          }) ??
      false;
}
