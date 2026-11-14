import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryEntry {
  final String barcode, name, brand;
  final int? score;
  final DateTime at;
  HistoryEntry(this.barcode, this.name, this.brand, this.score, this.at);

  Map<String, dynamic> toJson() => {
        'b': barcode, 'n': name, 'br': brand, 's': score,
        't': at.toIso8601String(),
      };
  factory HistoryEntry.fromJson(Map<String, dynamic> j) => HistoryEntry(
      j['b'], j['n'], j['br'], j['s'], DateTime.parse(j['t']));
}

/// Historique des scans, stocké sur le téléphone (gratuit, hors ligne).
class History {
  static const _key = 'history_v1';
  static const _max = 100;

  static Future<List<HistoryEntry>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_key) ?? [])
        .map((s) => HistoryEntry.fromJson(jsonDecode(s)))
        .toList();
  }

  static Future<void> add(HistoryEntry e) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await load();
    list.removeWhere((x) => x.barcode == e.barcode);
    list.insert(0, e);
    await prefs.setStringList(
        _key, list.take(_max).map((x) => jsonEncode(x.toJson())).toList());
  }
}
