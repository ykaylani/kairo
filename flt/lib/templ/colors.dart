import 'package:flutter/material.dart';

abstract class ColorsMain {
  // --- Brand & Background Gradient ---
  static const gradStart = Color(0xFF04380B);
  static const gradEnd = Color(0xFF179E2E);

  static const primary = Color(0xFF08751B);
  static const secondary = Color(0xFF43994F);

  /// Ready-to-use background gradient for `BoxDecoration`
  static const backgroundGradient = LinearGradient(
    colors: [gradStart, gradEnd],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // --- Surfaces & Cards (Placed over the gradient) ---
  /// Main solid card background (pure white makes UI crisp on green)
  static const surface = Color(0xFFFFFFFF);

  /// Glassmorphic container option (15% opacity white for frosted-glass cards)
  static const surfaceGlass = Color(0x26FFFFFF);

  // --- Text: Directly ON the Gradient ---
  /// Headers & main titles floating on the green background
  static const textOnGradPrimary = Color(0xFFFFFFFF);

  /// Subtitles/captions floating on the green background
  static const textOnGradSecondary = Color(0xFFCBD5E1);

  // --- Text: Inside Cards & Surfaces ---
  /// Main body text inside white cards (Dark Slate 900)
  static const textPrimary = Color(0xFF0F172A);

  /// Secondary text/hints inside white cards (Slate 500)
  static const textSecondary = Color(0xFF64748B);

  // --- Interactive Elements ---
  /// Dark Slate button (Use inside white cards for maximum punch)
  static const btn = Color(0xFF1E293B);
  static const textOnBtn = Color(0xFFFFFFFF);

  /// Pure White / Light button (Use directly on top of the green gradient)
  static const btnLight = Color(0xFFFFFFFF);
  static const textOnBtnLight = Color(0xFF0F172A);

  // --- Structural & Feedback ---
  /// Dividers inside white cards
  static const border = Color(0xFFE2E8F0);

  /// Subtle white border for glassmorphic/frosted cards
  static const borderGlass = Color(0x33FFFFFF);

  /// Alerts & validation
  static const error = Color(0xFFEF4444);
}