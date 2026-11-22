"""Import Moroccan products from Open Food Facts into the `products` table.

Uses the OFF search API (countries = Morocco), pages of 100, ~7s between calls
to stay under OFF's search rate limit. Raw pages are cached in data/off_pages/.
Re-running is safe: products are upserted by barcode, and rows already
'ai_to_verify' or 'validated' keep their status and enriched fields.
"""
import json
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

import pymysql
import requests
from dotenv import dotenv_values

ROOT = Path(__file__).resolve().parent.parent
CACHE = ROOT / "data" / "off_pages"
API = "https://world.openfoodfacts.org/api/v2/search"
PAGE_SIZE = 100
FIELDS = ",".join([
    "code", "product_name", "product_name_fr", "brands", "quantity", "categories",
    "countries", "ingredients_text", "ingredients_text_fr", "ingredients_text_ar",
    "lang", "additives_tags", "additives_n", "allergens_tags", "nutriscore_grade",
    "nova_group", "nutriments", "image_front_url", "last_modified_t",
])
HEADERS = {"User-Agent": "SahtiDataImport/0.1 (local test)"}


def db():
    env = dotenv_values(ROOT / ".env")
    return pymysql.connect(
        host=env.get("DB_HOST") or "localhost", port=int(env.get("DB_PORT") or 3306),
        user=env["DB_USER"], password=env["DB_PASSWORD"], database=env["DB_NAME"],
        charset="utf8mb4", autocommit=False,
    )


def fetch_page(page: int) -> dict:
    CACHE.mkdir(parents=True, exist_ok=True)
    cached = CACHE / f"page_{page:03d}.json"
    if cached.exists():
        return json.loads(cached.read_text(encoding="utf-8"))
    params = {"countries_tags_en": "morocco", "fields": FIELDS, "page_size": PAGE_SIZE, "page": page, "sort_by": "created_t"}
    for attempt in range(5):
        try:
            r = requests.get(API, params=params, headers=HEADERS, timeout=120)
            if r.status_code == 429 or r.status_code >= 500:
                raise requests.HTTPError(f"HTTP {r.status_code}")
            r.raise_for_status()
            data = r.json()
            cached.write_text(json.dumps(data, ensure_ascii=False), encoding="utf-8")
            time.sleep(7)
            return data
        except (requests.RequestException, ValueError) as e:
            wait = 15 * (attempt + 1)
            print(f"  page {page}: {e}, retry in {wait}s", flush=True)
            time.sleep(wait)
    raise SystemExit(f"Page {page} failed after retries")


def clean(s):
    if s is None:
        return None
    s = str(s).strip()
    return s or None


def row_from(p: dict):
    code = clean(p.get("code"))
    if not code or len(code) > 32:
        return None
    ingredients = clean(p.get("ingredients_text_fr")) or clean(p.get("ingredients_text")) or clean(p.get("ingredients_text_ar"))
    lang = "fr" if clean(p.get("ingredients_text_fr")) else (clean(p.get("lang")) if ingredients else None)
    additives = p.get("additives_tags") or []
    # additives_n present (even 0) means OFF analysed the ingredient list.
    additives_known = bool(additives) or (p.get("additives_n") is not None and ingredients is not None)
    missing = []
    if not ingredients:
        missing.append("ingredients")
    if not additives_known:
        missing.append("additives")
    name = clean(p.get("product_name_fr")) or clean(p.get("product_name"))
    if not name:
        missing.append("name")
    nova = p.get("nova_group")
    lm = p.get("last_modified_t")
    return {
        "barcode": code,
        "name": name[:255] if name else None,
        "brand": (clean(p.get("brands")) or "")[:255] or None,
        "quantity": (clean(p.get("quantity")) or "")[:100] or None,
        "categories": clean(p.get("categories")),
        "countries": clean(p.get("countries")),
        "ingredients_text": ingredients,
        "ingredients_lang": (lang or "")[:10] or None,
        "additives": ",".join(additives) if additives else None,
        "allergens": ",".join(p.get("allergens_tags") or []) or None,
        "nutriscore_grade": p.get("nutriscore_grade") if p.get("nutriscore_grade") in ("a", "b", "c", "d", "e") else None,
        "nova_group": int(nova) if isinstance(nova, (int, float)) or (isinstance(nova, str) and nova.isdigit()) else None,
        "nutriments": json.dumps(p.get("nutriments") or {}, ensure_ascii=False),
        "image_url": (clean(p.get("image_front_url")) or "")[:500] or None,
        "status": "complete" if not missing else "incomplete",
        "missing_fields": ",".join(missing) or None,
        "off_last_modified": datetime.fromtimestamp(lm, tz=timezone.utc).strftime("%Y-%m-%d %H:%M:%S") if isinstance(lm, (int, float)) else None,
    }


UPSERT = """
INSERT INTO products (barcode, name, brand, quantity, categories, countries, ingredients_text,
  ingredients_lang, additives, allergens, nutriscore_grade, nova_group, nutriments, image_url,
  status, missing_fields, off_last_modified)
VALUES (%(barcode)s, %(name)s, %(brand)s, %(quantity)s, %(categories)s, %(countries)s, %(ingredients_text)s,
  %(ingredients_lang)s, %(additives)s, %(allergens)s, %(nutriscore_grade)s, %(nova_group)s, %(nutriments)s, %(image_url)s,
  %(status)s, %(missing_fields)s, %(off_last_modified)s)
ON DUPLICATE KEY UPDATE
  name = IF(status IN ('ai_to_verify','validated'), name, VALUES(name)),
  brand = IF(status IN ('ai_to_verify','validated'), brand, VALUES(brand)),
  quantity = VALUES(quantity), categories = VALUES(categories), countries = VALUES(countries),
  ingredients_text = IF(status IN ('ai_to_verify','validated'), ingredients_text, VALUES(ingredients_text)),
  ingredients_lang = IF(status IN ('ai_to_verify','validated'), ingredients_lang, VALUES(ingredients_lang)),
  additives = IF(status IN ('ai_to_verify','validated'), additives, VALUES(additives)),
  allergens = IF(status IN ('ai_to_verify','validated'), allergens, VALUES(allergens)),
  nutriscore_grade = VALUES(nutriscore_grade), nova_group = VALUES(nova_group),
  nutriments = VALUES(nutriments), image_url = VALUES(image_url),
  missing_fields = IF(status IN ('ai_to_verify','validated'), missing_fields, VALUES(missing_fields)),
  off_last_modified = VALUES(off_last_modified),
  status = IF(status IN ('ai_to_verify','validated'), status, VALUES(status))
"""


def main():
    max_pages = int(sys.argv[1]) if len(sys.argv) > 1 else 10_000
    conn = db()
    first = fetch_page(1)
    total = int(first.get("count") or 0)
    pages = min(max_pages, (total + PAGE_SIZE - 1) // PAGE_SIZE)
    print(f"OFF Maroc: {total} produits, {pages} pages", flush=True)
    seen = 0
    for page in range(1, pages + 1):
        data = first if page == 1 else fetch_page(page)
        rows = [r for r in (row_from(p) for p in data.get("products", [])) if r]
        with conn.cursor() as cur:
            cur.executemany(UPSERT, rows)
        conn.commit()
        seen += len(rows)
        print(f"  page {page}/{pages}: {len(rows)} produits (total {seen})", flush=True)
    with conn.cursor() as cur:
        cur.execute("SELECT status, COUNT(*) FROM products GROUP BY status")
        for status, n in cur.fetchall():
            print(f"{status}: {n}")
    conn.close()


if __name__ == "__main__":
    main()
