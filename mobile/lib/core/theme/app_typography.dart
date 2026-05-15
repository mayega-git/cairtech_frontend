import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Typographies BBCMS — 3 stacks alignés sur le design (Design/styles.css).
///
/// - Sans (Inter en substitut de Geist): UI principale
/// - Serif (Cormorant Garamond en substitut d'Instrument Serif): titres, gros nombres
/// - Mono (JetBrains Mono en substitut de Geist Mono): eyebrows, labels, tabular
///
/// Google Fonts charge les polices via réseau au premier lancement puis cache.
class AppTypography {
  AppTypography._();

  static TextStyle sans({
    double size = 14,
    FontWeight weight = FontWeight.w500,
    Color color = AppColors.ink,
    double letterSpacing = -0.07,
    double height = 1.4,
  }) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );

  static TextStyle serif({
    double size = 32,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.ink,
    double letterSpacing = -0.6,
    double height = 1.05,
  }) =>
      GoogleFonts.cormorantGaramond(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );

  static TextStyle mono({
    double size = 11,
    FontWeight weight = FontWeight.w500,
    Color color = AppColors.muted,
    double letterSpacing = 1.5,
    double height = 1.2,
  }) =>
      GoogleFonts.jetBrainsMono(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );

  /// Eyebrow CSS .eyebrow : mono 10px, letterSpacing 0.14em, uppercase, muted.
  static TextStyle eyebrow({Color color = AppColors.muted}) => mono(
        size: 10,
        weight: FontWeight.w500,
        color: color,
        letterSpacing: 1.4,
      );
}
