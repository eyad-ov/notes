import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notes/services/firebase_auth_service.dart';
import 'package:notes/views/home_view.dart';
import 'package:notes/views/login_view.dart';
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
            print("state waiting !!!!!");
          } else if (snapshot.connectionState == ConnectionState.active) {
            print("state active!!!!");
            if (snapshot.hasData) {
              print("snapshot has data!!!!!!");
              print(snapshot.data!.email);
              if (snapshot.data!.isEmailVerified) {
                print("email is verified");
                return HomeView(notesUser: snapshot.data!,);
              } else {
                print("email is not verified");
                return VerificationView();
              }
            } else {
              print("snapshot does not have data");
              return SignUpView();
            }
          } else if (snapshot.connectionState == ConnectionState.done) {
            print("state done!!!!!!!");
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
  }
}
