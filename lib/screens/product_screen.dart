import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import '../models/product.dart';
import '../services/history.dart';
import '../services/off_api.dart';
import '../services/scoring.dart';
import 'add_product_screen.dart';
import 'widgets.dart';
import '../theme.dart';

/// Additifs : noms lisibles des plus courants (le reste affiche le code E).
const _additiveNames = {
  'en:e250': 'E250 – Nitrite de sodium',
  'en:e251': 'E251 – Nitrate de sodium',
  'en:e252': 'E252 – Nitrate de potassium',
  'en:e171': 'E171 – Dioxyde de titane',
  'en:e621': 'E621 – Glutamate monosodique',
  'en:e951': 'E951 – Aspartame',
  'en:e950': 'E950 – Acésulfame K',
  'en:e955': 'E955 – Sucralose',
  'en:e150d': 'E150d – Caramel au sulfite d\'ammonium',
  'en:e320': 'E320 – BHA',
  'en:e321': 'E321 – BHT',
};

String additiveLabel(String tag) =>
    _additiveNames[tag] ?? tag.replaceFirst('en:', '').toUpperCase();

class ProductScreen extends StatefulWidget {
  final String barcode;
  final OffApi? api;
  const ProductScreen({super.key, required this.barcode, this.api});
  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  late final OffApi _api = widget.api ?? OffApi();
  late Future<Product?> _future = _load();

  Future<Product?> _load() async {
    final p = await _api.fetch(widget.barcode);
    if (p != null) {
      await History.add(HistoryEntry(p.barcode, p.name, p.brand,
          computeScore(p)?.score, DateTime.now()));
    }
    return p;
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(widget.barcode)),
      body: FutureBuilder<Product?>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(s.t('loading')),
              ]),
            );
          }
          if (snap.hasError) {
            return _Message(
              icon: Icons.wifi_off,
              title: s.t('error'),
              action: s.t('retry'),
              onAction: () => setState(() => _future = _load()),
            );
          }
          final p = snap.data;
          if (p == null) {
            return _Message(
              icon: Icons.search_off,
              title: s.t('notFound'),
              body: s.t('notFoundHelp'),
              action: s.t('addProduct'),
              onAction: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => AddProductScreen(barcode: widget.barcode)),
              ),
            );
          }
          return _ProductView(product: p);
        },
      ),
    );
  }
}

class _ProductView extends StatelessWidget {
  final Product product;
  const _ProductView({required this.product});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final p = product;
    final score = computeScore(p);
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: p.imageUrl == null
                ? Container(
                    width: 96, height: 96,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: const Icon(Icons.image_not_supported))
                : Image.network(p.imageUrl!,
                    width: 96, height: 96, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const SizedBox(width: 96, height: 96)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.name.isEmpty ? p.barcode : p.name,
                  style: theme.textTheme.titleLarge),
              Text(p.brand, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 12),
              Row(children: [
                ScoreBadge(score: score?.score),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    score == null
                        ? s.t(isUnrated(p) ? 'unrated' : 'noScore')
                        : '${s.t('level${score.level}')} · ${score.score}/100'
                            '${score.provisional ? '\n${s.t('provisional')}' : ''}',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ]),
            ]),
          ),
        ]),
        const SizedBox(height: 16),
        _HalalCard(halal: p.halalOnPackage),
        if (score != null) ...[
          const SizedBox(height: 16),
          _Part(s.t('nutrition'), score.nutrition, 60,
              p.nutriScore == null ? null : 'Nutri-Score ${p.nutriScore!.toUpperCase()}'),
          _Part(s.t('additives'), score.additives, 20, null),
          _Part(s.t('processing'), score.processing, 20,
              p.nova == null ? null : 'NOVA ${p.nova}'),
        ],
        const SizedBox(height: 16),
        Text(s.t('riskyAdditives'), style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        if (score == null || score.riskyFound.isEmpty)
          Text(s.t('noRisky'))
        else
          for (final e in score.riskyFound.entries)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.circle, size: 14, color: const {
                AdditiveRisk.red: SahtiColors.mauvais,
                AdditiveRisk.orange: SahtiColors.mediocre,
                AdditiveRisk.yellow: SahtiColors.vigilance,
              }[e.value]),
              title: Text(additiveLabel(e.key)),
            ),
        if (p.nutriments.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(s.t('per100g'), style: theme.textTheme.titleMedium),
          for (final (key, label, unit) in [
            ('energy-kcal_100g', 'kcal', ''),
            ('fat_100g', 'fat', ' g'),
            ('saturated-fat_100g', 'satFat', ' g'),
            ('sugars_100g', 'sugars', ' g'),
            ('salt_100g', 'salt', ' g'),
          ])
            if (p.nutriments[key] != null)
              Row(children: [
                Expanded(child: Text(s.t(label))),
                Text('${p.nutriments[key]!.toStringAsFixed(1)}$unit'),
              ]),
        ],
        if (p.ingredientsText.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(s.t('ingredients'), style: theme.textTheme.titleMedium),
          Text(p.ingredientsText),
        ],
        const SizedBox(height: 24),
        Text(s.t('source'), style: theme.textTheme.bodySmall),
      ],
    );
  }
}

class _HalalCard extends StatelessWidget {
  final bool halal;
  const _HalalCard({required this.halal});
  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Card(
      child: ListTile(
        leading: Icon(halal ? Icons.verified : Icons.help_outline,
            color: halal ? SahtiColors.excellent : SahtiColors.inconnu),
        title: Text(s.t(halal ? 'halalYes' : 'halalNo')),
        subtitle: Text(s.t('halalNote')),
      ),
    );
  }
}

class _Part extends StatelessWidget {
  final String label;
  final int? value, max;
  final String? detail;
  const _Part(this.label, this.value, this.max, this.detail);
  @override
  Widget build(BuildContext context) {
    if (value == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(detail == null ? label : '$label · $detail')),
          Text('$value/$max'),
        ]),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: value! / max!,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
          color: scoreColor((value! * 100 / max!).round()),
        ),
      ]),
    );
  }
}

class _Message extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? body;
  final String action;
  final VoidCallback onAction;
  const _Message({required this.icon, required this.title, this.body,
      required this.action, required this.onAction});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center),
          if (body != null) ...[
            const SizedBox(height: 8),
            Text(body!, textAlign: TextAlign.center),
          ],
          const SizedBox(height: 24),
          FilledButton(onPressed: onAction, child: Text(action)),
        ]),
      ),
    );
  }
}
