"""List incomplete products (no ingredients) that have an ingredients photo on OFF.

Reads the OFF CSV export, keeps Moroccan rows with an image_ingredients_url and
no ingredients_text, and writes data/ingredient_photos.json ordered with
Moroccan barcodes (611...) first, then products with a name.
Usage: python scripts/find_ingredient_photos.py data/off_export/products.csv.gz
"""
import csv
import gzip
import json
import sys
from pathlib import Path

import pymysql
from dotenv import dotenv_values

ROOT = Path(__file__).resolve().parent.parent
csv.field_size_limit(10**9)


def main():
    e = dotenv_values(ROOT / ".env")
    conn = pymysql.connect(host="localhost", user=e["DB_USER"], password=e["DB_PASSWORD"],
                           database=e["DB_NAME"], charset="utf8mb4")
    with conn.cursor() as cur:
        cur.execute("""SELECT p.barcode FROM products p LEFT JOIN enrichment_runs r ON r.product_id = p.id
                       WHERE p.status = 'incomplete' AND r.id IS NULL AND p.missing_fields LIKE '%%ingredients%%'""")
        todo = {row[0] for row in cur.fetchall()}
    conn.close()

    found = []
    with gzip.open(sys.argv[1], "rt", encoding="utf-8", newline="") as f:
        for r in csv.DictReader(f, delimiter="\t", quoting=csv.QUOTE_NONE):
            code = r.get("code")
            if code in todo and r.get("image_ingredients_url"):
                found.append({"barcode": code, "name": r.get("product_name") or None,
                              "brand": r.get("brands") or None,
                              "photo": r["image_ingredients_url"].replace(".400.jpg", ".full.jpg")})
    found.sort(key=lambda x: (not x["barcode"].startswith("611"), x["name"] is None))
    out = ROOT / "data" / "ingredient_photos.json"
    out.write_text(json.dumps(found, ensure_ascii=False, indent=1), encoding="utf-8")
    print(f"{len(found)} fiches incomplètes avec photo d'ingrédients "
          f"({sum(1 for x in found if x['barcode'].startswith('611'))} à code marocain) -> {out}")


if __name__ == "__main__":
    main()
