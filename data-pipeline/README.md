# Base produits Sahti

Ce dossier contient les outils qui construisent la base produits de Sahti, à partir d'Open Food Facts (Maroc). Ils servent une seule fois, au démarrage, jamais au moment du scan dans l'app.

## Contenu
- `sql/schema.sql` : les tables `products` (avec un statut : complete, incomplete, ai_to_verify, validated), `product_sources` (la source de chaque information) et `enrichment_runs` (le temps et le résultat de chaque recherche). Le schéma marche avec MySQL 8 et MariaDB.
- `scripts/` :
  - `setup_db.py` : crée la base et un utilisateur dédié.
  - `import_off_csv.py` : importe l'export CSV d'Open Food Facts filtré sur le Maroc.
  - `auto_match.py` : complète une fiche avec un autre code-barres du même produit.
  - `find_ingredient_photos.py` et `import_agent_results.py` : lisent les photos d'étiquettes et enregistrent les listes d'ingrédients.
  - `filter_nonfood.py` et `fill_additives_from_names.py` : écartent les produits non alimentaires et traduisent les additifs en E-numbers.
  - `fill_names_off.py` : récupère les noms manquants.
- `admin/` : une page Laravel où l'on valide ou corrige chaque fiche avant publication. Elle est protégée par un mot de passe, défini avec `php artisan admin:password`.
- API publique en lecture seule pour l'app : `GET /api/v1/products/{code-barres}`. Elle renvoie le même format JSON qu'Open Food Facts. Seules les fiches complètes ou validées sont servies, et jamais les produits non alimentaires.
- `data/AGENT_RULES.md` : les règles de lecture des étiquettes.
- `data/agent_results/` : les listes d'ingrédients lues sur les photos.
- `BILAN_lot1.md` : les résultats, les temps et les pièges rencontrés.

## Installation locale
1. Copier `.env.example` en `.env`, puis remplir les accès MySQL. Le fichier `.env` ne doit jamais être commité.
2. Installer les dépendances : `pip install pymysql python-dotenv requests`
3. Créer la base : `python scripts/setup_db.py`
4. Lancer l'admin : `cd admin && composer install && php artisan serve --port=8010`

Les photos (3,7 Go) et l'export OFF (1,5 Go) ne sont pas dans le dépôt. Ils se retéléchargent depuis Open Food Facts.

## Licence des données
Les données viennent d'Open Food Facts et sont sous licence ODbL.
