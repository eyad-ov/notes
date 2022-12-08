import 'package:flutter/material.dart';

void showErrorDialog(String errorMessage, BuildContext context) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("error"),
          content: Text(errorMessage),
        );
      });
}
