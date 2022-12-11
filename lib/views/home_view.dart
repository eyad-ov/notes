import 'package:flutter/material.dart';
import 'package:notes/data/notes_user.dart';
import 'package:notes/data/user_note.dart';
import 'package:notes/services/authentication/firebase_auth_service.dart';
import 'package:notes/services/database/firebase_db_service.dart';
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
          TextButton(
            onPressed: () async {
              await FirebaseAuthService().signOut();
            },
            child: const Text(
              "Sign out",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          )
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
              return ListView(
                children: snapshot.data!.map((note) {

                  /// show only two words of the text!!
                  /// and try to sort the notes 
                  return ListTile(
                    title: Text(note.text),
                    onTap: () async {
                      String newText = await Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return NewNoteVeiw(text: note.text);
                      })) as String;
                      if(newText.isNotEmpty){
                        await FirebaseDB().updateNote(note.id!, newText);
                      }
                    },
                    trailing: IconButton(
                      onPressed: () async {
                        final noteId = note.id;
                        FirebaseDB().deleteNote(noteId!);
                      },
                      icon: const Icon(Icons.delete),
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
            );
            await FirebaseDB().addNote(note);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
