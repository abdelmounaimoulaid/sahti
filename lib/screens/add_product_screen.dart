import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../l10n/strings.dart';
import '../services/off_api.dart';
import '../services/pending.dart';
import 'widgets.dart';

/// Ajout d'un produit manquant : 3 photos + lecture automatique (OCR)
/// de la liste d'ingrédients, que l'utilisateur peut corriger.
class AddProductScreen extends StatefulWidget {
  final String barcode;
  const AddProductScreen({super.key, required this.barcode});
  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _picker = ImagePicker();
  final _name = TextEditingController();
  final _brand = TextEditingController();
  final _ingredients = TextEditingController();
  File? _front, _ingr, _nutri;
  bool _halal = false, _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _brand.dispose();
    _ingredients.dispose();
    super.dispose();
  }

  /// Prend une photo et la copie dans le dossier de l'app (le cache peut être vidé).
  Future<File?> _take() async {
    final x = await _picker.pickImage(
        source: ImageSource.camera, maxWidth: 1600, imageQuality: 85);
    if (x == null) return null;
    final dir = await getApplicationDocumentsDirectory();
    final dest =
        '${dir.path}/${widget.barcode}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    return File(x.path).copy(dest);
  }

  Future<void> _ocr(File f) async {
    // ML Kit fonctionne sur le téléphone, gratuit et hors ligne (alphabet latin).
    final rec = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final text =
          (await rec.processImage(InputImage.fromFilePath(f.path))).text;
      if (_ingredients.text.isEmpty) {
        _ingredients.text = text.replaceAll('\n', ' ').trim();
      }
    } finally {
      rec.close();
    }
  }

  Future<void> _submit() async {
    final s = S.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (_front == null ||
        _ingr == null ||
        _nutri == null ||
        _name.text.trim().isEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(s.t('missingPhotos'))));
      return;
    }
    setState(() => _busy = true);
    var sent = false;
    if (OffApi.canUpload) {
      try {
        await OffApi().upload(
          barcode: widget.barcode,
          name: _name.text.trim(),
          brand: _brand.text.trim(),
          ingredientsText: _ingredients.text.trim(),
          halal: _halal,
          front: _front!,
          ingredients: _ingr!,
          nutrition: _nutri!,
        );
        sent = true;
      } catch (_) {/* on garde le produit en attente */}
    }
    if (!sent) {
      await Pending.add({
        'code': widget.barcode,
        'name': _name.text.trim(),
        'brand': _brand.text.trim(),
        'ingredients': _ingredients.text.trim(),
        'halal': _halal,
        'front': _front!.path,
        'ingr': _ingr!.path,
        'nutri': _nutri!.path,
      });
    }
    if (!mounted) return;
    messenger.showSnackBar(
        SnackBar(content: Text(s.t(sent ? 'sent' : 'savedLocally'))));
    Navigator.pop(context);
  }

  Widget _photo(String label, File? file, ValueChanged<File> onTaken) {
    final s = S.of(context);
    final pal = SahtiPalette.of(context);
    final primary = Theme.of(context).colorScheme.primary;
    Future<void> take() async {
      final f = await _take();
      if (f != null) onTaken(f);
    }

    return Expanded(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Semantics(
          button: true,
          label: '$label. ${s.t(file == null ? 'takePhoto' : 'photoTaken')}',
          excludeSemantics: true,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: take,
            child: Container(
              height: 128,
              width: double.infinity,
              decoration: BoxDecoration(
                color: file == null ? pal.carte : pal.trait,
                borderRadius: BorderRadius.circular(16),
                border:
                    file == null ? Border.all(color: primary, width: 2) : null,
                image: file == null
                    ? null
                    : DecorationImage(
                        image: FileImage(file), fit: BoxFit.cover),
              ),
              child: file == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.photo_camera_outlined,
                            color: primary, size: 26),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text(s.t('takePhoto'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    )
                  : Align(
                      alignment: AlignmentDirectional.topEnd,
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                            color: primary, shape: BoxShape.circle),
                        child: Icon(Icons.check,
                            size: 16,
                            color: Theme.of(context).colorScheme.onPrimary),
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12, height: 1.3)),
      ]),
    );
  }

  Widget _field(String label, TextEditingController c,
      {String? hint, int lines = 1}) {
    final pal = SahtiPalette.of(context);
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: pal.trait, width: 1.5),
    );
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      TextField(
        controller: c,
        maxLines: lines,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: pal.carte,
          border: border,
          enabledBorder: border,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final pal = SahtiPalette.of(context);
    final taken = [_front, _ingr, _nutri].where((f) => f != null).length;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Row(children: [
              const BackRoundButton(),
              const SizedBox(width: 12),
              Expanded(
                child: Text(s.t('addProduct'),
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w700)),
              ),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                child: Text(s.t('photos'),
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
              ),
              Text(s.t('photosProgress', n: taken),
                  style: TextStyle(fontSize: 14, color: pal.discret)),
            ]),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: taken / 3,
                minHeight: 8,
                backgroundColor: pal.trait,
              ),
            ),
            const SizedBox(height: 16),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _photo(
                  s.t('photoFront'), _front, (f) => setState(() => _front = f)),
              const SizedBox(width: 10),
              _photo(s.t('photoIngredients'), _ingr, (f) {
                setState(() => _ingr = f);
                _ocr(f);
              }),
              const SizedBox(width: 10),
              _photo(s.t('photoNutrition'), _nutri,
                  (f) => setState(() => _nutri = f)),
            ]),
            const SizedBox(height: 16),
            Text(widget.barcode,
                textDirection: TextDirection.ltr,
                style: TextStyle(fontSize: 12, color: pal.discret)),
            const SizedBox(height: 12),
            _field(s.t('name'), _name),
            const SizedBox(height: 16),
            _field(s.t('brand'), _brand, hint: s.t('brandHint')),
            const SizedBox(height: 16),
            _field(s.t('ingredientsOcr'), _ingredients, lines: 4),
            const SizedBox(height: 16),
            Material(
              color: pal.carte,
              borderRadius: BorderRadius.circular(14),
              child: CheckboxListTile(
                value: _halal,
                onChanged: (v) => setState(() => _halal = v ?? false),
                title: Text(s.t('halalCheck'),
                    style: const TextStyle(fontSize: 14)),
                controlAffinity: ListTileControlAffinity.leading,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _busy ? null : _submit,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
                textStyle: const TextStyle(
                    fontFamily: 'ReadexPro',
                    fontSize: 17,
                    fontWeight: FontWeight.w600),
              ),
              child: _busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(s.t('send')),
            ),
            const SizedBox(height: 12),
            Text(s.t('license'),
                textAlign: TextAlign.center,
                style:
                    TextStyle(fontSize: 12, height: 1.4, color: pal.discret)),
          ],
        ),
      ),
    );
  }
}
