"""Render the Luau-generated room in Blender, using the verified PNGs for the offline mockup."""
import argparse
import hashlib
import json
import math
import sys
import textwrap
from pathlib import Path

import bpy
from mathutils import Matrix, Vector


def arguments():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("scene", type=Path)
    parser.add_argument("originals", type=Path, help="Directory with the original PNGs, named by slug")
    parser.add_argument("output", type=Path)
    parser.add_argument("--views", nargs="+", default=["entrada", "procesion", "obra", "huehueteotl", "itztlantli", "tonalli", "encarnacion", "introduccion", "cinco-estaciones", "retorno", "axonometria"])
    return parser.parse_args(sys.argv[sys.argv.index("--") + 1 :])


def rgb_linear(channels):
    return tuple(
        value / 12.92 if value <= 0.04045 else ((value + 0.055) / 1.055) ** 2.4
        for value in channels
    )


def surface(name, rgb, glow=0):
    material = bpy.data.materials.new(name)
    material.diffuse_color = (*rgb_linear(rgb), 1)
    material.use_nodes = True
    shader = material.node_tree.nodes.get("Principled BSDF")
    shader.inputs["Base Color"].default_value = material.diffuse_color
    shader.inputs["Roughness"].default_value = 0.76
    shader.inputs["Emission Color"].default_value = material.diffuse_color
    shader.inputs["Emission Strength"].default_value = glow
    return material


def emission_image(path):
    material = bpy.data.materials.new("PNG original · color sRGB")
    material.use_nodes = True
    nodes = material.node_tree.nodes
    nodes.clear()
    texture = nodes.new("ShaderNodeTexImage")
    texture.image = bpy.data.images.load(str(path.resolve()))
    texture.extension = "CLIP"
    emission = nodes.new("ShaderNodeEmission")
    output = nodes.new("ShaderNodeOutputMaterial")
    material.node_tree.links.new(texture.outputs["Color"], emission.inputs["Color"])
    material.node_tree.links.new(emission.outputs[0], output.inputs["Surface"])
    return material


def to_blender(value):
    x, y, z = value
    return Vector((x, -z, y))


def frame_for(values):
    x, y, z, *rotation = values
    matrix = Matrix(tuple(rotation[row * 3 : row * 3 + 3] for row in range(3))).to_4x4()
    matrix.translation = (x, y, z)
    conversion = Matrix(((1, 0, 0, 0), (0, 0, -1, 0), (0, 1, 0, 0), (0, 0, 0, 1)))
    return conversion @ matrix


def create_part(part, materials):
    shape = part["shape"]
    if shape == "Ball":
        bpy.ops.mesh.primitive_uv_sphere_add(segments=16, ring_count=10, radius=0.5)
        obj = bpy.context.object
    elif shape == "Cylinder":
        bpy.ops.mesh.primitive_cylinder_add(vertices=48, radius=0.5, depth=1)
        obj = bpy.context.object
        bpy.ops.transform.rotate(value=math.pi / 2, orient_axis="Y")
        bpy.ops.object.transform_apply(location=False, rotation=True, scale=False)
    elif shape == "Wedge":
        vertices = [
            (-0.5, -0.5, -0.5), (0.5, -0.5, -0.5),
            (0.5, -0.5, 0.5), (-0.5, -0.5, 0.5),
            (-0.5, 0.5, 0.5), (0.5, 0.5, 0.5),
        ]
        faces = [(0, 3, 2, 1), (3, 4, 5, 2), (0, 1, 5, 4), (0, 4, 3), (1, 2, 5)]
        mesh = bpy.data.meshes.new(part["name"])
        mesh.from_pydata(vertices, [], faces)
        mesh.update()
        obj = bpy.data.objects.new(part["name"], mesh)
        bpy.context.collection.objects.link(obj)
    else:
        bpy.ops.mesh.primitive_cube_add(size=1)
        obj = bpy.context.object

    obj.name = part["name"]
    frame = frame_for(part["transform"])
    obj.matrix_world = frame @ Matrix.Diagonal((*part["size"], 1))
    glow = 2.5 if part["material"] == "Neon" else 0.06
    key = (*part["color"], glow)
    if key not in materials:
        materials[key] = surface(part["material"], part["color"], glow)
    obj.data.materials.append(materials[key])
    return obj, frame


