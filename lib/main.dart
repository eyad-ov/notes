import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notes/services/authentication/firebase_auth_service.dart';
import 'package:notes/services/database/firebase_db_service.dart';
import 'package:notes/views/change_email_view.dart';
import 'package:notes/views/change_password_view.dart';
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
        return const NewNoteVeiw(
          text: "",
          darkMode: false,
        );
      },
      'newNoteDarkMode': (context) {
        return const NewNoteVeiw(
          text: "",
          darkMode: true,
        );
      },
      'settings': (context) {
        return const SettingsView(
          darkMode: false,
        );
      },
      'settingsDarkMode': (context) {
        return const SettingsView(
          darkMode: true,
        );
      },
      'changeEmail': (context) {
        return const ChangeEmailView(
          darkMode: false,
        );
      },
      'changeEmailDarkMode': (context) {
        return const ChangeEmailView(
          darkMode: true,
        );
      },
      'changePassword': (context) {
        return const ChangePasswordView(
          darkMode: false,
        );
      },
      'changePasswordDarkMode': (context) {
        return const ChangePasswordView(
          darkMode: true,
        );
      },
    },
  ));
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: StreamBuilder(
          stream: FirebaseAuthService().trackUserAuthChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
            } else if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData) {
                if (snapshot.data!.isEmailVerified) {
                  final user = snapshot.data!;
                  return StreamBuilder(
                      stream: FirebaseDB().userStream(user),
                      builder: ((context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.active) {
                          if (snapshot.hasData) {
                            return HomeView(
                              notesUser: user,
                              darkMode: snapshot.data!.darkMode,
                            );
                          }
                        }
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }));
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
          }),
    );
  }
}
