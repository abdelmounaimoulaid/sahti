# Mettre Sahti sur TestFlight et obtenir l'APK Android

## APK Android (rien à faire)

À chaque mise à jour de `main`, GitHub construit l'APK de test.
Pour l'installer : onglet **Releases** du dépôt → dernière « APK de test » →
télécharger le fichier `.apk` sur le téléphone → l'ouvrir → autoriser
l'installation depuis cette source si Android le demande.

Cet APK est signé avec une clé de test : parfait pour essayer l'app,
mais Google Play demandera une clé de publication plus tard.

## TestFlight (iPhone) : à faire une seule fois

### 1. Enregistrer l'identifiant de l'app
[developer.apple.com → Identifiers](https://developer.apple.com/account/resources/identifiers/list) → **+** →
App IDs → App → Description `Sahti`, Bundle ID **Explicit** `ma.sahti.sahti` → Register.

### 2. Créer l'app dans App Store Connect
[appstoreconnect.apple.com](https://appstoreconnect.apple.com) → Apps → **+** → Nouvelle app :
plateforme iOS, nom `Sahti`, langue principale Français, Bundle ID `ma.sahti.sahti`, SKU `sahti`.

### 3. Créer une clé d'API App Store Connect
App Store Connect → Utilisateurs et accès → **Intégrations** → App Store Connect API →
Clés d'équipe → **+** → nom `GitHub`, accès **Admin** (nécessaire pour que
GitHub crée les certificats de signature tout seul).
Noter le **Key ID** et l'**Issuer ID** affichés en haut, puis **télécharger la clé**
(fichier `AuthKey_XXXX.p8`, téléchargeable une seule fois).

### 4. Trouver le Team ID
[developer.apple.com/account](https://developer.apple.com/account) → Membership details → **Team ID** (10 caractères).

### 5. Ajouter les 4 secrets dans GitHub
Dépôt → Settings → Secrets and variables → Actions → **New repository secret** :

| Nom | Valeur |
|---|---|
| `APPLE_TEAM_ID` | le Team ID |
| `ASC_KEY_ID` | le Key ID |
| `ASC_ISSUER_ID` | l'Issuer ID |
| `ASC_KEY_P8` | tout le contenu du fichier `.p8` (ouvrir avec un éditeur de texte, copier de `-----BEGIN` à `-----END PRIVATE KEY-----`) |

Ces secrets restent dans GitHub : ne les envoyer à personne, ni dans un message.

## Envoyer une version sur TestFlight

Dépôt → onglet **Actions** → **TestFlight iOS** → **Run workflow**.
Compter 20 à 30 minutes, puis 10 à 30 minutes de traitement chez Apple.
La version apparaît ensuite dans App Store Connect → TestFlight.
Pour l'installer sur ton iPhone : ajoute-toi comme testeur interne, puis ouvre l'app TestFlight.
