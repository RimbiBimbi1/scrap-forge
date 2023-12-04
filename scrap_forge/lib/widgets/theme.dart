import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
);

ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.grey[800],
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: Colors.red,
      onPrimary: Colors.white,
      secondary: Colors.white12,
      onSecondary: Colors.white,
      error: Colors.amber,
      onError: Colors.amber,
      background: Colors.white10,
      onBackground: Colors.red,
      surface: Colors.red,
      onSurface: Colors.white,
    ),
    // textTheme: const TextTheme(),
    appBarTheme: AppBarTheme(
      foregroundColor: Colors.white,
      backgroundColor: Colors.red,
      // color: Colors.white,
    ));
