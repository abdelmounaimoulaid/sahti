import 'package:flutter/widgets.dart';

/// Textes de l'interface en français et en arabe.
/// Simple dictionnaire : ajouter une clé dans les deux langues.
class S {
  final String lang;
  const S(this.lang);

  static S of(BuildContext context) =>
      S(Localizations.localeOf(context).languageCode == 'ar' ? 'ar' : 'fr');

  static const _t = <String, Map<String, String>>{
    'appName': {'fr': 'Sahti', 'ar': 'صحتي'},
    'scan': {'fr': 'Scanner un produit', 'ar': 'امسح منتجًا'},
    'history': {'fr': 'Historique', 'ar': 'السجل'},
    'emptyHistory': {
      'fr': 'Aucun produit scanné pour l\'instant.',
      'ar': 'لم تقم بمسح أي منتج بعد.'
    },
    'pointCamera': {
      'fr': 'Placez le code-barres dans le cadre',
      'ar': 'ضع الرمز الشريطي داخل الإطار'
    },
    'loading': {'fr': 'Recherche du produit…', 'ar': 'جارٍ البحث عن المنتج…'},
    'notFound': {'fr': 'Produit introuvable', 'ar': 'المنتج غير موجود'},
    'notFoundHelp': {
      'fr': 'Aidez tout le monde : ajoutez ce produit en 3 photos.',
      'ar': 'ساعد الجميع: أضف هذا المنتج بثلاث صور.'
    },
    'addProduct': {'fr': 'Ajouter le produit', 'ar': 'أضف المنتج'},
    'error': {
      'fr': 'Erreur réseau. Vérifiez votre connexion.',
      'ar': 'خطأ في الشبكة. تحقق من اتصالك.'
    },
    'retry': {'fr': 'Réessayer', 'ar': 'أعد المحاولة'},
    'noScore': {
      'fr': 'Pas assez de données pour noter ce produit.',
      'ar': 'لا توجد بيانات كافية لتقييم هذا المنتج.'
    },
    'level0': {'fr': 'À éviter', 'ar': 'يُستحسن تجنبه'},
    'level1': {'fr': 'À limiter', 'ar': 'يُستحسن التقليل منه'},
    'provisional': {
      'fr': 'Note provisoire : des données manquent, ajoutez une photo.',
      'ar': 'تقييم مؤقت: بعض البيانات ناقصة، أضف صورة.'
    },
    'unrated': {
      'fr': 'Ce type de produit n\'est pas noté (lait infantile, complément, sucre ou sel pur, alcool).',
      'ar': 'هذا النوع من المنتجات لا يُقيَّم (حليب الرضع، المكملات، السكر أو الملح الخالص، الكحول).'
    },
    'level2': {'fr': 'Bon', 'ar': 'جيد'},
    'level3': {'fr': 'Excellent', 'ar': 'ممتاز'},
    'nutrition': {'fr': 'Nutrition', 'ar': 'التغذية'},
    'additives': {'fr': 'Additifs', 'ar': 'المضافات'},
    'processing': {'fr': 'Transformation', 'ar': 'درجة التصنيع'},
    'riskyAdditives': {'fr': 'Additifs à surveiller', 'ar': 'مضافات يجب الانتباه إليها'},
    'noRisky': {'fr': 'Aucun additif à surveiller', 'ar': 'لا توجد مضافات مقلقة'},
    'halalYes': {
      'fr': 'Halal indiqué sur l\'emballage',
      'ar': 'حلال مذكور على العبوة'
    },
    'halalNo': {
      'fr': 'Halal non indiqué sur l\'emballage',
      'ar': 'حلال غير مذكور على العبوة'
    },
    'halalNote': {
      'fr': 'Information déclarée par le fabricant, non vérifiée par l\'app.',
      'ar': 'معلومة يصرح بها المصنع، ولم يتحقق منها التطبيق.'
    },
    'ingredients': {'fr': 'Ingrédients', 'ar': 'المكونات'},
    'per100g': {'fr': 'Pour 100 g', 'ar': 'لكل 100 غ'},
    'sugars': {'fr': 'Sucres', 'ar': 'السكريات'},
    'fat': {'fr': 'Matières grasses', 'ar': 'الدهون'},
    'satFat': {'fr': 'Graisses saturées', 'ar': 'الدهون المشبعة'},
    'salt': {'fr': 'Sel', 'ar': 'الملح'},
    'kcal': {'fr': 'Énergie (kcal)', 'ar': 'الطاقة (سعرة)'},
    'photoFront': {'fr': '1. Photo de face', 'ar': '1. صورة الواجهة'},
    'photoIngredients': {'fr': '2. Liste des ingrédients', 'ar': '2. قائمة المكونات'},
    'photoNutrition': {'fr': '3. Tableau nutritionnel', 'ar': '3. الجدول الغذائي'},
    'name': {'fr': 'Nom du produit', 'ar': 'اسم المنتج'},
    'brand': {'fr': 'Marque', 'ar': 'العلامة التجارية'},
    'ingredientsOcr': {
      'fr': 'Ingrédients (lus sur la photo, corrigez si besoin)',
      'ar': 'المكونات (مقروءة من الصورة، صححها إن لزم)'
    },
    'halalCheck': {
      'fr': 'Le logo halal est présent sur l\'emballage',
      'ar': 'شعار حلال موجود على العبوة'
    },
    'send': {'fr': 'Envoyer', 'ar': 'إرسال'},
    'sent': {
      'fr': 'Merci ! Le produit a été envoyé.',
      'ar': 'شكرًا! تم إرسال المنتج.'
    },
    'savedLocally': {
      'fr': 'Merci ! Le produit est enregistré et sera envoyé plus tard.',
      'ar': 'شكرًا! تم حفظ المنتج وسيُرسل لاحقًا.'
    },
    'missingPhotos': {
      'fr': 'Il faut les 3 photos et le nom.',
      'ar': 'يلزم التقاط الصور الثلاث وكتابة الاسم.'
    },
    'source': {
      'fr': 'Données : Open Food Facts (ODbL)',
      'ar': 'البيانات: Open Food Facts (ODbL)'
    },
    'language': {'fr': 'العربية', 'ar': 'Français'},
  };

  String t(String key) => _t[key]?[lang] ?? _t[key]?['fr'] ?? key;
}
