import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import '../models/product.dart';
import '../services/allergens.dart';
import '../services/history.dart';
import '../services/off_api.dart';
import '../services/scoring.dart';
import '../services/settings.dart';
import 'add_product_screen.dart';
import 'not_found_screen.dart';
import 'settings_screen.dart' show showMethodSheet;
import 'widgets.dart';

/// Noms des additifs à surveiller (le reste affiche seulement le code E).
const additiveNames = {
  'en:e102': 'Tartrazine',
  'en:e104': 'Jaune de quinoléine',
  'en:e110': 'Jaune orangé S',
  'en:e122': 'Azorubine',
  'en:e124': 'Ponceau 4R',
  'en:e129': 'Rouge allura AC',
  'en:e150c': 'Caramel ammoniacal',
  'en:e150d': 'Caramel au sulfite d\'ammonium',
  'en:e171': 'Dioxyde de titane',
  'en:e211': 'Benzoate de sodium',
  'en:e220': 'Dioxyde de soufre',
  'en:e221': 'Sulfite de sodium',
  'en:e223': 'Métabisulfite de sodium',
  'en:e224': 'Métabisulfite de potassium',
  'en:e249': 'Nitrite de potassium',
  'en:e250': 'Nitrite de sodium',
  'en:e251': 'Nitrate de sodium',
  'en:e252': 'Nitrate de potassium',
  'en:e320': 'BHA',
  'en:e321': 'BHT',
  'en:e338': 'Acide phosphorique',
  'en:e339': 'Phosphates de sodium',
  'en:e340': 'Phosphates de potassium',
  'en:e341': 'Phosphates de calcium',
  'en:e407': 'Carraghénanes',
  'en:e433': 'Polysorbate 80',
  'en:e450': 'Diphosphates',
  'en:e451': 'Triphosphates',
  'en:e452': 'Polyphosphates',
  'en:e466': 'Carboxyméthylcellulose',
  'en:e621': 'Glutamate monosodique',
  'en:e950': 'Acésulfame K',
  'en:e951': 'Aspartame',
  'en:e954': 'Saccharine',
  'en:e955': 'Sucralose',
};

/// Code affiché d'un additif : 'en:e150d' → 'E150d'.
String additiveCode(String tag) {
  final c = tag.replaceFirst(RegExp(r'^[a-z]{2}:'), '');
  return c.isEmpty ? tag : 'E${c.substring(1)}';
}

/// Ancienne étiquette « code – nom » (gardée pour la compatibilité).
String additiveLabel(String tag) {
  final name = additiveNames[tag];
  return name == null ? additiveCode(tag) : '${additiveCode(tag)} – $name';
}

Color additiveColor(AdditiveRisk r) => const {
      AdditiveRisk.red: SahtiColors.mauvais,
      AdditiveRisk.orange: SahtiColors.mediocre,
      AdditiveRisk.yellow: SahtiColors.vigilance,
    }[r]!;

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
      await History.add(HistoryEntry(
          p.barcode, p.name, p.brand, computeScore(p)?.score, DateTime.now(),
          imageUrl: p.imageUrl));
    }
    return p;
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<Product?>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return _Centered(children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(s.t('loading')),
              ]);
            }
            if (snap.hasError) {
              return _Centered(children: [
                Icon(Icons.wifi_off,
                    size: 64, color: SahtiPalette.of(context).discret),
                const SizedBox(height: 16),
                Text(s.t('error'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => setState(() => _future = _load()),
                  child: Text(s.t('retry')),
                ),
              ]);
            }
            final p = snap.data;
            if (p == null) return NotFoundView(barcode: widget.barcode);
            return ProductView(product: p);
          },
        ),
      ),
    );
  }
}

class _Centered extends StatelessWidget {
  final List<Widget> children;
  const _Centered({required this.children});
  @override
  Widget build(BuildContext context) => Column(children: [
        const Padding(
          padding: EdgeInsetsDirectional.fromSTEB(16, 16, 16, 0),
          child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: BackRoundButton()),
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(mainAxisSize: MainAxisSize.min, children: children),
            ),
          ),
        ),
      ]);
}

