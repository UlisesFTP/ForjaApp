import 'package:flutter/material.dart';

abstract final class ForjaColors {
  static const background = Color(0xFF090909);
  static const surface = Color(0xFF191919);
  static const paper = Color(0xFFF4F4F1);
  static const ink = Color(0xFF111111);
  static const text = Color(0xFFF5F5F3);
  static const muted = Color(0xFFC4C4C0);
  static const border = Color(0xFF494949);

  // Colour outside the monochrome palette: the streak flame (D36, only the
  // flame and the heat map use it) and the action colours of D44, used only
  // on key action buttons, always with an icon and a text label.
  /// Flame on dark surfaces.
  static const flame = Color(0xFFFF9600);

  /// Inner core of the flame.
  static const flameCore = Color(0xFFFFC800);

  /// Flame on the light paper bar: darker, so it keeps 3:1 against it.
  static const flameDeep = Color(0xFFE65100);

  /// Unlit flame (no streak, or today's workout still to do).
  static const flameOff = Color(0xFF757570);

  /// White on the action colours (D44).
  static const onTone = Color(0xFFFFFFFF);

  /// Confirm, save, accept, complete (D44). Solid, with white text on it
  /// (at least 4.5:1) and at least 3:1 against the dark background.
  static const success = Color(0xFF15803D);

  /// Caution: skip, postpone, "not now", reject (D44). A dark yellow: white
  /// text is not readable on a bright one.
  static const caution = Color(0xFFA16207);

  /// Destructive: delete, discard, replace (D44).
  static const danger = Color(0xFFDC2626);
}

ThemeData forjaTheme() {
  final base = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    fontFamily: 'DM Sans',
    scaffoldBackgroundColor: ForjaColors.background,
    colorScheme: const ColorScheme.dark(
      primary: ForjaColors.paper,
      onPrimary: ForjaColors.ink,
      surface: ForjaColors.surface,
      onSurface: ForjaColors.text,
      secondary: ForjaColors.paper,
      error: ForjaColors.paper,
      onError: ForjaColors.ink,
      errorContainer: ForjaColors.surface,
      onErrorContainer: ForjaColors.text,
    ),
  );
  return base.copyWith(
    textTheme: base.textTheme.copyWith(
      headlineLarge: const TextStyle(
        fontFamily: 'Barlow Condensed',
        fontSize: 40,
        color: ForjaColors.text,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: const TextStyle(
        fontFamily: 'Barlow Condensed',
        fontSize: 32,
        color: ForjaColors.text,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: const TextStyle(
        fontFamily: 'Barlow Condensed',
        fontSize: 26,
        color: ForjaColors.text,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: const TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: ForjaColors.text,
      ),
      bodyMedium: const TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 14,
        color: ForjaColors.muted,
        height: 1.4,
      ),
      bodyLarge: const TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 16,
        color: ForjaColors.text,
        height: 1.4,
      ),
      labelLarge: const TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: ForjaColors.text,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ).copyWith(overlayColor: _feedback(ForjaColors.ink)),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 48),
        side: const BorderSide(color: ForjaColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ).copyWith(overlayColor: _feedback(ForjaColors.text)),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom().copyWith(
        overlayColor: _feedback(ForjaColors.text),
      ),
    ),
    // Icons on the dark surfaces use the text color (never the scheme's dimmer
    // default); the light cards set their own ink where they need it.
    iconTheme: const IconThemeData(color: ForjaColors.text),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        minimumSize: const Size(48, 48),
        foregroundColor: ForjaColors.text,
      ).copyWith(overlayColor: _feedback(ForjaColors.text)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ForjaColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      labelStyle: const TextStyle(color: ForjaColors.muted),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: ForjaColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: ForjaColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: ForjaColors.paper, width: 2),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: ForjaColors.paper,
      contentTextStyle: TextStyle(
        color: ForjaColors.ink,
        fontFamily: 'DM Sans',
        fontSize: 14,
      ),
    ),
    dividerTheme: const DividerThemeData(color: ForjaColors.border),
  );
}

/// Hover (pointer), focus (keyboard) and pressed (touch) feedback of the
/// buttons: a clearer tint than the Material default, in [color].
WidgetStateProperty<Color?> _feedback(Color color) =>
    WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.pressed)) {
        return color.withValues(alpha: .20);
      }
      if (states.contains(WidgetState.focused)) {
        return color.withValues(alpha: .16);
      }
      if (states.contains(WidgetState.hovered)) {
        return color.withValues(alpha: .10);
      }
      return null;
    });
