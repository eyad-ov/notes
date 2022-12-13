import 'package:flutter/material.dart';
import 'package:notes/data/notes_user.dart';
import 'package:notes/data/user_note.dart';
import 'package:notes/services/authentication/firebase_auth_service.dart';
import 'package:notes/services/database/firebase_db_service.dart';
import 'package:notes/views/alert_dialog.dart';
import 'package:notes/views/new_note_view.dart';

class HomeView extends StatefulWidget {
  final NotesUser notesUser;
  const HomeView({super.key, required this.notesUser});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        backgroundColor: Colors.red.shade300,
        actions: [
          Row(children: [
            TextButton(
              onPressed: () async {
                bool sure = await showAlertDialog(context);
                sure == true ? await FirebaseAuthService().signOut() : null;
              },
              child: const Text(
                "Sign out",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, 'settings');
                },
                icon: const Icon(
                  Icons.settings,
                )),
          ])
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseDB().userNoteStream(FirebaseAuthService().user),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
              List<UserNote> notes = snapshot.data!;
              notes.sort((a, b) => b.dateTime.compareTo(a.dateTime));
              return ListView(
                children: notes.map((note) {
                  String text = note.text;
                  if (note.text.length > 20) {
                    text = note.text.substring(0, 20);
                    text += "...";
                  }
                  DateTime dateTime = note.dateTime;
                  String minute = dateTime.minute.toString().length < 2
                      ? "0${dateTime.minute}"
                      : dateTime.minute.toString();
                  String hour = dateTime.hour.toString().length < 2
                      ? "0${dateTime.hour}"
                      : dateTime.hour.toString();
                  String day = dateTime.day.toString().length < 2
                      ? "0${dateTime.day}"
                      : dateTime.day.toString();
                  String month = dateTime.month.toString().length < 2
                      ? "0${dateTime.month}"
                      : dateTime.month.toString();
                  String year = dateTime.year.toString();
                  return Card(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: Colors.red.shade300,
                      ),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    color: Colors.grey.shade300,
                    child: ListTile(
                      title: Text(text),
                      onTap: () async {
                        String newText = await Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return NewNoteVeiw(text: note.text);
                        })) as String;
                        if (newText.isNotEmpty) {
                          await FirebaseDB().updateNote(note.id!, newText);
                        }
                      },
                      subtitle: Text("$hour:$minute  $day/$month/$year"),
                      trailing: IconButton(
                        onPressed: () async {
                          final noteId = note.id;
                          FirebaseDB().deleteNote(noteId!);
                        },
                        icon: const Icon(Icons.delete),
                      ),
                    ),
                  );
                }).toList(),
              );
            }
            return const Center(child: Text("no notes yet!"));
          }
          return const Text("home");
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          String text = await Navigator.pushNamed(context, "newNote") as String;
          if (text.isNotEmpty) {
            NotesUser user = FirebaseAuthService().user;
            UserNote note = UserNote(
              id: null,
              userId: user.id,
              userEmail: user.email,
              text: text,
              dateTime: DateTime.now(),
            );
            await FirebaseDB().addNote(note);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
