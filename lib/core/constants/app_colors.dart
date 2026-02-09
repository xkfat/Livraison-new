import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primaryBlue = Color(0xFF3769B0);
  static const Color primaryDark = Color(0xFF1E40AF);
  static const Color primaryLight = Color(0xFF60A5FA);
  
  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  // Background Colors
  static const Color lightBackground = Color(0xFFF3F4F6);
  static const Color darkBackground = Color(0xFF111827);
  static const Color cardBackground = Colors.white;
  
  // Text Colors
  static const Color textDark = Color(0xFF1F2937);
  static const Color textLight = Colors.white;
  static const Color textGrey = Color(0xFF6B7280);
  
  // Status-specific colors for delivery status
  static const Color statusEnAttente = Color(0xFFF59E0B);
  static const Color statusEnCours = Color(0xFF3B82F6);
  static const Color statusLivre = Color(0xFF10B981);
  static const Color statusAnnule = Color(0xFFEF4444);
  
static const Color inputBackground = Color(0xFFF3F4F6);
  // UI Elements
  static const Color divider = Color(0xFFE5E7EB);
  static const Color shadow = Color(0x1A000000);
  
  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}