import 'package:flutter/material.dart';
import 'package:notes/data/notes_user.dart';
import 'package:notes/services/firebase_auth_service.dart';

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
      body: Center(
        child: Text("welcome to home view ${widget.notesUser.email}"),
      ),
    );
  }
}
