import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppStyles {
  static TextStyle boolTextStyle() {
    return GoogleFonts.poppins(
      textStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  static TextStyle headLineTextStyle() {
    return GoogleFonts.poppins(
      textStyle: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  static TextStyle lightTextStyle() {
    return GoogleFonts.poppins(
      textStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.black38,
      ),
    );
  }

  static TextStyle simpleboolTextStyle() {
    return GoogleFonts.poppins(
      textStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  static TextStyle simpleTextStyle() {
    return GoogleFonts.poppins(
      textStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: Colors.grey[800],
      ),
    );
  }
}
