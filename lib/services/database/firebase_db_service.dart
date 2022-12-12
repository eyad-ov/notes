import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future<void> addNewUser(NotesUser user) async {
    await _firestore
        .collection('users')
        .doc(user.id)
        .set({'email': user.email});
  }

  // delete account and all notes of him

  Future<void> deleteNote(String noteId) async {
    await _firestore.collection('notes').doc(noteId).delete();
  }

  Future<void> updateNote(String noteId, String newText) async {
    await _firestore.collection('notes').doc(noteId).update({
      'text': newText,
      'date': DateTime.now(),
    });
  }

  Future<void> addNote(UserNote note) async {
    await _firestore.collection('notes').add({
      'user_id': note.userId,
      'user_email': note.userEmail,
      'text': note.text,
      'date': DateTime.now(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _querySnapShotStream(
      NotesUser user) {
    return _firestore
        .collection('notes')
        .where('user_id', isEqualTo: user.id)
        .snapshots();
  }

  Stream<List<UserNote>> userNoteStream(NotesUser user) {
    _querySnapShotStream(user).listen((querySnapshot) {
      final notes = querySnapshot.docs.map((queryDocumentSnapshot) {
        final id = queryDocumentSnapshot.id;
        final userId = queryDocumentSnapshot.data()['user_id'] as String;
        final userEmail = queryDocumentSnapshot.data()['user_email'] as String;
        final text = queryDocumentSnapshot.data()['text'] as String;
        final dateTime = (queryDocumentSnapshot.data()['date'] as Timestamp).toDate();
        return UserNote(
            id: id,
            userId: userId,
            userEmail: userEmail,
            text: text,
            dateTime: dateTime);
      }).toList();
      _noteStreamController.add(notes);
    });
    return _noteStreamController.stream;
  }
}
