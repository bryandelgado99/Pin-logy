import 'package:flutter/material.dart';

class Themes {
  static ThemeData lightTheme = ThemeData(
      primaryColor: const Color(0xffa386da),
      fontFamily: "Poppins",
      primarySwatch: Colors.purple,
      brightness: Brightness.light,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      appBarTheme: AppBarTheme(
          titleTextStyle:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
          iconTheme: const IconThemeData(color: Colors.black),
          backgroundColor: Colors.grey.shade50,
          elevation: 0),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10)),
        hintStyle: const TextStyle(
          fontSize: 14,
        ),
      ),
      cardColor: Colors.grey.shade200,
      progressIndicatorTheme:
          const ProgressIndicatorThemeData(color: Color.fromRGBO(67,33, 131, 1)),
      textTheme: const TextTheme(
          displayLarge: TextStyle(
              letterSpacing: -1.5,
              fontSize: 48,
              color: Colors.black,
              fontWeight: FontWeight.bold),
          displayMedium: TextStyle(
              letterSpacing: -1.0,
              fontSize: 40,
              color: Colors.black,
              fontWeight: FontWeight.bold),
          displaySmall: TextStyle(
              fontSize: 32, color: Colors.black, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(
              letterSpacing: -1.0,
              color: Colors.black,
              fontSize: 28,
              fontWeight: FontWeight.w600),
          headlineSmall: TextStyle(
              letterSpacing: -1.0,
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.w500),
          titleLarge: TextStyle(
              color: Colors.black, fontSize: 24, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(
              color: Colors.black, fontSize: 17, fontWeight: FontWeight.w500),
          titleSmall: TextStyle(
              color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
          bodyLarge: TextStyle(
              color: Color.fromARGB(255, 41, 41, 41),
              fontSize: 16,
              fontWeight: FontWeight.w400),
          bodyMedium: TextStyle(
              color: Color.fromARGB(255, 41, 41, 41),
              fontSize: 14,
              fontWeight: FontWeight.w400),
          labelLarge: TextStyle(
              color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
          bodySmall: TextStyle(
              color: Color.fromARGB(255, 41, 41, 41),
              fontSize: 12,
              fontWeight: FontWeight.w400),
          labelSmall: TextStyle(
              color: Color.fromARGB(255, 41, 41, 41),
              fontSize: 10,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.5)));

  static ThemeData darkTheme = ThemeData(
    fontFamily: "Open Sans",
    primaryColor: const Color(0xff432183),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    primarySwatch: Colors.deepPurple,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.grey.shade900,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey.shade900,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10)),
        hintStyle: const TextStyle(
          fontSize: 14,
        )),
    cardColor: const Color.fromRGBO(145, 103, 218, 1.0),
    progressIndicatorTheme:
        const ProgressIndicatorThemeData(color: Colors.white),
    textTheme: TextTheme(
        displayLarge: TextStyle(
            letterSpacing: -1.5,
            fontSize: 48,
            color: Colors.grey.shade50,
            fontWeight: FontWeight.bold),
        displayMedium: TextStyle(
            letterSpacing: -1.0,
            fontSize: 40,
            color: Colors.grey.shade50,
            fontWeight: FontWeight.bold),
        displaySmall: TextStyle(
            letterSpacing: -1.0,
            fontSize: 32,
            color: Colors.grey.shade50,
            fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(
            letterSpacing: -1.0,
            color: Colors.grey.shade50,
            fontSize: 28,
            fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(
            letterSpacing: -1.0,
            color: Colors.grey.shade50,
            fontSize: 24,
            fontWeight: FontWeight.w500),
        titleLarge: TextStyle(
            color: Colors.grey.shade50,
            fontSize: 24,
            fontWeight: FontWeight.w500),
        titleMedium: TextStyle(
            color: Colors.grey.shade50,
            fontSize: 17,
            fontWeight: FontWeight.w500),
        titleSmall: TextStyle(
            color: Colors.grey.shade50,
            fontSize: 14,
            fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(
            color: Colors.grey.shade50,
            fontSize: 16,
            fontWeight: FontWeight.w400),
        bodyMedium: TextStyle(
            color: Colors.grey.shade50,
            fontSize: 14,
            fontWeight: FontWeight.w400),
        labelLarge: const TextStyle(
            color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
        bodySmall: TextStyle(
            color: Colors.grey.shade50,
            fontSize: 12,
            fontWeight: FontWeight.w500),
        labelSmall: TextStyle(
            color: Colors.grey.shade50,
            fontSize: 10,
            fontWeight: FontWeight.w400)),
    bottomAppBarTheme: BottomAppBarTheme(color: Colors.grey.shade900),
  );
}