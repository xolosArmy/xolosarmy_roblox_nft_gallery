# Arquitectura de Colectividad Xoloitzcuintle

Desde el umbral, el cauce turquesa y las cinco figuras de basalto mantienen el eje visual hacia «Cauce del Itzcuintlan». El directorio indica los dos desvíos laterales. En el paño −X, «Itztlantli en el nuevo mundo» introduce violeta, obsidiana y un eclipse en relieve. En +X, «El calor de Huehueteotl» conserva la arcilla, el petate y el brasero ámbar. Cada obra lateral tiene una franja de lectura a la misma cota del piso. El tercer montaje sustituye únicamente el relieve del paño −X a Z 23.

![Planta acotada con tres exhibiciones, prompts y circulación](evidencia/planta.png)

| Elemento | Medidas y cotas locales en studs |
| --- | --- |
| Envolvente | X −22…22, Z 0…64. Altura libre 15. Piso de 1 de espesor y cubierta entre Y 15 y 16. |
| Umbral | Centro (0, 0, 0). Vano de 12 × 10. +Y arriba y +Z hacia la obra inaugural. El rótulo de regreso mira al interior. |
| Piso y recorridos | Piso continuo a Y=0. Franjas de 6 studs centradas en X ±10. Cruce transversal entre Z 49 y 58. |
| Cauce | Z 10…48. Centro `x = 3.5 sin((z−10)π/19)`. Orilla de 5.1 de ancho y agua de 4.55. Incrustación sobre piso continuo. |
| Procesión | Cinco figuras en Z 13, 21, 29, 37 y 45. Cada una tiene giro y zancada propios. |
| 001 · Cauce del Itzcuintlan | Obra 9 × 9 en (0, 7.65, 62.25), frente −Z. Placa en (7.7, 4.6, 62.18) y prompt en (7.7, 3.85, 61.68), con alcance de 9 studs. |
| 002 · El calor de Huehueteotl | Obra 8 × 8 en (20.35, 6.9, 37), frente −X. Placa en (20.28, 4.6, 30.05) y prompt en (19.78, 3.85, 30.05), con alcance de 7 studs. |
| Lectura 002 | X 14…19.4, Z 28…42. El corredor +X ocupa X 7…13. La franja de lectura es espacio libre sobre el piso. La luminaria y el brasero están fijados al paño. |
| 003 · Itztlantli en el nuevo mundo | Obra 8 × 8 en (−20.35, 6.9, 23), frente +X. Placa en (−20.28, 4.6, 30.15) y prompt en (−19.78, 3.85, 30.15), con alcance de 7 studs. |
| Lectura 003 | X −19.4…−14, Z 18…32. El corredor −X ocupa X −13…−7. El eclipse y el marco están montados en pared. |
| Directorio | Centro (0, 12.8, 15), frente al acceso (−Z). Al mirar hacia +Z, 002 queda a la izquierda, 003 a la derecha y 001 al fondo. |
| Expansión | Los otros paños de pizarra siguen disponibles. `Catalogo.json` aporta los metadatos de la serie, `Artworks.luau` los textos interpretativos y `Displays.luau` las posiciones, giros y dimensiones del montaje. |

La ficha amplía la placa con texto de alto contraste y desplazamiento vertical. La validación de cámara, navegación y legibilidad en dispositivo está en la [lista de aceptación](validacion.md).

## Comparación para revisión con Astra

[Planta de dos y tres estaciones a la misma escala](evidencia/comparativa.png). La tercera pieza queda adelantada respecto a la estación ámbar (Z 23 frente a Z 37), por lo que ambas pueden leerse en un recorrido de ida y vuelta alrededor del cauce. El plano permite revisar el protagonismo de 001 desde el umbral, el escalonamiento entre los paños y el espacio para detenerse a leer sin ocupar el paso. Los renders permiten evaluar el contraste entre turquesa, ámbar y violeta, así como la legibilidad del directorio y la escala del relieve.

## Previsualización

Blender usa las posiciones, medidas, colores y rótulos exportados desde Luau. Sus luces y cámaras son de previsualización. Las tres obras se muestran con sus PNG canónicos verificados. Los marcos de la maqueta Roblox muestran el aviso de asset pendiente.

| Vista | Imagen |
| --- | --- |
| Tres exhibiciones | [Perspectiva de conjunto](evidencia/tres-estaciones.jpg) |
| Cauce del Itzcuintlan | [Marco y placa](evidencia/obra.jpg) |
| El calor de Huehueteotl | [Marco, placa, petate y brasero](evidencia/huehueteotl.jpg) |
| Itztlantli en el nuevo mundo | [Marco, placa y eclipse](evidencia/itztlantli.jpg) |
| Volumen y recorridos | [Axonometría sin cubierta](evidencia/axonometria.jpg) |
| Acceso y circulación | [Entrada](evidencia/entrada.jpg) · [Procesión](evidencia/procesion.jpg) · [Regreso](evidencia/retorno.jpg) |

Las capturas y el video de Studio quedan pendientes de una prueba ejecutada en la copia del museo.

### Regenerar la previsualización

Desde la raíz del repositorio, con Lune 0.11.1, Blender 4.3 y Python con Pillow. Obtén los PNG en `originales` mediante [el procedimiento de verificación](obra.md).

```sh
lune run colectividad/tools/export_preview.luau sala.json
git show fa8d217:colectividad/docs/evidencia/planta.png > planta-etapa2.png
python3 colectividad/tools/draw_plan.py sala.json planta.png --compare planta-etapa2.png
blender -b --factory-startup --python-exit-code 1 \
  --python colectividad/tools/render_preview.py -- sala.json originales renders
```
