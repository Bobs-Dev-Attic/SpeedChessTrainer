import 'package:flutter/material.dart';

/// Builds the light and dark [ThemeData] from a user-chosen accent colour.
class AppThemes {
  static ThemeData light(Color seed) => _build(seed, Brightness.light);
  static ThemeData dark(Color seed) => _build(seed, Brightness.dark);

  static ThemeData _build(Color seed, Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      // Bundled fonts so the app renders fully offline. CanvasKit would
      // otherwise fetch Roboto and (for the chess piece glyphs) Noto Sans
      // Symbols from fonts.gstatic.com at runtime.
      fontFamily: 'Roboto',
      fontFamilyFallback: const ['NotoChessSymbols'],
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerHighest.withOpacity(0.45),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
        ),
      ),
    );
  }

  /// Accent colours offered in Settings.
  static const List<Color> accentChoices = [
    Color(0xFF769656), // board green
    Color(0xFF1E88E5), // blue
    Color(0xFF8E24AA), // purple
    Color(0xFFE53935), // red
    Color(0xFFFB8C00), // orange
    Color(0xFF00897B), // teal
    Color(0xFFEC407A), // pink
    Color(0xFF5E35B1), // deep purple
  ];
}
