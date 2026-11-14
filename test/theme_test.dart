import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sahti/theme.dart';

void main() {
  test('couleur de la note selon les seuils', () {
    expect(scoreColor(null), SahtiColors.inconnu);
    expect(scoreColor(100), SahtiColors.excellent);
    expect(scoreColor(75), SahtiColors.excellent);
    expect(scoreColor(74), SahtiColors.bon);
    expect(scoreColor(50), SahtiColors.bon);
    expect(scoreColor(49), SahtiColors.mediocre);
    expect(scoreColor(25), SahtiColors.mediocre);
    expect(scoreColor(24), SahtiColors.mauvais);
    expect(scoreColor(0), SahtiColors.mauvais);
  });

  test('texte foncé sur les notes claires, blanc sinon', () {
    expect(scoreOnColor(80), Colors.white);
    expect(scoreOnColor(60), SahtiColors.texte);
    expect(scoreOnColor(30), SahtiColors.texte);
    expect(scoreOnColor(10), Colors.white);
    expect(scoreOnColor(null), Colors.white);
  });

  test('thèmes clair et sombre utilisent la menthe et Readex Pro', () {
    final clair = sahtiTheme(Brightness.light);
    final sombre = sahtiTheme(Brightness.dark);
    expect(clair.colorScheme.primary, SahtiColors.menthe);
    expect(sombre.colorScheme.primary, SahtiColors.mentheSombre);
    expect(clair.textTheme.bodyMedium!.fontFamily, 'ReadexPro');
  });
}
