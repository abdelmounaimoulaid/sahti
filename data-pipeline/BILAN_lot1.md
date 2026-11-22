# Bilan du lot 1 : 100 fiches incomplètes (15 novembre 2026)

## Résultat
- 100 produits traités : grandes marques marocaines (codes 611…), sans ingrédients, au plus 3 par marque.
- **27 compositions trouvées** et marquées « trouvée par IA, à vérifier » :
  - 19 en confiance moyenne : même produit sous un autre code-barres (autre format ou pack).
  - 8 en confiance basse : la recette vient d'un produit proche de la même marque, à vérifier en priorité.
- 2 rejetées car étrangères : les deux Cerelac. Les seules fiches trouvées étaient égyptiennes (codes 622…).
- 71 non trouvées. La raison est notée pour chacune dans la base, table `enrichment_runs`.
- Le nombre de fiches correctes sera connu après ta validation dans la page admin.

## Temps
- Test de départ : 5 produits par recherche web classique en environ 12 minutes, 0 trouvé.
- Lot de 100 : environ 3 minutes de traitement en tout (mesuré sur l'horloge du PC), soit environ 2 secondes par produit. Ce temps couvre les recherches web et la comparaison avec les 6 905 fiches marocaines complètes de la base. Le temps de lecture et de décision n'est pas mesuré séparément.

## D'où viennent les compositions
- Toutes les compositions trouvées viennent d'Open Food Facts : ce sont des fiches marocaines du même produit ou de la même gamme.
- Les recherches web classiques (Google, sites de supermarchés) n'ont rien donné de fiable pour les produits marocains.

## Pièges rencontrés
1. **Recettes étrangères** : la recherche web renvoie surtout des produits français (Auchan, Danone France…) ou espagnols. Tous ont été écartés.
2. **Supermarchés marocains** : Marjane, Carrefour Maroc et Jumia n'affichent pas les ingrédients.
3. **Cerelac** : les fiches disponibles sont égyptiennes, alors que le produit est vendu au Maroc.
4. **Noms trop vagues** (« Mary trini », « Bimbo », « Aiguebelle ») : impossible de savoir quelle variante c'est.
5. **Versions light et classiques** : les recettes sont différentes (sucre ou édulcorants). Elles n'ont jamais été mélangées.
6. **Recettes qui changent** : deux fiches Pepsi ou deux fiches Tonik se contredisent. C'est signalé dans les notes.
7. **Photos et OCR d'Open Food Facts** : certaines photos « ingrédients » montrent en fait la face avant, et certains textes arabes sont illisibles.
8. **API Open Food Facts** : limitée, avec des erreurs 503. L'export CSV officiel est la bonne méthode d'import.

## Recommandation
Pour les 71 fiches non trouvées, la seule source fiable reste l'étiquette. Des photos du dos des emballages, prises en magasin et lues ensuite, permettraient de les compléter.

---

# Bilan du lot 2 : toutes les fiches (15 novembre 2026, après-midi)

## Résultat
- **803 fiches sont maintenant « trouvée par IA, à vérifier »** (il y en avait 27 au lot 1).
  - **694 lues sur la photo de l'étiquette** (source `packaging_photo`, confiance haute). Ce sont les vraies étiquettes marocaines publiées sur Open Food Facts que personne n'avait recopiées. Il y en a 25 de ma lecture test et 669 des 8 agents.
  - 109 rapprochées d'une fiche complète du même produit sous un autre code-barres : 68 en confiance moyenne, 41 en confiance basse.
- 1 526 photos de produits marocains (codes 611) ont été lues : environ 46 % donnent une liste complète. Les autres montrent le tableau nutritionnel, la face avant, un texte coupé, ou un produit qui n'est pas alimentaire.
- Les additifs écrits en toutes lettres ont été traduits en E-numbers (« benzoate de sodium » devient E211, par exemple) sur 198 fiches.
- Il reste 19 406 fiches incomplètes. 10 352 n'ont même pas de nom.

## Contrôle qualité
- J'ai comparé des lectures des agents avec la photo d'origine : par exemple la mortadelle Banchereau (6111242110014) est identique à l'étiquette, au mot près.
- Deux fichiers d'agents avaient un défaut d'encodage (les accents s'affichaient mal). C'est corrigé dans la base (439 champs).
- Les produits non alimentaires lus par erreur (gel douche, savon, parfum, compléments alimentaires) ont été remis en « incomplète ».

## Nouveaux pièges
1. **La base OFF Maroc contient des produits non alimentaires** : médicaments (codes 6118…), savons, shampoings, couches, crèmes solaires. Il faudra les exclure de l'app.
2. **Des noms trompeurs** :
   - « Azafran » et « Safran » sont des colorants ou assaisonnements (tartrazine E102, E110, glutamate), pas du safran.
   - Une « huile d'olive » contient 80 % d'huile de grignons raffinée.
   - Des « chocolats » sont des succédanés à base de graisse végétale.
   - Un « sirop au miel » n'est pas du miel.
3. **Mauvais nom dans OFF** : par exemple « Milo » est en fait des filets de maquereau, et « Sauce Béarnaise » est une mayonnaise light. La photo fait foi, mais vérifie le nom dans l'admin.
4. **Photos d'un autre produit** : le code-barres visible sur la photo est parfois différent. Ces fiches sont marquées non trouvées, ou signalées dans la note.
5. **Même nom, recettes différentes** : le 7UP 1 L et 1,5 L est en formule réduite en sucre avec édulcorants, contrairement au format 500 ml.
6. **Viande** : certaines saucisses « de volaille » contiennent du bœuf (arôme ou gras de bœuf). C'est important pour les allergies et les régimes.

## Suite possible
- 2 938 photos de produits importés (codes non marocains) n'ont pas encore été lues.
- Valider les 803 fiches dans l'admin (onglet « À vérifier »).

---

# Bilan final (15 novembre 2026, soir)

- **Toutes les photos d'ingrédients disponibles sur Open Food Facts sont lues** : 4 464 photos en tout.
- **1 754 fiches sont « trouvée par IA, à vérifier »**. Environ 1 645 viennent de la vraie étiquette, avec une confiance haute, et 109 d'une fiche du même produit.
- 1 210 produits non alimentaires ont été repérés (médicaments, cosmétiques, hygiène). Il faut les exclure de l'app.
- 18 455 fiches restent incomplètes. Aucune n'a de photo d'ingrédients sur Open Food Facts, et environ 10 000 n'ont même pas de nom. La seule façon de les compléter : photographier l'étiquette en magasin.
- Prochaine étape : valider les 1 754 fiches dans l'admin.
