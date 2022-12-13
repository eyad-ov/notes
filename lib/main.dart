import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notes/services/authentication/firebase_auth_service.dart';
import 'package:notes/views/home_view.dart';
import 'package:notes/views/login_view.dart';
import 'package:notes/views/new_note_view.dart';
import 'package:notes/views/reset_password_view.dart';
import 'package:notes/views/settings_view.dart';
import 'package:notes/views/signup_view.dart';
import 'package:notes/views/verification_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // what if it failed!?
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(),
    home: const NotesApp(),
    routes: {
      'login': (context) {
        return const LogInView();
      },
      'signup': (context) {
        return const SignUpView();
      },
      'resetPassword': (context) {
        return const ResetPasswordView();
      },
      'newNote': (context) {
        return const NewNoteVeiw(text: "");
      },
      'settings': (context) {
        return const SettingsView();
      },
    },
  ));
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseAuthService().trackUserAuthChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
          } else if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
              if (snapshot.data!.isEmailVerified) {
                return HomeView(
                  notesUser: snapshot.data!,
                );
              } else {
                return const VerificationView();
              }
            } else {
              return const SignUpView();
            }
          } else if (snapshot.connectionState == ConnectionState.done) {}
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
  }
}
