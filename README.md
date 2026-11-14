# Sahti (صحتي)

Application mobile (Android + iPhone) pour scanner les produits alimentaires vendus au Maroc
et voir leur note santé. **Ni publicité, ni marques qui paient pour leur note.**

## Ce que fait la V1

- Scan du code-barres (EAN-13, EAN-8, UPC) avec la caméra.
- Fiche produit depuis Open Food Facts (gratuit) : photo, note sur 100, détail, nutriments, ingrédients.
- Note (méthode v2) : nutrition 60 pts (Nutri-Score 2023) + transformation 20 pts (NOVA) + additifs 20 pts, avec plafonds (Nutri-Score D ≤ 49, E ≤ 29, additif rouge ≤ 49, NOVA 4 ≤ 74). Classement des additifs provisoire dans `lib/services/scoring.dart`.
- Halal : affiche seulement ce qui est déclaré sur l'emballage.
- Produit introuvable : 3 photos (face, ingrédients, tableau nutritionnel), lecture automatique
  des ingrédients (OCR sur le téléphone), envoi vers Open Food Facts.
- Interface en français et en arabe (bouton en haut à droite), avec affichage de droite à gauche.
- Historique des scans gardé sur le téléphone.

## Installer et lancer

1. Installer Flutter : https://docs.flutter.dev/get-started/install
2. Dans ce dossier, générer les dossiers Android et iOS :
   ```
   flutter create --org ma.sahti --project-name sahti --platforms android,ios .
   ```
3. Ajouter les permissions caméra (voir plus bas).
4. Lancer sur un téléphone branché :
   ```
   flutter pub get
   flutter run
   ```
5. Tests de la note :
   ```
   flutter test
   ```

### Permissions caméra

**Android** – dans `android/app/src/main/AndroidManifest.xml`, au-dessus de `<application` :
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.INTERNET" />
```
et dans `android/app/build.gradle`, mettre `minSdkVersion 21` (ou plus).

**iOS** – dans `ios/Runner/Info.plist` :
```xml
<key>NSCameraUsageDescription</key>
<string>Sahti utilise la caméra pour scanner les codes-barres et photographier les produits.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Sahti peut utiliser vos photos pour ajouter un produit.</string>
```
et dans `ios/Podfile`, mettre `platform :ios, '15.5'` (requis par la lecture de texte ML Kit).

## Envoi des produits vers Open Food Facts

Créez un compte gratuit sur https://world.openfoodfacts.org pour l'app, puis lancez/compilez avec :
```
flutter run --dart-define=OFF_USER=votre_compte --dart-define=OFF_PASSWORD=votre_mot_de_passe
```
Sans ces valeurs, les produits ajoutés sont gardés sur le téléphone (envoi prévu plus tard).

## Organisation du code

```
lib/
  main.dart                  App, langues FR/AR
  l10n/strings.dart          Tous les textes FR + AR
  models/product.dart        Produit (lecture Open Food Facts, halal emballage)
  services/off_api.dart      Lecture et envoi Open Food Facts
  services/scoring.dart      Calcul de la note /100
  services/history.dart      Historique local
  services/pending.dart      Produits ajoutés en attente d'envoi
  screens/                   Accueil, scanner, fiche produit, ajout produit
test/scoring_test.dart       Tests de la note
```

Données : Open Food Facts, licence ODbL (mention obligatoire, déjà affichée dans la fiche produit).
