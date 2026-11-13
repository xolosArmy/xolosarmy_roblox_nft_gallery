# Cauce del Itzcuintlan

Obra digital de **xolosArmy Network**, serie Colectividad Xoloitzcuintle, creada el 13 de noviembre de 2026. Edición 1/1. Cinco xoloitzcuintles siguen un cauce común. Su instinto de actuar en colectividad se entrelaza con su leyenda en una lectura poética del Valle de México y del Itzcuintlan. [Ficha curatorial](https://xolosarmy.xyz/blog/colectividad-xoloitzcuintle/cauce-del-itzcuintlan/) · [Catálogo canónico](https://xolosarmy.xyz/blog/colectividad-xoloitzcuintle/catalogo.json).

## Registro criptográfico

La edición es un SLP NFT1 Child en eCash de **xolosArmy Community**. **xolosArmy Official** corresponde a los NFT de linaje. La ficha del visitante usa el nombre Xolos Explorer y los dos identificadores completos. Roblox restringe los enlaces directos dentro de las experiencias. [Política de Roblox](https://en.help.roblox.com/hc/en-us/articles/360000910966-Social-Media-Links-for-Experiences-Communities).

- **Token y minteo** `750d49cd41749b550acbe59a8e81e4bcfcec5f74b2b49ae5d29145d17cad2ced`. [Token en Xolos Explorer](https://explorer.xolosarmy.xyz/token/750d49cd41749b550acbe59a8e81e4bcfcec5f74b2b49ae5d29145d17cad2ced) · [Transacción de minteo](https://explorer.xolosarmy.xyz/tx/750d49cd41749b550acbe59a8e81e4bcfcec5f74b2b49ae5d29145d17cad2ced).
- **Anuncio Tonalli Memo TM1** `4ae0b1fadced2eb706bfa6845f56a1cb7b99b25843d915facc27125f3ffce06e`. [Transacción del anuncio en Xolos Explorer](https://explorer.xolosarmy.xyz/tx/4ae0b1fadced2eb706bfa6845f56a1cb7b99b25843d915facc27125f3ffce06e).

El acceso a la sala y a la ficha está disponible para cualquier visitante. En el nodo Chronik que consulta Xolos Explorer, el minteo figura en el bloque 975387 y vincula el token al grupo padre del catálogo. El bloque 975391 contiene el memo con el ID del token y la ficha canónica.

## Verificar e importar el original

El PNG oficial de 1254 × 1254 px coincide con el SHA-256 del mandato. Su ubicación canónica sigue siendo el servidor de xolosArmy. El repositorio documenta cómo verificar esos bytes y la maqueta de Blender los usa directamente para la previsualización. [PNG original](https://xolosarmy.xyz/assets/colectividad-xoloitzcuintle/cauce-del-itzcuintlan.png).

```sh
curl --fail --location --output cauce-del-itzcuintlan.png \
  https://xolosarmy.xyz/assets/colectividad-xoloitzcuintle/cauce-del-itzcuintlan.png
echo 'c11d1d6ec30f0e5e6a4ce18575083dfd7233a40f42db4fa48b4449eb7117ccba  cauce-del-itzcuintlan.png' | sha256sum -c -
```

1. Con la cuenta autorizada para administrar assets del universo de prueba, importa el PNG exacto como **Image**. Usa Asset Manager o Importer en Studio. [Importador de Studio](https://create.roblox.com/docs/studio/importer).
2. Espera la moderación y confirma que la copia de prueba tiene permiso para usar el asset. Obtén el ID de contenido **Image** y configura `ImageIds["cauce-del-itzcuintlan"] = "rbxassetid://…"` en `src/server/Settings.luau`. Si partiste de un Decal, valida en Studio el ID de su textura, que puede diferir del ID del Decal. [Moderación de assets](https://en.help.roblox.com/hc/en-us/articles/21416271342868-Content-Moderation-on-Roblox).
3. En Play comprueba con una cuenta visitante que la imagen carga, conserva las cuatro esquinas y ocupa el marco cuadrado con ajuste **Fit**. Verifica la atribución junto a la obra. Roblox procesa su propia copia para servirla en el motor. Guarda el PNG fuente verificado como referencia de preservación.

**Estado del asset:** falta acceso a una cuenta de Roblox autorizada y al universo de prueba. El marco muestra un aviso explícito, con placa y ficha accesibles. El valor de `ImageIds` está vacío.
