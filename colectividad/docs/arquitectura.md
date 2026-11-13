# Arquitectura de Colectividad Xoloitzcuintle

La serie inspira una lectura espacial del Valle de México y del Itzcuintlan. La obra domina la vista desde el acceso. Entre ella y el umbral, cinco figuras de basalto avanzan sobre un cauce turquesa. Los relieves de montaña y los motivos originales de viento, cempasúchil y memoria acompañan el recorrido. Las proporciones y los motivos pertenecen a una interpretación poética.

![Planta acotada y recorrido de ida y vuelta](evidencia/planta.png)

| Elemento | Medidas y cotas locales en studs |
| --- | --- |
| Envolvente | X −22…22, Z 0…64. Altura libre 15. Piso de 1 de espesor y cubierta entre Y 15 y 16. |
| Umbral | Centro (0, 0, 0). Vano de 12 × 10. +Y arriba y +Z hacia la obra. El rótulo de regreso mira al interior. |
| Piso y recorridos | Piso continuo a Y=0. Franjas laterales de 6 studs centradas en X ±10. Cruce transversal ante la obra entre Z 49 y 58. |
| Cauce | Z 10…48. Centro `x = 3.5 sin((z−10)π/19)`. Orilla de 5.1 de ancho y agua de 4.55. Acabado sin colisión, corriente, daño ni efectos de partículas. |
| Procesión | Cinco figuras a Z 13, 21, 29, 37 y 45. Cada figura mira hacia el final del cauce con un giro y una zancada propios. |
| Exhibición | Obra de 9 × 9 centrada en (0, 7.65, 62.25). Placa a (7.7, 4.6, 62.18) y prompt a (7.7, 3.85, 61.68), orientados hacia −Z. |
| Módulos de expansión | Los paños laterales en Z 23 y 37 admiten futuros montajes. Los relieves completan esos paños en la exposición inaugural. Datos curatoriales en `Artworks.luau` y posiciones en los slots de `Displays.luau`. |

La iluminación usa luminarias locales ámbar y un foco en el marco. El piso de tierra, los paños de pizarra y la obsidiana del umbral mantienen un fondo sobrio. El visitante puede rodear el cauce, girar en la zona de lectura y volver por la otra orilla sin saltos. La ficha amplía la placa con texto de alto contraste y desplazamiento vertical. La validación de cámara y legibilidad en dispositivo está en la [lista de aceptación](validacion.md).

## Previsualización

Blender usa las posiciones, medidas, colores y rótulos exportados desde los módulos Luau. Su iluminación y cámara son de previsualización. La obra se muestra usando el PNG canónico verificado. En la maqueta Roblox aparece un aviso hasta configurar el asset autorizado.

| Vista | Imagen |
| --- | --- |
| Umbral | [Entrada](evidencia/entrada.jpg) |
| Orillas y esculturas | [Procesión](evidencia/procesion.jpg) |
| Marco y placa | [Obra](evidencia/obra.jpg) |
| Regreso | [Salida](evidencia/retorno.jpg) |
| Volumen y recorridos | [Axonometría sin cubierta](evidencia/axonometria.jpg) |

La planta es un plano derivado de la geometría y las imágenes son renders de Blender. Las capturas y el video de Studio quedan pendientes de una prueba ejecutada en la copia del museo.

### Regenerar la previsualización

Con Lune 0.11.1, Blender 4.3 y Python con Pillow, ejecuta desde la raíz del repositorio. Obtén el PNG con [el procedimiento de verificación](obra.md).

```sh
lune run colectividad/tools/export_preview.luau sala.json
python3 colectividad/tools/draw_plan.py sala.json planta.png
blender -b --factory-startup --python-exit-code 1 \
  --python colectividad/tools/render_preview.py -- sala.json cauce-del-itzcuintlan.png renders
```
