import 'package:flutter_test/flutter_test.dart';
import 'package:sahti/models/product.dart';
import 'package:sahti/services/scoring.dart';

void main() {
  test('produit sain : Nutri-Score A, NOVA 1, sans additif', () {
    final p = Product.fromOff('1', {
      'product_name': 'Lentilles',
      'nutriscore_grade': 'a',
      'nova_group': 1,
      'additives_tags': <String>[],
      'ingredients_text': 'lentilles',
    });
    expect(computeScore(p)!.score, 100);
  });

  test('additifs à surveiller et ultra-transformé font baisser la note', () {
    final p = Product.fromOff('2', {
      'nutriscore_grade': 'd',
      'nova_group': 4,
      'additives_tags': ['en:e250', 'en:e621', 'en:e330'],
    });
    final r = computeScore(p)!;
    expect(r.riskyFound, ['en:e250', 'en:e621']);
    expect(r.additives, 5);
    expect(r.score, 17); // (12 + 5 + 0) / 100
  });

  test('sans Nutri-Score : pas de note', () {
    expect(computeScore(Product.fromOff('3', {'nova_group': 2})), isNull);
  });

  test('halal lu sur les labels de l\'emballage', () {
    final p = Product.fromOff('4', {'labels_tags': ['en:halal']});
    expect(p.halalOnPackage, isTrue);
  });
}
