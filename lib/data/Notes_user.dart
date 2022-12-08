
// user should be able to delete his account

import 'package:firebase_auth/firebase_auth.dart';

class NotesUser{
  final String email;
  final bool isEmailVerified;

  NotesUser({required this.email, required this.isEmailVerified});
  
  factory NotesUser.fromFirebaseUser(User firebaseUser){
    return NotesUser(email: firebaseUser.email!, isEmailVerified: firebaseUser.emailVerified);
  }
}