import 'package:flutter/material.dart';

class AppColors {
  // Light Theme Colors
  static const Color lightPrimary = Color(0xFF3EB489); // Mint Green
  static const Color lightBackground = Color(0xFFFFFFFF); // White
  static const Color lightText = Color(0xFF2C2C2C);

  // Dark Theme Colors
  static const Color darkPrimary = Color(0xFF30A57D); // Darker Mint
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkText = Color(0xFFE0E0E0);

  static var mintGreen;
}

class AppTextStyles {
  static const TextStyle heading = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle body = TextStyle(fontSize: 14);

  static const TextStyle caption = TextStyle(fontSize: 12, color: Colors.grey);
}
