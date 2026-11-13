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
	["itztlantli-en-el-nuevo-mundo"] = {
		plaque = "Dentición del xolo, obsidiana y eclipse",
		summary = "La obra traza una analogía artística entre la dentición incompleta de algunos xoloitzcuintles sin pelo y los filos de obsidiana del macuahuitl. El eclipse enmarca esa relación en una escenografía ritual imaginada para un mundo nuevo.",
	},
	["tonalli-en-el-xolo"] = {
		plaque = "Barro, sol y tres cactus floridos",
		summary = "Un xoloitzcuintle de barro suspendido sobre el valle evoca la cerámica de perros de Colima y el paisaje de José María Velasco. El sol ilumina su cuerpo de terracota, que refleja la luz hacia tres cactus floridos. Los cactus representan a su familia humana y el xolo enlaza la tierra, el sol y la familia.",
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
