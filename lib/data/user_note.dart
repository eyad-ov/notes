
class UserNote {
  final String? id;
  final String userId;
  final String userEmail;
  String title;
  String text;
  DateTime dateTime;
  bool favorite;

  UserNote(
      {required this.id,
      required this.userId,
      required this.userEmail,
      required this.title,
      required this.text,
      required this.dateTime,
      required this.favorite});
}
