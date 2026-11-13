# Validación

## Ejecutada en Debian

- Compilación de todos los scripts Luau con el compilador oficial 0.746.
- Pruebas Lune sobre los módulos de sala y exhibición con instancias Luau de rbx-dom y consultas del mundo simuladas. Comprueban límites declarados, piso continuo, cinco figuras, alcance y cantidad de prompts, plano de imagen cuadrado, estado del marco y referencias canónicas. Verifican que la instalación queda inactiva fuera de la copia configurada, acepta un umbral girado, rechaza un umbral movido, duplicado u obstruido, conserva instancias históricas de prueba y no duplica la sala al reejecutarse.
- Construcción del Place local con Rojo 7.7.1 y lectura del archivo generado para comprobar el atributo de maqueta y los tipos de script. Generación del mapa de fuentes de integración parcial.
- SHA-256 y dimensiones del PNG original comprobados. Los enlaces de token y transacciones responden y los IDs coinciden con el catálogo canónico. El nodo Chronik que usa Xolos Explorer confirmó el minteo en el bloque 975387 y el anuncio en el bloque 975391.
- Inspección de la planta acotada y previsualizaciones de Blender. El paquete usa 328 piezas propias de sala y exhibición, 11 luces locales y cero emisores de partículas. La aproximación de la maqueta añade cinco piezas.

```sh
find colectividad -name '*.luau' -exec luau-compile --null {} +
rojo build colectividad/demo.project.json -o Colectividad-demo.rbxlx
rojo sourcemap colectividad/integration.project.json -o integracion.json
lune run colectividad/tests/verify.luau Colectividad-demo.rbxlx
```

## Aceptación pendiente en Roblox Studio

Ejecutar primero en la maqueta local y luego en la copia privada que contiene el museo real. La primera verifica el diseño espacial y la segunda verifica la conexión y regresión. [Modos de prueba de Studio](https://create.roblox.com/docs/studio/testing-modes).

- [ ] Confirmar versión y respaldo de origen, Place ID, Universe ID, nombre del modelo, coordenadas, abertura, Terrain y ruta de acceso antes de instalar.
- [ ] Recorrer la pirámide, cuatro exhibidores, Sala de los Espíritus, expansión, NPC y teletransportes antes y después. Registrar diferencias y comprobar que luces, prompts y GUI previos conservan su comportamiento.
- [ ] Entrar y regresar a pie por ambas orillas. Probar bordes, esquinas, avatares de varias alturas, giros de cámara, piso al ras y saltos junto a paredes. Verificar que no hay caídas ni atascos.
- [ ] Activar y cerrar la ficha varias veces y tras reaparecer. En una prueba con dos clientes, confirmar que la ficha abre solamente al visitante que activa el prompt. Validar una sola GUI, un solo prompt por pieza y ausencia de errores en Output.
- [ ] Comprobar la ficha con teclado (E y Retroceso), pantalla táctil y mando. En pantalla pequeña vertical y horizontal, revisar márgenes, contraste, desplazamiento y lectura de los dos IDs completos. Probar una visita sin credenciales de wallet ni NFT.
- [ ] Verificar los dos IDs con Xolos Explorer y el catálogo. Comprobar que los controles muestran atribución y datos de xolosArmy Community.
- [ ] Con un asset aprobado, probar que el PNG carga en la copia para una cuenta visitante y conserva proporción y esquinas. Probar el aviso visible con asset ausente o inaccesible.
- [ ] Medir tasa de cuadros y tiempos de renderizado en móvil y escritorio durante entrada, giro y acercamiento. Registrar dispositivo, resolución, calidad gráfica y mediciones.
- [ ] Guardar capturas de entrada, cauce, cinco figuras, obra, ficha y regreso. Registrar un recorrido breve en escritorio y emulación móvil con la versión exacta del Place de prueba.

Estas pruebas requieren Studio en Windows o macOS. El PR permanece en borrador para revisión del diseño y las pruebas pendientes.
