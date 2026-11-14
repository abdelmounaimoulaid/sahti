import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Produits ajoutés mais pas encore envoyés (pas de réseau ou compte
/// Open Food Facts non configuré). Les photos restent sur le téléphone.
class Pending {
  static const _key = 'pending_v1';

  static Future<List<Map<String, dynamic>>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_key) ?? [])
        .map((s) => jsonDecode(s) as Map<String, dynamic>)
        .toList();
  }

  static Future<void> add(Map<String, dynamic> item) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    list.add(jsonEncode(item));
    await prefs.setStringList(_key, list);
  }
}
