import 'package:flutter/material.dart';
import 'package:notes/constants/constans.dart';
import 'package:notes/data/notes_user.dart';
import 'package:notes/services/authentication/firebase_auth_service.dart';
import 'package:notes/services/database/firebase_db_service.dart';
import 'package:notes/services/font_family.dart';
import 'package:provider/provider.dart';

class NewNoteVeiw extends StatefulWidget {
  final String text;
  const NewNoteVeiw({super.key, required this.text});

  @override
  State<NewNoteVeiw> createState() => _NewNoteVeiwState();
}

class _NewNoteVeiwState extends State<NewNoteVeiw> {
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    _noteController.text = widget.text;
    super.initState();
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
            appBar: AppBar(
              title: const Text("Adding new Note"),
              backgroundColor: Colors.red.shade300,
            ),
            body: Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                style: TextStyle(
                  color: user.darkMode ? darkModeTextColor : textColor,
                  fontFamily: getFontFamily(user.font),
                ),
                controller: _noteController,
                maxLines: null,
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.pop(context, _noteController.text);
              },
              child: const Icon(Icons.save),
            ),
          );
        }),
      ),
    );
  }
}
