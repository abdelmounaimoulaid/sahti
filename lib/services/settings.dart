import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Réglages de l'utilisateur, gardés sur le téléphone :
/// langue, apparence, affichage du halal et allergènes à surveiller.
class AppSettings extends ChangeNotifier {
  static const _kLang = 'settings_lang';
  static const _kTheme = 'settings_theme';
  static const _kHalal = 'settings_halal';
  static const _kAllergens = 'settings_allergens';

  String _lang;
  ThemeMode _themeMode;
  bool _showHalal;
  final Set<String> _allergens;

  AppSettings({
    String lang = 'fr',
    ThemeMode themeMode = ThemeMode.system,
    bool showHalal = true,
    Set<String> allergens = const {},
  })  : _lang = lang,
        _themeMode = themeMode,
        _showHalal = showHalal,
        _allergens = {...allergens};

  static Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final theme = prefs.getString(_kTheme);
    return AppSettings(
      lang: prefs.getString(_kLang) == 'ar' ? 'ar' : 'fr',
      themeMode: ThemeMode.values
          .firstWhere((m) => m.name == theme, orElse: () => ThemeMode.system),
      showHalal: prefs.getBool(_kHalal) ?? true,
      allergens: (prefs.getStringList(_kAllergens) ?? const []).toSet(),
    );
  }

  String get lang => _lang;
  Locale get locale => Locale(_lang);
  ThemeMode get themeMode => _themeMode;
  bool get showHalal => _showHalal;
  Set<String> get allergens => Set.unmodifiable(_allergens);

  Future<void> setLang(String lang) async {
    _lang = lang == 'ar' ? 'ar' : 'fr';
    notifyListeners();
    await (await SharedPreferences.getInstance()).setString(_kLang, _lang);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    await (await SharedPreferences.getInstance()).setString(_kTheme, mode.name);
  }

  Future<void> setShowHalal(bool value) async {
    _showHalal = value;
    notifyListeners();
    await (await SharedPreferences.getInstance()).setBool(_kHalal, value);
  }

  Future<void> toggleAllergen(String id) async {
    if (!_allergens.remove(id)) _allergens.add(id);
    notifyListeners();
    await (await SharedPreferences.getInstance())
        .setStringList(_kAllergens, _allergens.toList()..sort());
  }
}

/// Donne accès aux réglages partout dans l'app : `SettingsScope.of(context)`.
class SettingsScope extends InheritedNotifier<AppSettings> {
  const SettingsScope({
    super.key,
    required AppSettings settings,
    required super.child,
  }) : super(notifier: settings);

  static AppSettings of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SettingsScope>()!.notifier!;
}
