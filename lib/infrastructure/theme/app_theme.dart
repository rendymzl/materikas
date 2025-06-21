import 'package:flutter/material.dart';

import 'text_theme.dart';

final ThemeData appTheme = ThemeData(
    fontFamily: 'Poppins',
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFFEF233C),
      onPrimary: Color(0xFFF5F8FF),
      secondary: Color(0xFF8D99AE),
      onSecondary: Color(0xFFF5F8FF),
      error: Color(0xFFba1a1a),
      onError: Color(0xFFF5F8FF),
      surface: Color(0xFFF5F8FF),
      onSurface: Color(0xff281717),
    ),
    primaryColor: Color(
        0xFFEF233C), // Warna lebih lembut dari primaryColor untuk background

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Color(0xFFEF233C), // Warna teks pada button
        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Bentuk medium rounded
        ),
        padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 18.0),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Color(0xFFEF233C),
        side: BorderSide(color: Color(0xFFEF233C)),
        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Bentuk medium rounded
        ),
        padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 18.0),
      ),
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      surfaceTintColor: Colors.white,
    ),
    textTheme: MTextTheme.lightTextTheme
    // TextTheme(
    //   displayLarge: TextStyle(
    //     color: Color(0xFFEF233C), // Text title
    //     fontSize: 24,
    //     fontWeight: FontWeight.bold,
    //   ),
    //   bodyLarge: TextStyle(
    //     color: Colors.black87, // Text body
    //     fontSize: 16,
    //   ),
    //   bodySmall: TextStyle(
    //     color: Colors.grey[600], // Text comment
    //     fontSize: 14,
    //   ),
    //   labelSmall: TextStyle(
    //     color: Colors.grey, // Text linethrough
    //     fontSize: 14,
    //     decoration: TextDecoration.lineThrough,
    //   ),
    // ),
    );
