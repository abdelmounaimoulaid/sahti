import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/strings.dart';
import '../theme.dart';

export '../theme.dart' show scoreColor, scoreOnColor, SahtiColors, SahtiPalette;

/// Pastille ronde avec la note sur 100.
class ScoreBadge extends StatelessWidget {
  final int? score;
  final double size;

  /// Affiche « /100 » sous le chiffre (grande pastille de la fiche).
  final bool outOf100;

  /// Texte à la place du chiffre (ex. « — » pour un produit en attente).
  final String? text;
  const ScoreBadge(
      {super.key,
      required this.score,
      this.size = 56,
      this.outOf100 = false,
      this.text});

  @override
  Widget build(BuildContext context) {
    final fg = scoreOnColor(score);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration:
          BoxDecoration(color: scoreColor(score), shape: BoxShape.circle),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(
          text ?? score?.toString() ?? '?',
          style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w700,
              height: 1,
              fontSize: size * (outOf100 ? 0.375 : 0.36)),
        ),
        if (outOf100 && score != null)
          Text('/100',
              textDirection: TextDirection.ltr,
              style: TextStyle(
                  color: fg, fontWeight: FontWeight.w600, fontSize: 13)),
      ]),
    );
  }
}

/// Mot de la note : Excellent, Bon, À limiter, À éviter.
String scoreWord(S s, int score) =>
    s.t('level${score >= 75 ? 3 : score >= 50 ? 2 : score >= 25 ? 1 : 0}');

/// Logo Sahti « le code-barres qui pousse », dessiné sans fichier SVG.
class SahtiLogo extends StatelessWidget {
  final double size;
  final Color? bars;
  const SahtiLogo({super.key, this.size = 40, this.bars});
  @override
  Widget build(BuildContext context) => CustomPaint(
        size: Size.square(size),
        painter: _LogoPainter(bars ?? Theme.of(context).colorScheme.primary),
      );
}

class _LogoPainter extends CustomPainter {
  final Color bars;
  _LogoPainter(this.bars);
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 100);
    final p = Paint()..color = bars;
    for (final (x, y, w, h) in const [
      (14.0, 40.0, 7.0, 46.0),
      (27.0, 40.0, 4.0, 46.0),
      (37.0, 40.0, 9.0, 46.0),
      (52.0, 28.0, 5.0, 58.0),
      (63.0, 40.0, 4.0, 46.0),
      (73.0, 40.0, 9.0, 46.0),
    ]) {
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(x, y, w, h), const Radius.circular(2)),
          p);
    }
    final leaf = Path()
      ..moveTo(54.5, 30)
      ..cubicTo(54.5, 18, 64, 10, 78, 10)
      ..cubicTo(78, 22, 68, 30, 54.5, 30)
      ..close();
    canvas.drawPath(leaf, Paint()..color = SahtiColors.safran);
  }

  @override
  bool shouldRepaint(_LogoPainter old) => old.bars != bars;
}

/// Bouton rond de 44 px (retour, réglages, partage).
class RoundButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color? background, foreground;
  const RoundButton(
      {super.key,
      required this.icon,
      required this.tooltip,
      this.onPressed,
      this.background,
      this.foreground});
  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, size: 22),
      style: IconButton.styleFrom(
        fixedSize: const Size(44, 44),
        backgroundColor: background ?? SahtiPalette.of(context).carte,
        foregroundColor: foreground ?? Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

/// Bouton retour : la flèche suit le sens de lecture (inversée en arabe).
class BackRoundButton extends StatelessWidget {
  final VoidCallback? onPressed;
  const BackRoundButton({super.key, this.onPressed});
  @override
  Widget build(BuildContext context) => RoundButton(
        icon: Icons.arrow_back_ios_new,
        tooltip: S.of(context).t('back'),
        onPressed: onPressed ?? () => Navigator.maybePop(context),
      );
}

/// Carte blanche arrondie des maquettes.
class SahtiCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const SahtiCard(
      {super.key,
      required this.child,
      this.padding = const EdgeInsets.all(18)});
  @override
  Widget build(BuildContext context) => Material(
        color: SahtiPalette.of(context).carte,
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.antiAlias,
        child: Container(
          width: double.infinity,
          padding: padding,
          child: child,
        ),
      );
}

/// Vignette du produit (photo ou case vide).
class ProductThumb extends StatelessWidget {
  final String? url;
  final double size;
  final double radius;
  const ProductThumb({super.key, this.url, this.size = 48, this.radius = 12});
  @override
  Widget build(BuildContext context) {
    final pal = SahtiPalette.of(context);
    final empty = Container(
      width: size,
      height: size,
      color: pal.trait,
      alignment: Alignment.center,
      child: Icon(Icons.image_outlined, color: pal.discret, size: size * 0.4),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: url == null
          ? empty
          : Image.network(url!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => empty),
    );
  }
}

/// Ligne produit (accueil, historique) : vignette, nom, mot de la note, note.
class ProductRow extends StatelessWidget {
  final String name;
  final String subtitle;
  final int? score;
  final String? imageUrl;
  final String? badgeText;
  final VoidCallback? onTap;
  const ProductRow(
      {super.key,
      required this.name,
      required this.subtitle,
      this.score,
      this.imageUrl,
      this.badgeText,
      this.onTap});
  @override
  Widget build(BuildContext context) {
    final pal = SahtiPalette.of(context);
    return Material(
      color: pal.carte,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(children: [
            ProductThumb(url: imageUrl),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(fontSize: 13, color: pal.discret)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ScoreBadge(score: score, size: 44, text: badgeText),
          ]),
        ),
      ),
    );
  }
}

/// Demande un code-barres tapé à la main. Retourne null si annulé.
Future<String?> askBarcode(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (context) => const _BarcodeDialog(),
  );
}

class _BarcodeDialog extends StatefulWidget {
  const _BarcodeDialog();
  @override
  State<_BarcodeDialog> createState() => _BarcodeDialogState();
}

class _BarcodeDialogState extends State<_BarcodeDialog> {
  final _ctrl = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    final code = _ctrl.text.trim();
    if (!isValidBarcode(code)) {
      setState(() => _error = S.of(context).t('barcodeInvalid'));
      return;
    }
    Navigator.pop(context, code);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return AlertDialog(
      title: Text(s.t('manual')),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        keyboardType: TextInputType.number,
        textDirection: TextDirection.ltr,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        maxLength: 14,
        onSubmitted: (_) => _submit(),
        decoration: InputDecoration(
          labelText: s.t('barcode'),
          hintText: s.t('barcodeHint'),
          errorText: _error,
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(s.t('cancel'))),
        FilledButton(onPressed: _submit, child: Text(s.t('validate'))),
      ],
    );
  }
}

bool isValidBarcode(String code) => RegExp(r'^\d{8,14}$').hasMatch(code);

/// Sens d'écriture d'un texte venant de la base (ingrédients souvent en
/// français même quand l'app est en arabe).
TextDirection textDirectionOf(String text) =>
    RegExp(r'[\u0600-\u06FF]').hasMatch(text)
        ? TextDirection.rtl
        : TextDirection.ltr;
