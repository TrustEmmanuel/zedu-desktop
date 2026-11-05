import 'package:flutter/material.dart';

class AppPalette {
  final Brightness brightness;
  final Color primary;
  final Color sidebar;
  final Color accent;
  final Color onPrimary;
  final Color onSidebar;
  final Color background;
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;
  final Color borderOutline;
  final Color divider;
  final Color success;
  final Color successBg;
  final Color error;
  final Color errorBg;
  final Color primaryBg;

  /// Green dot — user is active/online.
  final Color presenceActive;

  /// Dark semi-transparent dot — user is away/offline.
  final Color presenceAway;

  const AppPalette({
    required this.brightness,
    required this.primary,
    required this.sidebar,
    required this.accent,
    required this.onPrimary,
    required this.onSidebar,
    required this.background,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.borderOutline,
    required this.divider,
    required this.success,
    required this.successBg,
    required this.error,
    required this.errorBg,
    required this.primaryBg,
    required this.presenceActive,
    required this.presenceAway,
  });

  static const light = AppPalette(
    brightness: Brightness.light,
    primary: Color(0xFF6458F5),
    sidebar: Color(0xFF4848AD),
    accent: Color(0xFF5CCBBA),
    onPrimary: Color(0xFFFFFFFF),
    onSidebar: Color(0xFFFFFFFF),
    background: Color(0xFFFCFBFF),
    textPrimary: Color(0xFF1E1E1E),
    textSecondary: Color(0xFF0A090B),
    textHint: Color(0xFFA3A3A3),
    borderOutline: Color(0xffD0D0FD),
    divider: Color(0xffE5E7EB),
    success: Color(0xFF22C55E),
    successBg: Color(0xFFEFFFF5),
    error: Color(0xFFEF4444),
    errorBg: Color(0xFFFFF1F1),
    primaryBg: Color(0xFFF3EFFF),
    presenceActive: Color(0xFF22C55E),
    presenceAway: Color(0x661E1E1E),
  );

  static const dark = AppPalette(
    brightness: Brightness.dark,
    primary: Color(0xFFA5A0FF),
    sidebar: Color(0xFF1B1B36),
    accent: Color(0xFF5CCBBA),
    onPrimary: Color(0xFF17171F),
    onSidebar: Color(0xFFFFFFFF),
    background: Color(0xFF131318),
    textPrimary: Color(0xFFF4F4F6),
    textSecondary: Color(0xFFB9B9C3),
    textHint: Color(0xFF8F8F9A),
    borderOutline: Color(0xFF6B6B7E),
    divider: Color(0xFF2A2A33),
    success: Color(0xFF4ADE80),
    successBg: Color(0xFF0F2A1B),
    error: Color(0xFFF87171),
    errorBg: Color(0xFF2E1212),
    primaryBg: Color(0xFF221F3D),
    presenceActive: Color(0xFF22C55E),
    presenceAway: Color(0x66FFFFFF),
  );
}
