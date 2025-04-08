import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors based on your web app
  static const Color amber200 = Color(0xFFFEF3C7);
  static const Color indigo700 = Color(0xFF4338CA);
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  
  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    primaryColor: amber200,
    scaffoldBackgroundColor: black,
    colorScheme: const ColorScheme.dark(
      primary: amber200,
      secondary: indigo700,
      background: black,
      surface: Color(0xFF121212),
    ),
    textTheme: GoogleFonts.interTextTheme(
      ThemeData.dark().textTheme.copyWith(
        headline1: const TextStyle(color: amber200),
        headline2: const TextStyle(color: amber200),
        headline3: const TextStyle(color: amber200),
        headline4: const TextStyle(color: amber200),
        headline5: const TextStyle(color: amber200),
        headline6: const TextStyle(color: amber200),
        bodyText1: const TextStyle(color: white),
        bodyText2: const TextStyle(color: white),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: black,
      selectedItemColor: amber200,
      unselectedItemColor: Colors.grey,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: black,
      foregroundColor: amber200,
      elevation: 0,
    ),
  );
}