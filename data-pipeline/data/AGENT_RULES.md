# Rules for transcribing ingredient photos (Sahti)

Goal: for each product in your chunk file, read the Open Food Facts "ingredients" photo of the real Moroccan packaging and write down the FULL ingredient list.

## Steps for each product
1. Download the photo with Python `requests` into `C:\Users\PC\Desktop\sahti-data\data\photos\<barcode>.jpg`. Use the header `User-Agent: SahtiDataImport/0.1 (local test)`. If `.full.jpg` fails or is over 3 MB, use the same URL with `.400.jpg`. Wait 0.3 s between downloads.
2. Open the image with the Read tool and read it.
3. Decide:
   - **found**: the photo shows an ingredient list that you can read in full. Write it in FRENCH. Translate from Arabic or English if the label is only in that language, and say so in `note`. Keep percentages, E-numbers, "Contient…" and "Peut contenir…".
   - **not_found**: the photo shows something else (nutrition table, front of the pack, blurry or cut text). Give the reason in `note`.
   - Never guess or complete a list from memory. Never use a recipe from another country. If part of the list is unreadable, use not_found.
   - A one-ingredient product (milk, water, sugar…) is fine if the label itself says so.
   - If the photo shows a different product than the name (another flavour or variant), say so in `note`.
4. `additives`: the E-numbers in the list, as `en:e330,en:e211` (lowercase; colours, preservatives, emulsifiers, etc.). Empty string if none.
5. `allergens`: from this set only: en:gluten, en:milk, en:eggs, en:nuts, en:peanuts, en:soybeans, en:fish, en:crustaceans, en:molluscs, en:celery, en:mustard, en:sesame-seeds, en:sulphur-dioxide-and-sulphites, en:lupin. Only allergens actually in the ingredients, not the "peut contenir" traces.

## Output
Write ONE JSON file `C:\Users\PC\Desktop\sahti-data\data\agent_results\chunk_<N>.json`: a list with one object per product, in chunk order:
```json
{"barcode": "6111…", "outcome": "found", "ingredients_text": "…", "additives": "en:e330", "allergens": "en:milk", "note": "…"}
```
For not_found: `{"barcode": "…", "outcome": "not_found", "note": "reason"}`.
Save the file every 25 products, so work is not lost.

## Do not
- Do not write to the MySQL database. Do not change any other file.
- Do not open web pages other than the photo URLs.

## Additional rules (wave 2)
- Non-food products (medicines, cosmetics, soap, shampoo, perfume, diapers, food supplements in capsules/tablets, pet food): always `not_found`, note "Produit non alimentaire".
- These products are imported and sold in Morocco. If the photo shows several languages, use the French list; otherwise translate the list printed on THIS pack. Never use another country's recipe from memory.
- Write the JSON file with `encoding="utf-8"` and `ensure_ascii=False` (Python), so accents are kept.
- If any line of the list is cut off, hidden by glare or unreadable in every language on the pack, the product is not_found. Do not mark a list found as "probably complete".
