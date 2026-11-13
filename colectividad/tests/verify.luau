-- Runs source modules with Lune datatypes. World queries are controlled test doubles.
local fs = require("@lune/fs")
local luau = require("@lune/luau")
local process = require("@lune/process")
local r = require("@lune/roblox")
local serde = require("@lune/serde")

local env = table.clone(r)
local paths = {
	Geometry = "server/Geometry",
	Displays = "server/Displays",
	Room = "server/Room",
	Settings = "server/Settings",
	Artworks = "shared/Artworks",
	ExhibitConstants = "shared/ExhibitConstants",
}
local catalog = serde.decode("json", fs.readFile("colectividad/src/shared/Catalogo.json"))
local shared = { Artworks = "Artworks", ExhibitConstants = "ExhibitConstants", Catalogo = "Catalogo" }
local workspace = r.Instance.new("Workspace")
local studio, obstructed, levelFloor = false, false, true
local raycasts, boxes = 0, 0

r.implementMethod("WorldRoot", "Raycast", function(_, origin, delta)
	raycasts += 1
	assert(delta.Y == -1.6 or math.abs(delta.Y + 1.6) < 0.001)
	if levelFloor then
		return { Position = r.Vector3.new(origin.X, origin.Y - 0.8, origin.Z), Normal = r.Vector3.yAxis }
	end
	return nil
end)
r.implementMethod("WorldRoot", "GetPartBoundsInBox", function(_)
	boxes += 1
	return if obstructed then { workspace.Museo.Suelo } else {}
end)

local services = {
	ReplicatedStorage = { ColectividadXoloitzcuintle = shared },
	RunService = { IsStudio = function() return studio end },
	Workspace = workspace,
}
env.game = { PlaceId = 0, GameId = 0, GetService = function(_, name) return assert(services[name], name) end }
env.script = { Parent = { Displays = "Displays", Geometry = "Geometry", Catalogo = "Catalogo" } }
env.RaycastParams = { new = function() return {} end }
env.OverlapParams = { new = function() return {} end }

local modules = { Catalogo = catalog }
env.require = function(name)
	if not modules[name] then
		local path = "colectividad/src/" .. assert(paths[name]) .. ".luau"
		modules[name] = luau.load(fs.readFile(path), { debugName = path, environment = env })()
	end
	return modules[name]
end
local load = env.require

local function near(a, b)
	return math.abs(a - b) < 0.001
end

local function rejects(callback, expected)
	local ok, err = pcall(callback)
	assert(not ok and string.find(tostring(err), expected, 1, true), tostring(err))
end

local function findAll(root, className)
	local result = {}
	for _, child in root:GetDescendants() do
		if child:IsA(className) then
			table.insert(result, child)
		end
	end
	return result
end

local function part(parent, className, name)
	local node = r.Instance.new(className)
	node.Name = name
	node.Parent = parent
	return node
end

