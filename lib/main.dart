import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/shell.dart';
import 'services/settings.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = await AppSettings.load();
  runApp(SahtiApp(settings: settings));
}

/// Sahti (صحتي) : scanner de produits alimentaires pour le Maroc.
class SahtiApp extends StatelessWidget {
  final AppSettings settings;
  final Widget home;
  const SahtiApp(
      {super.key, required this.settings, this.home = const RootShell()});

  @override
  Widget build(BuildContext context) {
    return SettingsScope(
      settings: settings,
      child: ListenableBuilder(
        listenable: settings,
        builder: (context, _) => MaterialApp(
          title: 'Sahti',
          debugShowCheckedModeBanner: false,
          locale: settings.locale,
          supportedLocales: const [Locale('fr'), Locale('ar')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          themeMode: settings.themeMode,
          theme: sahtiTheme(Brightness.light),
          darkTheme: sahtiTheme(Brightness.dark),
          home: home,
        ),
      ),
    );
  }
}
