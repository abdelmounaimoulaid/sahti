import '../models/product.dart';

/// Un allergène que l'utilisateur peut surveiller (les 14 allergènes
/// à déclaration obligatoire, comme sur Open Food Facts).
class Allergen {
  final String id; // étiquette Open Food Facts, ex. 'en:gluten'
  final String fr, ar;

  /// Mots cherchés dans la liste des ingrédients quand les étiquettes
  /// Open Food Facts manquent. En lettres latines : mots entiers, sans
  /// accents, pluriel en -s/-x accepté. En arabe : simple recherche.
  final List<String> words;
  const Allergen(this.id, this.fr, this.ar, this.words);

  String label(String lang) => lang == 'ar' ? ar : fr;
}

/// Dans l'ordre de la maquette des réglages (les 7 plus courants d'abord).
const allergens = <Allergen>[
  Allergen('en:gluten', 'Gluten', 'الغلوتين', [
    'gluten',
    'ble',
    'froment',
    'orge',
    'seigle',
    'avoine',
    'epeautre',
    'kamut',
    'wheat',
    'barley',
    'rye',
    'oat',
    'oats',
    'spelt',
    'قمح',
    'شعير',
    'غلوتين',
    'شوفان'
  ]),
  Allergen('en:milk', 'Lait', 'الحليب', [
    'lait',
    'lactose',
    'beurre',
    'creme',
    'fromage',
    'lactoserum',
    'petit lait',
    'caseine',
    'caseinate',
    'yaourt',
    'milk',
    'whey',
    'butter',
    'cream',
    'cheese',
    'حليب',
    'زبدة',
    'جبن',
    'لاكتوز',
    'قشدة'
  ]),
  Allergen('en:eggs', 'Œufs', 'البيض', ['oeuf', 'egg', 'albumine', 'بيض']),
  Allergen('en:peanuts', 'Arachides', 'الفول السوداني', [
    'arachide',
    'cacahuete',
    'cacahouete',
    'peanut',
    'فول سوداني',
    'كاوكاو'
  ]),
  Allergen('en:nuts', 'Fruits à coque', 'المكسرات', [
    'amande',
    'noisette',
    'noix',
    'pistache',
    'cajou',
    'pecan',
    'macadamia',
    'almond',
    'hazelnut',
    'walnut',
    'cashew',
    'pistachio',
    'لوز',
    'بندق',
    'جوز',
    'فستق',
    'كاجو'
  ]),
  Allergen('en:soybeans', 'Soja', 'الصويا', ['soja', 'soya', 'soy', 'صويا']),
  Allergen('en:sesame-seeds', 'Sésame', 'السمسم',
      ['sesame', 'tahini', 'tahina', 'سمسم', 'طحينة']),
  Allergen('en:fish', 'Poisson', 'السمك', [
    'poisson',
    'thon',
    'sardine',
    'anchois',
    'saumon',
    'maquereau',
    'merlu',
    'fish',
    'tuna',
    'سمك',
    'سردين',
    'تونة',
    'أنشوبة'
  ]),
  Allergen('en:crustaceans', 'Crustacés', 'القشريات', [
    'crustace',
    'crevette',
    'crabe',
    'homard',
    'langouste',
    'langoustine',
    'shrimp',
    'prawn',
    'crab',
    'lobster',
    'قشريات',
    'روبيان',
    'قمرون'
  ]),
  Allergen('en:molluscs', 'Mollusques', 'الرخويات', [
    'mollusque',
    'moules',
    'calmar',
    'calamar',
    'poulpe',
    'huitre',
    'seiche',
    'squid',
    'octopus',
    'mussel',
    'oyster',
    'رخويات',
    'كلمار',
    'أخطبوط'
  ]),
  Allergen('en:celery', 'Céleri', 'الكرفس', ['celeri', 'celery', 'كرفس']),
  Allergen('en:mustard', 'Moutarde', 'الخردل', ['moutarde', 'mustard', 'خردل']),
  Allergen('en:sulphur-dioxide-and-sulphites', 'Sulfites', 'الكبريتيت', [
    'sulfite',
    'sulphite',
    'metabisulfite',
    'disulfite',
    'anhydride sulfureux',
    'e220',
    'e221',
    'e222',
    'e223',
    'e224',
    'e226',
    'e227',
    'e228'
  ]),
  Allergen('en:lupin', 'Lupin', 'الترمس', ['lupin', 'ترمس']),
];

