import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF00A651);
  static const Color primaryDark = Color(0xFF007A3D);
  static const Color primaryLight = Color(0xFF4CD787);
  static const Color accent = Color(0xFFFFC107);
  static const Color bg = Color(0xFFF6F8FA);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF101828);
  static const Color textSecondary = Color(0xFF667085);
  static const Color border = Color(0xFFE4E7EC);
  static const Color darkBg = Color(0xFF0B0E14);
  static const Color darkSurface = Color(0xFF161A22);
  static const Color darkElevated = Color(0xFF1F242E);
  static const Color darkBorder = Color(0xFF262C38);
  static const Color darkText = Color(0xFFF2F4F7);
  static const Color darkTextDim = Color(0xFF98A2B3);
  static const Color success = Color(0xFF12B76A);
  static const Color warning = Color(0xFFF79009);
  static const Color danger = Color(0xFFF04438);
  static const Color info = Color(0xFF2E90FA);
}

class AppGradients {
  static const LinearGradient green = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00C853), Color(0xFF007A3D)],
  );
  static const LinearGradient darkCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1F242E), Color(0xFF141821)],
  );
  static const LinearGradient ai = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00C853), Color(0xFF00A651)],
  );
  static const LinearGradient accentGlow = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFC107), Color(0xFFFF9800)],
  );
}

class AppRadius {
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 22;
  static const double xl = 28;
}

class AppShadows {
  static const List<BoxShadow> soft = [
    BoxShadow(color: Color(0x0F101828), blurRadius: 16, offset: Offset(0, 6)),
  ];
  static const List<BoxShadow> medium = [
    BoxShadow(color: Color(0x1A101828), blurRadius: 24, offset: Offset(0, 12)),
  ];
  static const List<BoxShadow> green = [
    BoxShadow(color: Color(0x5500A651), blurRadius: 24, offset: Offset(0, 10)),
  ];
}
