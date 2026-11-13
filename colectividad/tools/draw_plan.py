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
    args = parser.parse_args()
    elements = json.loads(args.scene.read_text())

    paper, ink, secondary = "#f1eadd", "#202b2c", "#505854"
    earth, basalt, water = "#dfd0bb", "#303c3b", "#389b88"
    amber, line = "#ae672d", "#a89a84"
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
        draw.ellipse((x - 12, y - 12, x + 12, y + 12), fill=ink, outline=paper, width=2)
        draw.text((x, y - 1), str(value), font=font(13, True), fill=paper, anchor="mm")

    for name, color in (
        ("Piso continuo", earth), ("Muro lateral", basalt), ("Muro del umbral", basalt),
        ("Muro de la obra", basalt), ("Jamba", basalt), ("Panel de pizarra", "#948473"),
        ("Orilla", "#7a9a7a"), ("Agua", water), ("Marco", "#a1582e"), ("Obra", "#e49847"),
        ("Placa", "#b78957"),
    ):
        for part in elements:
            if part["name"] == name:
                polygon(part, color)

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

    x, y = xy(7.7, 58.5)
    draw.ellipse((x - 7, y - 7, x + 7, y + 7), fill="#e49847", outline=ink, width=2)
    draw.text((x + 14, y - 13), "Leer ficha", font=font(16, True), fill=ink)
    draw.text(xy(0, 61), "OBRA", font=font(14, True), fill=ink, anchor="mt")

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
    draw.text((908, 249), "Recorrido", font=font(31, True), fill=ink)
    notes = [
        ("Umbral", "Piso a cota 0. Se entra y se regresa\npor la misma abertura."),
        ("Cauce", "Incrustación turquesa sobre piso continuo.\nCinco xolos orientados hacia la obra."),
        ("Orillas", "Dos franjas de paso libre de 6 studs.\nCruce transversal entre Z 49 y 58."),
        ("Muro principal", "Obra de 9 × 9 studs, placa y punto\nde lectura. Altura libre de sala: 15 studs."),
        ("Relieves laterales", "Los paños de pizarra admiten obras\nfuturas sin ocupar la circulación."),
    ]
    for index, (heading, copy) in enumerate(notes):
        y = 321 + index * 132
        draw.line((908, y - 12, 1363, y - 12), fill=line, width=1)
        draw.text((909, y), heading, font=font(22, True), fill=amber)
        draw.multiline_text((909, y + 36), copy, font=font(19), fill=ink, spacing=7)
    draw.text((908, 1030), "Cota y orientación locales respecto al Attachment.", font=font(16), fill=secondary)
    draw.text((908, 1057), "Implantación en el museo pendiente de inventario.", font=font(16), fill=secondary)

    args.output.parent.mkdir(parents=True, exist_ok=True)
    image.save(args.output, optimize=True)


if __name__ == "__main__":
    main()
