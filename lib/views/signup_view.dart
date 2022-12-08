import 'package:flutter/material.dart';
import 'package:notes/services/exceptions.dart';
import 'package:notes/services/firebase_auth_service.dart';
import 'package:notes/views/login_view.dart';
import 'package:notes/views/show_error.dart';

import '../data/notes_user.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  int signinOrLogin = 1;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (signinOrLogin == 1) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Sign up"),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  signinOrLogin = 2;
                });
                //Navigator.pushNamedAndRemoveUntil(
                //  context, "login", (route) => false);
              },
              child: const Text(
                "log in",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
          backgroundColor: Colors.red.shade300,
        ),
        body: ListView(
          children: [
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 3,
                    color: Colors.red.shade100,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                hintText: "Email address",
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 3,
                    color: Colors.red.shade100,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                hintText: "Password",
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Center(
              child: TextButton(
                onPressed: () async {
                  try {
                    final email = _emailController.text;
                    final password = _passwordController.text;
                    if (email.isNotEmpty && password.isNotEmpty) {
                      NotesUser notesUser = await FirebaseAuthService()
                          .signUpWithEmailAndPassword(
                              email: email, password: password);
                    }
                  } on WeakPasswordException {
                    showErrorDialog("Weak Password!", context);
                  } on EmailIsAlreadyUsedException {
                    showErrorDialog(
                        "There is already an account with this email!",
                        context);
                  } on InvalidEmailException {
                    showErrorDialog("Invalid Email!", context);
                  } catch (e) {
                    showErrorDialog(
                        "Something wring happend. Please try again", context);
                  }
                },
                child: Text(
                  "Sign up",
                  style: TextStyle(
                    color: Colors.red.shade300,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return const LogInView();
    }
  }
}
