import 'package:flutter/material.dart';

/// Sakinleştirici renk paleti - Psikolojik olarak huzur veren tonlar
class AppColors {
  AppColors._();

  // Primary - Soft Blue Tones (Güven ve sakinlik)
  static const Color primaryLight = Color(0xFF7EC8E3);
  static const Color primary = Color(0xFF5DADE2);
  static const Color primaryDark = Color(0xFF3498DB);

  // Secondary - Turquoise Tones (Tazelik ve canlılık)
  static const Color turquoiseLight = Color(0xFFA8E6CF);
  static const Color turquoise = Color(0xFF88D8B0);
  static const Color turquoiseDark = Color(0xFF56C596);

  // Accent - Pastel Mint (Doğallık)
  static const Color mintLight = Color(0xFFE8F8F5);
  static const Color mint = Color(0xFFD0ECE7);
  static const Color mintDark = Color(0xFFA3D9C9);

  // Neutral - Warm Beige (Sıcaklık)
  static const Color beigeLight = Color(0xFFFDF6E9);
  static const Color beige = Color(0xFFF5EBD7);
  static const Color beigeDark = Color(0xFFE8DCC8);

  // Background Colors
  static const Color backgroundLight = Color(0xFFF8FBFD);
  static const Color backgroundDark = Color(0xFF1A2634);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF243447);

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF2C3E50);
  static const Color textSecondaryLight = Color(0xFF7F8C8D);
  static const Color textPrimaryDark = Color(0xFFECF0F1);
  static const Color textSecondaryDark = Color(0xFFBDC3C7);

  // Success & Achievement
  static const Color success = Color(0xFF27AE60);
  static const Color successLight = Color(0xFFD4EFDF);
  
  // Warning (soft)
  static const Color warning = Color(0xFFF39C12);
  static const Color warningLight = Color(0xFFFCF3CF);

  // Water specific colors
  static const Color waterLight = Color(0xFFE3F2FD);
  static const Color water = Color(0xFF90CAF9);
  static const Color waterDark = Color(0xFF42A5F5);
  static const Color waterDeep = Color(0xFF1976D2);

  // Gradient combinations
  static const LinearGradient waterGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFB3E5FC),
      Color(0xFF81D4FA),
      Color(0xFF4FC3F7),
      Color(0xFF29B6F6),
    ],
  );

  static const LinearGradient calmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE8F8F5),
      Color(0xFFD4E6F1),
    ],
  );

  static const LinearGradient darkWaterGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF1A2634),
      Color(0xFF243447),
      Color(0xFF2C3E50),
    ],
  );

  static const LinearGradient achievementGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF56C596),
      Color(0xFF5DADE2),
    ],
  );
}

