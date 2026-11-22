"""Automatic enrichment: fill incomplete products from complete Moroccan products
that are the SAME product under another barcode (other format, pack, re-listing).

Rules (strict on purpose, everything goes to 'ai_to_verify' for human review):
- same brand (normalized) AND same product name once brand words, units,
  quantities and filler words are removed (exact word-set match, >= 2 words left, so vague names like "Chocolat" are skipped);
- same manufacturer: identical GS1 company prefix (first 7 digits of the barcode);
- the reference must have a full ingredient list (>= 3 ingredients, readable text);
- if several references match with different lists, the product is skipped (conflict);
- light / 0% / sans sucre / bio words are kept in the name, so variants never mix.
Usage: python scripts/auto_match.py [--dry-run]
"""
import json
import re
import sys
import unicodedata
from datetime import datetime
from pathlib import Path

import pymysql
from dotenv import dotenv_values

ROOT = Path(__file__).resolve().parent.parent
STOP = {
    "de", "du", "des", "la", "le", "les", "l", "d", "au", "aux", "a", "et", "en", "the", "of", "with",
    "pack", "x", "g", "gr", "kg", "ml", "cl", "l", "lt", "litre", "litres", "pcs", "pieces", "piece",
    "format", "mini", "maxi", "sachet", "boite", "bouteille", "pot", "pots", "pet", "can", "canette",
    "promo", "offre", "family", "familial", "new", "nouveau", "nouvelle",
}
ARABIC = re.compile(r"[؀-ۿ]")


def strip_accents(s: str) -> str:
    return "".join(c for c in unicodedata.normalize("NFD", s) if unicodedata.category(c) != "Mn")


def norm_brand(b: str) -> str:
    return strip_accents((b or "").split(",")[0].strip().lower())


def name_key(name: str, brand: str) -> frozenset:
    s = strip_accents((name or "").lower())
    brand_words = set(re.findall(r"[a-z]+", strip_accents((brand or "").lower())))
    words = re.findall(r"[a-z]+|[؀-ۿ]+|\d+%", s)
    keep = [w for w in words if w not in STOP and w not in brand_words and len(w) > 1]
    return frozenset(keep)


def good_ingredients(text: str) -> bool:
    if not text or len(text) < 25 or len(text) > 2500:
        return False
    parts = [p for p in re.split(r"[,،;]", text) if p.strip()]
    if len(parts) < 3:
        return False
    if re.search(r"\baqua\b|laureth|cocamidopropyl|parfum", text.lower()):
        return False  # cosmetics listed in OFF by mistake
    letters = sum(c.isalpha() for c in text)
    return letters / len(text) > 0.6


def main():
    dry = "--dry-run" in sys.argv
    e = dotenv_values(ROOT / ".env")
    conn = pymysql.connect(host=e.get("DB_HOST") or "localhost", port=int(e.get("DB_PORT") or 3306),
                           user=e["DB_USER"], password=e["DB_PASSWORD"], database=e["DB_NAME"],
                           charset="utf8mb4", cursorclass=pymysql.cursors.DictCursor)
    t_start = datetime.now()
    with conn.cursor() as cur:
        cur.execute("""SELECT p.id, p.barcode, p.name, p.brand FROM products p
                       LEFT JOIN enrichment_runs r ON r.product_id = p.id
                       WHERE p.status = 'incomplete' AND r.id IS NULL
                         AND p.missing_fields LIKE '%%ingredients%%'
                         AND p.name IS NOT NULL AND p.brand IS NOT NULL""")
        cands = cur.fetchall()
        cur.execute("""SELECT barcode, name, brand, ingredients_text, additives, allergens FROM products
                       WHERE status IN ('complete','validated') AND ingredients_text IS NOT NULL
                         AND name IS NOT NULL AND brand IS NOT NULL""")
        refs = cur.fetchall()

    index = {}
    for r in refs:
        if not good_ingredients(r["ingredients_text"]):
            continue
        k = (norm_brand(r["brand"]), name_key(r["name"], r["brand"]), r["barcode"][:7])
        if len(k[1]) < 2:
            continue
        index.setdefault(k, []).append(r)

    results, conflicts = [], 0
    for c in cands:
        k = (norm_brand(c["brand"]), name_key(c["name"], c["brand"]), c["barcode"][:7])
        if not k[1] or k not in index:
            continue
        matches = [m for m in index[k] if m["barcode"] != c["barcode"]]
        if not matches:
            continue
        texts = {re.sub(r"\W+", "", m["ingredients_text"].lower())[:80] for m in matches}
        if len(texts) > 1:
            conflicts += 1
            continue
        m = matches[0]
        url = "https://world.openfoodfacts.org/product/" + m["barcode"]
        src = dict(source_url=url, source_type="open_food_facts",
                   source_country="MA" if m["barcode"].startswith("611") else None,
                   confidence="medium" if m["barcode"].startswith("611") else "low")
        note = f"Rapprochement automatique : même marque, même nom, même fabricant (préfixe {m['barcode'][:7]}). Fiche source : {m['name']} ({m['barcode']})."
        if len(matches) > 1:
            note += f" {len(matches)} fiches concordantes."
        sources = [dict(field="ingredients_text", value=m["ingredients_text"], notes=note, **src)]
        if m["additives"]:
            sources.append(dict(field="additives", value=m["additives"], notes="Additifs de la fiche source.", **src))
        results.append({
            "barcode": c["barcode"], "outcome": "found", "notes": note,
            "fields": {"ingredients_text": m["ingredients_text"], "additives": m["additives"], "allergens": m["allergens"]},
            "sources": sources,
        })

    t_end = datetime.now()
    per = (t_end - t_start) / max(len(results), 1)
    for i, r in enumerate(results):
        r["started_at"] = (t_start + per * i).isoformat(sep=" ", timespec="seconds")
        r["finished_at"] = (t_start + per * (i + 1)).isoformat(sep=" ", timespec="seconds")
    out = ROOT / "data" / "results_auto_match.json"
    out.write_text(json.dumps(results, ensure_ascii=False, indent=1), encoding="utf-8")
    print(f"Candidats : {len(cands)} ; références utilisables : {sum(len(v) for v in index.values())}")
    print(f"Trouvés : {len(results)} ; conflits ignorés : {conflicts} ; temps : {(t_end - t_start).total_seconds():.1f}s -> {out}")
    if dry:
        for r in results[:25]:
            print(" ", r["barcode"], "|", r["notes"][:150])


if __name__ == "__main__":
    main()