def sign_text(name, body, size, frame, position, color, back=False):
    curve = bpy.data.curves.new(name, "FONT")
    curve.body = body
    curve.size = size
    curve.align_x = "CENTER"
    curve.align_y = "CENTER"
    font_path = Path("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf")
    if font_path.exists():
        curve.font = bpy.data.fonts.get("DejaVu Sans") or bpy.data.fonts.load(str(font_path))
    curve.materials.append(color)
    obj = bpy.data.objects.new(name, curve)
    bpy.context.collection.objects.link(obj)
    # Blender text faces local +Z. Rotate it toward the artwork's viewer.
    rotation = Matrix.Rotation(0 if back else math.pi, 4, "Y")
    obj.matrix_world = frame @ Matrix.Translation(position) @ rotation
    return obj


def art_plane(name, frame, size, material):
    w, h, depth = size
    mesh = bpy.data.meshes.new("Obra 1:1")
    # The -Z face is viewed with local +X to the left.
    mesh.from_pydata(
        [(w / 2, -h / 2, -depth / 2 - 0.012), (-w / 2, -h / 2, -depth / 2 - 0.012),
         (-w / 2, h / 2, -depth / 2 - 0.012), (w / 2, h / 2, -depth / 2 - 0.012)],
        [],
        [(0, 1, 2, 3)],
    )
    uv = mesh.uv_layers.new()
    for index, pair in enumerate(((0, 0), (1, 0), (1, 1), (0, 1))):
        uv.data[index].uv = pair
    plane = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(plane)
    plane.matrix_world = frame
    plane.data.materials.append(material)


def area(name, position, target, power, size, color):
    data = bpy.data.lights.new(name, "AREA")
    data.energy = power
    data.shape = "DISK"
    data.size = size
    data.color = color
    lamp = bpy.data.objects.new(name, data)
    bpy.context.collection.objects.link(lamp)
    lamp.location = to_blender(position)
    lamp.rotation_euler = (to_blender(target) - lamp.location).to_track_quat("-Z", "Y").to_euler()


def view(scene, camera, output, location, focus, lens, width=1200, height=720):
    camera.location = to_blender(location)
    camera.rotation_euler = (to_blender(focus) - camera.location).to_track_quat("-Z", "Y").to_euler()
    camera.data.lens = lens
    scene.render.resolution_x = width
    scene.render.resolution_y = height
    scene.render.filepath = str(output)
    bpy.ops.render.render(write_still=True)


