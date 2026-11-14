import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sahti/services/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('valeurs par défaut', () async {
    SharedPreferences.setMockInitialValues({});
    final s = await AppSettings.load();
    expect(s.lang, 'fr');
    expect(s.themeMode, ThemeMode.system);
    expect(s.showHalal, isTrue);
    expect(s.allergens, isEmpty);
  });

  test('les réglages sont gardés sur le téléphone', () async {
    SharedPreferences.setMockInitialValues({});
    final s = await AppSettings.load();
    await s.setLang('ar');
    await s.setThemeMode(ThemeMode.dark);
    await s.setShowHalal(false);
    await s.toggleAllergen('en:gluten');
    await s.toggleAllergen('en:milk');
    await s.toggleAllergen('en:milk');

    final again = await AppSettings.load();
    expect(again.lang, 'ar');
    expect(again.themeMode, ThemeMode.dark);
    expect(again.showHalal, isFalse);
    expect(again.allergens, {'en:gluten'});
  });
}
