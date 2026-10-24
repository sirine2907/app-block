import 'package:flutter/material.dart';

/// The soft, romantic palette for "For Anis".
///
/// Blush pink, dusty rose and cream for the light theme; deep burgundy and
/// plum for the dark theme. Kept in one place so the whole app feels like a
/// single love letter.
class AppColors {
  AppColors._();

  // --- Light theme ---
  static const Color blush = Color(0xFFFBE9EC); // soft background wash
  static const Color cream = Color(0xFFFFF7F3); // card / surface
  static const Color dustyRose = Color(0xFFD98BA0); // primary
  static const Color rose = Color(0xFFC96A86);
  static const Color burgundy = Color(0xFF7A2E43); // deep accent
  static const Color deepBurgundy = Color(0xFF5A1E30);
  static const Color inkLight = Color(0xFF4A2C35); // body text on light

  // --- Dark theme ---
  static const Color plum = Color(0xFF2A1420); // dark background
  static const Color plumSurface = Color(0xFF3A1E2E); // dark card
  static const Color darkRose = Color(0xFFE59BB0); // primary on dark
  static const Color softCream = Color(0xFFF3E4E8); // body text on dark

  // --- Shared ---
  static const Color heart = Color(0xFFE8738F);
  static const Color goldAccent = Color(0xFFE0B089);

  // Gradients
  static const List<Color> lightGradient = [
    Color(0xFFFFF7F3),
    Color(0xFFFBE4EA),
    Color(0xFFF6D4DE),
  ];

  static const List<Color> darkGradient = [
    Color(0xFF2A1420),
    Color(0xFF3A1E2E),
    Color(0xFF4A2434),
  ];
}
