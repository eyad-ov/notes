import 'package:flutter/material.dart';
import 'package:notes/data/notes_user.dart';
import 'package:notes/data/user_note.dart';
import 'package:notes/services/authentication/exceptions.dart';
import 'package:notes/services/authentication/firebase_auth_service.dart';
import 'package:notes/services/database/firebase_db_service.dart';
import 'package:notes/services/text_style.dart';
import 'package:notes/views/alert_dialog.dart';
import 'package:notes/constants/constans.dart';
import 'package:notes/views/show_message.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class HomeView extends StatefulWidget {
  final NotesUser notesUser;
  const HomeView({
    super.key,
    required this.notesUser,
  });

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final TextEditingController _searchController = TextEditingController();
  bool searched = false;

  @override
  void initState() {
    _searchController.addListener(() {
      setState(() {
        if (_searchController.text.isNotEmpty) {
          searched = true;
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotesUser>(builder: ((context, user, child) {
      return Scaffold(
          backgroundColor:
              user.darkMode ? darkModeHomeBackgroundColor : homeBackgroundColor,
          appBar: AppBar(
            title: Container(
              decoration: BoxDecoration(
                color:
                    user.darkMode ? darkModeSearchFieldColor : searchFieldColor,
                borderRadius: BorderRadius.circular(32),
              ),
              child: TextField(
                cursorColor: Colors.white,
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search notes',
                  suffixIcon: Icon(
                    Icons.search,
                    color: iconColor,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(20),
                ),
              ),
            ),
            centerTitle: true,
            backgroundColor: user.darkMode
                ? darkModeAppBarBackgroundColor
                : appBarBackgroundColor,
          ),
          body: StreamBuilder(
            stream: FirebaseDB().userNoteStream(FirebaseAuthService().user),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Column(
                    children: const [
                      Text(
                        "Something wrong happend, make sure you have internet connection",
                      ),
                      CircularProgressIndicator(),
                    ],
                  ),
                );
              }
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  List<UserNote> notes = snapshot.data!;
                  List<UserNote> favoriteNotes =
                      notes.where((note) => note.favorite).toList();
                  List<UserNote> notFavoriteNotes =
                      notes.where((note) => !note.favorite).toList();
                  favoriteNotes
                      .sort((a, b) => b.dateTime.compareTo(a.dateTime));
                  notFavoriteNotes
                      .sort((a, b) => b.dateTime.compareTo(a.dateTime));
                  notes.clear();
                  notes.addAll(favoriteNotes);
                  notes.addAll(notFavoriteNotes);
                  if (searched) {
                    String word = _searchController.text;
                    notes = notes.where((note) {
                      return note.text.contains(word);
                    }).toList();
                  }
                  return ListView(
                    children: notes.map((note) {
                      String text = note.text;
                      if (note.text.length > 20) {
                        text = note.text.substring(0, 20);
                        text += "...";
                      }
                      DateTime dateTime = note.dateTime;
                      String minute = dateTime.minute.toString().length < 2
                          ? "0${dateTime.minute}"
                          : dateTime.minute.toString();
                      String hour = dateTime.hour.toString().length < 2
                          ? "0${dateTime.hour}"
                          : dateTime.hour.toString();
                      String day = dateTime.day.toString().length < 2
                          ? "0${dateTime.day}"
                          : dateTime.day.toString();
                      String month = dateTime.month.toString().length < 2
                          ? "0${dateTime.month}"
                          : dateTime.month.toString();
                      String year = dateTime.year.toString();
                      return Card(
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                            color: noteBorderColor,
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        color: user.darkMode ? darkModeNoteColor : noteColor,
                        child: ListTile(
                          leading: IconButton(
                            onPressed: () async {
                              await FirebaseDB().updateNote(note.id!,
                                  favorite: !note.favorite);
                            },
                            icon: Icon(
                              Icons.star,
                              color: note.favorite ? Colors.red : Colors.grey,
                            ),
                          ),
                          title: Text(
                            text,
                            style: getTextStyle(user.font, user.darkMode),
                          ),
                          onTap: () async {
                            String newText = await Navigator.pushNamed(
                                context, "newNote",
                                arguments: note.text) as String;
                            if (newText.isNotEmpty) {
                              await FirebaseDB()
                                  .updateNote(note.id!, newText: newText);
                            }
                          },
                          subtitle: Text("$hour:$minute  $day/$month/$year"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  Share.share(note.text);
                                },
                                icon: const Icon(Icons.share),
                              ),
                              IconButton(
                                onPressed: () async {
                                  final sure = await showAlertDialog(
                                      context, "delete this note");
                                  if (sure) {
                                    final noteId = note.id;
                                    FirebaseDB().deleteNote(noteId!);
                                  }
                                },
                                icon: Icon(
                                  Icons.delete,
                                  color: user.darkMode
                                      ? darkModeIconColor
                                      : iconColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }
                return const Center(child: Text("no notes yet!"));
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              String text =
                  await Navigator.pushNamed(context, "newNote", arguments: "") as String;
              if (text.isNotEmpty) {
                NotesUser user = FirebaseAuthService().user;
                UserNote note = UserNote(
                  id: null,
                  userId: user.id,
                  userEmail: user.email,
                  text: text,
                  dateTime: DateTime.now(),
                  favorite: false,
                );
                await FirebaseDB().addNote(note);
              }
            },
            backgroundColor: user.darkMode
                ? darkModeFloatingActionButtonBackgroundColor
                : floatingActionButtonBackgroundColor,
            child: Icon(
              Icons.edit,
              color: user.darkMode ? darkModeIconColor : iconColor,
            ),
          ),
          drawer: const MyDrawer());
    }));
  }
}

class MyDrawer extends StatelessWidget {
  const MyDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<NotesUser>(builder: ((context, user, child) {
      return Drawer(
        backgroundColor: Colors.grey.shade300,
        child: ListView(
          children: [
            Container(
              height: 300,
              color: Colors.grey,
              child: Column(children: [
                Image.asset(
                  "images/icons/icon.png",
                  height: 250,
                ),
                Text(user.email),
              ]),
            ),
            Card(
              color: Colors.blue.shade100,
              elevation: 10,
              margin: const EdgeInsets.all(5),
              child: ListTile(
                style: ListTileStyle.drawer,
                textColor: Colors.pink,
                title: const Text("settings"),
                trailing: const Icon(Icons.settings),
                onTap: () {
                  Navigator.pushNamed(context, "settings", arguments: user);
                },
              ),
            ),
            Card(
              color: Colors.blue.shade100,
              elevation: 10,
              margin: const EdgeInsets.all(5),
              child: ListTile(
                style: ListTileStyle.drawer,
                textColor: Colors.pink,
                title: const Text("sign out"),
                trailing: const Icon(Icons.logout),
                onTap: () async {
                  bool sure = await showAlertDialog(context, "sign out");
                  sure == true ? await FirebaseAuthService().signOut() : null;
                },
              ),
            ),
            Card(
              color: Colors.blue.shade100,
              elevation: 10,
              margin: const EdgeInsets.all(5),
              child: ListTile(
                style: ListTileStyle.drawer,
                textColor: Colors.pink,
                title: const Text("delete account"),
                trailing: const Icon(Icons.delete_forever),
                onTap: () async {
                  try {
                    final navigator = Navigator.of(context);
                    bool sure =
                        await showAlertDialog(context, "delete your accout");
                    if (sure) {
                      await FirebaseDB()
                          .deleteAllNotesOfUser(FirebaseAuthService().user);
                      await FirebaseAuthService().deleteUser();
                      navigator.pop();
                    }
                  } on RequiersRecentLogInException {
                    showMessage("log in and try it again", context);
                  }
                },
              ),
            ),
          ],
        ),
      );
    }));
  }
}
