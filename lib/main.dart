import 'package:flutter/material.dart';
import 'package:lifevault/presentation/views/record_list_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LifeVaultApp());
}

class LifeVaultApp extends StatelessWidget {
  const LifeVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LifeVault',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(
          0xFFF9FAFB,
        ), // Very light cool gray
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFF263238), // Blue Grey 900 - Deep, Ink-like
          onPrimary: Colors.white,
          secondary: Color(0xFF546E7A), // Blue Grey 600
          onSecondary: Colors.white,
          tertiary: Color(0xFF455A64), // Blue Grey 700
          error: Color(0xFFB71C1C), // Deep Muted Red
          onError: Colors.white,
          surface: Colors.white,
          onSurface: Color(0xFF212121), // High contrast black
          onSurfaceVariant: Color(0xFF616161), // Medium contrast grey
          outline: Color(0xFFBDBDBD),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF9FAFB),
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Color(0xFF263238), // Deep Blue Grey
            fontSize: 28, // Larger, more editorial
            fontWeight: FontWeight.w800, // Extra Bold
            letterSpacing: -0.5,
            height: 1.2,
            fontFamily: 'Roboto', // Default, but emphasizing usage
          ),
          iconTheme: IconThemeData(color: Color(0xFF263238)),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius
                .zero, // Editorial: sharper corners? Or minimal? Let's go 4px.
            // Actually, user said "Graphic blocks". Let's use slight rounded e.g. 4-8px to feel "engineered".
            side: BorderSide.none, // We will control borders in components
          ),
          margin: EdgeInsets.zero,
        ),
        dividerTheme: const DividerThemeData(
          color: Color(0xFFEEEEEE),
          thickness: 1,
        ),
        textTheme: const TextTheme(
          // For section headers
          labelSmall: TextStyle(
            color: Color(0xFF546E7A),
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
          // For body text
          bodyMedium: TextStyle(
            color: Color(0xFF424242),
            fontSize: 15, // Slightly larger for readability
            height: 1.5,
          ),
          titleMedium: TextStyle(
            color: Color(0xFF263238),
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ),
      home: const RecordListScreen(),
    );
  }
}
