import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/home_screen.dart';

void main() => runApp(const SahtiApp());

/// Sahti (صحتي) : scanner de produits alimentaires pour le Maroc.
class SahtiApp extends StatefulWidget {
  const SahtiApp({super.key});

  static void toggleLanguage(BuildContext context) =>
      context.findAncestorStateOfType<_SahtiAppState>()!._toggle();

  @override
  State<SahtiApp> createState() => _SahtiAppState();
}

class _SahtiAppState extends State<SahtiApp> {
  Locale _locale = const Locale('fr');

  void _toggle() => setState(() => _locale =
      Locale(_locale.languageCode == 'fr' ? 'ar' : 'fr'));

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sahti',
      debugShowCheckedModeBanner: false,
      locale: _locale,
      supportedLocales: const [Locale('fr'), Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0B7A55)),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
