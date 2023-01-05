import 'package:flutter/material.dart';
import 'package:notes/constants/constans.dart';
import 'package:notes/data/notes_user.dart';
import 'package:notes/services/database/firebase_db_service.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late NotesUser user;

  @override
  void didChangeDependencies() {
    user = ModalRoute.of(context)!.settings.arguments as NotesUser;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: ListView(
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
              Navigator.pushNamed(context, "changeEmail", arguments: user);
            },
            trailing: const Icon(Icons.email),
          ),
          ListTile(
            title: const Text("change password"),
            onTap: () {
              Navigator.pushNamed(context, "changePassword", arguments: user);
            },
            trailing: const Icon(Icons.password),
          ),
          ListTile(
            title: const Text("change font"),
            onTap: () {
              Navigator.pushNamed(context, "changeFont", arguments: user);
            },
            trailing: const Icon(Icons.font_download),
          ),
          ListTile(
            title: const Text("font size"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () async {
                    double newSize = user.fontSize + 1;
                    if (newSize <= 40) {
                      await FirebaseDB().updateUser(user.id, fontSize: newSize);
                      setState(() {
                        user.fontSize++;
                      });
                    }
                  },
                  icon: const Icon(
                    Icons.add,
                    color: iconColor,
                  ),
                ),
                Text(user.fontSize.toInt().toString()),
                IconButton(
                  onPressed: () async {
                    double newSize = user.fontSize - 1;
                    if (newSize >= 10) {
                      await FirebaseDB().updateUser(user.id, fontSize: newSize);
                      setState(() {
                        user.fontSize--;
                      });
                    }
                  },
                  icon: const Icon(
                    Icons.remove,
                    color: iconColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
