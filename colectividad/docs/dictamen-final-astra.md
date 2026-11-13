# Dictamen arquitectónico de Astra

**Dictamen final de Astra: APROBACIÓN CONCEPTUAL.** En el segundo examen, Astra verificó en Blender los tres renders corregidos y el detalle de la cédula. Los dos hallazgos P2 quedaron resueltos. La previsualización reproduce la jerarquía, la alineación y los colores de los rótulos con una tipografía aproximada. El ensayo de recorrido declara el despeje geométrico, y la cámara se verifica en Studio. [Comparativa antes y después](evidencia/revision-final-antes-despues.jpg)

El dictamen inicial sobre [ca9b79d35ca5ec67f68546f26887724783436025](https://github.com/xolosArmy/xolosarmy_roblox_nft_gallery/commit/ca9b79d35ca5ec67f68546f26887724783436025) fue **APROBACIÓN CON CAMBIOS**. El volumen de 44 × 64 studs admite las cinco estaciones y la cédula. Astra pidió corregir la fidelidad de los renders tipográficos y el alcance declarado de la prueba de visibilidad. [Mandato de revisión](https://github.com/xolosArmy/xolosarmy_roblox_nft_gallery/pull/4#issuecomment-6861884100)

Astra inspeccionó visualmente el [conjunto](https://github.com/xolosArmy/xolosarmy_roblox_nft_gallery/blob/ca9b79d35ca5ec67f68546f26887724783436025/colectividad/docs/evidencia/cinco-estaciones.jpg), la [planta acotada](https://github.com/xolosArmy/xolosarmy_roblox_nft_gallery/blob/ca9b79d35ca5ec67f68546f26887724783436025/colectividad/docs/evidencia/planta.png), la [comparativa de cuatro y cinco estaciones](https://github.com/xolosArmy/xolosarmy_roblox_nft_gallery/blob/ca9b79d35ca5ec67f68546f26887724783436025/colectividad/docs/evidencia/comparativa-etapa5.png), [Encarnación](https://github.com/xolosArmy/xolosarmy_roblox_nft_gallery/blob/ca9b79d35ca5ec67f68546f26887724783436025/colectividad/docs/evidencia/encarnacion.jpg) y la [cédula](https://github.com/xolosArmy/xolosarmy_roblox_nft_gallery/blob/ca9b79d35ca5ec67f68546f26887724783436025/colectividad/docs/evidencia/introduccion.jpg). Cotejó las cotas y la validación declarada con el modelo.

| Aspecto | Observación y criterio para la revisión |
| --- | --- |
| Jerarquía y secuencia | El cauce turquesa y las cinco figuras conducen hacia 001, en el muro del fondo. 004 y 003 ocupan el primer tramo lateral, con terracota y violeta. 002 y 005 se enfrentan en el tramo medio, con ámbar y azul nocturno. La toma amplia da mayor tamaño aparente a las piezas cercanas. El criterio en Studio es que 001 se reconozca como remate al entrar y al levantar la vista durante el recorrido. |
| Trazado | La planta mantiene el vano de 12 × 10, dos corredores de 6 studs y el cruce Z 49–58. La franja 005 deja 1 stud lateral hasta el corredor y 3 hasta el cruce. Los 0.35 studs al paño anterior y 0.20 al siguiente son separaciones de montaje mural. Probar con dos avatares, cámara cercana y vistas oblicuas. |
| Cédula | El panel de 4.6 × 4.1 se sitúa a Y 4.35 en −X, Z 3.65. Queda en el lado opuesto a 004 y por debajo del directorio elevado. Su título, extracto y lector separado permiten elegir la profundidad de lectura. Confirmar contraste y tamaño desde la franja con la luz real, y que un visitante puede leer mientras otro atraviesa el acceso. |
| Conservación | El detalle de 005 muestra el conjunto «Memoria» completo sobre su placa. Su posición lo distingue del marco vecino de 003. Confirmar desde vista oblicua que los motivos se distinguen y que las placas siguen asociadas con la obra correcta. |
| Experiencia | Las 419 piezas, 15 luces locales y cero partículas describen el modelo. La aceptación de fluidez, memoria, texturas, controles y cámara requiere Roblox Studio y cliente en hardware real. |

## Correcciones verificadas

| Prioridad | Hallazgo reproducible | Corrección y verificación |
| --- | --- | --- |
| P2 | En la base, `tools/render_preview.py` centraba las placas y fijaba su tamaño y color. La cédula usaba cortes por número de caracteres que no correspondían al panel Luau. Se aprecia en `introduccion.jpg` y en las placas de `encarnacion.jpg`. | Exportar caja, escala de lienzo, tamaño, color, alineación y ajuste de texto desde cada SurfaceGui. Regenerar conjunto, cédula y 005 con una fuente de escritorio aproximada. Cotejar los tres pares en la [comparativa antes y después](evidencia/revision-final-antes-despues.jpg). |
| P2 | En la base, `tests/verify.luau` comprobaba el eje visual mediante cajas de piezas con `CanCollide`. El ensayo omitía elementos visibles como las figuras y el directorio. | Conservar la comprobación de circulación mediante cajas, retirar la afirmación de visibilidad automatizada y verificar el eje y los giros de cámara con dos clientes en Studio. [Validación](validacion.md) · [Guion de cámara y recorrido](qa-studio.md) |

## Presupuesto propuesto para Studio

Estos valores son criterios de aceptación del proyecto. La comparación usa el mismo dispositivo, calidad, resolución y recorrido, con tres pasadas de 60 segundos por versión.

| Indicador | Criterio |
| --- | --- |
| Geometría y luces | Hasta 435 piezas, 15 luces locales sin sombras y cero partículas. |
| Escritorio a 1080p | Mediana de fotograma ≤16.7 ms y p95 ≤20 ms. |
| Teléfono físico representativo | Mediana ≤33.3 ms y p95 ≤40 ms. Sesión adicional de 15 minutos. |
| Ambos dispositivos | p99 ≤66.7 ms y ausencia de pausas repetidas >100 ms atribuibles a la sala tras cargar. El p95 de cinco estaciones puede crecer como máximo 10 % respecto a cuatro, además de cumplir el valor absoluto. |
| Memoria | Incremento de hasta 128 MiB respecto al museo base en el mismo dispositivo. Registrar total y categoría de texturas. Tras 20 ciclos de abrir/cerrar lectores y reaparecer, verificar un crecimiento de hasta 5 MiB después de estabilizarse. |

Las comprobaciones de cajas sostienen el trazado y las holguras estáticas. La cámara, la coincidencia de avatares, la lectura en pantalla, las imágenes moderadas y el rendimiento permanecen pendientes de ejecución. El protocolo registra estos resultados aparte del dictamen artístico y de la aprobación humana. [QA en copia privada](qa-studio.md) · [Pruebas en hardware de Roblox](https://create.roblox.com/docs/performance-optimization/test-on-hardware)
