import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    final noteText = ModalRoute.of(context)!.settings.arguments as String;
    _noteController.text = noteText;
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
            appBar: AppBar(
              title: const Text("Adding new Note"),
              backgroundColor: Colors.red.shade300,
            ),
            body: Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                style: getTextStyle(user.font, user.darkMode),
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
