import 'package:flutter/widgets.dart';

/// Textes de l'interface en français et en arabe.
/// Simple dictionnaire : ajouter une clé dans les deux langues.
/// `{n}` et `{list}` sont remplacés par [S.t] (paramètre `args`).
class S {
  final String lang;
  const S(this.lang);

  static S of(BuildContext context) =>
      S(Localizations.localeOf(context).languageCode == 'ar' ? 'ar' : 'fr');

  bool get isAr => lang == 'ar';

  /// Séparateur de liste : virgule latine ou arabe.
  String join(Iterable<String> items) => items.join(isAr ? '، ' : ', ');

  static const _t = <String, Map<String, String>>{
    // Général et navigation
    'appName': {'fr': 'Sahti', 'ar': 'صحتي'},
    'nav': {'fr': 'Navigation principale', 'ar': 'التنقل الرئيسي'},
    'home': {'fr': 'Accueil', 'ar': 'الرئيسية'},
    'history': {'fr': 'Historique', 'ar': 'السجل'},
    'settings': {'fr': 'Réglages', 'ar': 'الإعدادات'},
    'back': {'fr': 'Retour', 'ar': 'رجوع'},
    'close': {'fr': 'Fermer', 'ar': 'إغلاق'},
    'cancel': {'fr': 'Annuler', 'ar': 'إلغاء'},
    'validate': {'fr': 'Valider', 'ar': 'تأكيد'},
    'photo': {'fr': 'Photo', 'ar': 'صورة'},
    'promise': {
      'fr': 'Sans publicité. Aucune marque ne paie pour sa note.',
      'ar': 'بلا إعلانات. لا تدفع أي علامة تجارية مقابل تقييمها.'
    },
    'source': {
      'fr': 'Données : Open Food Facts (ODbL)',
      'ar': 'البيانات: Open Food Facts (ODbL)'
    },

    // Accueil
    'tagline': {
      'fr': 'Scannez un produit, comprenez sa note, choisissez mieux.',
      'ar': 'امسح المنتج، افهم تقييمه، واختر الأفضل.'
    },
    'scan': {'fr': 'Scanner un produit', 'ar': 'امسح منتجًا'},
    'manual': {'fr': 'Saisir le code à la main', 'ar': 'أدخل الرمز يدويًا'},
    'recent': {'fr': 'Derniers scans', 'ar': 'آخر المنتجات'},
    'seeAll': {'fr': 'Tout voir', 'ar': 'عرض الكل'},
    'emptyHistory': {
      'fr': 'Aucun produit scanné pour l\'instant.',
      'ar': 'لم تقم بمسح أي منتج بعد.'
    },

    // Scan
    'scanTitle': {'fr': 'Scanner', 'ar': 'المسح'},
    'flash': {'fr': 'Allumer le flash', 'ar': 'تشغيل الفلاش'},
    'pointCamera': {
      'fr': 'Placez le code-barres dans le cadre',
      'ar': 'ضع الرمز الشريطي داخل الإطار'
    },
    'scanAuto': {
      'fr': 'La lecture se fait toute seule, pas besoin d\'appuyer.',
      'ar': 'تتم القراءة تلقائيًا، لا حاجة للضغط.'
    },
    'scanTip': {
      'fr': 'Peu de lumière ? Allumez le flash en haut de l\'écran.',
      'ar': 'الإضاءة ضعيفة؟ شغّل الفلاش أعلى الشاشة.'
    },
    'barcode': {'fr': 'Code-barres', 'ar': 'الرمز الشريطي'},
    'barcodeHint': {'fr': '8 à 14 chiffres', 'ar': 'من 8 إلى 14 رقمًا'},
    'barcodeInvalid': {
      'fr': 'Le code doit avoir 8 à 14 chiffres.',
      'ar': 'يجب أن يتكون الرمز من 8 إلى 14 رقمًا.'
    },
    'cameraError': {
      'fr': 'Caméra indisponible. Saisissez le code à la main.',
      'ar': 'الكاميرا غير متاحة. أدخل الرمز يدويًا.'
    },

    // Chargement et erreurs
    'loading': {'fr': 'Recherche du produit…', 'ar': 'جارٍ البحث عن المنتج…'},
    'error': {
      'fr': 'Erreur réseau. Vérifiez votre connexion.',
      'ar': 'خطأ في الشبكة. تحقق من اتصالك.'
    },
    'retry': {'fr': 'Réessayer', 'ar': 'أعد المحاولة'},

    // Produit introuvable
    'notFound': {'fr': 'Produit introuvable', 'ar': 'المنتج غير موجود'},
    'notFoundHelp': {
      'fr':
          'Aidez tout le monde : ajoutez ce produit en 3 photos. Ça prend moins d\'une minute.',
      'ar':
          'ساعد الجميع: أضف هذا المنتج بثلاث صور. لن يستغرق ذلك أكثر من دقيقة.'
    },
    'stepFront': {'fr': 'Face avant', 'ar': 'الواجهة'},
    'stepIngredients': {'fr': 'Ingrédients', 'ar': 'المكونات'},
    'stepNutrition': {'fr': 'Tableau nutritionnel', 'ar': 'الجدول الغذائي'},
    'whereAdded': {
      'fr':
          'Le produit sera ajouté à Sahti et à Open Food Facts, la base libre et gratuite.',
      'ar':
          'سيُضاف المنتج إلى صحتي وإلى Open Food Facts، القاعدة المفتوحة والمجانية.'
    },
    'addProduct': {'fr': 'Ajouter le produit', 'ar': 'أضف المنتج'},
    'scanOther': {'fr': 'Scanner un autre produit', 'ar': 'امسح منتجًا آخر'},

    // Fiche produit : note
    'scoreLabel': {'fr': 'Note Sahti', 'ar': 'تقييم صحتي'},
    'level0': {'fr': 'À éviter', 'ar': 'يُستحسن تجنبه'},
    'level1': {'fr': 'À limiter', 'ar': 'يُستحسن التقليل منه'},
    'level2': {'fr': 'Bon', 'ar': 'جيد'},
    'level3': {'fr': 'Excellent', 'ar': 'ممتاز'},
    'noScore': {
      'fr': 'Pas assez de données pour noter ce produit.',
      'ar': 'لا توجد بيانات كافية لتقييم هذا المنتج.'
    },
    'provisional': {
      'fr': 'Note provisoire : des données manquent, ajoutez une photo.',
      'ar': 'تقييم مؤقت: بعض البيانات ناقصة، أضف صورة.'
    },
    'unrated': {
      'fr':
          'Ce type de produit n\'est pas noté (lait infantile, complément, sucre ou sel pur, alcool).',
      'ar':
          'هذا النوع من المنتجات لا يُقيَّم (حليب الرضع، المكملات، السكر أو الملح الخالص، الكحول).'
    },
    'nutrition': {'fr': 'Nutrition', 'ar': 'التغذية'},
    'additives': {'fr': 'Additifs', 'ar': 'المضافات'},
    'processing': {'fr': 'Transformation', 'ar': 'درجة التصنيع'},
    'missingData': {'fr': 'Donnée manquante', 'ar': 'معلومة ناقصة'},
    'nova1': {
      'fr': 'Brut ou peu transformé (NOVA 1)',
      'ar': 'خام أو قليل التصنيع (NOVA 1)'
    },
    'nova2': {
      'fr': 'Ingrédient culinaire (NOVA 2)',
      'ar': 'مكوّن للطبخ (NOVA 2)'
    },
    'nova3': {'fr': 'Transformé (NOVA 3)', 'ar': 'مصنّع (NOVA 3)'},
    'nova4': {'fr': 'Ultra-transformé (NOVA 4)', 'ar': 'فائق التصنيع (NOVA 4)'},
    'riskyNone': {
      'fr': 'Aucun additif à surveiller',
      'ar': 'لا توجد مضافات يجب الانتباه إليها'
    },
    'riskyOne': {
      'fr': '1 additif à surveiller',
      'ar': 'مضاف واحد يجب الانتباه إليه'
    },
    'riskyMany': {
      'fr': '{n} additifs à surveiller',
      'ar': '{n} مضافات يجب الانتباه إليها'
    },
    'vNutriGood': {
      'fr': 'Bonne qualité nutritionnelle.',
      'ar': 'جودة غذائية جيدة.'
    },
    'vNutriMid': {
      'fr': 'Qualité nutritionnelle moyenne.',
      'ar': 'جودة غذائية متوسطة.'
    },
    'vNutriBad': {
      'fr': 'Qualité nutritionnelle faible.',
      'ar': 'جودة غذائية ضعيفة.'
    },
    'vUltra': {'fr': 'Ultra-transformé.', 'ar': 'فائق التصنيع.'},
    'howScore': {
      'fr': 'Comment est calculée la note ?',
      'ar': 'كيف يُحسب التقييم؟'
    },
    'methodTitle': {
      'fr': 'Comment on calcule la note',
      'ar': 'كيف نحسب التقييم'
    },
    'methodBody': {
      'fr': 'La note sur 100 additionne trois parties :\n'
          '• Nutrition, sur 60 points, d\'après le Nutri-Score.\n'
          '• Transformation, sur 20 points, d\'après le groupe NOVA.\n'
          '• Additifs, sur 20 points, selon les additifs à surveiller.\n\n'
          'Plafonds : Nutri-Score D, 49 au plus ; Nutri-Score E, 29 au plus ; '
          'additif à risque élevé, 49 au plus ; ultra-transformé, 74 au plus.\n\n'
          'S\'il manque une partie, la note est calculée sur les autres et marquée provisoire.\n\n'
          'Halal, bio et origine sont affichés, jamais notés. Aucune marque ne paie pour sa note.',
      'ar': 'يجمع التقييم من 100 ثلاثة أجزاء:\n'
          '• التغذية، من 60 نقطة، حسب نوتري-سكور.\n'
          '• درجة التصنيع، من 20 نقطة، حسب مجموعة NOVA.\n'
          '• المضافات، من 20 نقطة، حسب المضافات التي يجب الانتباه إليها.\n\n'
          'الحدود القصوى: نوتري-سكور D، 49 على الأكثر؛ نوتري-سكور E، 29 على الأكثر؛ '
          'مضاف عالي الخطورة، 49 على الأكثر؛ فائق التصنيع، 74 على الأكثر.\n\n'
          'إذا نقص جزء، يُحسب التقييم من الأجزاء الأخرى ويُعتبر مؤقتًا.\n\n'
          'حلال والمنتج العضوي والمنشأ تُعرض ولا تدخل في التقييم. لا تدفع أي علامة تجارية مقابل تقييمها.'
    },

    // Fiche produit : additifs, halal, allergènes, valeurs
    'riskyAdditives': {
      'fr': 'Additifs à surveiller',
      'ar': 'مضافات يجب الانتباه إليها'
    },
    'noRisky': {
      'fr': 'Aucun additif à surveiller',
      'ar': 'لا توجد مضافات مقلقة'
    },
    'risk0': {'fr': 'Risque élevé', 'ar': 'خطر مرتفع'},
    'risk1': {'fr': 'Risque modéré', 'ar': 'خطر متوسط'},
    'risk2': {'fr': 'Risque faible', 'ar': 'خطر ضعيف'},
    'otherAdditives': {
      'fr': 'Autres additifs, sans risque connu : {list}.',
      'ar': 'مضافات أخرى بلا خطر معروف: {list}.'
    },
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
    'allergenContains': {'fr': 'Contient : {list}', 'ar': 'يحتوي على: {list}'},
    'allergenTraces': {
      'fr': 'Peut contenir des traces de : {list}',
      'ar': 'قد يحتوي على آثار من: {list}'
    },
    'allergenNote': {
      'fr':
          'D\'après Open Food Facts et la liste des ingrédients. Vérifiez toujours l\'emballage.',
      'ar': 'حسب Open Food Facts وقائمة المكونات. تحقق دائمًا من العبوة.'
    },
    'allergenUnknown': {
      'fr': 'Allergènes non renseignés pour ce produit. Vérifiez l\'emballage.',
      'ar': 'لا توجد معلومات عن مسببات الحساسية لهذا المنتج. تحقق من العبوة.'
    },
    'ingredients': {'fr': 'Ingrédients', 'ar': 'المكونات'},
    'per100g': {'fr': 'Pour 100 g', 'ar': 'لكل 100 غ'},
    'kcal': {'fr': 'Énergie (kcal)', 'ar': 'الطاقة (سعرة)'},
    'fat': {'fr': 'Matières grasses', 'ar': 'الدهون'},
    'satFat': {'fr': 'Graisses saturées', 'ar': 'الدهون المشبعة'},
    'sugars': {'fr': 'Sucres', 'ar': 'السكريات'},
    'salt': {'fr': 'Sel', 'ar': 'الملح'},
    'report': {
      'fr': 'Ajouter une photo ou signaler une erreur',
      'ar': 'أضف صورة أو أبلغ عن خطأ'
    },

    // Ajout par photos
    'photos': {'fr': 'Photos', 'ar': 'الصور'},
    'photosProgress': {'fr': '{n} sur 3', 'ar': '{n} من 3'},
    'takePhoto': {'fr': 'Prendre la photo', 'ar': 'التقط الصورة'},
    'photoTaken': {'fr': 'Photo prise', 'ar': 'تم التقاط الصورة'},
    'photoFront': {'fr': '1. Photo de face', 'ar': '1. صورة الواجهة'},
    'photoIngredients': {
      'fr': '2. Liste des ingrédients',
      'ar': '2. قائمة المكونات'
    },
    'photoNutrition': {
      'fr': '3. Tableau nutritionnel',
      'ar': '3. الجدول الغذائي'
    },
    'name': {'fr': 'Nom du produit', 'ar': 'اسم المنتج'},
    'brand': {'fr': 'Marque', 'ar': 'العلامة التجارية'},
    'brandHint': {
      'fr': 'Ex. : nom sur l\'emballage',
      'ar': 'مثلًا: الاسم المكتوب على العبوة'
    },
    'ingredientsOcr': {
      'fr': 'Ingrédients (lus sur la photo, corrigez si besoin)',
      'ar': 'المكونات (مقروءة من الصورة، صححها إن لزم)'
    },
    'halalCheck': {
      'fr': 'Le logo halal est présent sur l\'emballage',
      'ar': 'شعار حلال موجود على العبوة'
    },
    'send': {'fr': 'Envoyer', 'ar': 'إرسال'},
    'license': {
      'fr':
          'Les photos seront partagées sur Open Food Facts sous licence libre. Sans réseau, le produit est gardé et envoyé plus tard.',
      'ar':
          'ستُنشر الصور على Open Food Facts برخصة حرة. بدون اتصال، يُحفظ المنتج ويُرسل لاحقًا.'
    },
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

    // Historique
    'clearAll': {'fr': 'Tout effacer', 'ar': 'مسح الكل'},
    'clearConfirm': {
      'fr': 'Effacer tout l\'historique ?',
      'ar': 'هل تريد مسح السجل بالكامل؟'
    },
    'clear': {'fr': 'Effacer', 'ar': 'مسح'},
    'search': {'fr': 'Rechercher dans l\'historique', 'ar': 'ابحث في السجل'},
    'noResults': {'fr': 'Aucun résultat.', 'ar': 'لا توجد نتائج.'},
    'today': {'fr': 'Aujourd\'hui', 'ar': 'اليوم'},
    'thisWeek': {'fr': 'Cette semaine', 'ar': 'هذا الأسبوع'},
    'older': {'fr': 'Plus ancien', 'ar': 'أقدم'},
    'pendingWord': {'fr': 'En attente d\'envoi', 'ar': 'في انتظار الإرسال'},
    'swipe': {
      'fr': 'Glissez une ligne pour la supprimer.',
      'ar': 'اسحب السطر لحذفه.'
    },
    'deleted': {'fr': 'Supprimé de l\'historique.', 'ar': 'حُذف من السجل.'},

    // Réglages
    'language': {'fr': 'Langue', 'ar': 'اللغة'},
    'theme': {'fr': 'Apparence', 'ar': 'المظهر'},
    'light': {'fr': 'Clair', 'ar': 'فاتح'},
    'dark': {'fr': 'Sombre', 'ar': 'داكن'},
    'auto': {'fr': 'Auto', 'ar': 'تلقائي'},
    'prefs': {'fr': 'Mes préférences', 'ar': 'تفضيلاتي'},
    'halalShow': {'fr': 'Afficher l\'info halal', 'ar': 'عرض معلومة حلال'},
    'halalShowSub': {
      'fr': 'Telle qu\'indiquée sur l\'emballage',
      'ar': 'كما هي مذكورة على العبوة'
    },
    'allergensTitle': {
      'fr': 'M\'alerter si le produit contient :',
      'ar': 'نبّهني إذا احتوى المنتج على:'
    },
    'pending0': {
      'fr': 'Aucun produit en attente',
      'ar': 'لا يوجد منتج في انتظار الإرسال'
    },
    'pending1': {
      'fr': '1 produit en attente',
      'ar': 'منتج واحد في انتظار الإرسال'
    },
    'pendingN': {
      'fr': '{n} produits en attente',
      'ar': '{n} منتجات في انتظار الإرسال'
    },
    'pendingSub': {
      'fr': 'Il sera envoyé dès que le réseau revient.',
      'ar': 'سيُرسل فور عودة الاتصال.'
    },
    'pendingNoAccount': {
      'fr':
          'L\'envoi vers Open Food Facts n\'est pas encore activé dans cette version.',
      'ar': 'الإرسال إلى Open Food Facts غير مفعّل بعد في هذا الإصدار.'
    },
    'sentCount': {
      'fr': 'Produits envoyés : {n}',
      'ar': 'المنتجات المرسلة: {n}'
    },
    'sendFailed': {
      'fr': 'Envoi impossible pour l\'instant. Réessayez plus tard.',
      'ar': 'تعذّر الإرسال حاليًا. أعد المحاولة لاحقًا.'
    },
    'additivesTitle': {
      'fr': 'Liste des additifs à surveiller',
      'ar': 'قائمة المضافات التي يجب الانتباه إليها'
    },
    'additivesIntro': {
      'fr': 'Classement provisoire, en cours de validation avec ses sources.',
      'ar': 'تصنيف مؤقت، قيد التحقق مع مصادره.'
    },
    'version': {'fr': 'Version {n}', 'ar': 'الإصدار {n}'},
  };

  String t(String key, {Object? n, Iterable<String>? list}) {
    var s = _t[key]?[lang] ?? _t[key]?['fr'] ?? key;
    if (n != null) s = s.replaceAll('{n}', '$n');
    if (list != null) s = s.replaceAll('{list}', join(list));
    return s;
  }

  /// Toutes les clés : sert au test qui vérifie que chaque texte existe
  /// dans les deux langues.
  static Iterable<String> get keys => _t.keys;
  static bool hasBoth(String key) =>
      (_t[key]?['fr']?.isNotEmpty ?? false) &&
      (_t[key]?['ar']?.isNotEmpty ?? false);
}
