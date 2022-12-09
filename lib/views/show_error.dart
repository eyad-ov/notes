import 'package:flutter/material.dart';

// Future return type!=??????


Future<void> showMessage(String msg, BuildContext context) {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("error"),
          content: Text(msg),
        );
      });
}
