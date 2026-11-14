import '../models/product.dart';

/// Méthode de notation Sahti, version 2 (voir le document de concept,
/// section « Système de notation ») :
///   nutrition 60 pts (Nutri-Score 2023, converti linéairement)
/// + transformation 20 pts (NOVA)
/// + additifs 20 pts
/// puis plafonds : Nutri-Score D ≤ 49, E ≤ 29, additif rouge ≤ 49, NOVA 4 ≤ 74.
/// Pas de bonus bio. Halal, bio et origine sont affichés, jamais notés.

enum AdditiveRisk { red, orange, yellow }

/// Classement PROVISOIRE des additifs, à valider et publier avec ses sources
/// (rouge = effet grave + preuves solides + exposition préoccupante).
const additiveRisks = <String, AdditiveRisk>{
  // Rouge
  'en:e171': AdditiveRisk.red, // dioxyde de titane (interdit dans l'UE)
  'en:e249': AdditiveRisk.red, 'en:e250': AdditiveRisk.red, // nitrites
  'en:e251': AdditiveRisk.red, 'en:e252': AdditiveRisk.red, // nitrates
  'en:e320': AdditiveRisk.red, // BHA
  // Orange
  'en:e102': AdditiveRisk.orange, 'en:e104': AdditiveRisk.orange,
  'en:e110': AdditiveRisk.orange, 'en:e122': AdditiveRisk.orange,
  'en:e124': AdditiveRisk.orange, 'en:e129': AdditiveRisk.orange, // azoïques
  'en:e150c': AdditiveRisk.orange, 'en:e150d': AdditiveRisk.orange,
  'en:e321': AdditiveRisk.orange, // BHT
  'en:e950': AdditiveRisk.orange, 'en:e951': AdditiveRisk.orange,
  'en:e954': AdditiveRisk.orange, 'en:e955': AdditiveRisk.orange, // édulcorants
  'en:e338': AdditiveRisk.orange, 'en:e339': AdditiveRisk.orange,
  'en:e340': AdditiveRisk.orange, 'en:e341': AdditiveRisk.orange,
  'en:e450': AdditiveRisk.orange, 'en:e451': AdditiveRisk.orange,
  'en:e452': AdditiveRisk.orange, // phosphates
  // Jaune
  'en:e211': AdditiveRisk.yellow, // benzoate de sodium
  'en:e220': AdditiveRisk.yellow, 'en:e221': AdditiveRisk.yellow,
  'en:e223': AdditiveRisk.yellow, 'en:e224': AdditiveRisk.yellow, // sulfites
  'en:e407': AdditiveRisk.yellow, // carraghénanes
  'en:e433': AdditiveRisk.yellow, 'en:e466': AdditiveRisk.yellow, // émulsifiants
  'en:e621': AdditiveRisk.yellow, // glutamate
};

/// Bornes de la conversion linéaire du score Nutri-Score 2023
/// Aliments : 60 × clip((40 − NS) / 55) ; boissons hors eau : 60 × clip((12 − NS) / 14).
const foodBest = -15, foodWorst = 40;
const drinkBest = -2, drinkWorst = 12;

/// Catégories non notées (fiche d'information seulement).
const unratedCategories = {
  'en:infant-formulas', 'en:baby-milks', 'en:dietary-supplements',
  'en:sugars', 'en:salts', 'en:alcoholic-beverages',
};

class ScoreResult {
  final int score; // 0..100
  final int? nutrition; // sur 60
  final int? additives; // sur 20
  final int? processing; // sur 20
  final Map<String, AdditiveRisk> riskyFound;
  final bool provisional; // données manquantes
  const ScoreResult(this.score, this.nutrition, this.additives,
      this.processing, this.riskyFound, {this.provisional = false});

  /// 3 = excellent (75+), 2 = bon (50+), 1 = à limiter (25+), 0 = à éviter
  int get level => score >= 75 ? 3 : score >= 50 ? 2 : score >= 25 ? 1 : 0;
}

bool isUnrated(Product p) => p.categories.any(unratedCategories.contains);

bool _isWater(Product p) =>
    p.categories.contains('en:waters') &&
    !p.categories.contains('en:flavoured-waters');

bool _isDrink(Product p) => p.categories.contains('en:beverages');

int? nutritionPoints(Product p) {
  final v = p.nutriScoreValue;
  if (v != null) {
    final (best, worst) =
        _isDrink(p) ? (drinkBest, drinkWorst) : (foodBest, foodWorst);
    final ratio = ((worst - v) / (worst - best)).clamp(0.0, 1.0);
    return (60 * ratio).round();
  }
  // Repli : seulement la lettre, on prend le milieu de chaque classe.
  return const {'a': 54, 'b': 42, 'c': 30, 'd': 18, 'e': 6}[p.nutriScore];
}

int additivePoints(Map<String, AdditiveRisk> found) {
  if (found.isEmpty) return 20;
  final risks = found.values.toList()..sort((a, b) => a.index - b.index);
  final worst = risks.first;
  var pts = 20 -
      const {
        AdditiveRisk.red: 20,
        AdditiveRisk.orange: 12,
        AdditiveRisk.yellow: 4,
      }[worst]!;
  final extra = risks.skip(1).where((r) => r != AdditiveRisk.red).length;
  pts -= 2 * extra;
  return pts < 0 ? 0 : pts;
}

/// Retourne null si le produit n'est pas noté ou sans aucune donnée nutritionnelle.
ScoreResult? computeScore(Product p) {
  if (isUnrated(p)) return null;
  if (_isWater(p)) return const ScoreResult(100, 60, 20, 20, {});

  final nutrition = nutritionPoints(p);
  if (nutrition == null) return null;

  final found = {
    for (final a in p.additives)
      if (additiveRisks[a] != null) a: additiveRisks[a]!,
  };
  final hasIngredients = p.ingredientsText.isNotEmpty || p.additives.isNotEmpty;
  final additives = hasIngredients ? additivePoints(found) : null;
  final processing = p.nova == null
      ? null
      : const {1: 20, 2: 16, 3: 10, 4: 0}[p.nova];

  // Partie manquante : on ramène les parties connues sur 100, note provisoire.
  var got = nutrition, max = 60;
  if (additives != null) { got += additives; max += 20; }
  if (processing != null) { got += processing; max += 20; }
  var score = (got * 100 / max).round();

  if (p.nutriScore == 'd' && score > 49) score = 49;
  if (p.nutriScore == 'e' && score > 29) score = 29;
  if (found.containsValue(AdditiveRisk.red) && score > 49) score = 49;
  if (p.nova == 4 && score > 74) score = 74;

  return ScoreResult(score, nutrition, additives, processing, found,
      provisional: additives == null || processing == null ||
          p.nutriScoreValue == null);
}
