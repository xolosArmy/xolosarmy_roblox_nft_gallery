# Colectividad Xoloitzcuintle

Ampliación del Museo del Itzcuintlan para el [mandato XR-ROBLOX-COLECTIVIDAD-SALA-001](https://github.com/xolosArmy/xolosarmy_roblox_nft_gallery/issues/3). La sala se genera en Luau. Incluye una entrada y un regreso físicos, dos recorridos alrededor del cauce, cinco esculturas y cuatro exhibiciones. «Cauce del Itzcuintlan», «El calor de Huehueteotl», «Itztlantli en el nuevo mundo» y «Tonalli en el Xolo».

| Revisión | Archivos |
| --- | --- |
| Diseño, planta y previsualizaciones | [Arquitectura](docs/arquitectura.md) |
| Inventario, anclaje, respaldo y reversión | [Integración](docs/integracion.md) |
| PNG originales, permisos de assets y referencias criptográficas | [Obras](docs/obra.md) |
| Pruebas automatizadas y recorrido de aceptación | [Validación](docs/validacion.md) |

## Abrir la maqueta local

Desde la raíz del repositorio, con Rojo 7.7.1:

```sh
rojo build colectividad/demo.project.json -o Colectividad-demo.rbxlx
```

Abre el archivo local en Roblox Studio para Windows o macOS. Usa **Play** y entra por el umbral. Activa **Leer ficha** en el muro del fondo y en los tres paños laterales. Vuelve por cualquiera de las dos orillas. El generador construye la sala durante Play. Cada marco muestra «Imagen pendiente de autorización en Roblox» hasta configurar su ID aprobado. La salida de la maqueta vuelve a su propio acceso.

## Probar el museo con la ampliación

Usa [la guía de integración](docs/integracion.md) sobre una copia de prueba. El proyecto parcial gestiona tres carpetas nuevas y deja la instalación inactiva hasta identificar la copia, revisar el acceso y configurar el umbral. La maqueta local y la copia del museo tienen proyectos Rojo distintos.