local room = load("Room")
local settings = load("Settings")
local constants = load("ExhibitConstants")
local artworks = load("Artworks")
local works = {
	["cauce-del-itzcuintlan"] = {
		"Cauce del Itzcuintlan", "750d49cd41749b550acbe59a8e81e4bcfcec5f74b2b49ae5d29145d17cad2ced",
		"4ae0b1fadced2eb706bfa6845f56a1cb7b99b25843d915facc27125f3ffce06e",
		r.Vector3.new(0, 7.65, 62.25), -r.Vector3.zAxis, 9, 9, r.Vector3.new(7.7, 4.6, 62.18),
	},
	["el-calor-de-huehueteotl"] = {
		"El calor de Huehueteotl", "ae430d802b9b2514f721f9305881bbdff03b7c8e3a495e3ad093fdf7b98e3b8f",
		"bfbd5d6cfb33cff43a71e886fe8ef4ba7068ea21231d5aec91682ad83e34af21",
		r.Vector3.new(20.35, 6.9, 37), -r.Vector3.xAxis, 8, 7, r.Vector3.new(20.28, 4.6, 30.05),
	},
	["itztlantli-en-el-nuevo-mundo"] = {
		"Itztlantli en el nuevo mundo", "cedd28604d9ac60fcf47c4b81fe448312169cbebe61cb832abbfa0d8070b6564",
		"0d408720977f09b14ea15bd4c14b94d73cc62d5b2a1463967556b9e04af3b1af",
		r.Vector3.new(-20.35, 6.9, 23), r.Vector3.xAxis, 8, 7, r.Vector3.new(-20.28, 4.6, 30.15),
	},
}
assert(#catalog.items == 3)
for _, item in catalog.items do
	local expected = assert(works[item.slug])
	local artwork = artworks[item.slug]
	assert(artwork.title == expected[1] and artwork.edition == "1/1")
	assert(artwork.tokenId == expected[2] and artwork.announcementId == expected[3])
	assert(artwork.explorerName == "Xolos Explorer" and artwork.collection == "xolosArmy Community")
	assert(item.explorer_url == "https://explorer.xolosarmy.xyz/token/" .. expected[2])
	assert(item.mint_tx_url == "https://explorer.xolosarmy.xyz/tx/" .. expected[2])
	assert(item.announcement.explorer_url == "https://explorer.xolosarmy.xyz/tx/" .. expected[3])
	assert(settings.ImageIds[item.slug] == "")
end
assert(room.install(settings, false) == nil)
rejects(function() room.install(settings, true) end, "Studio sin publicar")
studio = true

local function verifyRoom(built, threshold)
	local geometry = built.Arquitectura
	assert(#geometry.Procesion:GetChildren() == 5)
	assert(#findAll(geometry, "PointLight") == 10)
	assert(#findAll(geometry, "ParticleEmitter") == 0)
	assert(#findAll(built, "BasePart") <= 410)
	local floor = geometry.Envolvente["Piso continuo"]
	assert(floor.CanCollide and floor.Size == r.Vector3.new(44, 1, 64))
	local center = threshold:PointToObjectSpace(floor.CFrame.Position)
	assert(near(center.X, 0) and near(center.Y + floor.Size.Y / 2, 0) and near(center.Z, 32))
	for _, solid in findAll(geometry, "BasePart") do
		assert(solid.Anchored and not solid.CanTouch)
		if solid.Parent ~= geometry.Envolvente then
			assert(not solid.CanCollide)
		end
		if solid.CanCollide and solid ~= floor then
			local position = threshold:PointToObjectSpace(solid.CFrame.Position)
			-- No solid intrudes between ±17 below y=9 outside the entry/rear walls.
			assert(position.Y - solid.Size.Y / 2 > 8.999
				or math.abs(position.X) - solid.Size.X / 2 >= 5.999
				or position.Z + solid.Size.Z / 2 <= 1.001
				or position.Z - solid.Size.Z / 2 >= 62.999)
		end
	end
	local directory = geometry.Envolvente["Directorio de obras"]
	assert(not directory.CanCollide and directory.Senal.Texto.Text:find("003  Itztlantli", 1, true))
	assert(threshold:PointToObjectSpace(directory.CFrame.Position).Y - directory.Size.Y / 2 > 10)
	local exhibits = built.Exhibidores
	local promptPositions = {}
	assert(#exhibits:GetChildren() == 3 and #findAll(exhibits, "ProximityPrompt") == 3)
	assert(#findAll(exhibits, "SurfaceLight") == 3 and #findAll(exhibits, "ParticleEmitter") == 0)
	for slug, expected in works do
		local exhibit = exhibits[slug]
		local art = exhibit.Obra
		local plaque = exhibit.Placa
		local prompt = plaque.PuntoDeLectura[constants.promptName]
		assert(plaque.Ficha.Titulo.Text == expected[1] and plaque.Ficha.Edicion.Text:find("1/1", 1, true))
		assert(prompt.ObjectText == expected[1] and prompt.MaxActivationDistance == expected[7] and prompt.RequiresLineOfSight)
		assert(prompt:GetAttribute(constants.artworkAttribute) == slug)
		local position = plaque.CFrame:PointToWorldSpace(prompt.Parent.Position)
		for _, other in promptPositions do
			assert((position - other.position).Magnitude > prompt.MaxActivationDistance + other.range)
		end
		table.insert(promptPositions, { position = position, range = prompt.MaxActivationDistance })
		assert(art.Size.X == art.Size.Y and art.Size.X == expected[6] and art.Obra.Face == r.Enum.NormalId.Front)
		assert((threshold:PointToObjectSpace(art.CFrame.Position) - expected[4]).Magnitude < 0.001)
		assert(near(threshold:VectorToObjectSpace(art.CFrame.LookVector):Dot(expected[5]), 1))
		assert((threshold:PointToObjectSpace(plaque.CFrame.Position) - expected[8]).Magnitude < 0.001)
		assert(near(threshold:VectorToObjectSpace(plaque.CFrame.LookVector):Dot(expected[5]), 1))
		assert(art.Obra.Estado.Text:find("autorización", 1, true))
		assert(art.Obra:FindFirstChild("Imagen") == nil)
	end

	local sideExhibits = {
		{ slug = "el-calor-de-huehueteotl", side = 1, z = 30.05 },
		{ slug = "itztlantli-en-el-nuevo-mundo", side = -1, z = 30.15 },
	}
	for _, station in sideExhibits do
		local exhibit = exhibits[station.slug]
		for _, piece in findAll(exhibit, "BasePart") do
			local localFrame = threshold:ToObjectSpace(piece.CFrame)
			local half = piece.Size / 2
			local xExtent = math.abs(localFrame.XVector.X) * half.X + math.abs(localFrame.YVector.X) * half.Y
				+ math.abs(localFrame.ZVector.X) * half.Z
			-- Both wall assemblies sit behind the reading strips and walking corridors.
			assert(localFrame.X * station.side - xExtent > 19.4 and not piece.CanCollide and not piece.CanTouch)
		end
		local plaque = exhibit.Placa
		local promptOrigin = plaque.CFrame:PointToWorldSpace(plaque.PuntoDeLectura.Position)
		local reader = threshold:PointToWorldSpace(r.Vector3.new(station.side * 15, 4, station.z))
		assert((reader - promptOrigin).Magnitude < plaque.PuntoDeLectura[constants.promptName].MaxActivationDistance)
	end
	local hearth = exhibits["el-calor-de-huehueteotl"]
	assert(hearth:FindFirstChild("Petate") and hearth:FindFirstChild("Fuego simbólico"))
	local eclipse = exhibits["itztlantli-en-el-nuevo-mundo"]
	assert(eclipse["Corona del eclipse"].Shape == r.Enum.PartType.Cylinder)
	assert(eclipse["Sombra del eclipse"].Shape == r.Enum.PartType.Cylinder)
end

local demo = room.install(settings, true)
verifyRoom(demo, r.CFrame.identity)
assert(demo.AccesoDePrueba.Inicio:IsA("SpawnLocation"))
assert(room.install(settings, true) == demo)
assert(#workspace:GetChildren() == 1)
demo:Destroy()

local museum = part(workspace, "Model", "Museo")
local old = part(workspace, "Model", "XolosArmyPyramidGallery")
local hall = part(old, "Model", "SalaDeLosEspiritus")
local expansion = part(workspace, "Model", "TenochtitlanExpansion")
local floor = part(museum, "Part", "Suelo")
floor.Anchored = true
floor.CFrame = r.CFrame.new(180, 8, 320) * r.CFrame.Angles(0, math.pi / 2, 0)
local anchor = part(floor, "Attachment", "ColectividadThreshold")
anchor.CFrame = r.CFrame.new(0, 0.5, 6)
anchor.WorldCFrame = floor.CFrame * anchor.CFrame
local reviewed = {
	TestPlaceId = 88,
	TestUniverseId = 99,
	AnchorModelPath = { "Museo" },
	ExpectedThresholdCFrame = anchor.WorldCFrame,
	ReviewedClearance = true,
	ImageIds = {},
}

assert(room.install(reviewed, false) == nil)
env.game.PlaceId, env.game.GameId = 88, 100
assert(room.install(reviewed, false) == nil)
env.game.GameId = 99
rejects(function() room.install(reviewed, true) end, "Studio sin publicar")
reviewed.ReviewedClearance = false
rejects(function() room.install(reviewed, false) end, "Falta la revisión")
reviewed.ReviewedClearance = true

local conflicting = part(workspace, "Model", constants.roomName)
rejects(function() room.install(reviewed, false) end, "nombre de la sala ya está ocupado")
assert(conflicting.Parent == workspace)
conflicting:Destroy()

local duplicate = part(floor, "Attachment", anchor.Name)
rejects(function() room.install(reviewed, false) end, "más de una instancia")
duplicate:Destroy()
anchor.WorldCFrame *= r.CFrame.new(1, 0, 0)
rejects(function() room.install(reviewed, false) end, "cambió de posición")
anchor.WorldCFrame *= r.CFrame.new(-1, 0, 0)

levelFloor = false
rejects(function() room.install(reviewed, false) end, "piso continuo")
levelFloor = true
obstructed = true
rejects(function() room.install(reviewed, false) end, "volumen reservado")
obstructed = false
reviewed.ImageIds["itztlantli-en-el-nuevo-mundo"] = "https://example.invalid/imagen.png"
rejects(function() room.install(reviewed, false) end, "ID de imagen inválido")
assert(workspace:FindFirstChild(constants.roomName) == nil)
reviewed.ImageIds = {}

local built = room.install(reviewed, false)
verifyRoom(built, anchor.WorldCFrame)
local priorRaycasts, priorBoxes = raycasts, boxes
assert(room.install(reviewed, false) == built and raycasts == priorRaycasts and boxes == priorBoxes)
assert(#workspace:GetChildren() == 4 and hall.Parent == old and floor.Parent == museum and expansion.Parent == workspace)
assert(built:FindFirstChild("AccesoDePrueba") == nil)
assert(priorRaycasts == 19 and priorBoxes == 5, `{priorRaycasts} rayos, {priorBoxes} cajas`)
print("OK: datos canónicos, puerta de prueba, anclaje, geometría, colisiones declaradas, aislamiento, reversión y reejecución")

local function signal()
	local callbacks = {}
	return {
		Connect = function(_, callback)
			callbacks[callback] = true
			return { Disconnect = function() callbacks[callback] = nil end }
		end,
		emit = function(_, ...)
			for callback in callbacks do
				callback(...)
			end
		end,
		count = function()
			local count = 0
			for _ in callbacks do count += 1 end
			return count
		end,
	}
end

-- Run the actual LocalScript with synthetic Roblox signals.
local activated = signal()
r.implementMethod("Instance", "WaitForChild", function(node, name)
	return assert(node:FindFirstChild(name), name)
end)
r.implementProperty("GuiButton", "Activated", function() return activated end)
r.implementProperty("Instance", "Destroying", signal)
local playerGui = r.Instance.new("PlayerGui")
local player = {
	CharacterRemoving = signal(),
	WaitForChild = function(_, name)
		assert(name == "PlayerGui")
		return playerGui
	end,
}
local promptTriggered = signal()
local clientShared = {
	WaitForChild = function(_, name) return assert(shared[name], name) end,
	GetAttribute = function(_, name) return name == constants.readyAttribute end,
}
local bindings = 0
local clientServices = {
	Players = { LocalPlayer = player },
	ProximityPromptService = { PromptTriggered = promptTriggered },
	ReplicatedStorage = {
		WaitForChild = function(_, name)
			assert(name == "ColectividadXoloitzcuintle")
			return clientShared
		end,
	},
	Workspace = workspace,
	GuiService = {},
	UserInputService = { GetLastInputType = function() return r.Enum.UserInputType.Touch end },
	ContextActionService = {
		BindAction = function() bindings += 1 end,
		UnbindAction = function() bindings -= 1 end,
	},
	CollectionService = {
		GetTagged = function() return {} end,
		GetInstanceAddedSignal = signal,
		GetInstanceRemovedSignal = signal,
	},
}
local clientEnv = table.clone(r)
clientEnv.game = { GetService = function(_, name) return assert(clientServices[name], name) end }
clientEnv.require = load
local clientPath = "colectividad/src/client/Exhibit.client.luau"
local function runClient()
	luau.load(fs.readFile(clientPath), { debugName = clientPath, environment = clientEnv })()
end
runClient()
runClient()
assert(#playerGui:GetChildren() == 1 and promptTriggered:count() == 1 and activated:count() == 1)
local gui = playerGui[constants.guiName]
local scroller = gui.Ficha.Contenido
assert(gui.ScreenInsets == r.Enum.ScreenInsets.CoreUISafeInsets)
assert(scroller.AutomaticCanvasSize == r.Enum.AutomaticSize.Y and scroller.Token.TextWrapped and scroller.Anuncio.TextWrapped)
local prompts = {}
for slug in works do
	prompts[slug] = built.Exhibidores[slug].Placa.PuntoDeLectura[constants.promptName]
end
local cauce = "cauce-del-itzcuintlan"
local calor = "el-calor-de-huehueteotl"
local itztlantli = "itztlantli-en-el-nuevo-mundo"
promptTriggered:emit(prompts[calor], {})
assert(not gui.Enabled and bindings == 0)
local foreign = part(hall, "ProximityPrompt", constants.promptName)
foreign:SetAttribute(constants.artworkAttribute, calor)
promptTriggered:emit(foreign, player)
assert(not gui.Enabled and bindings == 0)
for _, slug in { cauce, itztlantli, calor, itztlantli, cauce } do
	promptTriggered:emit(prompts[slug], player)
	local expected = works[slug]
	assert(gui.Enabled and scroller.Obra.Text == expected[1] and scroller.Edicion.Text:find("1/1", 1, true))
	assert(scroller.Token.Text == expected[2] and scroller.Anuncio.Text == expected[3])
	assert(scroller.Explorador.Text == "Xolos Explorer" and bindings == 1)
end
prompts[itztlantli]:SetAttribute(constants.artworkAttribute, cauce)
promptTriggered:emit(prompts[itztlantli], player)
assert(scroller.Obra.Text == works[cauce][1] and bindings == 1)
activated:emit()
assert(not gui.Enabled and bindings == 0)
promptTriggered:emit(prompts[itztlantli], player)
assert(not gui.Enabled and bindings == 0)
prompts[itztlantli]:SetAttribute(constants.artworkAttribute, itztlantli)
promptTriggered:emit(prompts[itztlantli], player)
player.CharacterRemoving:emit()
assert(not gui.Enabled and bindings == 0)
print("OK: fichas correctas al alternar obras, aislamiento de prompts y una sola GUI y suscripción")

if process.args[1] then
	local demoPlace = r.deserializePlace(fs.readFile(process.args[1]))
	local bootstrap = demoPlace.ServerScriptService.ColectividadXoloitzcuintle.Bootstrap
	assert(bootstrap:IsA("Script") and bootstrap:GetAttribute("Demo") == true)
	local sharedPackage = demoPlace.ReplicatedStorage.ColectividadXoloitzcuintle
	assert(sharedPackage.Artworks:IsA("ModuleScript"))
	assert(sharedPackage.Catalogo:IsA("ModuleScript"))
	for _, work in works do
		assert(sharedPackage.Catalogo.Source:find(work[2], 1, true))
	end
	assert(demoPlace.StarterPlayer.StarterPlayerScripts.ColectividadXoloitzcuintle.Exhibit:IsA("LocalScript"))
	print("OK: artefacto Rojo y atributo de maqueta")
end