/// Fiche d'un produit trouvé.
class ProductView extends StatelessWidget {
  final Product product;
  const ProductView({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final settings = SettingsScope.of(context);
    final pal = SahtiPalette.of(context);
    final p = product;
    final score = computeScore(p);
    final check = checkAllergens(p, settings.allergens);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        const Align(
            alignment: AlignmentDirectional.centerStart,
            child: BackRoundButton()),
        const SizedBox(height: 14),
        Row(children: [
          ProductThumb(url: p.imageUrl, size: 92, radius: 18),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name.isEmpty ? p.barcode : p.name,
                    style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                        height: 1.25)),
                if (p.brand.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(p.brand,
                      style: TextStyle(fontSize: 14, color: pal.discret)),
                ],
                const SizedBox(height: 4),
                Text(p.barcode,
                    textDirection: TextDirection.ltr,
                    style: TextStyle(fontSize: 12, color: pal.discret)),
              ],
            ),
          ),
        ]),
        if (!check.isEmpty || check.unknown) ...[
          const SizedBox(height: 14),
          AllergenBanner(check: check),
        ],
        const SizedBox(height: 14),
        _ScoreCard(product: p, score: score),
        const SizedBox(height: 14),
        _AdditivesCard(product: p, score: score),
        if (settings.showHalal) ...[
          const SizedBox(height: 14),
          _HalalCard(halal: p.halalOnPackage),
        ],
        if (p.nutriments.isNotEmpty) ...[
          const SizedBox(height: 14),
          _NutritionCard(product: p),
        ],
        if (p.ingredientsText.isNotEmpty) ...[
          const SizedBox(height: 14),
          SahtiCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Title(s.t('ingredients')),
                const SizedBox(height: 8),
                Text(p.ingredientsText,
                    textDirection: textDirectionOf(p.ingredientsText),
                    style: TextStyle(
                        fontSize: 14, height: 1.5, color: pal.discret)),
              ],
            ),
          ),
        ],
        const SizedBox(height: 14),
        OutlinedButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => AddProductScreen(barcode: p.barcode)),
          ),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            side: BorderSide(
                color: Theme.of(context).colorScheme.primary, width: 1.5),
            textStyle: const TextStyle(
                fontFamily: 'ReadexPro',
                fontSize: 15,
                fontWeight: FontWeight.w600),
          ),
          child: Text(s.t('report'), textAlign: TextAlign.center),
        ),
        const SizedBox(height: 14),
        Text(s.t('source'),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: pal.discret)),
      ],
    );
  }
}

class _Title extends StatelessWidget {
  final String text;
  const _Title(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700));
}

