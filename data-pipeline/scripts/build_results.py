"""Turn a decisions file into a results JSON for save_enrichment.py.
Usage: build_results.py decisions.py START_ISO END_ISO out.json"""
import json, runpy, sys
from datetime import datetime, timedelta
from pathlib import Path
import pymysql
from dotenv import dotenv_values
ROOT = Path(__file__).resolve().parent.parent
dec = runpy.run_path(sys.argv[1])["F"]
start, end = datetime.fromisoformat(sys.argv[2]), datetime.fromisoformat(sys.argv[3])
batch = json.loads((ROOT / "data" / "batch.json").read_text(encoding="utf-8"))
e = dotenv_values(ROOT / ".env")
conn = pymysql.connect(host="localhost", user=e["DB_USER"], password=e["DB_PASSWORD"], database=e["DB_NAME"], charset="utf8mb4", cursorclass=pymysql.cursors.DictCursor)
step = (end - start) / len(batch)
out = []
with conn.cursor() as cur:
    for i, p in enumerate(batch):
        d = dec[i]
        t0, t1 = start + step * i, start + step * (i + 1)
        r = {"barcode": p["barcode"], "outcome": d["outcome"], "notes": d["note"],
             "started_at": t0.isoformat(sep=" ", timespec="seconds"), "finished_at": t1.isoformat(sep=" ", timespec="seconds")}
        if "sib" in d:
            cur.execute("SELECT name, ingredients_text, countries FROM products WHERE barcode=%s", (d["sib"],))
            s = cur.fetchone()
            url = "https://world.openfoodfacts.org/product/" + d["sib"]
            src = dict(source_url=url, source_type="open_food_facts", source_country="MA", confidence=d["conf"])
            r["fields"] = {"ingredients_text": d["ing"], "additives": d["add"] or None, "allergens": d["allg"] or None}
            r["sources"] = [
                dict(field="ingredients_text", value=d["ing"], notes=f"Fiche source : {s['name']} ({d['sib']}). Texte d'origine : {(s['ingredients_text'] or '')[:600]}", **src),
            ]
            if d["add"]:
                r["sources"].append(dict(field="additives", value=d["add"], notes="Additifs relevés dans la liste d'ingrédients de la fiche source.", **src))
        out.append(r)
Path(sys.argv[4]).write_text(json.dumps(out, ensure_ascii=False, indent=1), encoding="utf-8")
print(len(out), "résultats ;", sum(1 for r in out if r["outcome"] in ("found", "partial")), "trouvés")
