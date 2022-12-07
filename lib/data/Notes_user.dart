import 'package:firebase_auth/firebase_auth.dart';

class NotesUser{
  final String email;

  NotesUser(this.email);
  
  factory NotesUser.fromFirebaseUser(UserCredential userCredential){
    return NotesUser(userCredential.user!.email!);
  }
}