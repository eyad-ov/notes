import 'package:firebase_auth/firebase_auth.dart';
import 'package:notes/data/notes_user.dart';
import 'package:notes/services/authentication/exceptions.dart';
import 'package:notes/services/database/firebase_db_service.dart';

class FirebaseAuthService {
  FirebaseAuthService() {
    _firebaseAuth.setPersistence(Persistence.LOCAL);
  }
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<void> updateUserEmail(String newEmail) async {
    try {
      await _firebaseAuth.currentUser!.updateEmail(newEmail);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        throw InvalidEmailException();
      } else if (e.code == 'email-already-in-use') {
        throw EmailIsAlreadyUsedException();
      }
    } catch (_) {
      throw GeneralException();
    }
  }

  Future<void> updateUserPassword(String newPassword) async {
    try {
      await _firebaseAuth.currentUser!.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw WeakPasswordException();
      } else if (e.code == 'requires-recent-login') {
        throw RequiersRecentLogInException();
      }
    } catch (_) {
      throw GeneralException();
    }
  }

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

  Future<void> signInWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      final userInDB = await FirebaseDB().user;
      if (user.email != userInDB.email) {
        await FirebaseDB().updateUser(user.id, email: user.email);
        final notes = await FirebaseDB().getAllNotesOfUser(user);
        for (var note in notes) {
          await FirebaseDB().updateNote(note, email: user.email);
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        throw WrongPasswordException();
      } else if (e.code == 'user-not-found') {
        throw UserNotFoundException();
      } else if (e.code == 'invalid-email') {
        throw InvalidEmailException();
      }
    } catch (_) {
      throw GeneralException();
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<void> sendEmailVerification() async {
    if (_firebaseAuth.currentUser != null) {
      await _firebaseAuth.currentUser!.sendEmailVerification();
    }
  }

  Future<void> deleteUser() async {
    if (_firebaseAuth.currentUser != null) {
      try {
        await _firebaseAuth.currentUser!.delete();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          throw RequiersRecentLogInException();
        }
      } catch (_) {
        throw GeneralException();
      }
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
