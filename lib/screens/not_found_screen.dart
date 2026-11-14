import 'package:flutter/material.dart';
import '../l10n/strings.dart';
import 'add_product_screen.dart';
import 'scanner_screen.dart';
import 'widgets.dart';

/// Produit absent d'Open Food Facts : invitation à l'ajouter en 3 photos.
class NotFoundView extends StatelessWidget {
  final String barcode;
  const NotFoundView({super.key, required this.barcode});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final pal = SahtiPalette.of(context);
    final primary = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: Column(children: [
        const Align(
            alignment: AlignmentDirectional.centerStart,
            child: BackRoundButton()),
        Expanded(
          child: SingleChildScrollView(
            child: Column(children: [
              const SizedBox(height: 24),
              SizedBox(
                width: 132,
                height: 132,
                child: Stack(children: [
                  Container(
                    width: 132,
                    height: 132,
                    decoration:
                        BoxDecoration(color: pal.carte, shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: const SahtiLogo(size: 78, bars: Color(0xFFB9C9C0)),
                  ),
                  PositionedDirectional(
                    bottom: 4,
                    end: 4,
                    child: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                          color: SahtiColors.safran, shape: BoxShape.circle),
                      child: const Text('?',
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: SahtiColors.texte)),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 18),
              Text(s.t('notFound'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 26, fontWeight: FontWeight.w700)),
              const SizedBox(height: 18),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: pal.carte, borderRadius: BorderRadius.circular(10)),
                child: Text(barcode,
                    textDirection: TextDirection.ltr,
                    style: TextStyle(fontSize: 14, color: pal.discret)),
              ),
              const SizedBox(height: 18),
              Text(s.t('notFoundHelp'),
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontSize: 16, height: 1.5, color: pal.discret)),
              const SizedBox(height: 26),
              IntrinsicHeight(
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                    for (final (i, key) in const [
                      'stepFront',
                      'stepIngredients',
                      'stepNutrition'
                    ].indexed) ...[
                      if (i > 0) const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 14),
                          decoration: BoxDecoration(
                              color: pal.carte,
                              borderRadius: BorderRadius.circular(16)),
                          child: Column(children: [
                            Container(
                              width: 36,
                              height: 36,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: pal.mentheClaire,
                                  shape: BoxShape.circle),
                              child: Text('${i + 1}',
                                  style: TextStyle(
                                      color: primary,
                                      fontWeight: FontWeight.w700)),
                            ),
                            const SizedBox(height: 8),
                            Text(s.t(key),
                                textAlign: TextAlign.center,
                                style:
                                    const TextStyle(fontSize: 13, height: 1.3)),
                          ]),
                        ),
                      ),
                    ],
                  ])),
              const SizedBox(height: 18),
              Text(s.t('whereAdded'),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: pal.discret)),
              const SizedBox(height: 18),
            ]),
          ),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => AddProductScreen(barcode: barcode)),
          ),
          icon: const Icon(Icons.photo_camera_outlined),
          label: Text(s.t('addProduct')),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
            textStyle: const TextStyle(
                fontFamily: 'ReadexPro',
                fontSize: 17,
                fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () => openScanner(context, replace: true),
          style: TextButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          child: Text(s.t('scanOther'),
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }
}
