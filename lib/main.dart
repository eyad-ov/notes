import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notes/views/signup_view.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // what if it failed!?
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      
    ),
    home: const NotesApp(),
  ));
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const SignUpView();
  }
}