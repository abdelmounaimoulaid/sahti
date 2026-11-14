import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import '../services/history.dart';
import 'product_screen.dart';
import 'scanner_screen.dart';
import 'settings_screen.dart';
import 'widgets.dart';

/// Accueil : bouton de scan, saisie à la main, derniers scans, promesse.
class HomeScreen extends StatefulWidget {
  final VoidCallback? onSeeAll;
  const HomeScreen({super.key, this.onSeeAll});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<HistoryEntry> _recent = [];

  @override
  void initState() {
    super.initState();
    History.changes.addListener(_reload);
    _reload();
  }

  @override
  void dispose() {
    History.changes.removeListener(_reload);
    super.dispose();
  }

  Future<void> _reload() async {
    final h = await History.load();
    if (mounted) setState(() => _recent = h.take(3).toList());
  }

  void _open(String code) => Navigator.push(
      context, MaterialPageRoute(builder: (_) => ProductScreen(barcode: code)));

  Future<void> _manual() async {
    final code = await askBarcode(context);
    if (code != null && mounted) _open(code);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final pal = SahtiPalette.of(context);
    final primary = Theme.of(context).colorScheme.primary;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      children: [
        Row(children: [
          const SahtiLogo(size: 40),
          const SizedBox(width: 10),
          Expanded(
            child: Text(s.t('appName'),
                style: TextStyle(
                    fontSize: 26, fontWeight: FontWeight.w700, color: primary)),
          ),
          RoundButton(
            icon: Icons.settings_outlined,
            tooltip: s.t('settings'),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ]),
        const SizedBox(height: 12),
        Text(s.t('tagline'),
            style: TextStyle(fontSize: 15, color: pal.discret)),
        const SizedBox(height: 16),
        Semantics(
          button: true,
          child: Material(
            color: SahtiColors.menthe,
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => openScanner(context),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                          color: SahtiColors.safran,
                          borderRadius: BorderRadius.circular(18)),
                      child: const Icon(Icons.qr_code_scanner,
                          size: 30, color: SahtiColors.texte),
                    ),
                    const SizedBox(height: 16),
                    Text(s.t('scan'),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(s.t('pointCamera'),
                        style: const TextStyle(
                            color: Color(0xFFCDE7DC), fontSize: 14)),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: TextButton(
            onPressed: _manual,
            child: Text(s.t('manual'),
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: Text(s.t('recent'),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ),
          if (_recent.isNotEmpty)
            TextButton(
              onPressed: widget.onSeeAll,
              child: Text(s.t('seeAll'),
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600)),
            ),
        ]),
        const SizedBox(height: 8),
        if (_recent.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(s.t('emptyHistory'),
                style: TextStyle(fontSize: 14, color: pal.discret)),
          )
        else
          for (final e in _recent)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ProductRow(
                name: e.name.isEmpty ? e.barcode : e.name,
                subtitle: e.score == null ? '' : scoreWord(s, e.score!),
                score: e.score,
                imageUrl: e.imageUrl,
                onTap: () => _open(e.barcode),
              ),
            ),
        const SizedBox(height: 8),
        PromiseBanner(text: s.t('promise')),
      ],
    );
  }
}

/// Bandeau safran clair : « Sans publicité… ».
class PromiseBanner extends StatelessWidget {
  final String text;
  const PromiseBanner({super.key, required this.text});
  @override
  Widget build(BuildContext context) {
    final pal = SahtiPalette.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
          color: pal.safranClair, borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        Icon(Icons.verified_user_outlined,
            size: 20,
            color: Theme.of(context).brightness == Brightness.dark
                ? SahtiColors.safran
                : const Color(0xFF9A6A06)),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
      ]),
    );
  }
}
