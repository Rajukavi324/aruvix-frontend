import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primaryBlue = Color(0xFF1A3A8F);
  static const Color accentBlue = Color(0xFF2563EB);
  static const Color darkBg = Color(0xFF0B1A3B);
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFF1F5F9);
  static const Color green = Color(0xFF22C55E);
  static const Color orange = Color(0xFFF97316);
  static const Color red = Color(0xFFEF4444);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
        scaffoldBackgroundColor: const Color(0xFFF1F5F9),
      );
}