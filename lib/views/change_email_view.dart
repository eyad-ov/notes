import 'package:flutter/material.dart';
import 'package:notes/data/notes_user.dart';
import 'package:notes/main.dart';
import 'package:notes/services/authentication/firebase_auth_service.dart';
import 'package:notes/constants/constans.dart';
import 'package:notes/services/text_style.dart';
import 'package:notes/views/show_message.dart';

import '../services/authentication/exceptions.dart';

class ChangeEmailView extends StatefulWidget {
  const ChangeEmailView({super.key});

  @override
  State<ChangeEmailView> createState() => _ChangeEmailViewState();
}

class _ChangeEmailViewState extends State<ChangeEmailView> {
  final TextEditingController _emailController1 = TextEditingController();
  final TextEditingController _emailController2 = TextEditingController();

  @override
  void dispose() {
    _emailController1.dispose();
    _emailController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ModalRoute.of(context)!.settings.arguments as NotesUser;
    return Scaffold(
      backgroundColor:
          user.darkMode ? darkModeHomeBackgroundColor : homeBackgroundColor,
      appBar: AppBar(
        title: const Text("Change email"),
        backgroundColor: user.darkMode
            ? darkModeAppBarBackgroundColor
            : appBarBackgroundColor,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: ((context) => const NotesApp())),
                (route) => false,
              );
            },
            icon: Icon(
              Icons.login,
              color: user.darkMode ? darkModeIconColor : iconColor,
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          const SizedBox(
            height: 10,
          ),
          TextField(
            controller: _emailController1,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 3,
                  color: user.darkMode ? darkModeBorderColor : borderColor,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              hintText: "New email address",
              hintStyle: TextStyle(
                color: user.darkMode ? darkModeTextColor : textColor,
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          TextField(
            controller: _emailController2,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 3,
                  color: user.darkMode ? darkModeBorderColor : borderColor,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              hintText: "enter the email address again",
              hintStyle: TextStyle(
                color: user.darkMode ? darkModeTextColor : textColor,
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: user.darkMode ? darkModeNoteColor : noteColor,
              ),
              onPressed: () async {
                try {
                  final newEmail1 = _emailController1.text;
                  final newEmail2 = _emailController2.text;
                  if (newEmail1.isEmpty) {
                    showMessage("email field is empty!", context);
                  } else if (newEmail1 != newEmail2) {
                    showMessage("the emails are not the same!", context);
                  } else {
                    await FirebaseAuthService().updateUserEmail(newEmail1);

                    showSnackbar("your email was updated!");
                  }
                } on EmailIsAlreadyUsedException {
                  showMessage(
                      "There is already an account with this email!", context);
                } on InvalidEmailException {
                  showMessage("Invalid Email!", context);
                } catch (e) {
                  showMessage(
                      "Something wrong happend. Please try again", context);
                }
              },
              child: Text("change my email",
                  style: getTextStyle(user.font, user.darkMode, user.fontSize)),
            ),
          ),
        ],
      ),
    );
  }

  void showSnackbar(String msg) {
    final snackBar = SnackBar(
      content: Text(msg),
      action: SnackBarAction(
        label: 'ok',
        onPressed: () {},
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
