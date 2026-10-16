import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

import 'screens/library_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await pdfrxFlutterInitialize();
  runApp(const PasapaginaApp());
}

class PasapaginaApp extends StatelessWidget {
  const PasapaginaApp({super.key});

  static const cream = Color(0xFFF5EBD8);
  static const orange = Color(0xFFF3A34B);
  static const teal = Color(0xFF4F8A7B);
  static const ink = Color(0xFF34342F);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pasapagina',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: cream,
        colorScheme: ColorScheme.fromSeed(
          seedColor: orange,
          primary: ink,
          secondary: teal,
          surface: cream,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: cream,
          foregroundColor: ink,
          elevation: 0,
          centerTitle: false,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: orange,
            foregroundColor: ink,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
        ),
      ),
      home: LibraryScreen(),
    );
  }
}
