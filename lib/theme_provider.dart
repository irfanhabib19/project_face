import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  bool isDarkMode = true;

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }

  ThemeData get themeData => isDarkMode ? darkTheme : lightTheme;

  ThemeData get darkTheme => ThemeData.dark().copyWith(
        primaryColor: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFF0F2027),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      );

  ThemeData get lightTheme => ThemeData.light().copyWith(
        primaryColor: Colors.blueAccent,
        scaffoldBackgroundColor: const Color(0xFFF4F4F4),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      );
}
