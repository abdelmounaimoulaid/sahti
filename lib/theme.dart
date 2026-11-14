import 'package:flutter/material.dart';

/// Couleurs de l'identité Sahti (palette « menthe et safran »).
/// Référence visuelle : assets/brand/ et la planche d'identité.
class SahtiColors {
  SahtiColors._();

  // Marque
  static const menthe = Color(0xFF0F6B4F);
  static const mentheSombre = Color(0xFF4CC79A); // menthe pour le mode sombre
  static const safran = Color(0xFFE8A317);
  static const fond = Color(0xFFF4F8F5);
  static const fondSombre = Color(0xFF0E1713);
  static const texte = Color(0xFF13241D);
  static const texteSombre = Color(0xFFE6F0EA);

  // Note sur 100 : mêmes couleurs en clair et en sombre.
  // Grands écarts de clarté entre niveaux, et la note s'affiche toujours
  // avec son chiffre et son mot, jamais avec la couleur seule.
  static const excellent = Color(0xFF0B6B3A); // 75 à 100
  static const bon = Color(0xFF7DB83A); // 50 à 74
  static const mediocre = Color(0xFFF0A020); // 25 à 49
  static const mauvais = Color(0xFFE0442E); // 0 à 24
  static const inconnu = Color(0xFF8A9690);
}

/// Couleur de la note (0 à 100). Gris si la note est inconnue.
Color scoreColor(int? score) {
  if (score == null) return SahtiColors.inconnu;
  if (score >= 75) return SahtiColors.excellent;
  if (score >= 50) return SahtiColors.bon;
  if (score >= 25) return SahtiColors.mediocre;
  return SahtiColors.mauvais;
}

/// Couleur du texte posé sur [scoreColor] : foncé sur les tons clairs
/// (Bon, Médiocre) pour rester lisible, blanc sinon.
Color scoreOnColor(int? score) {
  if (score != null && score >= 25 && score < 75) return SahtiColors.texte;
  return Colors.white;
}

const _police = 'ReadexPro';

ThemeData sahtiTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final scheme = ColorScheme.fromSeed(
    seedColor: SahtiColors.menthe,
    brightness: brightness,
  ).copyWith(
    primary: dark ? SahtiColors.mentheSombre : SahtiColors.menthe,
    onPrimary: dark ? SahtiColors.fondSombre : Colors.white,
    secondary: SahtiColors.safran,
    onSecondary: SahtiColors.texte,
    surface: dark ? SahtiColors.fondSombre : SahtiColors.fond,
    onSurface: dark ? SahtiColors.texteSombre : SahtiColors.texte,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: _police,
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.primary,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: _police,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: scheme.primary,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: const StadiumBorder(),
        textStyle: const TextStyle(
            fontFamily: _police, fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),
  );
}
