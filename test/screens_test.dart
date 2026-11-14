import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sahti/main.dart';
import 'package:sahti/screens/history_screen.dart';
import 'package:sahti/screens/product_screen.dart';
import 'package:sahti/screens/scanner_screen.dart';
import 'package:sahti/screens/settings_screen.dart';
import 'package:sahti/screens/shell.dart';
import 'package:sahti/services/history.dart';
import 'package:sahti/services/off_api.dart';
import 'package:sahti/services/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

const biscuits = {
  'status': 1,
  'product': {
    'product_name_fr': 'Biscuits fourrés chocolat',
    'brands': 'Marque exemple',
    'nutriscore_grade': 'd',
    'nutriscore_score': 20,
    'nova_group': 4,
    'categories_tags': ['en:biscuits'],
    'additives_tags': ['en:e322', 'en:e450', 'en:e500'],
    'labels_tags': ['en:halal'],
    'allergens_tags': ['en:gluten', 'en:milk'],
    'traces_tags': ['en:nuts'],
    'ingredients_text_fr':
        'Farine de blé, sucre, huile de palme, cacao maigre 6 %, poudre de lait, émulsifiant (E322), poudres à lever (E450, E500), sel.',
    'nutriments': {
      'energy-kcal_100g': 470,
      'fat_100g': 18,
      'saturated-fat_100g': 8,
      'sugars_100g': 30,
      'salt_100g': 0.6,
    },
  },
};

OffApi fakeApi(Map<String, dynamic>? body) =>
    OffApi(MockClient((req) async => body == null
        ? http.Response('{"status":0}', 404)
        : http.Response.bytes(utf8.encode(jsonEncode(body)), 200,
            headers: {'content-type': 'application/json; charset=utf-8'})));

