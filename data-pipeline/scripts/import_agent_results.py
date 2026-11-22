"""Load agent transcription results (data/agent_results/chunk_N.json) into the database.

Each found item becomes 'ai_to_verify' with a packaging_photo source (confidence high).
Skips barcodes that already have an enrichment run. Usage: import_agent_results.py chunk_1.json [...]
"""
import json
import os
import sys
from datetime import datetime
from pathlib import Path

import pymysql
from dotenv import dotenv_values

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / "scripts"))
from save_enrichment import ALLOWED_FIELDS  # noqa: E402,F401


def main():
    photos = {x["barcode"]: x["photo"] for x in json.loads((ROOT / "data" / "ingredient_photos.json").read_text(encoding="utf-8"))}
    e = dotenv_values(ROOT / ".env")
    conn = pymysql.connect(host="localhost", user=e["DB_USER"], password=e["DB_PASSWORD"], database=e["DB_NAME"], charset="utf8mb4")
    stats = {"found": 0, "not_found": 0, "skipped": 0}
    with conn.cursor() as cur:
        for name in sys.argv[1:]:
            path = ROOT / "data" / "agent_results" / name
            items = json.loads(path.read_text(encoding="utf-8"))
            t_end = datetime.fromtimestamp(os.path.getmtime(path))
            t_start = datetime.fromtimestamp(os.path.getmtime(ROOT / "data" / "chunks" / name))
            step = (t_end - t_start) / max(len(items), 1)
            for i, it in enumerate(items):
                cur.execute("SELECT p.id, (SELECT COUNT(*) FROM enrichment_runs r WHERE r.product_id=p.id) FROM products p WHERE barcode=%s", (it["barcode"],))
                row = cur.fetchone()
                if not row or row[1]:
                    stats["skipped"] += 1
                    continue
                pid = row[0]
                a, b = t_start + step * i, t_start + step * (i + 1)
                found = it.get("outcome") == "found" and (it.get("ingredients_text") or "").strip()
                outcome = "found" if found else "not_found"
                note = ("Lu sur la photo de l'étiquette (Open Food Facts). " if found else "") + (it.get("note") or "")
                cur.execute("INSERT INTO enrichment_runs (product_id, started_at, finished_at, duration_sec, outcome, notes) VALUES (%s,%s,%s,%s,%s,%s)",
                            (pid, a, b, int((b - a).total_seconds()), outcome, note.strip() or None))
                if found:
                    url = photos.get(it["barcode"], "")
                    ing, add, allg = it["ingredients_text"].strip(), (it.get("additives") or "").strip() or None, (it.get("allergens") or "").strip() or None
                    cur.execute("INSERT INTO product_sources (product_id, field, value, source_url, source_type, source_country, confidence, notes) VALUES (%s,'ingredients_text',%s,%s,'packaging_photo','MA','high',%s)",
                                (pid, ing, url, it.get("note") or None))
                    if add:
                        cur.execute("INSERT INTO product_sources (product_id, field, value, source_url, source_type, source_country, confidence, notes) VALUES (%s,'additives',%s,%s,'packaging_photo','MA','high','Relevés sur l''étiquette.')",
                                    (pid, add, url))
                    cur.execute("UPDATE products SET ingredients_text=%s, additives=%s, allergens=%s, status='ai_to_verify' WHERE id=%s", (ing, add, allg, pid))
                stats[outcome] += 1
    conn.commit()
    conn.close()
    print(stats)


if __name__ == "__main__":
    main()
