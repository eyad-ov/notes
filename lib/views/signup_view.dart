import 'package:flutter/material.dart';
import 'package:notes/services/firebase_auth_service.dart';

import '../data/Notes_user.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
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
        title: const Text("Sign up"),
        actions: [
          TextButton(
            onPressed: () {},
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
                  NotesUser notesUser = await FirebaseAuthService()
                      .signUpWithEmailAndPassword(
                          email: email, password: password);
                  print(notesUser.email);
                } catch (e) { 
                  // exception to be handeld correctly
                  print("hi");
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
  }
}
