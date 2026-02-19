import 'package:flutter/material.dart';
import 'package:lifevault/presentation/views/record_list_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LifeVaultApp());
}

/// LifeVault Design System
///
/// Tone: Institutional, editorial, technically confident.
/// Inspired by: MongoDB website typography + modern rounded mobile layout.
class LifeVaultApp extends StatelessWidget {
  const LifeVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LifeVault',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: const RecordListScreen(),
    );
  }

  ThemeData _buildTheme() {
    // ── Palette ───────────────────────────────────────────────────────────────
    // Deep slate-green primary (institutional authority)
    const kPrimary = Color(0xFF00684A); // MongoDB-like forest green
    const kSecondary = Color(0xFF3D4F58); // Muted steel
    const kSurface = Color(0xFFFFFFFF);
    const kBackground = Color(0xFFF6F8F7); // Very faint green-grey
    const kError = Color(0xFFC0392B); // Deep muted red
    const kOnSurface = Color(0xFF1A1F1E); // Near-black
    const kOnSurfaceVariant = Color(0xFF596066);
    const kOutline = Color(0xFFD8E0DE);

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: kBackground,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: kPrimary,
        onPrimary: Colors.white,
        primaryContainer: Color(0xFFB7F5DB),
        onPrimaryContainer: Color(0xFF00251A),
        secondary: kSecondary,
        onSecondary: Colors.white,
        secondaryContainer: Color(0xFFD4E5E0),
        onSecondaryContainer: Color(0xFF1C2B2E),
        tertiary: Color(0xFF496B5E),
        onTertiary: Colors.white,
        error: kError,
        onError: Colors.white,
        surface: kSurface,
        onSurface: kOnSurface,
        onSurfaceVariant: kOnSurfaceVariant,
        outline: kOutline,
        outlineVariant: Color(0xFFEAF1EE),
        surfaceContainerHighest: Color(0xFFEDF3F1),
        surfaceContainerHigh: Color(0xFFF1F6F4),
        surfaceContainer: Color(0xFFF6F8F7),
        shadow: Color(0x0D1A1F1E),
      ),

      // ── AppBar ─────────────────────────────────────────────────────────────
      appBarTheme: const AppBarTheme(
        backgroundColor: kBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: kOnSurface,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          height: 1.2,
        ),
        iconTheme: IconThemeData(color: kOnSurface),
      ),

      // ── Card ───────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: kSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: EdgeInsets.zero,
      ),

      // ── Chip ───────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFEDF3F1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        side: BorderSide.none,
        labelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      ),

      // ── Divider ────────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: kOutline,
        thickness: 1,
        space: 1,
      ),

      // ── FloatingActionButton ───────────────────────────────────────────────
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),

      // ── FilledButton ───────────────────────────────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: kPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),

      // ── Input Decoration ───────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: kSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kOutline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kOutline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kPrimary, width: 1.5),
        ),
        labelStyle: const TextStyle(color: kOnSurfaceVariant, fontSize: 14),
        hintStyle: const TextStyle(color: Color(0xFFA0ABAB), fontSize: 14),
      ),

      // ── Text Theme ─────────────────────────────────────────────────────────
      textTheme: const TextTheme(
        // App-level display
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w900,
          letterSpacing: -1.0,
          color: kOnSurface,
          height: 1.1,
        ),
        displayMedium: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.8,
          color: kOnSurface,
          height: 1.15,
        ),
        // Section headers (H2)
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
          color: kOnSurface,
          height: 1.2,
        ),
        headlineSmall: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
          color: kOnSurface,
        ),
        // Card titles
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
          color: kOnSurface,
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
          color: kOnSurface,
        ),
        titleSmall: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: kOnSurface,
        ),
        // Body
        bodyLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: kOnSurface,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: kOnSurface,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: kOnSurfaceVariant,
          height: 1.4,
        ),
        // Labels / metadata (overline-style)
        labelLarge: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: kOnSurfaceVariant,
        ),
        labelMedium: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
          color: kOnSurfaceVariant,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: kOnSurfaceVariant,
        ),
      ),
    );
  }
}

/// Design tokens used across widgets.
/// Import this file in any widget to access shared constants.
class LVColors {
  LVColors._();

  static const primary = Color(0xFF00684A);
  static const primaryDark = Color(0xFF00352A);
  static const background = Color(0xFFF6F8F7);
  static const surface = Colors.white;

  // Expiry urgency
  static const expired = Color(0xFFC0392B);
  static const expiredBg = Color(0xFFFDF0EE);
  static const expiringSoon = Color(0xFFB06200);
  static const expiringSoonBg = Color(0xFFFEF5E7);
  static const valid = Color(0xFF00684A);
  static const validBg = Color(0xFFF0FAF6);
  static const noExpiry = Color(0xFF596066);
  static const noExpiryBg = Color(0xFFF0F2F2);
  static const onSurface = Color(0xFF1A1F1E);
}
