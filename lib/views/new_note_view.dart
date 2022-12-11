import 'package:flutter/material.dart';

class NewNoteVeiw extends StatefulWidget {
  final String text;
  const NewNoteVeiw({super.key, required this.text});

  @override
  State<NewNoteVeiw> createState() => _NewNoteVeiwState();
}

class _NewNoteVeiwState extends State<NewNoteVeiw> {
final TextEditingController _noteController = TextEditingController();

@override
  void initState() {
    _noteController.text = widget.text;
    super.initState();
  }

@override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Adding new Note"),
        backgroundColor: Colors.red.shade300,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: TextField(
          controller: _noteController,
          maxLines: null,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.pop(context,_noteController.text);
        },
        child: const Icon(Icons.save),
      ),
    );
  }
}