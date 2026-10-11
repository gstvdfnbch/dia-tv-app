import 'package:flutter/material.dart';

/// Paleta inspirada no site diatv (diaestudio.com/site): fundo quase preto,
/// acento em gradiente roxo -> magenta, textos claros.
class DiaColors {
  static const Color bg = Color(0xFF070708);
  static const Color surface = Color(0xFF121216);
  static const Color surfaceHi = Color(0xFF1C1C22);
  static const Color stroke = Color(0xFF26262E);
  static const Color text = Color(0xFFF5F5F7);
  static const Color textDim = Color(0xFF9A9AA6);
  static const Color purple = Color(0xFF7C3AED);
  static const Color magenta = Color(0xFFEC4899);
  static const Color pink = Color(0xFFF472B6);

  static const LinearGradient accent = LinearGradient(
    colors: [purple, magenta],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}

ThemeData buildDiaTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: DiaColors.bg,
    colorScheme: base.colorScheme.copyWith(
      surface: DiaColors.bg,
      primary: DiaColors.magenta,
      secondary: DiaColors.purple,
    ),
    textTheme: base.textTheme.apply(
      bodyColor: DiaColors.text,
      displayColor: DiaColors.text,
      fontFamily: 'SF Pro Display',
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: DiaColors.bg,
      elevation: 0,
      centerTitle: false,
    ),
    splashFactory: InkSparkle.splashFactory,
  );
}
