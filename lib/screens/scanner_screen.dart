import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../l10n/strings.dart';
import 'product_screen.dart';
import 'widgets.dart';

/// Ouvre l'écran de scan. Le code lu ouvre directement la fiche produit.
Future<void> openScanner(BuildContext context, {bool replace = false}) {
  final route = MaterialPageRoute(builder: (_) => const ScannerScreen());
  return replace
      ? Navigator.pushReplacement(context, route)
      : Navigator.push(context, route);
}

/// Écran de scan (toujours sombre, comme la maquette) : cadre safran,
/// flash, et saisie du code à la main.
class ScannerScreen extends StatefulWidget {
  /// Remplace la caméra (tests, captures d'écran).
  final Widget? cameraPreview;
  const ScannerScreen({super.key, this.cameraPreview});
  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  MobileScannerController? _controller;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    if (widget.cameraPreview == null) {
      _controller = MobileScannerController(
        formats: const [
          BarcodeFormat.ean13,
          BarcodeFormat.ean8,
          BarcodeFormat.upcA,
          BarcodeFormat.upcE,
        ],
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _open(String code) {
    if (_done) return;
    _done = true;
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => ProductScreen(barcode: code)));
  }

  void _onDetect(BarcodeCapture capture) {
    for (final b in capture.barcodes) {
      final v = b.rawValue;
      if (v != null && isValidBarcode(v)) return _open(v);
    }
  }

  Future<void> _manual() async {
    await _controller?.stop();
    if (!mounted) return;
    final code = await askBarcode(context);
    if (!mounted) return;
    if (code != null) {
      _open(code);
    } else {
      await _controller?.start();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    const fg = SahtiColors.texteSombre;
    const muted = Color(0xFFB7CABF);
    const overlay = Color(0x73000000);
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: SahtiColors.mentheSombre,
            ),
      ),
      child: Scaffold(
        backgroundColor: SahtiColors.fondSombre,
        body: Stack(children: [
          Positioned.fill(
            child: widget.cameraPreview ??
                MobileScanner(
                  controller: _controller,
                  onDetect: _onDetect,
                  errorBuilder: (context, error, child) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(s.t('cameraError'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: fg)),
                    ),
                  ),
                ),
          ),
          SafeArea(
            bottom: false,
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(children: [
                  RoundButton(
                    icon: Icons.close,
                    tooltip: s.t('close'),
                    background: overlay,
                    foreground: Colors.white,
                    onPressed: () => Navigator.maybePop(context),
                  ),
                  Expanded(
                    child: Text(s.t('scanTitle'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: fg,
                            fontSize: 17,
                            fontWeight: FontWeight.w600)),
                  ),
                  RoundButton(
                    icon: Icons.flash_on,
                    tooltip: s.t('flash'),
                    background: overlay,
                    foreground: SahtiColors.safran,
                    onPressed: () => _controller?.toggleTorch(),
                  ),
                ]),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const _Viewfinder(),
                      const SizedBox(height: 24),
                      Text(s.t('pointCamera'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: fg,
                              fontSize: 18,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text(s.t('scanAuto'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: muted, fontSize: 14)),
                    ],
                  ),
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xEB0E1713),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                child: SafeArea(
                  top: false,
                  child: Column(children: [
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _manual,
                        icon: const Icon(Icons.keyboard_outlined),
                        label: Text(s.t('manual')),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          foregroundColor: fg,
                          side: const BorderSide(
                              color: SahtiColors.mentheSombre, width: 1.5),
                          textStyle: const TextStyle(
                              fontFamily: 'ReadexPro',
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(children: [
                      const Icon(Icons.info_outline,
                          size: 18, color: SahtiColors.mentheSombre),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(s.t('scanTip'),
                            style: const TextStyle(color: muted, fontSize: 13)),
                      ),
                    ]),
                  ]),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

/// Cadre de visée : coins safran et ligne menthe.
class _Viewfinder extends StatelessWidget {
  const _Viewfinder();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 190,
      child: CustomPaint(
        painter: _CornersPainter(),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            height: 3,
            decoration: BoxDecoration(
              color: SahtiColors.mentheSombre,
              borderRadius: BorderRadius.circular(2),
              boxShadow: const [
                BoxShadow(color: SahtiColors.mentheSombre, blurRadius: 12)
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CornersPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r =
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(20));
    // Assombrit autour du cadre.
    canvas.drawDRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTRB(-2000, -2000, 2000, 2000), Radius.zero),
      r,
      Paint()..color = const Color(0x59000000),
    );
    final paint = Paint()
      ..color = SahtiColors.safran
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    const l = 44.0, rad = 20.0;
    final w = size.width, h = size.height;
    for (final path in [
      Path()
        ..moveTo(0, l)
        ..lineTo(0, rad)
        ..arcToPoint(const Offset(rad, 0), radius: const Radius.circular(rad))
        ..lineTo(l, 0),
      Path()
        ..moveTo(w - l, 0)
        ..lineTo(w - rad, 0)
        ..arcToPoint(Offset(w, rad), radius: const Radius.circular(rad))
        ..lineTo(w, l),
      Path()
        ..moveTo(w, h - l)
        ..lineTo(w, h - rad)
        ..arcToPoint(Offset(w - rad, h), radius: const Radius.circular(rad))
        ..lineTo(w - l, h),
      Path()
        ..moveTo(l, h)
        ..lineTo(rad, h)
        ..arcToPoint(Offset(0, h - rad), radius: const Radius.circular(rad))
        ..lineTo(0, h - l),
    ]) {
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_CornersPainter old) => false;
}