/// Bandeau d'alerte allergènes, en haut de la fiche.
class AllergenBanner extends StatelessWidget {
  final AllergenCheck check;
  const AllergenBanner({super.key, required this.check});
  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final pal = SahtiPalette.of(context);
    final unknown = check.isEmpty;
    final fg =
        unknown ? Theme.of(context).colorScheme.onSurface : pal.alerteTexte;
    return Semantics(
      container: true,
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: unknown ? pal.trait : pal.alerte,
          borderRadius: BorderRadius.circular(18),
          border: unknown
              ? null
              : Border.all(color: SahtiColors.mauvais, width: 1.5),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(unknown ? Icons.help_outline : Icons.warning_amber_rounded,
              color: unknown ? pal.discret : SahtiColors.mauvais, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (unknown)
                  Text(s.t('allergenUnknown'),
                      style: TextStyle(fontSize: 14, color: fg))
                else ...[
                  if (check.contains.isNotEmpty)
                    Text(
                        s.t('allergenContains',
                            list: check.contains.map((a) => a.label(s.lang))),
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: fg)),
                  if (check.traces.isNotEmpty) ...[
                    if (check.contains.isNotEmpty) const SizedBox(height: 4),
                    Text(
                        s.t('allergenTraces',
                            list: check.traces.map((a) => a.label(s.lang))),
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: fg)),
                  ],
                  const SizedBox(height: 6),
                  Text(s.t('allergenNote'),
                      style: TextStyle(fontSize: 12, color: fg)),
                ],
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

/// Phrase courte sous le mot de la note.
String scoreVerdict(S s, ScoreResult r, Product p) {
  final out = <String>[];
  final n = r.nutrition;
  if (n != null) {
    out.add(s.t(n >= 40
        ? 'vNutriGood'
        : n < 25
            ? 'vNutriBad'
            : 'vNutriMid'));
  }
  if (p.nova == 4) out.add(s.t('vUltra'));
  final k = r.riskyFound.length;
  if (k > 0) out.add('${s.t(k == 1 ? 'riskyOne' : 'riskyMany', n: k)}.');
  if (r.provisional) out.add(s.t('provisional'));
  return out.join(' ');
}

class _ScoreCard extends StatelessWidget {
  final Product product;
  final ScoreResult? score;
  const _ScoreCard({required this.product, required this.score});
  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final pal = SahtiPalette.of(context);
    final p = product;
    final r = score;
    if (r == null) {
      return SahtiCard(
        child: Row(children: [
          const ScoreBadge(score: null, size: 72),
          const SizedBox(width: 16),
          Expanded(
            child: Text(s.t(isUnrated(p) ? 'unrated' : 'noScore'),
                style: const TextStyle(fontSize: 15, height: 1.4)),
          ),
        ]),
      );
    }
    final k = r.riskyFound.length;
    final nutriLabel = s.isAr ? 'نوتري-سكور' : 'Nutri-Score';
    return Semantics(
      label: s.t('scoreLabel'),
      container: true,
      child: SahtiCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              ScoreBadge(score: r.score, size: 96, outOf100: true),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.t('level${r.level}'),
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(scoreVerdict(s, r, p),
                        style: TextStyle(
                            fontSize: 14, height: 1.4, color: pal.discret)),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 16),
            ExcludeSemantics(
              child: Row(children: [
                for (final c in const [
                  SahtiColors.mauvais,
                  SahtiColors.mediocre,
                  SahtiColors.bon,
                  SahtiColors.excellent
                ]) ...[
                  Expanded(
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                          color: c, borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                  if (c != SahtiColors.excellent) const SizedBox(width: 3),
                ],
              ]),
            ),
            const SizedBox(height: 16),
            ScorePart(
              label: s.t('nutrition'),
              value: r.nutrition,
              max: 60,
              detail: p.nutriScore == null
                  ? s.t('missingData')
                  : '$nutriLabel ${p.nutriScore!.toUpperCase()}',
            ),
            ScorePart(
              label: s.t('processing'),
              value: r.processing,
              max: 20,
              detail: p.nova == null || p.nova! < 1 || p.nova! > 4
                  ? s.t('missingData')
                  : s.t('nova${p.nova}'),
            ),
            ScorePart(
              label: s.t('additives'),
              value: r.additives,
              max: 20,
              detail: r.additives == null
                  ? s.t('missingData')
                  : s.t(
                      k == 0
                          ? 'riskyNone'
                          : k == 1
                              ? 'riskyOne'
                              : 'riskyMany',
                      n: k),
            ),
            TextButton(
              onPressed: () => showMethodSheet(context),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                textStyle: const TextStyle(
                    fontFamily: 'ReadexPro',
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
              child: Text(s.t('howScore')),
            ),
          ],
        ),
      ),
    );
  }
}

/// Une partie de la note : libellé, points, jauge et explication.
class ScorePart extends StatelessWidget {
  final String label;
  final int? value;
  final int max;
  final String detail;
  const ScorePart(
      {super.key,
      required this.label,
      required this.value,
      required this.max,
      required this.detail});
  @override
  Widget build(BuildContext context) {
    final pal = SahtiPalette.of(context);
    final v = value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text(label,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          ),
          Text('${v ?? '—'} / $max',
              textDirection: TextDirection.ltr,
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: LinearProgressIndicator(
            value: v == null ? 0 : (v / max).clamp(0.02, 1.0),
            minHeight: 10,
            backgroundColor: pal.trait,
            color: scoreColor(v == null ? null : (v * 100 / max).round()),
          ),
        ),
        const SizedBox(height: 6),
        Text(detail, style: TextStyle(fontSize: 13, color: pal.discret)),
      ]),
    );
  }
}

