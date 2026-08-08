import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const AruvixApp());
}

class AruvixApp extends StatelessWidget {
  const AruvixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ARUVIX',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const SplashScreen(),
    );
  }
}