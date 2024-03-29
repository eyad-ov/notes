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

/// This widget is showed when the user is signed in.
/// The user's notes will be shown sorted by date, unless the notes are marked as favorites. 
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
  FocusNode focusNode = FocusNode();
  bool searchIcon = true;

  @override
  void initState() {
    // if user currently is not searching for notes, the search field should be "unfocused"
    focusNode.addListener(() {
      searchIcon = !searchIcon;
    });

    //when user type something in the search field, the notes shown should be updated correspondingly
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

    // this consumer catches any changes of the user, such as darkMode option.
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
                focusNode: focusNode,
                cursorColor: Colors.white,
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search notes',
                  suffixIcon: searchIcon
                      ? Icon(
                          Icons.search,
                          color: user.darkMode ? darkModeIconColor : iconColor,
                        )
                      : IconButton(
                          onPressed: () {
                            _searchController.text = "";
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                          icon: Icon(
                            Icons.cancel,
                            color:
                                user.darkMode ? darkModeIconColor : iconColor,
                          ),
                        ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(20),
                ),
              ),
            ),
            centerTitle: true,
            backgroundColor: user.darkMode
                ? darkModeAppBarBackgroundColor
                : appBarBackgroundColor,
          ),
          // the StreamBuilder waits for any changes in the notes of current user,such as: new created notes, note got deleted..
          // and rebuilds itself to show the new state of the notes.
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
                  // all notes should be fetched first.
                  // the notes are sorted by date, unless the notes are marked as favorites.
                  // the favorite notes will be shown first.
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

                  // if the user currently is searching, the notes that will be shown are only the ones that match the search word.
                  if (searched) {
                    String word = _searchController.text;
                    notes = notes.where((note) {
                      return note.text.contains(word) ||
                          note.title.contains(word);
                    }).toList();
                  }
                  return ListView(
                    children: notes.map((note) {
                      String title = note.title;
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

                            // mark the note as favorite and update it in cloud.
                            onPressed: () async {
                              await FirebaseDB().updateNote(note.id!,
                                  favorite: !note.favorite);
                            },
                            icon: Icon(
                              Icons.star,
                              color: note.favorite
                                  ? Colors.yellow[400]
                                  : Colors.grey,
                            ),
                          ),
                          title: Text(
                            title.isEmpty ? "untitled" : title,
                            style: getTextStyle(
                                user.font, user.darkMode, user.fontSize),
                          ),
                          // when user touch the note, user will be sent to new screen, where he can edit the note.
                          // after coming back, the updated data will be synchronised with data in the cloud. 
                          onTap: () async {
                            final args = await Navigator.pushNamed(
                                    context, "newNote",
                                    arguments: [note.title, note.text])
                                as List<String>;
                            String newTitle = args[0];
                            String newText = args[1];
                            if (newTitle.isNotEmpty || newText.isNotEmpty) {
                              await FirebaseDB().updateNote(note.id!,
                                  newTitle: newTitle, newText: newText);
                            }
                          },
                          subtitle: Text("$hour:$minute  $day/$month/$year"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                // this allows the user to share his note with someone.
                                onPressed: () {
                                  Share.share("${note.title}:\n\n${note.text}");
                                },
                                icon: Icon(
                                  Icons.share,
                                  color: user.darkMode
                                      ? darkModeIconColor
                                      : iconColor,
                                ),
                              ),
                              IconButton(
                                onPressed: () async {
                                  // ask the user if he is sure about deleting the note. if so, then delete the note in the cloud too. 
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
            // this sends the user to a new screen, where he can create a new Note.
            // after coming back the new note will be shown and sent to the cloud.
            onPressed: () async {
              final args = await Navigator.pushNamed(context, "newNote",
                  arguments: ["", ""]) as List<String>;

              String title = args[0];
              String text = args[1];
              if (title.isNotEmpty || text.isNotEmpty) {
                NotesUser user = FirebaseAuthService().user;
                UserNote note = UserNote(
                  id: null,
                  userId: user.id,
                  userEmail: user.email,
                  title: title,
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

/// the drawer has a menu, where user can change settings, log out or delete the account permanently.
class MyDrawer extends StatelessWidget {
  const MyDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // this consumer catches any changes of the user, such as darkMode option.
    return Consumer<NotesUser>(builder: ((context, user, child) {
      return Drawer(
        backgroundColor:
            user.darkMode ? darkModeHomeBackgroundColor : homeBackgroundColor,
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
              color: user.darkMode ? darkModeNoteColor : noteColor,
              elevation: 10,
              margin: const EdgeInsets.all(5),
              child: ListTile(
                title: Text(
                  "settings",
                  style: getTextStyle(user.font, user.darkMode, user.fontSize),
                ),
                trailing: const Icon(Icons.settings),
                onTap: () {
                  Navigator.pushNamed(context, "settings", arguments: user);
                },
              ),
            ),
            Card(
              color: user.darkMode ? darkModeNoteColor : noteColor,
              elevation: 10,
              margin: const EdgeInsets.all(5),
              child: ListTile(
                title: Text(
                  "sign out",
                  style: getTextStyle(user.font, user.darkMode, user.fontSize),
                ),
                trailing: const Icon(Icons.logout),
                onTap: () async {
                  // ask user if sure about logging out, if so, log out the user.
                  bool sure = await showAlertDialog(context, "sign out");
                  sure == true ? await FirebaseAuthService().signOut() : null;
                },
              ),
            ),
            Card(
              color: user.darkMode ? darkModeNoteColor : noteColor,
              elevation: 10,
              margin: const EdgeInsets.all(5),
              child: ListTile(
                title: Text(
                  "delete account",
                  style: getTextStyle(user.font, user.darkMode, user.fontSize),
                ),
                trailing: const Icon(Icons.delete_forever),
                onTap: () async {
                  try {
                    // if user wants to delete the account, all his notes will be first in cloud deleted.
                    // then the user will be deleted as well.
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
