import 'package:flutter/material.dart';

/// Bảng màu chủ đạo của ứng dụng - phong cách hiện đại, tối giản
class AppColors {
  AppColors._();

  // Màu thương hiệu chính - Indigo/Violet gradient hiện đại
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryDark = Color(0xFF5849C2);
  static const Color primaryLight = Color(0xFFA29BFE);

  static const Color secondary = Color(0xFF00CEC9);
  static const Color accent = Color(0xFFFD79A8);

  // Nền
  static const Color background = Color(0xFFF7F7FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0EFFB);

  // Chữ
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color textHint = Color(0xFFB2BEC3);

  // Trạng thái / mức độ ưu tiên
  static const Color priorityLow = Color(0xFF00B894);
  static const Color priorityMedium = Color(0xFFFDCB6E);
  static const Color priorityHigh = Color(0xFFE17055);

  static const Color success = Color(0xFF00B894);
  static const Color warning = Color(0xFFFDCB6E);
  static const Color error = Color(0xFFD63031);
  static const Color overdue = Color(0xFFD63031);

  static const Color divider = Color(0xFFEEEEF7);
  static const Color shadow = Color(0x1A6C5CE7);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6C5CE7), Color(0xFF8E7CFB)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00CEC9), Color(0xFF6C5CE7)],
  );

  static Color priorityColor(String priority) {
    switch (priority.toUpperCase()) {
      case 'HIGH':
        return priorityHigh;
      case 'MEDIUM':
        return priorityMedium;
      case 'LOW':
      default:
        return priorityLow;
    }
  }
}
