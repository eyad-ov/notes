import 'package:google_fonts/google_fonts.dart';

String? getFontFamily(String? font) {
  if (font != null) {
    return GoogleFonts.getFont(font).fontFamily;
  }
  return null;
}
