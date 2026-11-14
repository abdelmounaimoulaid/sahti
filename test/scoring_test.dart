import 'package:flutter_test/flutter_test.dart';
import 'package:sahti/models/product.dart';
import 'package:sahti/services/scoring.dart';

Product make(Map<String, dynamic> m) => Product.fromOff('1', m);

void main() {
  test('produit brut excellent : score Nutri-Score minimal, NOVA 1, sans additif', () {
    final r = computeScore(make({
      'nutriscore_grade': 'a', 'nutriscore_score': -15, 'nova_group': 1,
      'additives_tags': <String>[], 'ingredients_text': 'lentilles',
    }))!;
    expect(r.score, 100);
    expect(r.provisional, isFalse);
  });

  test('eau = 100', () {
    expect(computeScore(make({'categories_tags': ['en:beverages', 'en:waters']}))!.score, 100);
  });

  test('additifs : pire compte pleinement, suivants -2', () {
    expect(additivePoints({}), 20);
    expect(additivePoints({'en:e621': AdditiveRisk.yellow}), 16);
    expect(additivePoints({'en:e951': AdditiveRisk.orange, 'en:e621': AdditiveRisk.yellow}), 6);
    expect(additivePoints({'en:e250': AdditiveRisk.red, 'en:e951': AdditiveRisk.orange}), 0);
  });

  test('plafond additif rouge à 49', () {
    final r = computeScore(make({
      'nutriscore_grade': 'a', 'nutriscore_score': -15, 'nova_group': 1,
      'additives_tags': ['en:e250'], 'ingredients_text': 'x',
    }))!;
    expect(r.score, 49);
  });

  test('plafonds Nutri-Score D, E et NOVA 4', () {
    Product p(String g, int s, int nova) => make({
          'nutriscore_grade': g, 'nutriscore_score': s, 'nova_group': nova,
          'additives_tags': <String>[], 'ingredients_text': 'x',
        });
    expect(computeScore(p('d', -15, 1))!.score, 49);
    expect(computeScore(p('e', -15, 1))!.score, 29);
    expect(computeScore(p('a', -15, 4))!.score, 74);
  });

  test('boisson : grille séparée', () {
    final r = computeScore(make({
      'categories_tags': ['en:beverages'], 'nutriscore_grade': 'e',
      'nutriscore_score': 20, 'nova_group': 4,
      'additives_tags': <String>[], 'ingredients_text': 'x',
    }))!;
    expect(r.nutrition, 0);
  });

  test('NOVA manquant : note provisoire', () {
    final r = computeScore(make({
      'nutriscore_grade': 'b', 'nutriscore_score': 1,
      'additives_tags': <String>[], 'ingredients_text': 'x',
    }))!;
    expect(r.provisional, isTrue);
  });

  test('non notés : lait infantile, compléments, sucre, sel', () {
    expect(computeScore(make({'categories_tags': ['en:infant-formulas'], 'nutriscore_grade': 'a'})), isNull);
    expect(computeScore(make({'categories_tags': ['en:sugars'], 'nutriscore_grade': 'e'})), isNull);
  });

  test('sans Nutri-Score : pas de note', () {
    expect(computeScore(make({'nova_group': 2})), isNull);
  });

  test('halal lu sur les labels de l\'emballage', () {
    expect(make({'labels_tags': ['en:halal']}).halalOnPackage, isTrue);
  });
}
