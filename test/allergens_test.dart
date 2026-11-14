import 'package:flutter_test/flutter_test.dart';
import 'package:sahti/models/product.dart';
import 'package:sahti/services/allergens.dart';

Product _p(
        {List<String> tags = const [],
        List<String> traces = const [],
        String ingredients = ''}) =>
    Product(
        barcode: '6111234567890',
        name: 'Test',
        brand: '',
        allergenTags: tags,
        traceTags: traces,
        ingredientsText: ingredients);

List<String> _ids(List<Allergen> l) => l.map((a) => a.id).toList();

void main() {
  test('rien à surveiller : aucune alerte', () {
    final c = checkAllergens(_p(tags: ['en:gluten']), {});
    expect(c.isEmpty, isTrue);
    expect(c.unknown, isFalse);
  });

  test('étiquettes Open Food Facts', () {
    final c = checkAllergens(
        _p(tags: ['en:gluten', 'en:milk'], traces: ['en:nuts']),
        {'en:gluten', 'en:nuts', 'en:eggs'});
    expect(_ids(c.contains), ['en:gluten']);
    expect(_ids(c.traces), ['en:nuts']);
  });

  test('lecture de la liste d\'ingrédients quand les étiquettes manquent', () {
    final c = checkAllergens(
        _p(ingredients: 'Farine de BLÉ, sucre, Œufs frais, poudre de lait.'),
        {'en:gluten', 'en:eggs', 'en:milk', 'en:soybeans'});
    expect(_ids(c.contains), ['en:gluten', 'en:milk', 'en:eggs']);
  });

  test('ingrédients en arabe', () {
    final c = checkAllergens(
        _p(ingredients: 'دقيق القمح، سكر، حليب مجفف، سمسم'),
        {'en:gluten', 'en:milk', 'en:sesame-seeds', 'en:peanuts'});
    expect(_ids(c.contains), ['en:gluten', 'en:milk', 'en:sesame-seeds']);
  });

  test('beurre de cacao, lait et noix de coco ne sont pas des allergènes', () {
    final c = checkAllergens(
        _p(
            ingredients:
                'Sucre, beurre de cacao, lait de coco, noix de coco râpée'),
        {'en:milk', 'en:nuts'});
    expect(c.isEmpty, isTrue);
  });

  test('« peut contenir des traces de » compte comme traces', () {
    final c = checkAllergens(
        _p(
            ingredients:
                'Sucre, farine de blé. Peut contenir des traces d\'arachides et de lait.'),
        {'en:gluten', 'en:peanuts', 'en:milk'});
    expect(_ids(c.contains), ['en:gluten']);
    expect(_ids(c.traces), ['en:milk', 'en:peanuts']);
  });

  test('mots entiers seulement : « moulé » n\'est pas une moule', () {
    final c =
        checkAllergens(_p(ingredients: 'Café moulé, sucre'), {'en:molluscs'});
    expect(c.isEmpty, isTrue);
  });

  test('ni étiquettes ni ingrédients : inconnu', () {
    final c = checkAllergens(_p(), {'en:gluten'});
    expect(c.unknown, isTrue);
  });
}
