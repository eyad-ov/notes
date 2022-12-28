import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes/data/notes_user.dart';
import 'package:notes/services/authentication/firebase_auth_service.dart';
import 'package:notes/services/database/firebase_db_service.dart';
import 'package:notes/services/text_style.dart';

// style all texts with the method getTextStyle
class ChangeFontView extends StatefulWidget {
  const ChangeFontView({
    super.key,
  });

  @override
  State<ChangeFontView> createState() => _ChangeFontViewState();
}

class _ChangeFontViewState extends State<ChangeFontView> {
  String? _font;
  late NotesUser _user;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _user = ModalRoute.of(context)!.settings.arguments as NotesUser;
    _font = _user.font;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final fonts = GoogleFonts.asMap().keys.toList(growable: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text("choose a font"),
      ),
      body: ListView.builder(
          itemCount: fonts.length,
          itemBuilder: ((context, index) {
            return RadioListTile(
              title: Text(
                fonts[index],
                style: getTextStyle(fonts[index], _user.darkMode),
              ),
              value: fonts[index],
              groupValue: _font,
              onChanged: ((value) async {
                setState(() {
                  _font = value;
                });
                final user = FirebaseAuthService().user;
                await FirebaseDB().updateUser(user.id, font: value);
              }),
            );
          })),
    );
  }
}
