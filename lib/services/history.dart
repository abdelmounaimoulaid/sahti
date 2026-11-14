import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryEntry {
  final String barcode, name, brand;
  final int? score;
  final DateTime at;
  final String? imageUrl;
  HistoryEntry(this.barcode, this.name, this.brand, this.score, this.at,
      {this.imageUrl});

  Map<String, dynamic> toJson() => {
        'b': barcode,
        'n': name,
        'br': brand,
        's': score,
        't': at.toIso8601String(),
        if (imageUrl != null) 'i': imageUrl,
      };
  factory HistoryEntry.fromJson(Map<String, dynamic> j) =>
      HistoryEntry(j['b'], j['n'], j['br'], j['s'], DateTime.parse(j['t']),
          imageUrl: j['i']);
}

/// Historique des scans, stocké sur le téléphone (gratuit, hors ligne).
class History {
  static const _key = 'history_v1';
  static const _max = 100;

  /// Change à chaque modification, pour rafraîchir l'accueil et l'historique.
  static final changes = ValueNotifier<int>(0);

  static Future<List<HistoryEntry>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_key) ?? [])
        .map((s) => HistoryEntry.fromJson(jsonDecode(s)))
        .toList();
  }

  static Future<void> _save(List<HistoryEntry> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _key, list.take(_max).map((x) => jsonEncode(x.toJson())).toList());
    changes.value++;
  }

  static Future<void> add(HistoryEntry e) async {
    final list = await load();
    list.removeWhere((x) => x.barcode == e.barcode);
    list.insert(0, e);
    await _save(list);
  }

  static Future<void> remove(String barcode) async {
    final list = await load();
    list.removeWhere((x) => x.barcode == barcode);
    await _save(list);
  }

  static Future<void> clear() => _save([]);
}
