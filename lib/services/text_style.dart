import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes/constants/constans.dart';

/// returns a TextStyle based on [font], [darkMode] and [fontSize]
TextStyle getTextStyle(String font, bool darkMode, double fontSize) {
  String? fontFamily = GoogleFonts.getFont(font).fontFamily;
  Color color;
  if (darkMode) {
    color = darkModeTextColor;
  } else {
    color = textColor;
  }
  return TextStyle(color: color, fontFamily: fontFamily, fontSize: fontSize);
}
