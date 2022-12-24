import 'package:flutter/material.dart';
import 'package:notes/services/database/firebase_db_service.dart';

class SettingsView extends StatefulWidget {
  final bool darkMode;
  const SettingsView({super.key, required this.darkMode});

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
                    Navigator.pushNamed(
                        context,
                        widget.darkMode
                            ? "changeEmailDarkMode"
                            : "changeEmail");
                  },
                  trailing: const Icon(Icons.change_circle),
                ),
                ListTile(
                  title: const Text("change password"),
                  onTap: () {
                    Navigator.pushNamed(
                        context,
                        widget.darkMode
                            ? "changePasswordDarkMode"
                            : "changePassword");
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
