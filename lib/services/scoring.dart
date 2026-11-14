import '../models/product.dart';

/// Additifs considérés "à surveiller" (liste courte et prudente, à réviser).
const riskyAdditives = <String>{
  'en:e102', 'en:e104', 'en:e110', 'en:e122', 'en:e124', 'en:e129', // colorants azoïques
  'en:e150c', 'en:e150d', 'en:e171', // caramels ammoniacaux, dioxyde de titane
  'en:e249', 'en:e250', 'en:e251', 'en:e252', // nitrites / nitrates
  'en:e320', 'en:e321', // BHA / BHT
  'en:e621', // glutamate
  'en:e950', 'en:e951', 'en:e954', 'en:e955', // édulcorants
};

class ScoreResult {
  final int score; // 0..100
  final int? nutrition; // sur 55
  final int? additives; // sur 25
  final int? processing; // sur 20
  final List<String> riskyFound;
  const ScoreResult(this.score, this.nutrition, this.additives,
      this.processing, this.riskyFound);

  /// 0 = mauvais, 1 = médiocre, 2 = bon, 3 = excellent
  int get level => score >= 75 ? 3 : score >= 50 ? 2 : score >= 25 ? 1 : 0;
}

/// Note sur 100 : nutrition 55 (Nutri-Score) + additifs 25 + transformation 20 (NOVA).
/// Si une partie manque, les autres sont ramenées sur 100.
/// Retourne null si aucune donnée n'est disponible.
ScoreResult? computeScore(Product p) {
  int? nutrition;
  if (p.nutriScore != null) {
    nutrition = const {'a': 55, 'b': 44, 'c': 28, 'd': 12, 'e': 0}[p.nutriScore];
  }

  final risky = p.additives.where(riskyAdditives.contains).toList();
  int? additives;
  if (p.additives.isNotEmpty || p.ingredientsText.isNotEmpty) {
    additives = (25 - risky.length * 10).clamp(0, 25);
  }

  int? processing;
  if (p.nova != null) {
    processing = const {1: 20, 2: 15, 3: 8, 4: 0}[p.nova];
  }

  var got = 0, max = 0;
  if (nutrition != null) { got += nutrition; max += 55; }
  if (additives != null) { got += additives; max += 25; }
  if (processing != null) { got += processing; max += 20; }
  if (max == 0 || nutrition == null) return null; // nutrition indispensable

  return ScoreResult((got * 100 / max).round(), nutrition, additives,
      processing, risky);
}
