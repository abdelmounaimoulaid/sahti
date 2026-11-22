"""Mark non-food items (cosmetics, medicines, supplements) as not_found in an agent results file."""
import json, re, sys
PAT = re.compile(r'non[- ]?food|not food|non alimentaire|cosm[ée]ti|medicine|m[ée]dicament|\bINCI\b|supplement|compl[ée]ment alimentaire|shampo|soap|savon|lotion|diaper|couche|wipes|lingette|deodor|d[ée]odorant|shower|gel douche|perfume|parfum|baby oil|capsule', re.I)
for name in sys.argv[1:]:
    p = f'data/agent_results/{name}'
    d = json.load(open(p, encoding='utf-8')); n = 0
    for x in d:
        if x.get('outcome') == 'found' and PAT.search(x.get('note') or ''):
            x['outcome'] = 'not_found'; x['note'] = 'Produit non alimentaire. ' + (x.get('note') or ''); n += 1
    json.dump(d, open(p, 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
    print(name, 'reclassés:', n)
