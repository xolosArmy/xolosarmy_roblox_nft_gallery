"""Draw the measured plan from the exported Luau scene. Requires Pillow."""
import argparse
import json
import math
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


def font(size, bold=False):
    family = "DejaVuSans-Bold.ttf" if bold else "DejaVuSans.ttf"
    return ImageFont.truetype(family, size)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("scene", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--compare", type=Path, help="Planta de tres obras para componer la comparación")
    args = parser.parse_args()
    data = json.loads(args.scene.read_text())
    elements = data["parts"]
    artwork_numbers = {item["slug"]: f'{item["number"]:03d}' for item in data["catalog"]}

    paper, ink, secondary = "#f1eadd", "#202b2c", "#505854"
    earth, basalt, water = "#dfd0bb", "#303c3b", "#389b88"
    amber, line, violet, terracotta = "#ae672d", "#a89a84", "#633b87", "#a64c39"
    image = Image.new("RGB", (1430, 1200), paper)
    draw = ImageDraw.Draw(image)
    draw.text((64, 56), "Colectividad Xoloitzcuintle", font=font(48, True), fill=ink)
    draw.text((66, 122), "Museo del Itzcuintlan · Planta arquitectónica en studs", font=font(23), fill=secondary)
    draw.line((65, 177, 1365, 177), fill=line, width=2)

    def xy(x, z):
        return (462 + 11.5 * x, 1025 - 11.5 * z)

    def polygon(element, fill):
        x, _, z, xx, _, xz, _, _, _, zx, _, zz = element["transform"]
        w, _, depth = element["size"]
        corners = ((-w / 2, -depth / 2), (w / 2, -depth / 2),
                   (w / 2, depth / 2), (-w / 2, depth / 2))
        draw.polygon([xy(x + xx * a + xz * b, z + zx * a + zz * b) for a, b in corners], fill=fill)

    def arrow(a, b, fill, width=3, head=11):
        draw.line((a, b), fill=fill, width=width)
        angle = math.atan2(b[1] - a[1], b[0] - a[0])
        left = (b[0] - head * math.cos(angle - 0.52), b[1] - head * math.sin(angle - 0.52))
        right = (b[0] - head * math.cos(angle + 0.52), b[1] - head * math.sin(angle + 0.52))
        draw.polygon((b, left, right), fill=fill)

    def number(point, value):
        x, y = point
        if isinstance(value, str):
            draw.rounded_rectangle((x - 18, y - 11, x + 18, y + 11), radius=5, fill=ink, outline=paper, width=2)
        else:
            draw.ellipse((x - 12, y - 12, x + 12, y + 12), fill=ink, outline=paper, width=2)
        draw.text((x, y - 1), str(value), font=font(13, True), fill=paper, anchor="mm")

    for name, color in (
        ("Piso continuo", earth), ("Muro lateral", basalt), ("Muro del umbral", basalt),
        ("Muro de la obra", basalt), ("Jamba", basalt), ("Panel de pizarra", "#948473"),
        ("Orilla", "#7a9a7a"), ("Agua", water), ("Paño de arcilla", "#a1582e"),
        ("Paño de obsidiana", violet), ("Paño de terracota", terracotta), ("Marco", "#a1582e"), ("Obra", "#e49847"),
        ("Placa", "#b78957"),
    ):
        for part in elements:
            if part["name"] == name:
                polygon(part, color)

    draw.rectangle((xy(14, 42), xy(19.4, 28)), fill="#e7bc90", outline=amber, width=2)
    draw.rectangle((xy(-19.4, 32), xy(-14, 18)), fill="#d9c6e9", outline=violet, width=2)
    draw.rectangle((xy(14, 20), xy(19.4, 5)), fill="#e8bdab", outline=terracotta, width=2)
    for part in elements:
        if part["name"] == "Torso":
            x, _, z, *_ = part["transform"]
            number(xy(x, z), int(part["group"].split()[-1]))

    paths = (
        ((-3, -4), (-3, 5), (-10, 8), (-10, 54), (-7, 57), (2, 57)),
        ((2, 57), (10, 54), (10, 8), (3, 5), (3, -4)),
    )
    for path in paths:
        points = [xy(*pair) for pair in path]
        draw.line(points, fill="#8b4528", width=4, joint="curve")
        for idx in (2, 3, len(points) - 1):
            start, end = points[idx - 1], points[idx]
            middle = ((start[0] + end[0]) / 2, (start[1] + end[1]) / 2)
            arrow(start, middle if idx == 3 else end, "#8b4528", 4, 13)

    for part in elements:
        if part["name"] == "Obra":
            x, _, z, *_ = part["transform"]
            tag = xy(x - math.copysign(3, x), z) if abs(x) > 10 else xy(x, z - 2.2)
            number(tag, artwork_numbers[part["group"]])
        if "prompt" in part:
            px, _, pz = part["prompt"]
            x, y = xy(px, pz)
            draw.ellipse((x - 6, y - 6, x + 6, y + 6), fill="#e49847", outline=ink, width=2)

    arrow(xy(10.1, 34.5), xy(15.2, 34.5), "#ae672d", width=3, head=9)
    draw.text(xy(20, 25.8), "Lectura 002", font=font(15, True), fill=ink, anchor="rt")
    arrow(xy(-10.1, 24.5), xy(-15.2, 24.5), violet, width=3, head=9)
    draw.text(xy(-20, 16.6), "Lectura 003", font=font(15, True), fill=ink, anchor="lt")

    arrow(xy(10.1, 12.5), xy(15.2, 12.5), terracotta, width=3, head=9)
    draw.text(xy(20, 3.8), "Lectura 004", font=font(15, True), fill=ink, anchor="rt")

    # Dimension lines sit outside the walkable plan.
    x1, top = xy(-22, 64)
    x2, bottom = xy(22, 0)
    arrow((462, top - 34), (x1, top - 34), secondary)
    arrow((462, top - 34), (x2, top - 34), secondary)
    draw.rectangle((425, top - 48, 500, top - 20), fill=paper)
    draw.text((462, top - 35), "44", font=font(19, True), fill=ink, anchor="mm")
    arrow((x1 - 43, (top + bottom) / 2), (x1 - 43, top), secondary)
    arrow((x1 - 43, (top + bottom) / 2), (x1 - 43, bottom), secondary)
    draw.rectangle((x1 - 60, 637, x1 - 26, 678), fill=paper)
    draw.text((x1 - 43, 656), "64", font=font(19, True), fill=ink, anchor="mm")
    draw.text((462, 1102), "Umbral · vano 12 × 10", font=font(20, True), fill=ink, anchor="mm")
    arrow((784, 979), (784, 906), secondary)
    draw.text((784, 997), "+Z", font=font(16, True), fill=ink, anchor="mt")

    draw.line((856, 227, 856, 1115), fill=line, width=2)
    draw.text((908, 232), "Recorrido y exhibiciones", font=font(31, True), fill=ink)
    notes = [
        ("Umbral", "Piso a cota 0. Se entra y se regresa\npor la misma abertura."),
        ("Cauce", "Incrustación turquesa sobre piso continuo.\nCinco xolos orientados hacia la obra."),
        ("Orillas", "Dos franjas de paso libre de 6 studs.\nCruce transversal entre Z 49 y 58."),
        ("001 · Cauce del Itzcuintlan", "Muro del fondo · obra 9 × 9, frente −Z.\nCentro (0, 7.65, 62.25)."),
        ("002 · El calor de Huehueteotl", "Paño +X · obra 8 × 8, frente −X.\nCentro (20.35, 6.9, 37).\nLectura: X 14–19.4, Z 28–42."),
        ("003 · Itztlantli en el nuevo mundo", "Paño −X · obra 8 × 8, frente +X.\nCentro (−20.35, 6.9, 23).\nLectura: X −19.4 a −14, Z 18–32."),
        ("004 · Tonalli en el Xolo", "Paño +X · obra 8 × 8, frente −X.\nCentro (20.35, 6.9, 11).\nLectura: X 14–19.4, Z 5–20."),
    ]
    for index, (heading, copy) in enumerate(notes):
        y = (289, 380, 471, 562, 657, 775, 893)[index]
        draw.line((908, y - 12, 1363, y - 12), fill=line, width=1)
        draw.text((909, y), heading, font=font(22, True), fill={5: violet, 6: terracotta}.get(index, amber))
        draw.multiline_text((909, y + 30), copy, font=font(18), fill=ink, spacing=7)
    draw.ellipse((909, 1024, 921, 1036), fill="#e49847", outline=ink, width=2)
    draw.text((933, 1019), "Prompt · Leer ficha", font=font(17), fill=ink)
    draw.text((908, 1055), "Altura libre: 15 studs. Cotas respecto al umbral.", font=font(16), fill=secondary)
    draw.text((908, 1083), "Implantación en el museo pendiente de inventario.", font=font(16), fill=secondary)

    args.output.parent.mkdir(parents=True, exist_ok=True)
    image.save(args.output, optimize=True)
    if args.compare:
        prior = Image.open(args.compare).convert("RGB")
        # Both plans use the same crop and native scale.
        crop = (126, 220, 816, 1118)
        comparison = Image.new("RGB", (1490, 1115), paper)
        comparison.paste(prior.crop(crop), (30, 155))
        comparison.paste(image.crop(crop), (770, 155))
        captions = ImageDraw.Draw(comparison)
        captions.text((64, 39), "Colectividad Xoloitzcuintle · tres y cuatro obras", font=font(43, True), fill=ink)
        captions.text((66, 107), "Etapa 3 · Tres estaciones", font=font(26, True), fill=ink)
        captions.text((806, 107), "Etapa 4 · Tonalli en el paño +X", font=font(26, True), fill=terracotta)
        captions.line((745, 107, 745, 1060), fill=line, width=2)
        captions.text((66, 1068), "Misma escala y envolvente de 44 × 64 studs", font=font(20), fill=secondary)
        comparison.save(args.output.with_name("comparativa-etapa4.png"), optimize=True)


if __name__ == "__main__":
    main()
