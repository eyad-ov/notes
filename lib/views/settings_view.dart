import 'package:flutter/material.dart';
import 'package:notes/constants/constans.dart';
import 'package:notes/data/notes_user.dart';
import 'package:notes/services/database/firebase_db_service.dart';
import 'package:notes/services/text_style.dart';

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
      backgroundColor:
          user.darkMode ? darkModeHomeBackgroundColor : homeBackgroundColor,
      appBar: AppBar(
        backgroundColor: user.darkMode
            ? darkModeAppBarBackgroundColor
            : appBarBackgroundColor,
        title: const Text("Settings"),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(
              "Dark mode",
              style: getTextStyle(user.font, user.darkMode, user.fontSize),
            ),
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
            title: Text(
              "change email",
              style: getTextStyle(user.font, user.darkMode, user.fontSize),
            ),
            onTap: () {
              Navigator.pushNamed(context, "changeEmail", arguments: user);
            },
            trailing: const Icon(Icons.email),
          ),
          ListTile(
            title: Text(
              "change password",
              style: getTextStyle(user.font, user.darkMode, user.fontSize),
            ),
            onTap: () {
              Navigator.pushNamed(context, "changePassword", arguments: user);
            },
            trailing: const Icon(Icons.password),
          ),
          ListTile(
            title: Text(
              "change font",
              style: getTextStyle(user.font, user.darkMode, user.fontSize),
            ),
            onTap: () {
              Navigator.pushNamed(context, "changeFont", arguments: user);
            },
            trailing: const Icon(Icons.font_download),
          ),
          ListTile(
            title: Text(
              "font size",
              style: getTextStyle(user.font, user.darkMode, user.fontSize),
            ),
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
                  icon: Icon(
                    Icons.add,
                    color: user.darkMode ? darkModeIconColor : iconColor,
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
                  icon: Icon(
                    Icons.remove,
                    color: user.darkMode ? darkModeIconColor : iconColor,
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