class _AdditivesCard extends StatelessWidget {
  final Product product;
  final ScoreResult? score;
  const _AdditivesCard({required this.product, required this.score});
  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final pal = SahtiPalette.of(context);
    final risky = {
      for (final a in product.additives)
        if (additiveRisks[a] != null) a: additiveRisks[a]!,
    };
    final sorted = risky.entries.toList()
      ..sort((a, b) => a.value.index - b.value.index);
    final others = product.additives
        .where((a) => !risky.containsKey(a))
        .map(additiveCode)
        .toList();
    return SahtiCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Title(s.t('riskyAdditives')),
          const SizedBox(height: 12),
          if (sorted.isEmpty)
            Text(s.t('noRisky'), style: const TextStyle(fontSize: 14))
          else
            for (final e in sorted)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: additiveColor(e.value),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(additiveCode(e.key),
                        textDirection: TextDirection.ltr,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: e.value == AdditiveRisk.red
                                ? Colors.white
                                : SahtiColors.texte)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!s.isAr && additiveNames[e.key] != null)
                          Text(additiveNames[e.key]!,
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w600)),
                        Text(s.t('risk${e.value.index}'),
                            style: TextStyle(fontSize: 13, color: pal.discret)),
                      ],
                    ),
                  ),
                ]),
              ),
          if (others.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(s.t('otherAdditives', list: others),
                style: TextStyle(fontSize: 13, color: pal.discret)),
          ],
        ],
      ),
    );
  }
}

class _HalalCard extends StatelessWidget {
  final bool halal;
  const _HalalCard({required this.halal});
  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final pal = SahtiPalette.of(context);
    return SahtiCard(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: halal ? pal.mentheClaire : pal.trait,
            shape: BoxShape.circle,
          ),
          child: Icon(halal ? Icons.check : Icons.question_mark,
              size: 22,
              color:
                  halal ? Theme.of(context).colorScheme.primary : pal.discret),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.t(halal ? 'halalYes' : 'halalNo'),
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(s.t('halalNote'),
                  style:
                      TextStyle(fontSize: 13, height: 1.4, color: pal.discret)),
            ],
          ),
        ),
      ]),
    );
  }
}

class _NutritionCard extends StatelessWidget {
  final Product product;
  const _NutritionCard({required this.product});
  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final pal = SahtiPalette.of(context);
    String fmt(double v, String unit) {
      final txt = v == v.roundToDouble()
          ? v.toStringAsFixed(0)
          : v.toStringAsFixed(1).replaceAll('.', ',');
      return unit.isEmpty ? txt : '$txt $unit';
    }

    final rows = [
      for (final (key, label, unit) in const [
        ('energy-kcal_100g', 'kcal', ''),
        ('fat_100g', 'fat', 'g'),
        ('saturated-fat_100g', 'satFat', 'g'),
        ('sugars_100g', 'sugars', 'g'),
        ('salt_100g', 'salt', 'g'),
      ])
        if (product.nutriments[key] != null)
          (s.t(label), fmt(product.nutriments[key]!, unit)),
    ];
    return SahtiCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Title(s.t('per100g')),
          const SizedBox(height: 6),
          for (final (i, (label, value)) in rows.indexed)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: i == rows.length - 1
                    ? null
                    : Border(bottom: BorderSide(color: pal.trait)),
              ),
              child: Row(children: [
                Expanded(
                    child: Text(label, style: const TextStyle(fontSize: 14))),
                Text(value,
                    textDirection: TextDirection.ltr,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
              ]),
            ),
        ],
      ),
    );
  }
}
