import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes/constants/constans.dart';

TextStyle getTextStyle(String font, bool darkmode) {
  String? fontFamily = GoogleFonts.getFont(font).fontFamily;
  Color color;
  if (darkmode) {
    color = darkModeTextColor;
  } else {
    color = textColor;
  }
  return TextStyle(color: color, fontFamily: fontFamily);
}
