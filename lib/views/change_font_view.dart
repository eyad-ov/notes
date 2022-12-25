import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes/services/authentication/firebase_auth_service.dart';
import 'package:notes/services/database/firebase_db_service.dart';


// font that used recently should be visible
// futurebuilder in all views are bad for costs of firebase
class ChangeFontView extends StatefulWidget {
  const ChangeFontView({
    super.key,
  });

  @override
  State<ChangeFontView> createState() => _ChangeFontViewState();
}

class _ChangeFontViewState extends State<ChangeFontView> {
  String? _font;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final fonts = GoogleFonts.asMap().keys.toList(growable: false);
    return FutureBuilder(
      future: FirebaseDB().user,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("choose a font"),
            ),
            body: ListView.builder(
                itemCount: fonts.length,
                itemBuilder: ((context, index) {
                  return RadioListTile(
                    value: fonts[index],
                    groupValue: _font,
                    onChanged: ((value) async {
                      setState(() {
                        _font = value;
                      });
                      final user = FirebaseAuthService().user;
                      await FirebaseDB().updateUser(user.id, font: value);
                    }),
                    title: Text(fonts[index]),
                  );
                })),
          );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
