"""Save web-research results for products into the database.

Input: a JSON file with a list of results, e.g.
[
  {
    "barcode": "6111234567890",
    "outcome": "found" | "partial" | "not_found" | "rejected_foreign",
    "started_at": "2026-11-15 12:30:00", "finished_at": "2026-11-15 12:32:10",
    "notes": "pitfalls...",
    "fields": {"ingredients_text": "...", "additives": "en:e330", "allergens": "en:milk"},
    "sources": [
      {"field": "ingredients_text", "value": "...", "source_url": "https://...",
       "source_type": "moroccan_retailer", "source_country": "MA",
       "confidence": "high", "notes": "..."}
    ]
  }
]
Products with outcome found/partial get status 'ai_to_verify' and the found fields.
Usage: python scripts/save_enrichment.py data/results_xxx.json
"""
import json
import sys
from datetime import datetime
from pathlib import Path

import pymysql
from dotenv import dotenv_values

ROOT = Path(__file__).resolve().parent.parent
ALLOWED_FIELDS = {"name", "brand", "ingredients_text", "additives", "allergens"}


def main():
    results = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
    e = dotenv_values(ROOT / ".env")
    conn = pymysql.connect(host=e.get("DB_HOST") or "localhost", port=int(e.get("DB_PORT") or 3306),
                           user=e["DB_USER"], password=e["DB_PASSWORD"], database=e["DB_NAME"],
                           charset="utf8mb4", autocommit=False)
    saved = 0
    with conn.cursor() as cur:
        for r in results:
            cur.execute("SELECT id FROM products WHERE barcode = %s", (r["barcode"],))
            row = cur.fetchone()
            if not row:
                print(f"  inconnu: {r['barcode']}")
                continue
            pid = row[0]
            started = datetime.fromisoformat(r["started_at"])
            finished = datetime.fromisoformat(r["finished_at"])
            cur.execute(
                "INSERT INTO enrichment_runs (product_id, started_at, finished_at, duration_sec, outcome, notes) "
                "VALUES (%s,%s,%s,%s,%s,%s)",
                (pid, started, finished, int((finished - started).total_seconds()), r["outcome"], r.get("notes")),
            )
            for s in r.get("sources", []):
                cur.execute(
                    "INSERT INTO product_sources (product_id, field, value, source_url, source_type, source_country, confidence, notes) "
                    "VALUES (%s,%s,%s,%s,%s,%s,%s,%s)",
                    (pid, s["field"], s["value"], s["source_url"], s.get("source_type", "other"),
                     s.get("source_country"), s.get("confidence", "low"), s.get("notes")),
                )
            fields = {k: v for k, v in (r.get("fields") or {}).items() if k in ALLOWED_FIELDS}
            if r["outcome"] in ("found", "partial") and fields:
                sets = ", ".join(f"{k} = %s" for k in fields)
                cur.execute(f"UPDATE products SET {sets}, status = 'ai_to_verify' WHERE id = %s",
                            (*fields.values(), pid))
            saved += 1
    conn.commit()
    conn.close()
    print(f"{saved} résultats enregistrés")


if __name__ == "__main__":
    main()
