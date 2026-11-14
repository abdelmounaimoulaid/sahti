# Graph Report - sahti  (2026-11-14)

## Corpus Check
- 42 files · ~18,143 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 33 file(s) not represented in the graph (top: .xml 9, (none) 4, .plist 4)
- WARNING: 33 of 116 files seen (28%) have no supported extractor and are missing from this graph entirely. It may look complete while representing only part of the codebase.

## Summary
- 569 nodes · 696 edges · 30 communities (19 shown, 11 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `7c8af5af`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- product_screen.dart
- add_product_screen.dart
- history.dart
- dependencies
- AppDelegate
- product.dart
- scoring.dart
- widgets.dart
- home_screen.dart
- screens_test.dart
- theme.dart
- gen_brand.py
- Sahti (صحتي)
- settings.dart
- analysis_options.yaml
- MainActivity.kt
- CLAUDE.md
- LaunchImage.imageset/README.md
- allergens.dart
- scanner_screen.dart
- settings_screen.dart
- shell.dart

## God Nodes (most connected - your core abstractions)
1. `dependencies` - 9 edges
2. `SahtiPalette` - 5 edges
3. `AppDelegate` - 5 edges
4. `Sahti (صحتي)` - 5 edges
5. `AppSettings` - 4 edges
6. `lockup()` - 4 edges
7. `png()` - 4 edges
8. `text_path()` - 4 edges
9. `flutter` - 4 edges
10. `AddProductScreen` - 3 edges

## Surprising Connections (you probably didn't know these)
- `SahtiApp` --inherits--> `StatelessWidget`  [EXTRACTED]
  lib/main.dart → None  _Bridges community 7 → community 0_
- `PromiseBanner` --inherits--> `StatelessWidget`  [EXTRACTED]
  lib/screens/home_screen.dart → None  _Bridges community 0 → community 8_
- `_Viewfinder` --inherits--> `StatelessWidget`  [EXTRACTED]
  lib/screens/scanner_screen.dart → None  _Bridges community 0 → community 23_
- `AdditivesScreen` --inherits--> `StatelessWidget`  [EXTRACTED]
  lib/screens/settings_screen.dart → None  _Bridges community 0 → community 24_
- `_NavItem` --inherits--> `StatelessWidget`  [EXTRACTED]
  lib/screens/shell.dart → None  _Bridges community 0 → community 25_

## Import Cycles
- None detected.

## Communities (30 total, 11 thin omitted)

### Community 0 - "product_screen.dart"
Cohesion: 0.05
Nodes (42): additiveCode, additiveColor, additiveLabel, additiveNames, _AdditivesCard, AllergenBanner, api, barcode (+34 more)

### Community 1 - "add_product_screen.dart"
Cohesion: 0.07
Nodes (25): AddProductScreen, _AddProductScreenState, barcode, _brand, build, createState, dispose, _field (+17 more)

### Community 2 - "history.dart"
Cohesion: 0.05
Nodes (32): add, at, brand, changes, clear, fromJson, History, HistoryEntry (+24 more)

### Community 3 - "dependencies"
Cohesion: 0.07
Nodes (29): dependencies, flutter, flutter_localizations, google_mlkit_text_recognition, http, image_picker, mobile_scanner, path_provider (+21 more)

### Community 4 - "AppDelegate"
Cohesion: 0.12
Nodes (6): Flutter, AppDelegate, SceneDelegate, RunnerTests, Testing, UIKit

### Community 5 - "product.dart"
Cohesion: 0.10
Nodes (17): additives, allergenTags, barcode, brand, categories, fromOff, halalOnPackage, imageUrl (+9 more)

### Community 6 - "scoring.dart"
Cohesion: 0.07
Nodes (27): additivePoints, AdditiveRisk, additiveRisks, additives, computeScore, drinkBest, extra, foodBest (+19 more)

### Community 7 - "widgets.dart"
Cohesion: 0.04
Nodes (35): build, home, main, SahtiApp, settings, askBarcode, badgeText, bars (+27 more)

### Community 8 - "home_screen.dart"
Cohesion: 0.06
Nodes (26): build, _clearAll, createState, dispose, initState, _items, _match, _pending (+18 more)

### Community 9 - "screens_test.dart"
Cohesion: 0.06
Nodes (15): _ids, main, _p, main, make, biscuits, fakeApi, main (+7 more)

### Community 10 - "theme.dart"
Cohesion: 0.05
Nodes (33): alerte, alerteTexte, bon, carte, clair, copyWith, dark, discret (+25 more)

### Community 11 - "gen_brand.py"
Cohesion: 0.16
Nodes (6): app_icon(), lockup(), png(), svg(), symbole(), text_path()

### Community 12 - "Sahti (صحتي)"
Cohesion: 0.29
Nodes (6): Ce que fait la V1, Envoi des produits vers Open Food Facts, Installer et lancer, Organisation du code, Permissions caméra, Sahti (صحتي)

### Community 13 - "settings.dart"
Cohesion: 0.06
Nodes (25): hasBoth, isAr, join, keys, lang, of, S, _t (+17 more)

### Community 14 - "analysis_options.yaml"
Cohesion: 0.50
Nodes (3): analyzer, exclude, include

### Community 22 - "allergens.dart"
Cohesion: 0.07
Nodes (28): _accents, Allergen, allergenById, AllergenCheck, allergens, ar, checkAllergens, contains (+20 more)

### Community 23 - "scanner_screen.dart"
Cohesion: 0.08
Nodes (21): build, cameraPreview, _controller, _CornersPainter, createState, dispose, _done, initState (+13 more)

### Community 24 - "settings_screen.dart"
Cohesion: 0.09
Nodes (19): AdditivesScreen, appVersion, context, createState, dispose, initState, onChanged, _pending (+11 more)

### Community 25 - "shell.dart"
Cohesion: 0.11
Nodes (14): activeIcon, build, createState, current, label, _NavItem, onScan, onTab (+6 more)

## Knowledge Gaps
- **307 isolated node(s):** `S`, `lang`, `isAr`, `_t`, `keys` (+302 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 409 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **11 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `ScoreResult` connect `scoring.dart` to `product_screen.dart`?**
  _High betweenness centrality (0.012) - this node is a cross-community bridge._
- **What connects `S`, `lang`, `isAr` to the rest of the system?**
  _307 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `product_screen.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.051207729468599035 - nodes in this community are weakly interconnected._
- **Why does `AllergenCheck` connect `allergens.dart` to `product_screen.dart`?**
  _High betweenness centrality (0.007) - this node is a cross-community bridge._
- **Should `add_product_screen.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.07007575757575757 - nodes in this community are weakly interconnected._
- **Should `history.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.045328399629972246 - nodes in this community are weakly interconnected._
- **Should `dependencies` be split into smaller, more focused modules?**
  _Cohesion score 0.06666666666666667 - nodes in this community are weakly interconnected._