import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'scanner_screen.dart';
import 'widgets.dart';

/// Écran racine : Accueil et Historique, avec la barre du bas
/// (Accueil · bouton scan safran au centre · Historique).
class RootShell extends StatefulWidget {
  const RootShell({super.key});
  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(index: _tab, children: [
          HomeScreen(onSeeAll: () => setState(() => _tab = 1)),
          const HistoryScreen(),
        ]),
      ),
      bottomNavigationBar: SahtiNavBar(
        current: _tab,
        onTab: (i) => setState(() => _tab = i),
        onScan: () => openScanner(context),
      ),
    );
  }
}

class SahtiNavBar extends StatelessWidget {
  final int current;
  final ValueChanged<int> onTab;
  final VoidCallback onScan;
  const SahtiNavBar(
      {super.key,
      required this.current,
      required this.onTab,
      required this.onScan});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final pal = SahtiPalette.of(context);
    return Semantics(
      label: s.t('nav'),
      container: true,
      child: Container(
        decoration: BoxDecoration(
          color: pal.carte,
          border: Border(top: BorderSide(color: pal.trait)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: s.t('home'),
                  selected: current == 0,
                  onTap: () => onTab(0),
                ),
                Transform.translate(
                  offset: const Offset(0, -18),
                  child: Semantics(
                    button: true,
                    label: s.t('scan'),
                    excludeSemantics: true,
                    child: Material(
                      color: SahtiColors.safran,
                      shape: const CircleBorder(),
                      elevation: 6,
                      shadowColor: const Color(0x400F6B4F),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: onScan,
                        child: const SizedBox(
                          width: 64,
                          height: 64,
                          child: Icon(Icons.qr_code_scanner,
                              size: 30, color: SahtiColors.texte),
                        ),
                      ),
                    ),
                  ),
                ),
                _NavItem(
                  icon: Icons.history,
                  activeIcon: Icons.history,
                  label: s.t('history'),
                  selected: current == 1,
                  onTap: () => onTab(1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon, activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _NavItem(
      {required this.icon,
      required this.activeIcon,
      required this.label,
      required this.selected,
      required this.onTap});
  @override
  Widget build(BuildContext context) {
    final color = selected
        ? Theme.of(context).colorScheme.primary
        : SahtiPalette.of(context).discret;
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 72, minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(selected ? activeIcon : icon, color: color, size: 24),
              const SizedBox(height: 2),
              Text(label,
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600, color: color)),
            ]),
          ),
        ),
      ),
    );
  }
}
