import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import '../services/history.dart';
import '../services/pending.dart';
import 'product_screen.dart';
import 'widgets.dart';

/// Historique : recherche, groupes par date, produits en attente d'envoi,
/// suppression d'une ligne par glissement.
class HistoryScreen extends StatefulWidget {
  /// Date du jour (fixée dans les tests).
  final DateTime Function() now;
  const HistoryScreen({super.key, this.now = DateTime.now});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<HistoryEntry> _items = [];
  List<Map<String, dynamic>> _pending = [];
  String _query = '';

  @override
  void initState() {
    super.initState();
    History.changes.addListener(_reload);
    Pending.changes.addListener(_reload);
    _reload();
  }

  @override
  void dispose() {
    History.changes.removeListener(_reload);
    Pending.changes.removeListener(_reload);
    super.dispose();
  }

  Future<void> _reload() async {
    final h = await History.load();
    final p = await Pending.load();
    if (!mounted) return;
    setState(() {
      _items = h;
      _pending = p;
    });
  }

  bool _match(String name, String brand, String code) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return name.toLowerCase().contains(q) ||
        brand.toLowerCase().contains(q) ||
        code.contains(q);
  }

  Future<void> _clearAll() async {
    final s = S.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(s.t('clearConfirm')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(s.t('cancel'))),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(s.t('clear'))),
        ],
      ),
    );
    if (ok == true) await History.clear();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final pal = SahtiPalette.of(context);
    final now = widget.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(const Duration(days: 6));

    final pending = _pending
        .where((p) => _match(
            '${p['name'] ?? ''}', '${p['brand'] ?? ''}', '${p['code'] ?? ''}'))
        .toList();
    final items =
        _items.where((e) => _match(e.name, e.brand, e.barcode)).toList();
    final groups = <String, List<HistoryEntry>>{
      'today': items.where((e) => !e.at.isBefore(today)).toList(),
      'thisWeek': items
          .where((e) => e.at.isBefore(today) && !e.at.isBefore(weekStart))
          .toList(),
      'older': items.where((e) => e.at.isBefore(weekStart)).toList(),
    };

    Widget groupTitle(String text) => Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: Text(text,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: pal.discret)),
        );

    final empty = _items.isEmpty && _pending.isEmpty;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      children: [
        Row(children: [
          Expanded(
            child: Text(s.t('history'),
                style:
                    const TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
          ),
          if (_items.isNotEmpty)
            TextButton(
              onPressed: _clearAll,
              child: Text(s.t('clearAll'),
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600)),
            ),
        ]),
        const SizedBox(height: 12),
        if (empty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Text(s.t('emptyHistory'),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: pal.discret)),
          )
        else ...[
          TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: s.t('search'),
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: pal.carte,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (pending.isNotEmpty) ...[
            groupTitle(s.t('pendingWord')),
            for (final p in pending)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ProductRow(
                  name: '${p['name'] ?? p['code']}',
                  subtitle: s.t('pendingWord'),
                  score: null,
                  badgeText: '—',
                ),
              ),
          ],
          for (final g in groups.entries)
            if (g.value.isNotEmpty) ...[
              groupTitle(s.t(g.key)),
              for (final e in g.value)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Dismissible(
                    key: ValueKey('h-${e.barcode}'),
                    background: Container(
                      decoration: BoxDecoration(
                          color: SahtiColors.mauvais,
                          borderRadius: BorderRadius.circular(16)),
                      alignment: AlignmentDirectional.centerStart,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child:
                          const Icon(Icons.delete_outline, color: Colors.white),
                    ),
                    secondaryBackground: Container(
                      decoration: BoxDecoration(
                          color: SahtiColors.mauvais,
                          borderRadius: BorderRadius.circular(16)),
                      alignment: AlignmentDirectional.centerEnd,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child:
                          const Icon(Icons.delete_outline, color: Colors.white),
                    ),
                    onDismissed: (_) {
                      setState(() => _items.remove(e));
                      History.remove(e.barcode);
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(s.t('deleted'))));
                    },
                    child: ProductRow(
                      name: e.name.isEmpty ? e.barcode : e.name,
                      subtitle: e.score == null ? '' : scoreWord(s, e.score!),
                      score: e.score,
                      imageUrl: e.imageUrl,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  ProductScreen(barcode: e.barcode))),
                    ),
                  ),
                ),
            ],
          if (items.isEmpty && pending.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(s.t('noResults'),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: pal.discret)),
            ),
          if (_items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(s.t('swipe'),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: pal.discret)),
            ),
        ],
      ],
    );
  }
}
