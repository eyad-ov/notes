import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes/main.dart';
import 'package:notes/services/authentication/firebase_auth_service.dart';
import 'package:notes/services/database/firebase_db_service.dart';
import 'package:notes/views/constans.dart';
import 'package:notes/views/show_message.dart';

import '../services/authentication/exceptions.dart';

class ChangeEmailView extends StatefulWidget {
  final bool darkMode;
  const ChangeEmailView({super.key, required this.darkMode});

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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Change email"),
        backgroundColor: widget.darkMode
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
            icon: const Icon(Icons.login),
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
                  color: Colors.red.shade100,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              hintText: "New email address",
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
                  color: Colors.red.shade100,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              hintText: "enter the email address again",
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Center(
            child: TextButton(
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
              child: Text(
                "change my email",
                style: TextStyle(
                  color: Colors.red.shade300,
                ),
              ),
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
