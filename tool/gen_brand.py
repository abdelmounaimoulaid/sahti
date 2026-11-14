"""Génère les fichiers de marque Sahti : SVG du logo, icônes Android et iOS.

Usage : pip install fonttools uharfbuzz cairosvg pillow
        python tool/gen_brand.py . assets/fonts/ReadexPro-Bold.ttf assets/fonts/ReadexPro-SemiBold.ttf
"""
import io, json, os, sys
import uharfbuzz as hb
from fontTools.ttLib import TTFont
from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.pens.transformPen import TransformPen
import cairosvg
from PIL import Image

REPO = sys.argv[1]
FONT = sys.argv[2]  # ReadexPro-Bold.ttf
SEMI = sys.argv[3]  # ReadexPro-SemiBold.ttf

MENTHE = "#0F6B4F"; MENTHE_D = "#4CC79A"; SAFRAN = "#E8A317"; INK = "#13241D"; BLANC = "#FFFFFF"; NUIT = "#0E1713"

def text_path(font_path, text, size, x, baseline, rtl=False):
    """Contours d'un texte (mis en forme par HarfBuzz) en chemin SVG. Retourne (d, largeur)."""
    data = open(font_path, "rb").read()
    face = hb.Face(data); font = hb.Font(face)
    buf = hb.Buffer(); buf.add_str(text); buf.guess_segment_properties()
    hb.shape(font, buf, {})
    tt = TTFont(font_path); gs = tt.getGlyphSet(); order = tt.getGlyphOrder()
    upm = tt["head"].unitsPerEm; s = size / upm
    pen = SVGPathPen(gs)
    cx = 0
    for info, pos in zip(buf.glyph_infos, buf.glyph_positions):
        name = order[info.codepoint]
        tp = TransformPen(pen, (s, 0, 0, -s, x + (cx + pos.x_offset) * s, baseline - pos.y_offset * s))
        gs[name].draw(tp)
        cx += pos.x_advance
    return pen.getCommands(), cx * s

# Symbole : code-barres dont une barre devient une pousse (viewBox 100)
def symbole(bar, leaf):
    return (f'<g fill="{bar}"><rect x="14" y="40" width="7" height="46" rx="2"/><rect x="27" y="40" width="4" height="46" rx="2"/>'
            f'<rect x="37" y="40" width="9" height="46" rx="2"/><rect x="52" y="28" width="5" height="58" rx="2"/>'
            f'<rect x="63" y="40" width="4" height="46" rx="2"/><rect x="73" y="40" width="9" height="46" rx="2"/></g>'
            f'<path d="M54.5 30 C54.5 18 64 10 78 10 C78 22 68 30 54.5 30 Z" fill="{leaf}"/>')

def svg(w, h, body, bg=None):
    rect = f'<rect width="{w}" height="{h}" fill="{bg}"/>' if bg else ""
    return f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}" width="{w}" height="{h}">{rect}{body}</svg>\n'

def lockup(bar, leaf, ink):
    # symbole 100x100 puis "sahti" et "صحتي" empilés
    d1, w1 = text_path(FONT, "sahti", 52, 104, 58)
    d2, w2 = text_path(SEMI, "صحتي", 32, 0, 92, rtl=True)
    # aligne l'arabe sur le bord droit du mot latin
    x2 = 104 + w1 - w2
    d2, _ = text_path(SEMI, "صحتي", 32, x2, 94, rtl=True)
    w = int(104 + max(w1, w2) + 4)
    body = symbole(bar, leaf) + f'<path d="{d1}" fill="{ink}"/><path d="{d2}" fill="{ink}"/>'
    return svg(w, 116, body)

def app_icon(size=1024, pad=0.0, bg=MENTHE, rounded=False):
    # symbole blanc + feuille safran sur fond menthe ; pad = marge (fraction) pour l'icône adaptative
    k = (1 - 2 * pad) * size / 100 * 0.78
    off = (size - 100 * k) / 2
    body = f'<g transform="translate({off} {off + 2*k}) scale({k})">{symbole(BLANC, SAFRAN)}</g>'
    return svg(size, size, body, bg)

out = os.path.join(REPO, "assets", "brand"); os.makedirs(out, exist_ok=True)
files = {
    "sahti-symbole.svg": svg(100, 100, symbole(MENTHE, SAFRAN)),
    "sahti-symbole-sombre.svg": svg(100, 100, symbole(MENTHE_D, SAFRAN)),
    "sahti-symbole-blanc.svg": svg(100, 100, symbole(BLANC, BLANC)),
    "sahti-logo.svg": lockup(MENTHE, SAFRAN, INK),
    "sahti-logo-sombre.svg": lockup(MENTHE_D, SAFRAN, "#E8EFEB"),
    "sahti-icone-app.svg": app_icon(),
}
for n, c in files.items():
    open(os.path.join(out, n), "w").write(c)

def png(svgtxt, px, path, opaque=True):
    data = cairosvg.svg2png(bytestring=svgtxt.encode(), output_width=px, output_height=px)
    im = Image.open(io.BytesIO(data))
    im = im.convert("RGB") if opaque else im.convert("RGBA")
    os.makedirs(os.path.dirname(path), exist_ok=True); im.save(path, optimize=True)

png(files["sahti-icone-app.svg"], 1024, os.path.join(out, "sahti-icone-app-1024.png"))

# iOS : toutes les tailles listées dans Contents.json, sans transparence
ios = os.path.join(REPO, "ios/Runner/Assets.xcassets/AppIcon.appiconset")
for img in json.load(open(os.path.join(ios, "Contents.json")))["images"]:
    px = round(float(img["size"].split("x")[0]) * int(img["scale"][0]))
    png(files["sahti-icone-app.svg"], px, os.path.join(ios, img["filename"]))

# Android : icône classique + icône adaptative (Android 8+) + monochrome (Android 13)
res = os.path.join(REPO, "android/app/src/main/res")
dens = {"mdpi": 1, "hdpi": 1.5, "xhdpi": 2, "xxhdpi": 3, "xxxhdpi": 4}
fg = svg(108, 108, f'<g transform="translate(21.4 21.4) scale(0.68)">{symbole(BLANC, SAFRAN)}</g>')
mono = svg(108, 108, f'<g transform="translate(21.4 21.4) scale(0.68)">{symbole(BLANC, BLANC)}</g>')
for d, m in dens.items():
    png(app_icon(), round(48 * m), os.path.join(res, f"mipmap-{d}", "ic_launcher.png"))
    png(fg, round(108 * m), os.path.join(res, f"mipmap-{d}", "ic_launcher_foreground.png"), opaque=False)
    png(mono, round(108 * m), os.path.join(res, f"mipmap-{d}", "ic_launcher_monochrome.png"), opaque=False)
os.makedirs(os.path.join(res, "mipmap-anydpi-v26"), exist_ok=True)
open(os.path.join(res, "mipmap-anydpi-v26", "ic_launcher.xml"), "w").write(
    '<?xml version="1.0" encoding="utf-8"?>\n<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
    '    <background android:drawable="@color/ic_launcher_background"/>\n'
    '    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>\n'
    '    <monochrome android:drawable="@mipmap/ic_launcher_monochrome"/>\n</adaptive-icon>\n')
open(os.path.join(res, "values", "colors.xml"), "w").write(
    '<?xml version="1.0" encoding="utf-8"?>\n<resources>\n    <color name="ic_launcher_background">#0F6B4F</color>\n'
    '    <color name="sahti_fond">#F4F8F5</color>\n    <color name="sahti_fond_sombre">#0E1713</color>\n</resources>\n')
print("ok")
