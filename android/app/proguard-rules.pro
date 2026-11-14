# ML Kit (lecture du texte) : on n'utilise que l'alphabet latin.
# Le plugin cite aussi les modèles chinois, devanagari, japonais et coréen,
# absents de l'app : R8 ne doit pas s'arrêter sur ces classes manquantes.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
