import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes/services/database/firebase_db_service.dart';
import 'package:notes/views/change_email.dart';
import 'package:notes/views/change_password.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: FutureBuilder(
        future: FirebaseDB().user,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final user = snapshot.data!;
            return ListView(
              children: [
                ListTile(
                  title: const Text("Dark mode"),
                  trailing: Checkbox(
                    value: user.darkMode,
                    onChanged: (value) async {
                      await FirebaseDB()
                          .updateUser(user.id, darkMode: value ?? false);
                      setState(() {
                        user.darkMode = value ?? false;
                      });
                    },
                  ),
                ),
                ListTile(
                  title: const Text("change email"),
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) {
                        // false !!!
                        // cursor problem too!
                        return const ChangeEmailView(darkMode: false);
                      }),
                      (route) => false,
                    );
                  },
                  trailing: const Icon(Icons.change_circle),
                ),
                ListTile(
                  title: const Text("change password"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) {
                        // false !!!
                        // cursor problem too!
                        return const ChangePasswordView(darkMode: false);
                      }),
                    );
                  },
                  trailing: const Icon(Icons.password),
                ),
              ],
            );
          }
          return const CircularProgressIndicator();
        },
      ),
    );
  }
}