def main(args):
    data = json.loads(args.scene.read_text())
    originals = {}
    for item in data["catalog"]:
        path = args.originals / f'{item["slug"]}.png'
        if hashlib.sha256(path.read_bytes()).hexdigest() != item["original_image_sha256"]:
            raise ValueError(f"El PNG canónico de {item['name']} no coincide con el SHA-256")
        originals[item["slug"]] = (item["name"], path)
    args.output.mkdir(parents=True, exist_ok=True)
    bpy.ops.wm.read_factory_settings(use_empty=True)
    scene = bpy.context.scene
    scene.render.engine = "CYCLES"
    scene.cycles.samples = 14
    scene.cycles.use_denoising = False
    scene.render.threads_mode = "FIXED"
    scene.render.threads = 8
    scene.view_settings.view_transform = "Standard"
    scene.world = bpy.data.worlds.new("Ambiente de previsualización")
    scene.world.use_nodes = True
    scene.world.node_tree.nodes.get("Background").inputs["Strength"].default_value = 0.12

    materials = {}
    text = surface("Texto ámbar", (0.98, 0.87, 0.67), 1)
    art = {slug: (name, emission_image(path)) for slug, (name, path) in originals.items()}
    roof = []
    for part in data["parts"]:
        obj, frame = create_part(part, materials)
        if part["name"] in {"Cubierta", "Viga transversal", "Luz de recorrido"}:
            roof.append(obj)
        if part["name"] == "Obra":
            name, material = art[part["group"]]
            art_plane(name, frame, part["size"], material)
        elif part["name"] == "Rotulo del umbral":
            w, _, depth = part["size"]
            for sign in part["signs"]:
                back = sign["face"] == "Back"
                sign_text("Rótulo", sign["labels"][0]["text"], 0.48 if back else 0.65, frame,
                          (0, 0, (1 if back else -1) * (depth / 2 + 0.014)), text, back)
        elif part["name"] == "Directorio de obras":
            for label in part["signs"][0]["labels"]:
                y = part["size"][1] * (0.5 - label["y"] - label["h"] / 2)
                x = -part["size"][0] * (label["x"] + label["w"] / 2 - 0.5)
                sign_text("Directorio", label["text"], 0.31, frame,
                          (x, y, -part["size"][2] / 2 - 0.014), text)
        elif part["name"] == "CedulaIntroductoria":
            width, height, depth = part["size"]
            for label in part["signs"][0]["labels"]:
                size = label["size"] / 100
                columns = 23 if label["y"] < 0.2 else 33
                copy = textwrap.fill(label["text"], columns)
                y = height * (0.5 - label["y"] - label["h"] / 2)
                sign_text("Cédula de entrada", copy, size, frame,
                          (0, y, -depth / 2 - 0.014), text)
        elif part["name"] == "Placa":
            w, h, depth = part["size"]
            for label in part["signs"][0]["labels"]:
                copy = label["text"].replace(" del Valle", "\ndel Valle").replace(" y el abrigo", "\ny el abrigo").replace(" y un mundo", "\ny un mundo")
                y = h * (0.5 - label["y"] - label["h"] / 2)
                sign_text("Placa · atribución", copy, 0.22, frame,
                          (0, y, -depth / 2 - 0.014), text)

    for z in (3, 15, 29, 43, 58):
        for side in (-1, 1):
            area("Luz local cálida", (side * 10.5, 13.75, z), (side * 6, 0, z), 1100, 5.5, (1, 0.74, 0.48))
    area("Luz del marco", (0, 12.3, 60.5), (0, 5, 62), 460, 4.4, (1, 0.87, 0.70))
    area("Luz del petate", (18.1, 10.7, 36.5), (20, 2.4, 36.5), 530, 4, (1, 0.61, 0.30))
    area("Luz violeta del eclipse", (-18.1, 10.65, 23.0), (-20, 4.1, 22.6), 580, 4, (0.61, 0.40, 1.0))
    area("Luz solar de terracota", (17.9, 11, 10), (20, 4.5, 11), 610, 4, (1, 0.72, 0.42))
    area("Luz de Venus", (-18.7, 10.5, 37), (-20, 5, 37), 310, 3.4, (0.48, 0.61, 0.95))
    area("Luz de lectura", (-17.5, 7, 4), (-20, 4.5, 3.65), 165, 3, (1, 0.86, 0.68))
    area("Luz rasante del cauce", (0, 11.6, 29), (0, 0, 31), 780, 12, (0.62, 0.86, 0.89))
    area("Luz del acceso", (0, 9, -5), (0, 7, 1), 540, 7, (1, 0.8, 0.63))

    bpy.ops.object.camera_add()
    camera = bpy.context.object
    scene.camera = camera

    views = {
        "entrada": ((0, 5.4, -14), (0, 9.1, 20), 26),
        "procesion": ((-10, 6.1, 8), (0, 3.4, 29), 23),
        "obra": ((1.25, 5.65, 44), (2, 7.3, 62), 29),
        "huehueteotl": ((3.5, 5.5, 32.2), (20, 6.5, 36.6), 27),
        "itztlantli": ((-4.0, 5.5, 23.4), (-20, 6.1, 23.5), 25),
        "tonalli": ((3.6, 5.6, 11.6), (20, 6.15, 11.45), 26),
        "encarnacion": ((-4.2, 5.7, 38.8), (-20, 6.2, 38.5), 25),
        "introduccion": ((-11.5, 4.9, 4.7), (-20.3, 4.35, 3.65), 33),
        "cinco-estaciones": ((-7.5, 6.25, 1.9), (6, 6.1, 40), 9.5),
        "retorno": ((9.5, 5.65, 47), (0, 6.3, 0), 24),
    }
    for name, parameters in views.items():
        if name in args.views:
            view(scene, camera, args.output / f"{name}.png", *parameters, width=1100, height=660)
    if "axonometria" in args.views:
        for obj in roof:
            obj.hide_render = True
        area("Luz general de maqueta", (0, 54, 20), (0, 0, 30), 16000, 48, (0.90, 0.95, 1))
        camera.data.type = "ORTHO"
        camera.data.ortho_scale = 95
        view(scene, camera, args.output / "axonometria.png", (-48, 95, -37), (0, 6, 32), 40, 1150, 1000)


if __name__ == "__main__":
    main(arguments())
