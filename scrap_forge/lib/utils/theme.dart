import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: Colors.red,
        onPrimary: Colors.white,
        secondary: Colors.deepOrange.shade200,
        onSecondary: Colors.black,
        error: Colors.amber,
        onError: Colors.amber,
        background: Colors.white,
        onBackground: Colors.black,
        surface: Colors.red,
        onSurface: Colors.white,
        outline: Colors.black),
    // textTheme: const TextTheme(),
    appBarTheme: const AppBarTheme(
      foregroundColor: Colors.white,
      backgroundColor: Colors.red,
      // color: Colors.white,
    ));

ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.grey[900],
    cardColor: Colors.grey.shade800,
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: Colors.red,
      onPrimary: Colors.white,
      secondary: Colors.grey.shade800,
      onSecondary: Colors.white,
      error: Colors.amber,
      onError: Colors.amber,
      background: Colors.grey.shade800,
      onBackground: Colors.red,
      surface: Colors.red,
      onSurface: Colors.white,
      outline: Colors.grey.shade500,
    ),
    // textTheme: const TextTheme(),
    appBarTheme: const AppBarTheme(
      foregroundColor: Colors.white,
      backgroundColor: Colors.red,
      // color: Colors.white,
    ));
