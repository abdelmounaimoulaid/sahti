"""Import Moroccan products from the Open Food Facts CSV export.

Download (≈1.5 GB): https://static.openfoodfacts.org/data/en.openfoodfacts.org.products.csv.gz
into data/off_export/products.csv.gz, then run:
    python scripts/import_off_csv.py data/off_export/products.csv.gz
Streams the gzip (no unzip needed), keeps rows whose countries_tags contain
en:morocco, and upserts them with the same rules as import_off.py.
"""
import csv
import gzip
import sys

from import_off import UPSERT, db, row_from

csv.field_size_limit(10**9)
BATCH = 500


def to_off_dict(r: dict) -> dict:
    nutriments = {k[:-5] + "_100g": v for k, v in ((k, r[k]) for k in r if k.endswith("_100g")) if v not in ("", None)}
    nutriments = {k: float(v) if _is_num(v) else v for k, v in nutriments.items()}
    return {
        "code": r.get("code"),
        "product_name": r.get("product_name"),
        "brands": r.get("brands"),
        "quantity": r.get("quantity"),
        "categories": r.get("categories"),
        "countries": r.get("countries"),
        "ingredients_text": r.get("ingredients_text"),
        "lang": r.get("lang") or None,
        "additives_tags": [t for t in (r.get("additives_tags") or "").split(",") if t],
        "additives_n": int(float(r["additives_n"])) if _is_num(r.get("additives_n")) else None,
        "allergens_tags": [t for t in (r.get("allergens") or "").split(",") if t],
        "nutriscore_grade": r.get("nutriscore_grade"),
        "nova_group": int(float(r["nova_group"])) if _is_num(r.get("nova_group")) else None,
        "nutriments": nutriments,
        "image_front_url": r.get("image_url"),
        "last_modified_t": int(r["last_modified_t"]) if (r.get("last_modified_t") or "").isdigit() else None,
    }


def _is_num(v) -> bool:
    try:
        float(v)
        return True
    except (TypeError, ValueError):
        return False


def main():
    path = sys.argv[1]
    conn = db()
    rows, kept, scanned = [], 0, 0
    with gzip.open(path, "rt", encoding="utf-8", newline="") as f:
        reader = csv.DictReader(f, delimiter="\t", quoting=csv.QUOTE_NONE)
        for r in reader:
            scanned += 1
            if "en:morocco" not in (r.get("countries_tags") or ""):
                continue
            row = row_from(to_off_dict(r))
            if not row:
                continue
            rows.append(row)
            if len(rows) >= BATCH:
                with conn.cursor() as cur:
                    cur.executemany(UPSERT, rows)
                conn.commit()
                kept += len(rows)
                rows = []
                print(f"  {kept} produits marocains ({scanned} lignes lues)", flush=True)
    if rows:
        with conn.cursor() as cur:
            cur.executemany(UPSERT, rows)
        conn.commit()
        kept += len(rows)
    with conn.cursor() as cur:
        cur.execute("SELECT status, COUNT(*) FROM products GROUP BY status")
        counts = cur.fetchall()
    conn.close()
    print(f"Terminé : {kept} produits marocains sur {scanned} lignes.")
    for status, n in counts:
        print(f"{status}: {n}")


if __name__ == "__main__":
    main()
