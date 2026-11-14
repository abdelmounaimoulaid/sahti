import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import '../services/allergens.dart';
import '../services/off_api.dart';
import '../services/pending.dart';
import '../services/scoring.dart';
import '../services/settings.dart';
import 'home_screen.dart' show PromiseBanner;
import 'product_screen.dart' show additiveCode, additiveColor, additiveNames;
import 'widgets.dart';

const appVersion = '1.0';

/// Explication de la note, en bas de l'écran.
Future<void> showMethodSheet(BuildContext context) {
  final s = S.of(context);
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(s.t('methodTitle'),
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Text(s.t('methodBody'),
              style: const TextStyle(fontSize: 15, height: 1.5)),
        ]),
      ),
    ),
  );
}

/// Réglages : langue, apparence, halal, allergènes, produits en attente.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _pending = 0;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    Pending.changes.addListener(_reload);
    _reload();
  }

  @override
  void dispose() {
    Pending.changes.removeListener(_reload);
    super.dispose();
  }

  Future<void> _reload() async {
    final n = (await Pending.load()).length;
    if (mounted) setState(() => _pending = n);
  }

  Future<void> _send() async {
    final s = S.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _sending = true);
    final sent = await Pending.sendAll();
    if (!mounted) return;
    setState(() => _sending = false);
    messenger.showSnackBar(SnackBar(
        content:
            Text(sent > 0 ? s.t('sentCount', n: sent) : s.t('sendFailed'))));
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final pal = SahtiPalette.of(context);
    final settings = SettingsScope.of(context);
    final primary = Theme.of(context).colorScheme.primary;

    Widget h2(String text) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(text,
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        );

    Widget link(String label, VoidCallback onTap) => ListTile(
          title: Text(label, style: const TextStyle(fontSize: 15)),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        );

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Row(children: [
              const BackRoundButton(),
              const SizedBox(width: 12),
              Text(s.t('settings'),
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 16),
            SahtiCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  h2(s.t('language')),
                  _Segmented<String>(
                    value: settings.lang,
                    onChanged: settings.setLang,
                    options: const [('fr', 'Français'), ('ar', 'العربية')],
                  ),
                  const SizedBox(height: 18),
                  h2(s.t('theme')),
                  _Segmented<ThemeMode>(
                    value: settings.themeMode,
                    onChanged: settings.setThemeMode,
                    options: [
                      (ThemeMode.light, s.t('light')),
                      (ThemeMode.dark, s.t('dark')),
                      (ThemeMode.system, s.t('auto')),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SahtiCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  h2(s.t('prefs')),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: settings.showHalal,
                    onChanged: settings.setShowHalal,
                    title: Text(s.t('halalShow'),
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                    subtitle: Text(s.t('halalShowSub'),
                        style: TextStyle(fontSize: 13, color: pal.discret)),
                  ),
                  const SizedBox(height: 8),
                  Text(s.t('allergensTitle'),
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    for (final a in allergens)
                      FilterChip(
                        label: Text(a.label(s.lang)),
                        selected: settings.allergens.contains(a.id),
                        onSelected: (_) => settings.toggleAllergen(a.id),
                        showCheckmark: false,
                        selectedColor: primary,
                        labelStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: settings.allergens.contains(a.id)
                              ? Theme.of(context).colorScheme.onPrimary
                              : null,
                        ),
                        shape: StadiumBorder(
                          side: BorderSide(
                              color: settings.allergens.contains(a.id)
                                  ? primary
                                  : pal.trait,
                              width: 1.5),
                        ),
                      ),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SahtiCard(
              child: Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          _pending == 0
                              ? s.t('pending0')
                              : _pending == 1
                                  ? s.t('pending1')
                                  : s.t('pendingN', n: _pending),
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                      if (_pending > 0) ...[
                        const SizedBox(height: 4),
                        Text(
                            OffApi.canUpload
                                ? s.t('pendingSub')
                                : s.t('pendingNoAccount'),
                            style: TextStyle(fontSize: 13, color: pal.discret)),
                      ],
                    ],
                  ),
                ),
                if (_pending > 0 && OffApi.canUpload) ...[
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: _sending ? null : _send,
                    child: _sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(s.t('send')),
                  ),
                ],
              ]),
            ),
            const SizedBox(height: 14),
            SahtiCard(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(children: [
                link(s.t('methodTitle'), () => showMethodSheet(context)),
                link(
                    s.t('additivesTitle'),
                    () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AdditivesScreen()))),
              ]),
            ),
            const SizedBox(height: 14),
            PromiseBanner(text: s.t('promise')),
            const SizedBox(height: 14),
            Text('${s.t('source')} · ${s.t('version', n: appVersion)}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: pal.discret)),
          ],
        ),
      ),
    );
  }
}

/// Choix exclusif en pastilles (langue, apparence).
class _Segmented<T> extends StatelessWidget {
  final T value;
  final ValueChanged<T> onChanged;
  final List<(T, String)> options;
  const _Segmented(
      {required this.value, required this.onChanged, required this.options});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<T>(
        showSelectedIcon: false,
        segments: [
          for (final (v, label) in options)
            ButtonSegment(value: v, label: Text(label)),
        ],
        selected: {value},
        onSelectionChanged: (sel) => onChanged(sel.first),
        style: SegmentedButton.styleFrom(
          minimumSize: const Size.fromHeight(44),
          textStyle: const TextStyle(
              fontFamily: 'ReadexPro', fontWeight: FontWeight.w600),
          selectedBackgroundColor: Theme.of(context).colorScheme.primary,
          selectedForegroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }
}

/// Liste des additifs à surveiller (classement provisoire).
class AdditivesScreen extends StatelessWidget {
  const AdditivesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final pal = SahtiPalette.of(context);
    final entries = additiveRisks.entries.toList()
      ..sort((a, b) => a.value.index != b.value.index
          ? a.value.index - b.value.index
          : a.key.compareTo(b.key));
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Row(children: [
              const BackRoundButton(),
              const SizedBox(width: 12),
              Expanded(
                child: Text(s.t('additivesTitle'),
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w700)),
              ),
            ]),
            const SizedBox(height: 12),
            Text(s.t('additivesIntro'),
                style: TextStyle(fontSize: 14, color: pal.discret)),
            const SizedBox(height: 12),
            for (final e in entries)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 64,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  alignment: Alignment.center,
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
                title: Text(additiveNames[e.key] ?? additiveCode(e.key),
                    textDirection: TextDirection.ltr,
                    textAlign: s.isAr ? TextAlign.right : TextAlign.left),
                subtitle: Text(s.t('risk${e.value.index}')),
              ),
          ],
        ),
      ),
    );
  }
}
