local catalog = require(script.Parent.Catalogo)

local interpretation = {
	["cauce-del-itzcuintlan"] = {
		plaque = "Lectura poética del Valle de México y del Itzcuintlan",
		summary = "Cinco xoloitzcuintles siguen un cauce común. Su instinto de actuar en colectividad se entrelaza con su leyenda en una lectura poética del Valle de México y del Itzcuintlan.",
	},
	["el-calor-de-huehueteotl"] = {
		plaque = "El petate, el fuego y el abrigo compartido",
		summary = "Sobre un petate, los xoloitzcuintles se acurrucan en tres niveles y comparten su calor. El brasero de Huehuetéotl evoca un fuego que la comunidad resguarda. La escena propone una lectura contemporánea del abrigo colectivo.",
	},
}

local months = {
	"enero", "febrero", "marzo", "abril", "mayo", "junio",
	"julio", "agosto", "septiembre", "octubre", "noviembre", "diciembre",
}
local artworks = {}
for _, item in catalog.items do
	local copy = assert(interpretation[item.slug], "Falta el texto curatorial de " .. item.slug)
	local year, month, day = item.date:match("^(%d%d%d%d)%-(%d%d)%-(%d%d)$")
	artworks[item.slug] = table.freeze({
		title = item.name,
		edition = item.edition,
		date = string.format("%d de %s de %s", tonumber(day), months[tonumber(month)], year),
		credit = "xolosArmy Network · " .. catalog.collection,
		summary = copy.summary,
		plaque = copy.plaque,
		protocol = item.protocol .. " · " .. catalog.network,
		collection = catalog.nft_collection,
		tokenId = item.token_id,
		announcementProtocol = item.announcement.protocol,
		announcementId = item.announcement.txid,
		explorerName = "Xolos Explorer",
	})
end

return table.freeze(artworks)
