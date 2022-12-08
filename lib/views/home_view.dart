import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notes/services/firebase_auth_service.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        backgroundColor: Colors.red.shade300,
        actions: [
          TextButton(
            onPressed: () async {
              await FirebaseAuthService().signOut();
            },
            child: const Text(
              "Sign out",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
      body: const Center(
        child: Text("welcome to home view"),
      ),
    );
  }
}
