"""Fill missing name / brand / quantity / categories from Open Food Facts (all languages).

For products whose name is empty or just the barcode, fetch the full OFF product
and take the first non-empty name among fr, ar, en, es, de, it, generic names.
Only empty columns are filled; nothing existing is overwritten. ~95 requests/min
(OFF limit is 100/min). Safe to stop and restart: progress in data/fill_names_done.txt.
Usage: python scripts/fill_names_off.py
"""
import re
import time
from pathlib import Path

import pymysql
import requests
from dotenv import dotenv_values

ROOT = Path(__file__).resolve().parent.parent
DONE = ROOT / "data" / "fill_names_done.txt"
H = {"User-Agent": "SahtiDataImport/0.1 (local test)"}
LANGS = ["fr", "ar", "en", "es", "de", "it", "nl", "pt"]


def pick_name(p, barcode):
    keys = ["product_name_" + l for l in LANGS] + ["product_name"] + ["generic_name_" + l for l in LANGS] + ["generic_name", "abbreviated_product_name"]
    for k in keys:
        v = (p.get(k) or "").strip()
        if v and v != barcode and not re.fullmatch(r"\d{6,}", v):
            return v[:255]
    return None


def main():
    e = dotenv_values(ROOT / ".env")
    conn = pymysql.connect(host="localhost", user=e["DB_USER"], password=e["DB_PASSWORD"], database=e["DB_NAME"], charset="utf8mb4", autocommit=True)
    done = set(DONE.read_text().split()) if DONE.exists() else set()
    with conn.cursor() as cur:
        cur.execute("SELECT id, barcode, brand, quantity, categories FROM products WHERE name IS NULL OR name REGEXP '^[0-9]+$'")
        todo = [r for r in cur.fetchall() if r[1] not in done]
    print(f"{len(todo)} produits à chercher", flush=True)
    filled = 0
    with conn.cursor() as cur, DONE.open("a") as log:
        for i, (pid, bc, brand, qty, cats) in enumerate(todo, 1):
            for attempt in range(4):
                try:
                    r = requests.get(f"https://world.openfoodfacts.org/api/v2/product/{bc}.json", headers=H, timeout=30)
                    if r.status_code in (429, 503):
                        raise requests.HTTPError(str(r.status_code))
                    p = (r.json() or {}).get("product") or {}
                    break
                except Exception:
                    time.sleep(10 * (attempt + 1))
                    p = None
            if p:
                name = pick_name(p, bc)
                upd = {}
                if name:
                    upd["name"] = name
                if not brand and (p.get("brands") or "").strip():
                    upd["brand"] = p["brands"].strip()[:255]
                if not qty and (p.get("quantity") or "").strip():
                    upd["quantity"] = p["quantity"].strip()[:100]
                if not cats and (p.get("categories") or "").strip():
                    upd["categories"] = p["categories"].strip()
                if upd:
                    sets = ", ".join(f"{k}=%s" for k in upd)
                    cur.execute(f"UPDATE products SET {sets} WHERE id=%s", (*upd.values(), pid))
                    if name:
                        cur.execute("UPDATE products SET missing_fields = NULLIF(TRIM(BOTH ',' FROM REPLACE(CONCAT(',', missing_fields, ','), ',name,', ',')), '') WHERE id=%s", (pid,))
                        filled += 1
            log.write(bc + "\n")
            if i % 200 == 0:
                log.flush()
                print(f"  {i}/{len(todo)} traités, {filled} noms trouvés", flush=True)
            time.sleep(0.63)
    print(f"Terminé : {filled} noms trouvés sur {len(todo)}", flush=True)


if __name__ == "__main__":
    main()
