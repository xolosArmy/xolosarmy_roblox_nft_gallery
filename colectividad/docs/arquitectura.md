# Arquitectura de Colectividad Xoloitzcuintle

Desde el umbral, cinco figuras de basalto siguen un cauce turquesa hasta «Cauce del Itzcuintlan». Al volver por el corredor +X, una franja lateral permite detenerse ante «El calor de Huehueteotl». El segundo montaje sustituye solo el relieve del paño +X en Z 37. El paño de arcilla, la trama de petate y un brasero esquemático con luz ámbar aluden al abrigo colectivo de la obra. Los elementos están montados en pared y el piso mantiene la misma cota.

![Planta acotada con ambas exhibiciones, prompts y circulación](evidencia/planta.png)

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
| Expansión | Los otros paños de pizarra siguen disponibles. `Catalogo.json` aporta los metadatos de la serie, `Artworks.luau` los textos interpretativos y `Displays.luau` las posiciones, giros y dimensiones del montaje. |

La ficha amplía la placa con texto de alto contraste y desplazamiento vertical. La validación de cámara, navegación y legibilidad en dispositivo está en la [lista de aceptación](validacion.md).

## Previsualización

Blender usa las posiciones, medidas, colores y rótulos exportados desde Luau. Sus luces y cámaras son de previsualización. Ambas obras se muestran con sus PNG canónicos verificados. Los marcos de la maqueta Roblox muestran el aviso de asset pendiente.

| Vista | Imagen |
| --- | --- |
| Ambas exhibiciones | [Perspectiva de conjunto](evidencia/ambas.jpg) |
| Cauce del Itzcuintlan | [Marco y placa](evidencia/obra.jpg) |
| El calor de Huehueteotl | [Marco, placa, petate y brasero](evidencia/huehueteotl.jpg) |
| Volumen y recorridos | [Axonometría sin cubierta](evidencia/axonometria.jpg) |
| Acceso y circulación | [Entrada](evidencia/entrada.jpg) · [Procesión](evidencia/procesion.jpg) · [Regreso](evidencia/retorno.jpg) |

Las capturas y el video de Studio quedan pendientes de una prueba ejecutada en la copia del museo.

### Regenerar la previsualización

Desde la raíz del repositorio, con Lune 0.11.1, Blender 4.3 y Python con Pillow. Obtén los PNG en `originales` mediante [el procedimiento de verificación](obra.md).

```sh
lune run colectividad/tools/export_preview.luau sala.json
python3 colectividad/tools/draw_plan.py sala.json planta.png
blender -b --factory-startup --python-exit-code 1 \
  --python colectividad/tools/render_preview.py -- sala.json originales renders
```
