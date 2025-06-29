import 'package:flutter/material.dart';

class AppColors {
  // ===== الألوان الأساسية (Core Colors) =====
  static const Color primary = Color(0xFF008080); // Teal داكن
  static const Color primaryLight = Color(0xFFE0F8F8); // Light Teal
  static const Color primaryDark = Color(0xFF006666); // Darker Teal
  static const Color secondary = Color(0xFF70A4A4); // Grayish Teal
  static const Color accent = Color(0xFFFFC107); // Amber
  static const Color error = Color(0xFFF44336); // Red Coral

  // ===== ألوان النصوص (Text Colors) =====
  static const Color textDark = Color(0xFF2E2E2E); // Charcoal
  static const Color textLight = Color(0xFF757575); // Gray
  static const Color textInverse = Color(0xFFFFFFFF); // White

  // ===== ألوان الخلفية (Background Colors) =====
  static const Color background = Color(0xFFE0F8F8); // Light Teal
  static const Color surface = Color(0xFFFFFFFF); // White
  static const Color card = Color(0xFFF9FAFB); // Light Gray
  static const Color cardBorder = Color(0xFFE5E7EB); // Border Gray

  // ===== ألوان الحالة (Status Colors) =====
  static const Color success = Color(0xFF4CAF50); // Green
  static const Color successLight = Color(0xFFE8F5E8);
  static const Color warning = Color(0xFFFF9800); // Orange
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF2196F3); // Blue
  static const Color infoLight = Color(0xFFE3F2FD);

  // ===== ألوان المخزون (Inventory Status) =====
  static const Color stockNormal = Color(0xFF4CAF50); // Green
  static const Color stockLow = Color(0xFFFF9800); // Orange
  static const Color stockOut = Color(0xFFF44336); // Red

  // ===== ألوان الحركات (Transaction Types) =====
  static const Color incoming = Color(0xFF4CAF50); // Green
  static const Color outgoing = Color(0xFFF44336); // Red
  static const Color consumption = Color(0xFFFF9800); // Orange
  static const Color adjustment = Color(0xFF2196F3); // Blue

  // ===== ألوان الأزرار (Button Colors) =====
  static const Color buttonPrimary = Color(0xFF008080);
  static const Color buttonPrimaryHover = Color(0xFF006666);
  static const Color buttonSecondary = Color(0xFF70A4A4);
  static const Color buttonSecondaryHover = Color(0xFF5A8A8A);
  static const Color buttonSuccess = Color(0xFF4CAF50);
  static const Color buttonWarning = Color(0xFFFF9800);
  static const Color buttonError = Color(0xFFF44336);

  // ===== التدرجات اللونية (Gradients) =====
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, Color(0xFF5A8A8A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, Color(0xFFE6A700)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [success, Color(0xFF388E3C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warningGradient = LinearGradient(
    colors: [warning, Color(0xFFF57C00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient errorGradient = LinearGradient(
    colors: [error, Color(0xFFD32F2F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [surface, Color(0xFFF8FAFC)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [background, Color(0xFFD0F0F0)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ===== الظلال (Shadows) =====
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 15,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> floatingShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.2),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}
