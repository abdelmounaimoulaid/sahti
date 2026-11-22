"""Add E-numbers for additives written by name in ingredient lists (e.g. "benzoate de sodium" -> en:e211).

Applies only to products in 'ai_to_verify' (still reviewed by a human). Keeps existing tags.
Usage: python scripts/fill_additives_from_names.py
"""
import re
from pathlib import Path

import pymysql
from dotenv import dotenv_values

ROOT = Path(__file__).resolve().parent.parent
NAMES = {
    r"acide citrique|citric acid": "e330", r"acide ascorbique|vitamine c\b|ascorbic acid": "e300",
    r"acide lactique|lactic acid": "e270", r"acide malique": "e296", r"acide tartrique": "e334",
    r"acide phosphorique|phosphoric acid": "e338", r"acide sorbique|sorbic acid": "e200",
    r"sorbate de potassium|potassium sorbate": "e202", r"benzoate de sodium|sodium benzoate": "e211",
    r"propionate de calcium|calcium propionate": "e282", r"propionate de sodium": "e281",
    r"citrates? de sodium|sodium citrate": "e331", r"citrates? de potassium": "e332",
    r"l[ée]cithine de soja|soya? lecithin|l[ée]cithine de tournesol|l[ée]cithines?\b": "e322",
    r"mono- ?et diglyc[ée]rides|mono and diglycerides": "e471",
    r"gomme (de )?xanthane|xanthan gum": "e415", r"gomme de guar|guar gum": "e412",
    r"gomme arabique|gum arabic|acacia gum": "e414", r"carragh[ée]nanes?|carrageenan": "e407",
    r"pectine|pectin": "e440", r"agar": "e406", r"carboxym[ée]thylcellulose|\bcmc\b": "e466",
    r"bicarbonate de sodium|sodium bicarbonate": "e500", r"bicarbonate d'ammonium|ammonium bicarbonate": "e503",
    r"bicarbonate de potassium": "e501", r"pyrophosphate acide de sodium|diphosphates?": "e450",
    r"carbonate de calcium|calcium carbonate": "e170", r"glyc[ée]rine|glyc[ée]rol|glycerin": "e422",
    r"sorbitol": "e420", r"maltitol": "e965", r"aspartame": "e951", r"ac[ée]sulfame": "e950",
    r"sucralose": "e955", r"glycosides de st[ée]viol|steviol": "e960", r"saccharine": "e954",
    r"glutamate monosodique|monosodium glutamate": "e621", r"caramel au sulfite d'ammonium": "e150d",
    r"tartrazine": "e102", r"jaune orang[ée] s|sunset yellow": "e110", r"rouge allura|allura red": "e129",
    r"carmin|cochenille|carmine": "e120", r"dioxyde de titane|titanium dioxide": "e171",
    r"b[ée]ta-?carot[èe]ne": "e160a", r"nitrite de sodium|sodium nitrite": "e250",
    r"m[ée]tabisulfite de sodium|sodium metabisulphite": "e223", r"dioxyde de silicium|silicon dioxide": "e551",
    r"cur?cumine": "e100", r"chlorure de calcium": "e509", r"chlorure de potassium": "e508",
}


def main():
    e = dotenv_values(ROOT / ".env")
    conn = pymysql.connect(host="localhost", user=e["DB_USER"], password=e["DB_PASSWORD"], database=e["DB_NAME"], charset="utf8mb4")
    changed = 0
    with conn.cursor() as cur:
        cur.execute("SELECT id, ingredients_text, additives FROM products WHERE status='ai_to_verify' AND ingredients_text IS NOT NULL")
        for pid, text, adds in cur.fetchall():
            low = text.lower()
            tags = [t for t in (adds or "").split(",") if t]
            have = {t.split(":")[-1] for t in tags}
            for code in re.findall(r"\be ?(\d{3,4}[a-z]?)", low):
                if "e" + code not in have:
                    tags.append("en:e" + code); have.add("e" + code)
            for pat, code in NAMES.items():
                if code not in have and re.search(pat, low):
                    tags.append("en:" + code); have.add(code)
            new = ",".join(tags) or None
            if new != (adds or None):
                cur.execute("UPDATE products SET additives=%s WHERE id=%s", (new, pid))
                changed += 1
    conn.commit()
    conn.close()
    print(f"{changed} fiches : additifs complétés")


if __name__ == "__main__":
    main()
