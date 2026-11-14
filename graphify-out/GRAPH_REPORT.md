# Graph Report - sahti  (2026-11-14)

## Corpus Check
- 31 files · ~7,872 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 33 file(s) not represented in the graph (top: .xml 9, (none) 4, .plist 4)
- WARNING: 33 of 105 files seen (31%) have no supported extractor and are missing from this graph entirely. It may look complete while representing only part of the codebase.

## Summary
- 279 nodes · 307 edges · 23 communities (16 shown, 7 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `331e7ae9`
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
- scanner_screen.dart
- theme.dart
- Sahti (صحتي)
- package:flutter/material.dart
- analysis_options.yaml
- MainActivity.kt
- CLAUDE.md
- LaunchImage.imageset/README.md
- flutter

## God Nodes (most connected - your core abstractions)
1. `dependencies` - 9 edges
2. `AppDelegate` - 5 edges
3. `Sahti (صحتي)` - 5 edges
4. `flutter` - 4 edges
5. `SahtiApp` - 3 edges
6. `_SahtiAppState` - 3 edges
7. `ProductScreen` - 3 edges
8. `_ProductScreenState` - 3 edges
9. `dev_dependencies` - 3 edges
10. `fonts` - 3 edges

## Surprising Connections (you probably didn't know these)
- `HomeScreen` --inherits--> `StatefulWidget`  [EXTRACTED]
  lib/screens/home_screen.dart → None  _Bridges community 9 → community 8_
- `ScannerScreen` --inherits--> `StatefulWidget`  [EXTRACTED]
  lib/screens/scanner_screen.dart → None  _Bridges community 9 → community 10_

## Import Cycles
- None detected.

## Communities (23 total, 7 thin omitted)

### Community 0 - "product_screen.dart"
Cohesion: 0.07
Nodes (23): action, additiveLabel, _additiveNames, api, barcode, body, build, createState (+15 more)

### Community 1 - "add_product_screen.dart"
Cohesion: 0.10
Nodes (14): barcode, _brand, build, createState, dispose, _halal, _ingredients, _name (+6 more)

### Community 2 - "history.dart"
Cohesion: 0.08
Nodes (19): lang, of, S, _t, add, at, brand, fromJson (+11 more)

### Community 3 - "dependencies"
Cohesion: 0.09
Nodes (21): dependencies, flutter, flutter_localizations, google_mlkit_text_recognition, http, image_picker, mobile_scanner, path_provider (+13 more)

### Community 4 - "AppDelegate"
Cohesion: 0.12
Nodes (6): Flutter, AppDelegate, SceneDelegate, RunnerTests, Testing, UIKit

### Community 5 - "product.dart"
Cohesion: 0.12
Nodes (13): additives, barcode, brand, fromOff, halalOnPackage, imageUrl, ingredientsText, labels (+5 more)

### Community 6 - "scoring.dart"
Cohesion: 0.13
Nodes (11): additives, computeScore, got, level, nutrition, processing, risky, riskyAdditives (+3 more)

### Community 7 - "off_api.dart"
Cohesion: 0.14
Nodes (9): _base, canUpload, _client, fetch, OffApi, _password, _ua, upload (+1 more)

### Community 8 - "home_screen.dart"
Cohesion: 0.13
Nodes (9): build, createState, _history, HomeScreen, _HomeScreenState, initState, _open, _reload (+1 more)

### Community 9 - "main.dart"
Cohesion: 0.13
Nodes (12): build, createState, _locale, main, SahtiApp, _SahtiAppState, _toggle, toggleLanguage (+4 more)

### Community 10 - "scanner_screen.dart"
Cohesion: 0.20
Nodes (8): build, _controller, createState, dispose, _done, _onDetect, ScannerScreen, _ScannerScreenState

### Community 11 - "theme.dart"
Cohesion: 0.10
Nodes (19): bon, dark, excellent, fond, fondSombre, inconnu, mauvais, mediocre (+11 more)

### Community 12 - "Sahti (صحتي)"
Cohesion: 0.29
Nodes (6): Ce que fait la V1, Envoi des produits vers Open Food Facts, Installer et lancer, Organisation du code, Permissions caméra, Sahti (صحتي)

### Community 13 - "package:flutter/material.dart"
Cohesion: 0.13
Nodes (5): build, score, size, main, main

### Community 14 - "analysis_options.yaml"
Cohesion: 0.50
Nodes (3): analyzer, exclude, include

### Community 22 - "flutter"
Cohesion: 0.25
Nodes (8): flutter, assets, fonts, uses-material-design, asset, family, fonts, weight

## Knowledge Gaps
- **125 isolated node(s):** `_locale`, `main`, `toggleLanguage`, `createState`, `_toggle` (+120 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 200 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **7 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `OffApi` connect `off_api.dart` to `product_screen.dart`?**
  _High betweenness centrality (0.020) - this node is a cross-community bridge._
- **What connects `_locale`, `main`, `toggleLanguage` to the rest of the system?**
  _125 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `product_screen.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.07096774193548387 - nodes in this community are weakly interconnected._
- **Why does `Product` connect `product.dart` to `product_screen.dart`?**
  _High betweenness centrality (0.018) - this node is a cross-community bridge._
- **Should `add_product_screen.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.09523809523809523 - nodes in this community are weakly interconnected._
- **Should `history.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.07671957671957672 - nodes in this community are weakly interconnected._
- **Should `dependencies` be split into smaller, more focused modules?**
  _Cohesion score 0.09090909090909091 - nodes in this community are weakly interconnected._