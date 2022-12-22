import 'package:firebase_auth/firebase_auth.dart';

class NotesUser {
  final String id;
  final String email;
  final bool isEmailVerified;
  bool darkMode;

  NotesUser(
      {required this.id,
      required this.email,
      required this.isEmailVerified,
      required this.darkMode});

  factory NotesUser.fromFirebaseUser(User firebaseUser) {
    return NotesUser(
      id: firebaseUser.uid,
      email: firebaseUser.email!,
      isEmailVerified: firebaseUser.emailVerified,
      darkMode: false,
    );
  }
}
