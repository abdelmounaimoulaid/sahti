import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'off_api.dart';

/// Produits ajoutés mais pas encore envoyés (pas de réseau ou compte
/// Open Food Facts non configuré). Les photos restent sur le téléphone.
class Pending {
  static const _key = 'pending_v1';

  /// Change à chaque ajout ou envoi, pour rafraîchir les écrans.
  static final changes = ValueNotifier<int>(0);

  static Future<List<Map<String, dynamic>>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_key) ?? [])
        .map((s) => jsonDecode(s) as Map<String, dynamic>)
        .toList();
  }

  static Future<void> _save(List<Map<String, dynamic>> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, list.map(jsonEncode).toList());
    changes.value++;
  }

  static Future<void> add(Map<String, dynamic> item) async {
    final list = await load();
    list.removeWhere((x) => x['code'] == item['code']);
    list.add(item);
    await _save(list);
  }

  /// Essaie d'envoyer chaque produit en attente. Retourne le nombre envoyé.
  static Future<int> sendAll([OffApi? api]) async {
    if (!OffApi.canUpload) return 0;
    final client = api ?? OffApi();
    final list = await load();
    final left = <Map<String, dynamic>>[];
    var sent = 0;
    for (final item in list) {
      try {
        await client.upload(
          barcode: item['code'],
          name: item['name'] ?? '',
          brand: item['brand'] ?? '',
          ingredientsText: item['ingredients'] ?? '',
          halal: item['halal'] == true,
          front: File(item['front']),
          ingredients: File(item['ingr']),
          nutrition: File(item['nutri']),
        );
        sent++;
      } catch (_) {
        left.add(item);
      }
    }
    await _save(left);
    return sent;
  }
}
