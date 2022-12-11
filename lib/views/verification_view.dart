import 'package:flutter/material.dart';
import 'package:notes/services/authentication/firebase_auth_service.dart';

class VerificationView extends StatefulWidget {
  const VerificationView({super.key});

  @override
  State<VerificationView> createState() => _VerificationViewState();
}

class _VerificationViewState extends State<VerificationView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verification"),
        backgroundColor: Colors.red.shade300,
        actions: [
          TextButton(
            onPressed: () async{
              await FirebaseAuthService().signOut();
            },
            child: const Text(
              "Sign out",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: ListView(
          children: [
            const Text(
                "Click the button to send you an email for verification...\n after verfiying sign out and log in again"),
            TextButton(
              onPressed: () async{
                FirebaseAuthService().sendEmailVerification();
              },
              child: const Text("Send an Email"),
            ),
          ],
        ),
      ),
    );
  }
}
