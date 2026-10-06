import 'package:flutter/material.dart';

abstract class ColorsMain {
  static const gradStart = Color(0xFF04380B);
  static const gradEnd = Color(0xFF179E2E);

  static const primary = Color(0xFF08751B);
  static const secondary = Color(0xFF43994F);

  static const backgroundGradient = LinearGradient(
    colors: [gradStart, gradEnd],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const surface = Color(0xFFFFFFFF);
  static const surfaceGlass = Color(0x10FFFFFF);

  static const textOnGradPrimary = Color(0xFFFFFFFF);
  static const textOnGradSecondary = Color(0xFFCBD5E1);

  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);

  static const btn = Color(0xFF1E293B);
  static const textOnBtn = Color(0xFFFFFFFF);

  static const btnLight = Color(0xFFFFFFFF);
  static const textOnBtnLight = Color(0xFF0F172A);

  static const border = Color(0xFFE2E8F0);
  static const borderGlass = Color(0x33FFFFFF);

  static const error = Color(0xFFEF4444);
}