"""Print candidates with full sibling details (ingredients, additives, allergens). Usage: show_leads.py START END"""
import json, sys
from pathlib import Path
import pymysql
from dotenv import dotenv_values
ROOT = Path(__file__).resolve().parent.parent
e = dotenv_values(ROOT / ".env")
conn = pymysql.connect(host="localhost", user=e["DB_USER"], password=e["DB_PASSWORD"], database=e["DB_NAME"], charset="utf8mb4", cursorclass=pymysql.cursors.DictCursor)
batch = json.loads((ROOT / "data" / "batch.json").read_text(encoding="utf-8"))
a, b = int(sys.argv[1]), int(sys.argv[2])
with conn.cursor() as cur:
    for i in range(a, min(b, len(batch))):
        p = batch[i]
        print(f"\n#{i} {p['barcode']} | {p['name']} | {p['brand']} | {p['quantity']} | cat: {(p['categories'] or '')[:80]}")
        for s in p["siblings"]:
            cur.execute("SELECT barcode,name,quantity,ingredients_text,additives,allergens,countries FROM products WHERE barcode=%s", (s["barcode"],))
            r = cur.fetchone()
            print(f"   ~ {r['barcode']} | {r['name']} | {r['quantity']} | ctry: {r['countries']}\n     ING: {r['ingredients_text']}\n     ADD: {r['additives']} | ALL: {r['allergens']}")