Allergen? allergenById(String id) {
  for (final a in allergens) {
    if (a.id == id) return a;
  }
  return null;
}

/// Ce qu'on a trouvé pour les allergènes surveillés.
class AllergenCheck {
  final List<Allergen> contains;
  final List<Allergen> traces;

  /// Ni étiquettes ni liste d'ingrédients : on ne peut rien dire.
  final bool unknown;
  const AllergenCheck(this.contains, this.traces, {this.unknown = false});

  bool get isEmpty => contains.isEmpty && traces.isEmpty;
}

/// Expressions qui contiennent un mot d'allergène sans en être un.
const _notAllergens = [
  'beurre de cacao',
  'cocoa butter',
  'lait de coco',
  'coconut milk',
  'creme de coco',
  'noix de coco',
  'noix de muscade',
  'beurre de karite',
  'creme de tartre',
  'sans gluten',
  'gluten free',
  'sans lactose',
];

const _accents = {
  'à': 'a',
  'â': 'a',
  'ä': 'a',
  'á': 'a',
  'ç': 'c',
  'é': 'e',
  'è': 'e',
  'ê': 'e',
  'ë': 'e',
  'î': 'i',
  'ï': 'i',
  'í': 'i',
  'ô': 'o',
  'ö': 'o',
  'ó': 'o',
  'ù': 'u',
  'û': 'u',
  'ü': 'u',
  'ú': 'u',
  'ÿ': 'y',
  'ñ': 'n',
  'œ': 'oe',
  'æ': 'ae',
};

/// Texte en minuscules, sans accents, mots séparés par une espace,
/// avec une espace au début et à la fin.
String normalizeIngredients(String text) {
  final low = text.toLowerCase().split('').map((c) => _accents[c] ?? c).join();
  final words = low
      .split(RegExp(r'[^\p{L}\p{N}]+', unicode: true))
      .where((w) => w.isNotEmpty);
  var s = ' ${words.join(' ')} ';
  for (final x in _notAllergens) {
    s = s.replaceAll(' $x ', ' ');
  }
  return s;
}

const _traceMarkers = [
  ' peut contenir ',
  ' traces ',
  ' trace ',
  ' may contain ',
  ' قد يحتوي ',
];

final _latin = RegExp(r'^[a-z0-9 ]+$');

bool _mentions(String normalized, Allergen a) {
  for (final w in a.words) {
    if (_latin.hasMatch(w)) {
      if (normalized.contains(' $w ') ||
          normalized.contains(' ${w}s ') ||
          normalized.contains(' ${w}x ')) {
        return true;
      }
    } else if (normalized.contains(w)) {
      return true;
    }
  }
  return false;
}

/// Allergènes de [watched] présents dans le produit : étiquettes
/// Open Food Facts, complétées par la lecture de la liste d'ingrédients
/// (mieux vaut une alerte de trop qu'une alerte manquée).
AllergenCheck checkAllergens(Product p, Set<String> watched) {
  final hasTags = p.allergenTags.isNotEmpty || p.traceTags.isNotEmpty;
  final hasText = p.ingredientsText.trim().isNotEmpty;
  if (watched.isEmpty) return const AllergenCheck([], []);
  if (!hasTags && !hasText) {
    return const AllergenCheck([], [], unknown: true);
  }
  // « Peut contenir des traces de lait » : la fin du texte parle de traces.
  var text = hasText ? normalizeIngredients(p.ingredientsText) : '';
  var traceText = '';
  final cut = _traceMarkers
      .map((m) => text.indexOf(m))
      .where((i) => i >= 0)
      .fold<int?>(null, (a, b) => a == null || b < a ? b : a);
  if (cut != null) {
    traceText = ' ${text.substring(cut)}';
    text = '${text.substring(0, cut)} ';
  }
  final contains = <Allergen>[];
  final traces = <Allergen>[];
  for (final a in allergens) {
    if (!watched.contains(a.id)) continue;
    if (p.allergenTags.contains(a.id) || (hasText && _mentions(text, a))) {
      contains.add(a);
    } else if (p.traceTags.contains(a.id) ||
        (traceText.isNotEmpty && _mentions(traceText, a))) {
      traces.add(a);
    }
  }
  return AllergenCheck(contains, traces);
}
