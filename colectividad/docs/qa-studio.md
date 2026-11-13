# QA en copia privada de Roblox Studio

Registra el commit del PR, el operador, la fecha, la versión de Studio y la versión de la copia de prueba. El dictamen artístico y los resultados de este protocolo se registran por separado. La integración final y la publicación requieren autorización explícita.

## Identificación, respaldo y umbral

1. En Creator Hub, abre el universo del Museo del Itzcuintlan y su lista de Places. Registra propietario, Universe ID, Place ID, nombre del lugar y versión de origen. Confirma los IDs en la Command Bar de la sesión correspondiente con `print(game.GameId, game.PlaceId)`. Registra por separado los IDs de la copia privada, con acceso restringido a las cuentas de prueba. [Archivos de Place](https://create.roblox.com/docs/projects/place-files)
2. Guarda una copia local del Place de origen, calcula su SHA-256 y registra nombre, tamaño y versión. Vuelve a abrir el archivo en Studio y comprueba que contiene la jerarquía esperada y que arranca. Conserva el archivo intacto para la reversión. Captura el acceso, los recorridos y las interacciones existentes antes de sincronizar.
3. En la copia de prueba localiza la ruta del museo en Explorer. Comprueba la abertura de 12 × 10 studs, el piso al ras, las colisiones y el terreno en el volumen reservado de 44 × 64 studs. Registra la ruta del modelo y los doce componentes del `WorldCFrame` de `ColectividadThreshold`. Sigue los pasos de integración y confirma que el servidor crea un único modelo de sala en el umbral previsto. [Procedimiento de integración](integracion.md)
4. Haz una pasada de reversión en la copia. Retira las tres carpetas del paquete y el Attachment de prueba, reinicia y compara con la línea base. Conserva las dos evidencias junto al hash del respaldo.

## Imágenes y cuenta visitante

Comprueba SHA-256 y 1254 × 1254 px para cada PNG antes de importarlo con la cuenta titular autorizada. En la copia privada registra para cada obra el Image ID, propietario, estado de moderación, permiso para el universo de prueba y resultado con la cuenta visitante. Configura los IDs solo en la copia de prueba. La cuenta visitante debe poder ver las cinco imágenes completas y en proporción cuadrada, junto a sus placas, y abrir las fichas. Comprueba además el aviso de imagen pendiente con un ID vacío en una sesión local. [Fuentes y SHA-256](obra.md) · [Importación de assets](https://create.roblox.com/docs/studio/importer) · [Privacidad de assets](https://create.roblox.com/docs/projects/assets/privacy)

## Recorrido y entradas

| Prueba | Aceptación y evidencia |
| --- | --- |
| Umbral, orillas y cruce final | En modo Server & Clients con dos jugadores, prueba avance en paralelo y en sentidos contrarios por cada corredor. Detén un jugador frente a la cédula y luego frente a 005 mientras el otro pasa. Ambos completan la vuelta, cruzan en Z 49–58 y regresan al museo sin atascarse, caer ni necesitar saltar. Guarda grabación desde ambos clientes. |
| Cámara y jerarquía | Captura el umbral y la primera vista hacia 001 a tres alturas de avatar. Repite con giros de cámara, acercamiento a ambos muros, primera persona y tercera persona. En 003 y 005 confirma que se distinguen las dos placas, el relieve «Memoria» y el paño siguiente. Desde la franja real pide a una cuenta visitante que señale qué placa corresponde a 003 y cuál a 005. Conserva tomas frontal y oblicua. |
| Cédula y directorio | Comprueba a pie que se identifican el acceso al texto completo y la dirección de las cinco estaciones. Verifica título, extracto y contraste bajo la luz efectiva del Place. La cédula debe permitir que otro jugador pase hacia la sala mientras el primero lee. |
| Cinco fichas y lector | Cada jugador abre los cinco prompts NFT y el de introducción. La pantalla del otro permanece cerrada. Comprueba edición, token, anuncio y título, alternancia sin superposición, desplazamiento hasta el final y cierre después de reaparecer. Confirma acceso sin wallet y revisa Output en cliente y servidor. |
| Dispositivos y controles | En escritorio prueba E, Retroceso, ratón y teclado. En Device Simulator usa teléfono vertical y horizontal y un perfil de tableta, con apertura táctil y desplazamiento. Con Controller Emulator prueba apertura, foco, desplazamiento y cierre con B. En un teléfono físico, repite apertura, desplazamiento y cierre táctiles, y comprueba lectura a distancia de brazo. Usa el mismo dispositivo para medir rendimiento. |
| Museo existente | Recorre antes y después las salas, NPC, pads, colisiones e interacciones ya presentes. Guarda la comparación y registra cualquier regresión. |

[Modos de prueba de Studio](https://create.roblox.com/docs/studio/testing-modes)

## Medición de rendimiento

Usa la misma copia, cámara, resolución, calidad gráfica y recorrido al comparar cuatro y cinco estaciones. Haz tres pasadas de 60 segundos por variante después de 30 segundos de calentamiento. Recorre umbral, cédula, 004, 003, 005, cruce y regreso. En la variante de cuatro obras pasa por la misma ubicación de 005. Registra la primera carga de imágenes por separado. Añade una sesión de 15 minutos en el teléfono físico. Captura tiempos de fotograma y memoria con MicroProfiler y Developer Console en el cliente Roblox de escritorio y en un teléfono físico representativo. Usa la emulación de Studio para controles y encuadre.

Anota por dispositivo modelo, SO, resolución, calidad gráfica, mediana y p95 del tiempo de fotograma, p99, máximo de memoria, memoria tras 20 ciclos de abrir/cerrar lectores y reaparecer y tiempo de carga de las cinco imágenes. Adjunta los volcados y las capturas al resultado. Los presupuestos de revisión artística figuran en el dictamen de Astra y deben cotejarse con esas mediciones. [Pruebas en hardware](https://create.roblox.com/docs/performance-optimization/test-on-hardware) · [MicroProfiler](https://create.roblox.com/docs/performance-optimization/microprofiler/use-microprofiler)

## Registro de aceptación

Para cada prueba registra `Pasa`, `Falla` o `Pendiente`, junto con el dispositivo, la evidencia y la incidencia si aplica. Adjunta el resultado al PR con el SHA probado y la versión de la copia. La aprobación humana se registra después de revisar este resultado.
