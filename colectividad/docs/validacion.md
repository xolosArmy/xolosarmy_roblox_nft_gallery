# Validación

## Ejecutada en Debian

- Compilación de todos los scripts Luau con el compilador oficial 0.746.
- Pruebas Lune con instancias de rbx-dom y consultas del mundo simuladas. Verifican los tres marcos cuadrados, su orientación, tres prompts con los títulos y datos correctos, y el rechazo de un ID inválido en la tercera obra sin dejar una instalación parcial. Confirman el anclaje de prueba, la conservación de instancias históricas simuladas y la reejecución sin duplicados.
- Prueba del LocalScript con señales simuladas. Al alternar entre obras se actualizan título, edición, token y anuncio. Solo se procesa el prompt del visitante local y de su exhibidor. Se comprueba una sola GUI, una sola suscripción, cierre y limpieza al reaparecer. Se verifican las propiedades de ajuste de texto, márgenes de pantalla y desplazamiento de la ficha.
- Construcción con Rojo 7.7.1 de ambos proyectos y lectura de la maqueta generada para comprobar sus scripts y catálogo. Generación del mapa de fuentes de la integración parcial.
- Dimensiones y SHA-256 de los tres PNG verificados. Xolos Explorer ofrece las referencias de token, minteo y anuncio. Se verificaron en el nodo que consulta el explorador los tres minteos y los tres anuncios.
- Cotejo de los montajes 001 y 002, cauce, esculturas y envolvente colisionable contra la exportación de la Etapa 2. Los archivos de las salas históricas coinciden con `main`.
- Planta y previsualizaciones de Blender inspeccionadas. El paquete añade 374 piezas, 13 luces locales y cero emisores de partículas. Los dos montajes laterales quedan fuera del paso y el área de lectura en las comprobaciones geométricas.

```sh
find colectividad -name '*.luau' -exec luau-compile --null {} +
rojo build colectividad/demo.project.json -o Colectividad-demo.rbxlx
rojo build colectividad/integration.project.json -o Colectividad-integracion-validacion.rbxlx
rojo sourcemap colectividad/integration.project.json -o integracion.json
lune run colectividad/tests/verify.luau Colectividad-demo.rbxlx
```

## Aceptación pendiente en Roblox Studio

Ejecutar primero en la maqueta local y luego en la copia privada que contiene el museo real. La primera verifica el diseño espacial y la segunda verifica la conexión y regresión. [Modos de prueba de Studio](https://create.roblox.com/docs/studio/testing-modes).

- [ ] Confirmar versión y respaldo de origen, Place ID, Universe ID, nombre del modelo, coordenadas, abertura, Terrain y ruta de acceso antes de instalar.
- [ ] Recorrer la pirámide, cuatro exhibidores, Sala de los Espíritus, expansión, NPC y teletransportes antes y después. Registrar diferencias y comprobar que luces, prompts y GUI previos conservan su comportamiento.
- [ ] Entrar y regresar a pie por ambas orillas. Detenerse en cada franja lateral con otro visitante pasando por el corredor. Probar bordes, esquinas, avatares de varias alturas, giros de cámara, piso al ras y saltos junto a paredes. Verificar la lectura del directorio desde el umbral y que no hay caídas ni atascos.
- [ ] Alternar entre los tres prompts, cerrar cada ficha y volver a probar tras reaparecer. En una prueba con dos clientes, confirmar que la ficha abre solamente al visitante que activa el prompt. Validar una sola GUI, un solo prompt por pieza y ausencia de errores en Output.
- [ ] Comprobar la ficha con teclado (E y Retroceso), pantalla táctil y mando. En pantalla pequeña vertical y horizontal, revisar márgenes, contraste, desplazamiento y lectura de los dos IDs completos en cada ficha. Probar una visita sin credenciales de wallet ni NFT.
- [ ] Verificar el token y anuncio de cada obra con Xolos Explorer y el catálogo. Comprobar que los controles muestran atribución y datos de xolosArmy Community.
- [ ] Con los assets aprobados, probar que los tres PNG cargan en la copia para una cuenta visitante y conservan proporción y esquinas. Probar el aviso visible con asset ausente o inaccesible.
- [ ] Medir tasa de cuadros y tiempos de renderizado en móvil y escritorio durante entrada, giro y acercamiento. Registrar dispositivo, resolución, calidad gráfica y mediciones.
- [ ] Guardar capturas de entrada, cauce, cinco figuras, las tres obras, las tres fichas y regreso. Registrar un recorrido breve en escritorio y emulación móvil con la versión exacta del Place de prueba.

Estas pruebas requieren Studio en Windows o macOS. El PR permanece en borrador para revisión del diseño y las pruebas pendientes.
