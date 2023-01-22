import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notes/services/authentication/firebase_auth_service.dart';
import 'package:notes/services/encryption/aes_encryption.dart';
import '../../data/notes_user.dart';
import '../../data/user_note.dart';

/// Responsible for all database operations, like adding notes, updating notes etc...
class FirebaseDB {
  static final FirebaseDB _firebaseDB = FirebaseDB._internal();
  factory FirebaseDB() {
    return _firebaseDB;
  }
  FirebaseDB._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// stream to notify about all changes of notes. 
  final StreamController<List<UserNote>> _noteStreamController =
      StreamController.broadcast();

  /// stream to notify about all changes of user.
  final StreamController<NotesUser> _userStreamController =
      StreamController.broadcast();

  /// returns the user from database based on id.
  Future<NotesUser> get user async {
    final id = FirebaseAuthService().user.id;
    final docRef = _firestore.collection('users').doc(id);
    final doc = await docRef.get();
    final email = doc.data()!['email'] as String;
    final darkMode = doc.data()!['dark_mode'] as bool;
    final font = doc.data()!['font'] as String;
    final fontSize = doc.data()!['font_size'] as double;
    return NotesUser(
        id: id,
        email: email,
        isEmailVerified: true,
        darkMode: darkMode,
        font: font,
        fontSize: fontSize);
  }

  /// adds a new user in database
  Future<void> addNewUser(NotesUser user) async {
    await _firestore.collection('users').doc(user.id).set({
      'email': user.email,
      'dark_mode': user.darkMode,
      'font': user.font,
      'font_size': user.fontSize,
    });
  }

  /// can update [darkMode], [email], [font] or [fontSize] of a user
  Future<void> updateUser(String userId,
      {bool? darkMode, String? email, String? font, double? fontSize}) async {
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
    if (fontSize != null) {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({'font_size': fontSize});
    }
  }

  /// deletes all the notes of specific user
  Future<void> deleteAllNotesOfUser(NotesUser user) async {
    final notes = await getAllNotesOfUser(user);
    for (var noteId in notes) {
      await deleteNote(noteId);
    }
    await _firestore.collection('users').doc(user.id).delete();
  }

  /// returns all the notes of a specific user
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

  /// deletes the note with [noteId] from database
  Future<void> deleteNote(String noteId) async {
    await _firestore.collection('notes').doc(noteId).delete();
  }

  /// can update the title [newTitle], the text [newText], the email [email] or mark as [favorite] for the note with [noteId]
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

  /// encrypts the title and text of the note then adds it to the database
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

  /// stream that notify changes of a specific user in database
  Stream<DocumentSnapshot<Map<String, dynamic>>> _usersQuerySnapShotStream(
      NotesUser user) {
    return _firestore.collection('users').doc(user.id).snapshots();
  }

  /// stream that listens to changes of a specific user
  Stream<NotesUser> userStream(NotesUser user) {
    _usersQuerySnapShotStream(user).listen((documentSnapshot) {
      String id = documentSnapshot.id;
      String email = documentSnapshot.data()!['email'];
      bool darkMode = documentSnapshot.data()!['dark_mode'];
      String font = documentSnapshot.data()!['font'];
      double fontSize = documentSnapshot.data()!['font_size'];
      final user = NotesUser(
        id: id,
        email: email,
        isEmailVerified: true,
        darkMode: darkMode,
        font: font,
        fontSize: fontSize,
      );
      _userStreamController.add(user);
    });

    return _userStreamController.stream;
  }

  /// stream that notify changes of all nontes that belongs to specific user 
  Stream<QuerySnapshot<Map<String, dynamic>>> _notesQuerySnapShotStream(
      NotesUser user) {
    return _firestore
        .collection('notes')
        .where('user_id', isEqualTo: user.id)
        .snapshots();
  }

  /// stream that listens to changes of all nontes that belongs to specific user 
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
