import 'package:flutter/material.dart';
import 'package:notes/services/authentication/exceptions.dart';
import 'package:notes/services/authentication/firebase_auth_service.dart';
import 'package:notes/services/database/firebase_db_service.dart';
import 'package:notes/views/alert_dialog.dart';
import 'package:notes/views/show_error.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: ListView(
        children: [
          TextButton(
            onPressed: () async {
              try {
                final navigator = Navigator.of(context);
                bool sure = await showAlertDialog(context,"delete your accout");
                if (sure) {
                  await FirebaseDB()
                      .deleteAllNotesOfUser(FirebaseAuthService().user);
                  await FirebaseAuthService().deleteUser();
                  navigator.pop();
                }
              } on RequiersRecentLogInException {
                showMessage("log in and try it again", context);
              }
            },
            child: const Text("delete account"),
          ),
        ],
      ),
    );
  }
}
