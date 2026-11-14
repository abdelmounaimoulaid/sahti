import 'package:flutter_test/flutter_test.dart';
import 'package:sahti/l10n/strings.dart';
import 'package:sahti/services/allergens.dart';

void main() {
  test('chaque texte existe en français et en arabe', () {
    final missing = S.keys.where((k) => !S.hasBoth(k)).toList();
    expect(missing, isEmpty);
  });

  test('chaque allergène a un nom dans les deux langues', () {
    for (final a in allergens) {
      expect(a.fr, isNotEmpty);
      expect(a.ar, isNotEmpty);
    }
  });

  test('paramètres {n} et {list}', () {
    expect(const S('fr').t('riskyMany', n: 3), '3 additifs à surveiller');
    expect(const S('fr').t('allergenContains', list: ['Gluten', 'Lait']),
        'Contient : Gluten, Lait');
    expect(const S('ar').t('allergenContains', list: ['الغلوتين', 'الحليب']),
        'يحتوي على: الغلوتين، الحليب');
  });
}
