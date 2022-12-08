import 'package:flutter/material.dart';
import 'package:notes/services/exceptions.dart';
import 'package:notes/services/firebase_auth_service.dart';
import 'package:notes/views/show_error.dart';

import '../data/notes_user.dart';

class LogInView extends StatefulWidget {
  const LogInView({super.key});

  @override
  State<LogInView> createState() => _LogInViewState();
}

class _LogInViewState extends State<LogInView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Log in"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, "signup", (route) => false);
            },
            child: const Text(
              "Sign up",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
        backgroundColor: Colors.red.shade300,
      ),
      body: Column(
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
                        .signInWithEmailAndPassword(
                            email: email, password: password);
                    /*Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context){
                    return const VerificationView();
                  }), (route) => false);*/
                    print(notesUser.email);
                  }
                } on WrongPasswordException {
                  showErrorDialog("Wrong Password!", context);
                } on UserNotFoundException {
                  showErrorDialog(
                      "There is no account associated with this email!",
                      context);
                } on InvalidEmailException {
                  showErrorDialog("Invalid Email!", context);
                } catch (e) {
                  showErrorDialog(
                      "Something wring happend. Please try again", context);
                }
              },
              child: Text(
                "Log in",
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
}
