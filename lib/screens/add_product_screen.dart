import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../l10n/strings.dart';
import '../services/off_api.dart';
import '../services/pending.dart';

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
    final dest = '${dir.path}/${widget.barcode}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    return File(x.path).copy(dest);
  }

  Future<void> _ocr(File f) async {
    // ML Kit fonctionne sur le téléphone, gratuit et hors ligne (alphabet latin).
    final rec = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final text = (await rec.processImage(InputImage.fromFilePath(f.path))).text;
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
    if (_front == null || _ingr == null || _nutri == null ||
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
    return Expanded(
      child: InkWell(
        onTap: () async {
          final f = await _take();
          if (f != null) onTaken(f);
        },
        child: Container(
          height: 120,
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(12),
            image: file == null
                ? null
                : DecorationImage(image: FileImage(file), fit: BoxFit.cover),
          ),
          alignment: Alignment.center,
          child: file == null
              ? Padding(
                  padding: const EdgeInsets.all(4),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.photo_camera),
                    Text(label, textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12)),
                  ]),
                )
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.t('addProduct'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(widget.barcode, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          Row(children: [
            _photo(s.t('photoFront'), _front, (f) => setState(() => _front = f)),
            _photo(s.t('photoIngredients'), _ingr, (f) {
              setState(() => _ingr = f);
              _ocr(f);
            }),
            _photo(s.t('photoNutrition'), _nutri, (f) => setState(() => _nutri = f)),
          ]),
          const SizedBox(height: 16),
          TextField(controller: _name,
              decoration: InputDecoration(labelText: s.t('name'))),
          TextField(controller: _brand,
              decoration: InputDecoration(labelText: s.t('brand'))),
          const SizedBox(height: 8),
          TextField(
            controller: _ingredients,
            maxLines: 5,
            decoration: InputDecoration(
                labelText: s.t('ingredientsOcr'),
                border: const OutlineInputBorder()),
          ),
          CheckboxListTile(
            value: _halal,
            onChanged: (v) => setState(() => _halal = v ?? false),
            title: Text(s.t('halalCheck')),
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _busy ? null : _submit,
            child: _busy
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : Text(s.t('send')),
          ),
        ],
      ),
    );
  }
}
