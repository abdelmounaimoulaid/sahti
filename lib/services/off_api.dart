import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/product.dart';

/// Client minimal Open Food Facts (gratuit, sans clé pour la lecture).
class OffApi {
  static const _base = 'https://world.openfoodfacts.org';
  // Open Food Facts demande un User-Agent identifiant l'app.
  static const _ua = 'Sahti/0.1 (Flutter)';
  // Compte Open Food Facts de l'app pour l'envoi de produits.
  // À passer au build : --dart-define=OFF_USER=xxx --dart-define=OFF_PASSWORD=yyy
  static const _user = String.fromEnvironment('OFF_USER');
  static const _password = String.fromEnvironment('OFF_PASSWORD');

  static bool get canUpload => _user.isNotEmpty && _password.isNotEmpty;

  final http.Client _client;
  OffApi([http.Client? client]) : _client = client ?? http.Client();

  // Base Sahti (produits marocains vérifiés). Modifiable au build :
  // --dart-define=SAHTI_API=https://...
  static const _sahtiBase = String.fromEnvironment('SAHTI_API',
      defaultValue: 'https://noted-orange-otter-67.hostingersite.com');

  /// Retourne le produit, ou null s'il n'existe pas.
  /// Cherche d'abord dans la base Sahti (fiches marocaines vérifiées),
  /// puis sur Open Food Facts. Si la fiche Sahti n'a pas de nom ou d'image,
  /// ils sont complétés depuis Open Food Facts.
  Future<Product?> fetch(String barcode) async {
    final sahti = await _fetchSahti(barcode);
    if (sahti != null &&
        _str(sahti['product_name']).isNotEmpty &&
        _str(sahti['image_front_url']).isNotEmpty) {
      return Product.fromOff(barcode, sahti);
    }
    Map<String, dynamic>? off;
    try {
      off = await _fetchOff(barcode);
    } catch (_) {
      if (sahti == null) rethrow;
    }
    if (sahti == null) {
      return off == null ? null : Product.fromOff(barcode, off);
    }
    final merged = Map<String, dynamic>.from(sahti);
    if (off != null) {
      for (final k in const [
        'product_name',
        'product_name_fr',
        'product_name_ar',
        'product_name_en',
        'brands',
        'image_front_url',
        'image_url',
        'labels_tags',
      ]) {
        final v = merged[k];
        final empty = v == null || (v is String && v.trim().isEmpty) ||
            (v is List && v.isEmpty);
        if (empty && off[k] != null) merged[k] = off[k];
      }
    }
    return Product.fromOff(barcode, merged);
  }

  static String _str(Object? v) => v is String ? v.trim() : '';

  /// Fiche de la base Sahti, ou null (absente, erreur réseau, délai dépassé).
  Future<Map<String, dynamic>?> _fetchSahti(String barcode) async {
    try {
      final res = await _client
          .get(Uri.parse('$_sahtiBase/api/v1/products/$barcode'),
              headers: {'User-Agent': _ua, 'Accept': 'application/json'})
          .timeout(const Duration(seconds: 4));
      if (res.statusCode != 200) return null;
      final body = jsonDecode(utf8.decode(res.bodyBytes));
      if (body is! Map || body['status'] != 1 || body['product'] is! Map) {
        return null;
      }
      return Map<String, dynamic>.from(body['product'] as Map);
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> _fetchOff(String barcode) async {
    final uri = Uri.parse('$_base/api/v2/product/$barcode.json'
        '?lc=fr&fields=code,product_name,product_name_fr,product_name_ar,'
        'product_name_en,brands,image_front_url,image_url,nutriscore_grade,'
        'nutrition_grades,nutriscore_score,categories_tags,nova_group,additives_tags,labels_tags,'
        'allergens_tags,traces_tags,'
        'ingredients_text,ingredients_text_fr,ingredients_text_ar,nutriments');
    final res = await _client.get(uri, headers: {'User-Agent': _ua});
    if (res.statusCode == 404) return null;
    if (res.statusCode != 200) {
      throw HttpException('Open Food Facts: ${res.statusCode}');
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (body['status'] != 1 || body['product'] == null) return null;
    return body['product'] as Map<String, dynamic>;
  }

  /// Crée ou complète un produit sur Open Food Facts avec ses photos.
  Future<void> upload({
    required String barcode,
    required String name,
    required String brand,
    required String ingredientsText,
    required bool halal,
    required File front,
    required File ingredients,
    required File nutrition,
  }) async {
    final fields = {
      'code': barcode,
      'user_id': _user,
      'password': _password,
      'product_name': name,
      'brands': brand,
      'ingredients_text_fr': ingredientsText,
      'countries': 'Maroc',
      if (halal) 'add_labels': 'Halal',
    };
    final res = await _client.post(Uri.parse('$_base/cgi/product_jqm2.pl'),
        headers: {'User-Agent': _ua}, body: fields);
    if (res.statusCode != 200) {
      throw HttpException('Envoi produit: ${res.statusCode}');
    }
    for (final (field, file) in [
      ('front_fr', front),
      ('ingredients_fr', ingredients),
      ('nutrition_fr', nutrition),
    ]) {
      final req = http.MultipartRequest(
          'POST', Uri.parse('$_base/cgi/product_image_upload.pl'))
        ..headers['User-Agent'] = _ua
        ..fields.addAll({
          'code': barcode,
          'imagefield': field,
          'user_id': _user,
          'password': _password,
        })
        ..files.add(
            await http.MultipartFile.fromPath('imgupload_$field', file.path));
      final r = await _client.send(req);
      if (r.statusCode != 200) {
        throw HttpException('Envoi photo $field: ${r.statusCode}');
      }
    }
  }
}
