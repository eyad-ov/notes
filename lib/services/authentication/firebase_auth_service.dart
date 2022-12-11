import 'package:firebase_auth/firebase_auth.dart';
import 'package:notes/data/notes_user.dart';
import 'package:notes/services/authentication/exceptions.dart';

class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<NotesUser> signUpWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      return NotesUser.fromFirebaseUser(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw WeakPasswordException();
      } else if (e.code == 'email-already-in-use') {
        throw EmailIsAlreadyUsedException();
      } else if (e.code == 'invalid-email') {
        throw InvalidEmailException();
      }
    }
    throw GeneralException();
  }

  NotesUser get user => NotesUser.fromFirebaseUser(_firebaseAuth.currentUser!);

  Future<NotesUser> signInWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      return NotesUser.fromFirebaseUser(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        throw WrongPasswordException();
      } else if (e.code == 'user-not-found') {
        throw UserNotFoundException();
      } else if (e.code == 'invalid-email') {
        throw InvalidEmailException();
      }
    }
    throw GeneralException();
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<void> sendEmailVerification() async {
    if (_firebaseAuth.currentUser != null) {
      await _firebaseAuth.currentUser!.sendEmailVerification();
    }
  }

  Future<void> sendEmailToResetPassword({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        throw InvalidEmailException();
      } else if (e.code == 'user-not-found') {
        throw UserNotFoundException();
      }
    } catch (_) {
      throw GeneralException();
    }
  }

  Stream<NotesUser?> trackUserAuthChanges() {
    return _firebaseAuth.userChanges().map((user) {
      return NotesUser.fromFirebaseUser(user!);
    });
  }
}