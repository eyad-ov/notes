import 'package:flutter/material.dart';
import 'package:notes/data/notes_user.dart';
import 'package:notes/services/authentication/exceptions.dart';
import 'package:notes/services/authentication/firebase_auth_service.dart';
import 'package:notes/constants/constans.dart';
import 'package:notes/services/text_style.dart';
import 'package:notes/views/show_message.dart';

/// the screen lets user change password
class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final TextEditingController _passwordController1 = TextEditingController();
  final TextEditingController _passwordController2 = TextEditingController();
  bool hidePassword1 = true;
  bool hidePassword2 = true;
  @override
  void dispose() {
    _passwordController1.dispose();
    _passwordController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ModalRoute.of(context)!.settings.arguments as NotesUser;
    return Scaffold(
      backgroundColor:
          user.darkMode ? darkModeHomeBackgroundColor : homeBackgroundColor,
      appBar: AppBar(
        title: const Text("Change password"),
        backgroundColor: user.darkMode
            ? darkModeAppBarBackgroundColor
            : appBarBackgroundColor,
      ),
      body: ListView(
        children: [
          const SizedBox(
            height: 10,
          ),
          TextField(
            controller: _passwordController1,
            obscureText: hidePassword1,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 3,
                  color: user.darkMode ? darkModeBorderColor : borderColor,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              hintText: "New password",
              hintStyle: TextStyle(
                color: user.darkMode ? darkModeTextColor : textColor,
              ),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    hidePassword1 = !hidePassword1;
                  });
                },
                icon: Icon(
                  hidePassword1 ? Icons.visibility : Icons.visibility_off,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          TextField(
            controller: _passwordController2,
            obscureText: hidePassword2,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 3,
                  color: user.darkMode ? darkModeBorderColor : borderColor,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              hintText: "enter the password again",
              hintStyle: TextStyle(
                color: user.darkMode ? darkModeTextColor : textColor,
              ),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    hidePassword2 = !hidePassword2;
                  });
                },
                icon: Icon(
                  hidePassword2 ? Icons.visibility : Icons.visibility_off,
                ),
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
              
              // update the user password
              onPressed: () async {
                try {
                  final newPassword1 = _passwordController1.text;
                  final newPassword2 = _passwordController2.text;
                  if (newPassword1.isEmpty) {
                    showMessage("Password field is empty!", context);
                  } else if (newPassword1 != newPassword2) {
                    showMessage("the passwords are not the same!", context);
                  } else {
                    await FirebaseAuthService()
                        .updateUserPassword(newPassword1);
                    showSnackbar("your password was updated!");
                  }
                } on WeakPasswordException {
                  showMessage("Password is too weak!", context);
                } on RequiersRecentLogInException {
                  showMessage("you should log in and try again!", context);
                } catch (e) {
                  showMessage("Something wrong happend. Please try again later",
                      context);
                }
              },
              child: Text(
                "change my password",
                style: getTextStyle(user.font, user.darkMode, user.fontSize),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// shows snackbar to notify the user about success 
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
