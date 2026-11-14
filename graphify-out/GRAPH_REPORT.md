# Graph Report - sahti  (2026-11-14)

## Corpus Check
- 32 files · ~9,202 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 33 file(s) not represented in the graph (top: .xml 9, (none) 4, .plist 4)
- WARNING: 33 of 106 files seen (31%) have no supported extractor and are missing from this graph entirely. It may look complete while representing only part of the codebase.

## Summary
- 318 nodes · 354 edges · 21 communities (14 shown, 7 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `76122a0b`
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
- off_api.dart
- home_screen.dart
- main.dart
- theme.dart
- gen_brand.py
- Sahti (صحتي)
- analysis_options.yaml
- MainActivity.kt
- CLAUDE.md
- LaunchImage.imageset/README.md

## God Nodes (most connected - your core abstractions)
1. `dependencies` - 9 edges
2. `AppDelegate` - 5 edges
3. `Sahti (صحتي)` - 5 edges
4. `flutter` - 4 edges
5. `text_path()` - 4 edges
6. `lockup()` - 4 edges
7. `png()` - 4 edges
8. `SahtiApp` - 3 edges
9. `_SahtiAppState` - 3 edges
10. `ProductScreen` - 3 edges

## Surprising Connections (you probably didn't know these)
- `HomeScreen` --inherits--> `StatefulWidget`  [EXTRACTED]
  lib/screens/home_screen.dart → None  _Bridges community 1 → community 8_

## Import Cycles
- None detected.

## Communities (21 total, 7 thin omitted)

### Community 0 - "product_screen.dart"
Cohesion: 0.07
Nodes (23): action, additiveLabel, _additiveNames, api, barcode, body, build, createState (+15 more)

### Community 1 - "add_product_screen.dart"
Cohesion: 0.06
Nodes (28): SahtiApp, _SahtiAppState, AddProductScreen, _AddProductScreenState, barcode, _brand, build, createState (+20 more)

### Community 2 - "history.dart"
Cohesion: 0.08
Nodes (19): lang, of, S, _t, add, at, brand, fromJson (+11 more)

### Community 3 - "dependencies"
Cohesion: 0.07
Nodes (29): dependencies, flutter, flutter_localizations, google_mlkit_text_recognition, http, image_picker, mobile_scanner, path_provider (+21 more)

### Community 4 - "AppDelegate"
Cohesion: 0.12
Nodes (6): Flutter, AppDelegate, SceneDelegate, RunnerTests, Testing, UIKit

### Community 5 - "product.dart"
Cohesion: 0.11
Nodes (15): additives, barcode, brand, categories, fromOff, halalOnPackage, imageUrl, ingredientsText (+7 more)

### Community 6 - "scoring.dart"
Cohesion: 0.07
Nodes (27): additivePoints, AdditiveRisk, additiveRisks, additives, computeScore, drinkBest, extra, foodBest (+19 more)

### Community 7 - "off_api.dart"
Cohesion: 0.13
Nodes (9): _base, canUpload, _client, fetch, OffApi, _password, _ua, upload (+1 more)

### Community 8 - "home_screen.dart"
Cohesion: 0.12
Nodes (9): build, createState, _history, HomeScreen, _HomeScreenState, initState, _open, _reload (+1 more)

### Community 9 - "main.dart"
Cohesion: 0.08
Nodes (12): build, createState, _locale, main, _toggle, toggleLanguage, build, score (+4 more)

### Community 10 - "theme.dart"
Cohesion: 0.10
Nodes (20): bon, dark, excellent, fond, fondSombre, inconnu, mauvais, mediocre (+12 more)

### Community 11 - "gen_brand.py"
Cohesion: 0.16
Nodes (6): app_icon(), lockup(), png(), svg(), symbole(), text_path()

### Community 12 - "Sahti (صحتي)"
Cohesion: 0.29
Nodes (6): Ce que fait la V1, Envoi des produits vers Open Food Facts, Installer et lancer, Organisation du code, Permissions caméra, Sahti (صحتي)

### Community 14 - "analysis_options.yaml"
Cohesion: 0.50
Nodes (3): analyzer, exclude, include

## Knowledge Gaps
- **145 isolated node(s):** `_locale`, `main`, `toggleLanguage`, `createState`, `_toggle` (+140 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 227 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **7 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `OffApi` connect `off_api.dart` to `product_screen.dart`?**
  _High betweenness centrality (0.016) - this node is a cross-community bridge._
- **What connects `_locale`, `main`, `toggleLanguage` to the rest of the system?**
  _145 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `product_screen.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.07096774193548387 - nodes in this community are weakly interconnected._
- **Why does `Product` connect `product.dart` to `product_screen.dart`?**
  _High betweenness centrality (0.015) - this node is a cross-community bridge._
- **Should `add_product_screen.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.057692307692307696 - nodes in this community are weakly interconnected._
- **Should `history.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.07671957671957672 - nodes in this community are weakly interconnected._
- **Should `dependencies` be split into smaller, more focused modules?**
  _Cohesion score 0.06666666666666667 - nodes in this community are weakly interconnected._