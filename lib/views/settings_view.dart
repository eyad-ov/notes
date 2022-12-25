import 'package:flutter/material.dart';
import 'package:notes/services/authentication/firebase_auth_service.dart';
import 'package:notes/services/database/firebase_db_service.dart';

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
      body: StreamBuilder(
        stream: FirebaseDB().userStream(FirebaseAuthService().user),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
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
                      Navigator.pushNamed(context, "changeEmail");
                    },
                    trailing: const Icon(Icons.email),
                  ),
                  ListTile(
                    title: const Text("change password"),
                    onTap: () {
                      Navigator.pushNamed(context, "changePassword");
                    },
                    trailing: const Icon(Icons.password),
                  ),
                  ListTile(
                    title: const Text("change font"),
                    onTap: () {
                      Navigator.pushNamed(context, "changeFont");
                    },
                    trailing: const Icon(Icons.font_download),
                  ),
                ],
              );
            }
          }

          return const CircularProgressIndicator();
        },
      ),
    );
  }
}