Future<AppSettings> pumpApp(WidgetTester tester, Widget home,
    {String lang = 'fr',
    Set<String> allergens = const {},
    Size size = const Size(390, 844)}) async {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final settings =
      AppSettings(lang: lang, allergens: allergens, themeMode: ThemeMode.light);
  await tester.pumpWidget(SahtiApp(settings: settings, home: home));
  await tester.pumpAndSettle();
  return settings;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  for (final lang in ['fr', 'ar']) {
    testWidgets('accueil et barre du bas ($lang)', (tester) async {
      await pumpApp(tester, const RootShell(), lang: lang);
      final ar = lang == 'ar';
      expect(
          find.text(ar ? 'امسح منتجًا' : 'Scanner un produit'), findsOneWidget);
      expect(find.text(ar ? 'الرئيسية' : 'Accueil'), findsOneWidget);
      expect(find.text(ar ? 'السجل' : 'Historique'), findsOneWidget);
      expect(find.bySemanticsLabel(ar ? 'امسح منتجًا' : 'Scanner un produit'),
          findsWidgets);
      final dir = Directionality.of(
          tester.element(find.text(ar ? 'آخر المنتجات' : 'Derniers scans')));
      expect(dir, ar ? TextDirection.rtl : TextDirection.ltr);
    });

    testWidgets('fiche produit complète, sans débordement ($lang)',
        (tester) async {
      await pumpApp(tester,
          ProductScreen(barcode: '6111234567890', api: fakeApi(biscuits)),
          lang: lang, allergens: {'en:gluten', 'en:nuts', 'en:eggs'});
      final ar = lang == 'ar';
      expect(find.text(ar ? 'يحتوي على: الغلوتين' : 'Contient : Gluten'),
          findsOneWidget);
      expect(
          find.text(ar
              ? 'قد يحتوي على آثار من: المكسرات'
              : 'Peut contenir des traces de : Fruits à coque'),
          findsOneWidget);
      expect(find.text('Nutri-Score D'), ar ? findsNothing : findsOneWidget);
      expect(
          find.text(ar ? 'فائق التصنيع (NOVA 4)' : 'Ultra-transformé (NOVA 4)'),
          findsOneWidget);
      await tester.scrollUntilVisible(
          find.text(
              ar ? 'حلال مذكور على العبوة' : 'Halal indiqué sur l\'emballage'),
          300);
      expect(find.text('E450'), findsOneWidget);
    });

    testWidgets('produit introuvable ($lang)', (tester) async {
      await pumpApp(
          tester, ProductScreen(barcode: '6111234567890', api: fakeApi(null)),
          lang: lang);
      expect(
          find.text(lang == 'ar' ? 'المنتج غير موجود' : 'Produit introuvable'),
          findsOneWidget);
      expect(find.text(lang == 'ar' ? 'أضف المنتج' : 'Ajouter le produit'),
          findsOneWidget);
    });

    testWidgets('réglages sans débordement ($lang)', (tester) async {
      await pumpApp(tester, const SettingsScreen(), lang: lang);
      expect(
          find.text(lang == 'ar' ? 'الإعدادات' : 'Réglages'), findsOneWidget);
    });

    testWidgets('écran de scan ($lang)', (tester) async {
      await pumpApp(tester,
          const ScannerScreen(cameraPreview: ColoredBox(color: Colors.black)),
          lang: lang);
      expect(
          find.text(
              lang == 'ar' ? 'أدخل الرمز يدويًا' : 'Saisir le code à la main'),
          findsOneWidget);
    });
  }

  testWidgets('petit écran (320 px) en arabe : accueil et fiche',
      (tester) async {
    await pumpApp(tester, const RootShell(),
        lang: 'ar', size: const Size(320, 640));
    await pumpApp(
        tester, ProductScreen(barcode: '6111234567890', api: fakeApi(biscuits)),
        lang: 'ar', allergens: {'en:gluten'}, size: const Size(320, 640));
    expect(tester.takeException(), isNull);
  });

  testWidgets('réglages : allergènes, halal et langue', (tester) async {
    final settings = await pumpApp(tester, const SettingsScreen());
    await tester.tap(find.text('Lait'));
    await tester.pumpAndSettle();
    expect(settings.allergens, {'en:milk'});

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(settings.showHalal, isFalse);

    await tester.tap(find.text('العربية'));
    await tester.pumpAndSettle();
    expect(settings.lang, 'ar');
    expect(find.text('الإعدادات'), findsOneWidget);
  });

  testWidgets('info halal masquée si désactivée', (tester) async {
    tester.view.physicalSize = const Size(390, 844) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final settings = AppSettings(showHalal: false, themeMode: ThemeMode.light);
    await tester.pumpWidget(SahtiApp(
        settings: settings,
        home: ProductScreen(barcode: '1', api: fakeApi(biscuits))));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Pour 100 g'), 300);
    expect(find.text('Halal indiqué sur l\'emballage'), findsNothing);
  });

  testWidgets('historique : groupes par date et recherche', (tester) async {
    final now = DateTime(2026, 11, 14, 18);
    await History.add(
        HistoryEntry('3', 'Eau minérale', 'X', 100, DateTime(2026, 10, 1)));
    await History.add(
        HistoryEntry('2', 'Pain de mie', 'Y', 58, DateTime(2026, 11, 11)));
    await History.add(
        HistoryEntry('1', 'Yaourt nature', 'Z', 85, DateTime(2026, 11, 14, 9)));
    await pumpApp(tester, Scaffold(body: HistoryScreen(now: () => now)));
    expect(find.text('Aujourd\'hui'), findsOneWidget);
    expect(find.text('Cette semaine'), findsOneWidget);
    expect(find.text('Plus ancien'), findsOneWidget);
    expect(find.text('Excellent'), findsNWidgets(2));

    await tester.enterText(find.byType(TextField), 'pain');
    await tester.pumpAndSettle();
    expect(find.text('Pain de mie'), findsOneWidget);
    expect(find.text('Yaourt nature'), findsNothing);
  });
}
