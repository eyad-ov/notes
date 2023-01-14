import 'package:flutter/material.dart';
import 'package:notes/constants/constans.dart';
import 'package:notes/data/notes_user.dart';
import 'package:notes/services/authentication/firebase_auth_service.dart';
import 'package:notes/services/database/firebase_db_service.dart';
import 'package:notes/services/text_style.dart';
import 'package:provider/provider.dart';

class NewNoteVeiw extends StatefulWidget {
  const NewNoteVeiw({super.key});

  @override
  State<NewNoteVeiw> createState() => _NewNoteVeiwState();
}

class _NewNoteVeiwState extends State<NewNoteVeiw> {
  late final TextEditingController _noteController = TextEditingController();
  late final TextEditingController _noteTitleController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    final args = ModalRoute.of(context)!.settings.arguments as List<String>;
    _noteTitleController.text = args[0];
    _noteController.text = args[1];
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureProvider(
      create: (context) => FirebaseDB().user,
      initialData: FirebaseAuthService().user,
      child: Consumer<NotesUser>(
        builder: ((context, user, child) {
          return Scaffold(
            backgroundColor: user.darkMode
                ? darkModeHomeBackgroundColor
                : homeBackgroundColor,
            appBar: AppBar(
              title: Text(_noteTitleController.text.toUpperCase()),
              backgroundColor: user.darkMode
                  ? darkModeAppBarBackgroundColor
                  : appBarBackgroundColor,
            ),
            body: Padding(
              padding: const EdgeInsets.all(10),
              child: ListView(children: [
                Container(
                  color: user.darkMode ? darkModeNoteColor : noteColor,
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: "Title",
                      counterText: "",
                    ),
                    style:
                        getTextStyle(user.font, user.darkMode, user.fontSize),
                    controller: _noteTitleController,
                    maxLines: 1,
                    maxLength: 20,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Container(
                  color: user.darkMode ? darkModeNoteColor : noteColor,
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: "Your note",
                    ),
                    style:
                        getTextStyle(user.font, user.darkMode, user.fontSize),
                    controller: _noteController,
                    maxLines: null,
                  ),
                ),
              ]),
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: user.darkMode
                  ? darkModeFloatingActionButtonBackgroundColor
                  : floatingActionButtonBackgroundColor,
              onPressed: () {
                final args = [_noteTitleController.text, _noteController.text];
                Navigator.pop(context, args);
              },
              child: const Icon(Icons.save),
            ),
          );
        }),
      ),
    );
  }
}
