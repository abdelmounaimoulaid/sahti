/// Un produit alimentaire, construit à partir de la réponse Open Food Facts.
class Product {
  final String barcode;
  final String name;
  final String brand;
  final String? imageUrl;
  final String? nutriScore; // 'a'..'e' ou null
  final int? nova; // 1..4 ou null
  final List<String> additives; // ex. ['en:e330', 'en:e250']
  final List<String> labels; // ex. ['en:halal', 'en:organic']
  final String ingredientsText;
  final Map<String, double> nutriments; // pour 100 g

  const Product({
    required this.barcode,
    required this.name,
    required this.brand,
    this.imageUrl,
    this.nutriScore,
    this.nova,
    this.additives = const [],
    this.labels = const [],
    this.ingredientsText = '',
    this.nutriments = const {},
  });

  /// Halal V1 : uniquement ce qui est déclaré sur l'emballage (label "halal").
  bool get halalOnPackage =>
      labels.any((l) => l.toLowerCase().contains('halal'));

  factory Product.fromOff(String barcode, Map<String, dynamic> p) {
    String pick(List<String> keys) {
      for (final k in keys) {
        final v = p[k];
        if (v is String && v.trim().isNotEmpty) return v.trim();
      }
      return '';
    }

    final grade = (p['nutriscore_grade'] ?? p['nutrition_grades']) as String?;
    final novaRaw = p['nova_group'];
    final nutr = <String, double>{};
    final rawN = p['nutriments'];
    if (rawN is Map) {
      for (final key in const [
        'energy-kcal_100g',
        'fat_100g',
        'saturated-fat_100g',
        'sugars_100g',
        'salt_100g',
        'fiber_100g',
        'proteins_100g',
      ]) {
        final v = rawN[key];
        if (v is num) nutr[key] = v.toDouble();
      }
    }

    return Product(
      barcode: barcode,
      name: pick(['product_name_fr', 'product_name', 'product_name_ar', 'product_name_en']),
      brand: pick(['brands']),
      imageUrl: pick(['image_front_url', 'image_url']).isEmpty
          ? null
          : pick(['image_front_url', 'image_url']),
      nutriScore: (grade != null && 'abcde'.contains(grade) && grade.length == 1)
          ? grade
          : null,
      nova: novaRaw is num ? novaRaw.toInt() : int.tryParse('$novaRaw'),
      additives: List<String>.from(p['additives_tags'] ?? const []),
      labels: List<String>.from(p['labels_tags'] ?? const []),
      ingredientsText: pick(['ingredients_text_fr', 'ingredients_text', 'ingredients_text_ar']),
      nutriments: nutr,
    );
  }
}
