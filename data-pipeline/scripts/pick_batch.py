"""Pick N incomplete products to enrich via web research -> data/batch.json.

Priority: Moroccan barcode (611...), missing ingredients, with name and brand,
from brands that are frequent in the base (better documented online), at most
3 products per brand for variety. For each, lists 'siblings': complete products
of the same brand in the base, as leads to check (same recipe, other format).
Usage: python scripts/pick_batch.py 100
"""
import json
import re
import sys
from pathlib import Path

import pymysql
from dotenv import dotenv_values

ROOT = Path(__file__).resolve().parent.parent


def norm_brand(b):
    return re.sub(r"\s+", " ", (b or "").split(",")[0].strip().lower())


def words(s):
    return {w for w in re.findall(r"[a-zà-ÿ]{3,}", (s or "").lower())}


def main():
    n = int(sys.argv[1]) if len(sys.argv) > 1 else 100
    e = dotenv_values(ROOT / ".env")
    conn = pymysql.connect(host=e.get("DB_HOST") or "localhost", port=int(e.get("DB_PORT") or 3306),
                           user=e["DB_USER"], password=e["DB_PASSWORD"], database=e["DB_NAME"],
                           charset="utf8mb4", cursorclass=pymysql.cursors.DictCursor)
    with conn.cursor() as cur:
        cur.execute("""
            SELECT p.id, p.barcode, p.name, p.brand, p.quantity, p.categories, p.missing_fields
            FROM products p LEFT JOIN enrichment_runs r ON r.product_id = p.id
            WHERE p.status = 'incomplete' AND r.id IS NULL AND p.barcode LIKE '611%%'
              AND p.name IS NOT NULL AND p.brand IS NOT NULL AND p.name NOT REGEXP '^[0-9]+$'
              AND p.missing_fields LIKE '%%ingredients%%'
        """)
        cands = cur.fetchall()
        cur.execute("SELECT barcode, name, brand, ingredients_text FROM products WHERE status IN ('complete','validated') AND ingredients_text IS NOT NULL")
        complete = cur.fetchall()
    conn.close()

    brand_count = {}
    for c in cands:
        brand_count[norm_brand(c["brand"])] = brand_count.get(norm_brand(c["brand"]), 0) + 1
    by_brand = {}
    for c in complete:
        by_brand.setdefault(norm_brand(c["brand"]), []).append(c)

    cands.sort(key=lambda c: (-brand_count[norm_brand(c["brand"])], c["id"]))
    picked, per_brand = [], {}
    for c in cands:
        b = norm_brand(c["brand"])
        if per_brand.get(b, 0) >= 3:
            continue
        per_brand[b] = per_brand.get(b, 0) + 1
        w = words(c["name"])
        sib = sorted(by_brand.get(b, []), key=lambda s: -len(w & words(s["name"])))
        c["siblings"] = [{"barcode": s["barcode"], "name": s["name"], "ingredients": s["ingredients_text"][:300]}
                         for s in sib[:3] if w & words(s["name"])]
        picked.append(c)
        if len(picked) >= n:
            break
    out = ROOT / "data" / "batch.json"
    out.write_text(json.dumps(picked, ensure_ascii=False, indent=1), encoding="utf-8")
    print(f"{len(picked)} produits, {len(per_brand)} marques, {sum(1 for p in picked if p['siblings'])} avec piste interne -> {out}")


if __name__ == "__main__":
    main()
