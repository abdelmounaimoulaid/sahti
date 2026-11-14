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

  // Additifs « à surveiller » (risque faible), entre safran et jaune.
  static const vigilance = Color(0xFFF9CB28);
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

/// Couleurs secondaires de l'interface (cartes, textes discrets, traits),
/// différentes en clair et en sombre. Lire avec `SahtiPalette.of(context)`.
@immutable
class SahtiPalette extends ThemeExtension<SahtiPalette> {
  final Color carte; // fond des cartes et de la barre du bas
  final Color discret; // texte secondaire
  final Color trait; // séparateurs, fonds de jauge, vignettes vides
  final Color mentheClaire; // pastilles d'étapes, icône halal
  final Color safranClair; // bandeau de la promesse
  final Color alerte; // bandeau allergènes : fond
  final Color alerteTexte; // bandeau allergènes : texte

  const SahtiPalette({
    required this.carte,
    required this.discret,
    required this.trait,
    required this.mentheClaire,
    required this.safranClair,
    required this.alerte,
    required this.alerteTexte,
  });

  static const clair = SahtiPalette(
    carte: Colors.white,
    discret: Color(0xFF3E5248),
    trait: Color(0xFFE3EDE7),
    mentheClaire: Color(0xFFDDF1E8),
    safranClair: Color(0xFFFBEFD2),
    alerte: Color(0xFFFBE3DF),
    alerteTexte: Color(0xFF8A1F10),
  );

  static const sombre = SahtiPalette(
    carte: Color(0xFF16231D),
    discret: Color(0xFFB7CABF),
    trait: Color(0xFF22332B),
    mentheClaire: Color(0xFF1C3A2E),
    safranClair: Color(0xFF3A2E12),
    alerte: Color(0xFF4A1C15),
    alerteTexte: Color(0xFFFFD6CF),
  );

  static SahtiPalette of(BuildContext context) =>
      Theme.of(context).extension<SahtiPalette>() ?? clair;

  @override
  SahtiPalette copyWith() => this;

  @override
  SahtiPalette lerp(ThemeExtension<SahtiPalette>? other, double t) =>
      t < 0.5 || other is! SahtiPalette ? this : other;
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
    extensions: [dark ? SahtiPalette.sombre : SahtiPalette.clair],
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
