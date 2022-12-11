import 'package:flutter/material.dart';
import 'package:notes/services/authentication/exceptions.dart';
import 'package:notes/views/show_error.dart';

import '../services/authentication/firebase_auth_service.dart';

class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({super.key});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reset password"),
        backgroundColor: Colors.red.shade300,
      ),
      body: Center(
        child: ListView(
          children: [
            const SizedBox(
              height: 10,
            ),
            const Center(
                child: Text(
                    "you can reset your password with the following email.")),
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
            ElevatedButton.icon(
              icon: const Icon(Icons.email),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade300,
              ),
              onPressed: () async {
                try {
                  final email = _emailController.text;
                  if (email.isNotEmpty) {
                    await FirebaseAuthService()
                        .sendEmailToResetPassword(email: email)
                        .then((value) {
                      showSnackbar("email has been sent succesfully");
                    });
                  }
                } on InvalidEmailException {
                  showMessage("Invalid Email!", context);
                } on UserNotFoundException {
                  showMessage("There is no account associated with this email!",
                      context);
                }catch(_){
                  showMessage("Something wrong happend. Please try again", context);
                }
              },
              label: const Text("send an email"),
            ),
          ],
        ),
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
