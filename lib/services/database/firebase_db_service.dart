import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notes/services/authentication/firebase_auth_service.dart';
import 'package:notes/services/encryption.dart/aes_encryption.dart';
import '../../data/notes_user.dart';
import '../../data/user_note.dart';

class FirebaseDB {
  static final FirebaseDB _firebaseDB = FirebaseDB._internal();
  factory FirebaseDB() {
    return _firebaseDB;
  }
  FirebaseDB._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StreamController<List<UserNote>> _noteStreamController =
      StreamController.broadcast();

  final StreamController<NotesUser> _userStreamController =
      StreamController.broadcast();

  Future<NotesUser> get user async {
    final id = FirebaseAuthService().user.id;
    final docRef = _firestore.collection('users').doc(id);
    final doc = await docRef.get();
    final email = doc.data()!['email'] as String;
    final darkMode = doc.data()!['dark_mode'] as bool;
    final font = doc.data()!['font'] as String;
    return NotesUser(
        id: id,
        email: email,
        isEmailVerified: true,
        darkMode: darkMode,
        font: font);
  }

  Future<void> addNewUser(NotesUser user) async {
    await _firestore.collection('users').doc(user.id).set({
      'email': user.email,
      'dark_mode': user.darkMode,
      'font': user.font,
    });
  }

  Future<void> updateUser(String userId,
      {bool? darkMode, String? email, String? font}) async {
    if (darkMode != null) {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({'dark_mode': darkMode});
    }
    if (email != null) {
      await _firestore.collection('users').doc(userId).update({'email': email});
    }
    if (font != null) {
      await _firestore.collection('users').doc(userId).update({'font': font});
    }
  }

  Future<void> deleteAllNotesOfUser(NotesUser user) async {
    final notes = await getAllNotesOfUser(user);
    for (var noteId in notes) {
      await deleteNote(noteId);
    }
    await _firestore.collection('users').doc(user.id).delete();
  }

  Future<List<String>> getAllNotesOfUser(NotesUser user) async {
    List<String> notes = [];
    final querySnapshot = await _firestore
        .collection('notes')
        .where('user_id', isEqualTo: user.id)
        .get();
    for (var note in querySnapshot.docs) {
      notes.add(note.id);
    }
    return notes;
  }

  Future<void> deleteNote(String noteId) async {
    await _firestore.collection('notes').doc(noteId).delete();
  }

  Future<void> updateNote(String noteId,
      {String? newTitle,
      String? newText,
      String? email,
      bool? favorite}) async {
    if (newText != null && newTitle != null) {
      if (newTitle.isNotEmpty) {
        newTitle = AESEncryption.encrypt(newTitle);
      }
      if (newText.isNotEmpty) {
        newText = AESEncryption.encrypt(newText);
      }
      await _firestore.collection('notes').doc(noteId).update({
        'title': newTitle,
        'text': newText,
        'date': DateTime.now(),
      });
    }
    if (email != null) {
      await _firestore.collection('notes').doc(noteId).update({
        'email': email,
      });
    }
    if (favorite != null) {
      await _firestore.collection('notes').doc(noteId).update({
        'favorite': favorite,
      });
    }
  }

  Future<void> addNote(UserNote note) async {
    if (note.title.isNotEmpty) {
      note.title = AESEncryption.encrypt(note.title);
    }
    if (note.text.isNotEmpty) {
      note.text = AESEncryption.encrypt(note.text);
    }
    await _firestore.collection('notes').add({
      'user_id': note.userId,
      'user_email': note.userEmail,
      'title': note.title,
      'text': note.text,
      'date': DateTime.now(),
      'favorite': false,
    });
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> _usersQuerySnapShotStream(
      NotesUser user) {
    return _firestore.collection('users').doc(user.id).snapshots();
  }

  Stream<NotesUser> userStream(NotesUser user) {
    _usersQuerySnapShotStream(user).listen((documentSnapshot) {
      String id = documentSnapshot.id;
      String email = documentSnapshot.data()!['email'];
      bool darkMode = documentSnapshot.data()!['dark_mode'];
      String font = documentSnapshot.data()!['font'];
      final user = NotesUser(
          id: id,
          email: email,
          isEmailVerified: true,
          darkMode: darkMode,
          font: font);
      _userStreamController.add(user);
    });

    return _userStreamController.stream;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _notesQuerySnapShotStream(
      NotesUser user) {
    return _firestore
        .collection('notes')
        .where('user_id', isEqualTo: user.id)
        .snapshots();
  }

  Stream<List<UserNote>> userNoteStream(NotesUser user) {
    _notesQuerySnapShotStream(user).listen((querySnapshot) {
      final notes = querySnapshot.docs.map((queryDocumentSnapshot) {
        final id = queryDocumentSnapshot.id;
        final userId = queryDocumentSnapshot.data()['user_id'] as String;
        final userEmail = queryDocumentSnapshot.data()['user_email'] as String;
        String title = queryDocumentSnapshot.data()['title'] as String;
        String text = queryDocumentSnapshot.data()['text'] as String;
        if (title.isNotEmpty) {
          title = AESEncryption.decrypt(title);
        }
        if (text.isNotEmpty) {
          text = AESEncryption.decrypt(text);
        }
        final dateTime =
            (queryDocumentSnapshot.data()['date'] as Timestamp).toDate();
        final favorite = queryDocumentSnapshot.data()['favorite'] as bool;
        return UserNote(
            id: id,
            userId: userId,
            userEmail: userEmail,
            title: title,
            text: text,
            dateTime: dateTime,
            favorite: favorite);
      }).toList();
      _noteStreamController.add(notes);
    });
    return _noteStreamController.stream;
  }
}
