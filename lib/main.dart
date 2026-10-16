import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'introduction_animation/introduction_animation_screen.dart';
import 'services/auth_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Tanpa await: sesi login tersimpan dibaca di latar belakang selama animasi intro berjalan.
  unawaited(AuthService.instance.init());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deteksi Bahasa Isyarat',
      debugShowCheckedModeBanner: false,
            theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.light(
          primary: AppColors.primary,
          onPrimary: AppColors.onPrimary,
          primaryContainer: AppColors.primaryContainer,
          onPrimaryContainer: AppColors.onPrimaryContainer,
          secondary: AppColors.secondary,
          onSecondary: AppColors.onSecondary,
          surface: AppColors.surface,
          onSurface: AppColors.onSurface,
          error: AppColors.error,
        ),
        scaffoldBackgroundColor: AppColors.surface,
        fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      ),
      home: const IntroductionAnimationScreen(),
    );
  }
}