import 'package:firebase_auth/firebase_auth.dart';
import 'package:notes/data/Notes_user.dart';

class FirebaseAuthService{
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;



  // exceptions !!!
  
  Future<NotesUser> signUpWithEmailAndPassword({required String email, required String password})async{
    final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    return NotesUser.fromFirebaseUser(userCredential);
  }

  Future<NotesUser> signInWithEmailAndPassword({required String email, required String password})async{
    final userCredential = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    return NotesUser.fromFirebaseUser(userCredential);
  } 

  Future<void> signOut() async{
    await _firebaseAuth.signOut();
  }

}