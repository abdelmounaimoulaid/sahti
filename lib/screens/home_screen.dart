import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import '../main.dart';
import '../services/history.dart';
import 'product_screen.dart';
import 'scanner_screen.dart';
import 'widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<HistoryEntry> _history = [];

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final h = await History.load();
    if (mounted) setState(() => _history = h);
  }

  Future<void> _scan() async {
    final code = await Navigator.push<String>(
        context, MaterialPageRoute(builder: (_) => const ScannerScreen()));
    if (code == null || !mounted) return;
    await _open(code);
  }

  Future<void> _open(String code) async {
    await Navigator.push(context,
        MaterialPageRoute(builder: (_) => ProductScreen(barcode: code)));
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(s.t('appName')),
        actions: [
          TextButton(
            onPressed: () => SahtiApp.toggleLanguage(context),
            child: Text(s.t('language')),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _scan,
        icon: const Icon(Icons.qr_code_scanner),
        label: Text(s.t('scan')),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: _history.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(s.t('emptyHistory'), textAlign: TextAlign.center),
              ),
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: 96),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(s.t('history'),
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                for (final e in _history)
                  ListTile(
                    leading: ScoreBadge(score: e.score, size: 44),
                    title: Text(e.name.isEmpty ? e.barcode : e.name),
                    subtitle: Text(e.brand),
                    onTap: () => _open(e.barcode),
                  ),
              ],
            ),
    );
  }
}
