-- Runs source modules with Lune datatypes. World queries are controlled test doubles.
local fs = require("@lune/fs")
local luau = require("@lune/luau")
local process = require("@lune/process")
local r = require("@lune/roblox")
local serde = require("@lune/serde")

local env = table.clone(r)
local paths = {
	Geometry = "server/Geometry",
	Introduction = "server/Introduction",
	Introduccion = "shared/Introduccion",
	ReaderView = "client/ReaderView",
	Displays = "server/Displays",
	Room = "server/Room",
	Settings = "server/Settings",
	Artworks = "shared/Artworks",
	ExhibitConstants = "shared/ExhibitConstants",
}
local catalog = serde.decode("json", fs.readFile("colectividad/src/shared/Catalogo.json"))
local shared = { Artworks = "Artworks", ExhibitConstants = "ExhibitConstants", Catalogo = "Catalogo", Introduccion = "Introduccion" }
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
env.script = { Parent = { Displays = "Displays", Geometry = "Geometry", Introduction = "Introduction", Catalogo = "Catalogo" } }
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
	["tonalli-en-el-xolo"] = {
		"Tonalli en el Xolo", "c7a24c96df32e5cab48af66856d2fe07fbef5fc3f40b216a0e5662a918db6ba4",
		"72a9501b398996778ff280b8f47ce76ee36b694446e417a8425c5936e8ea0daf",
		r.Vector3.new(20.35, 6.9, 11), -r.Vector3.xAxis, 8, 6, r.Vector3.new(20.28, 4.6, 16.70),
	},
	["encarnacion-de-xolotl"] = {
		"Encarnación de Xolotl", "717d555b1ecc1f701c8273fe3fb4d80954d1eca26874188584e6facd9f0634ba",
		"c98bd3482477680413d78f82642204721e94869e4c9c78dba9ec6013ed1ff3eb",
		r.Vector3.new(-20.35, 6.9, 37), r.Vector3.xAxis, 8, 6, r.Vector3.new(-20.28, 4.6, 44.5),
	},
}
assert(#catalog.items == 5)
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

-- Check clearance against the bounds of collidable architecture in room coordinates.
local function verifyRouteClearance(geometry, threshold)
	local solids = {}
	for _, node in findAll(geometry, "BasePart") do
		if node.CanCollide and node.Name ~= "Piso continuo" then
			local frame = threshold:ToObjectSpace(node.CFrame)
			local half = node.Size / 2
			local x, y, z = frame.XVector, frame.YVector, frame.ZVector
			local extent = r.Vector3.new(
				math.abs(x.X) * half.X + math.abs(y.X) * half.Y + math.abs(z.X) * half.Z,
				math.abs(x.Y) * half.X + math.abs(y.Y) * half.Y + math.abs(z.Y) * half.Z,
				math.abs(x.Z) * half.X + math.abs(y.Z) * half.Y + math.abs(z.Z) * half.Z
			)
			table.insert(solids, { name = node.Name, low = frame.Position - extent, high = frame.Position + extent })
		end
	end

	local function clear(low, high)
		for _, solid in solids do
			local intersects = low.X < solid.high.X and high.X > solid.low.X
				and low.Y < solid.high.Y and high.Y > solid.low.Y
				and low.Z < solid.high.Z and high.Z > solid.low.Z
			assert(not intersects, "Ruta obstruida por " .. solid.name)
		end
	end

	clear(r.Vector3.new(-5.95, 0.02, 0), r.Vector3.new(5.95, 9.9, 5))
	clear(r.Vector3.new(-13, 0.02, 49), r.Vector3.new(13, 8, 58))
	clear(r.Vector3.new(-19.4, 0.02, 33), r.Vector3.new(-14, 8, 46))
	clear(r.Vector3.new(-19.4, 0.02, 2), r.Vector3.new(-14, 8, 5.7))
	for _, center in { -10, 10 } do
		clear(r.Vector3.new(center - 3, 0.02, 5), r.Vector3.new(center + 3, 8, 58))
		for _, offset in { -1.5, 1.5 } do
			clear(r.Vector3.new(center + offset - 1.25, 0.05, 5), r.Vector3.new(center + offset + 1.25, 6.05, 58))
		end
	end
end

local function verifyRoom(built, threshold)
	local geometry = built.Arquitectura
	verifyRouteClearance(geometry, threshold)
	assert(#geometry.Procesion:GetChildren() == 5)
	assert(#findAll(geometry, "PointLight") == 10)
	assert(#findAll(geometry, "ParticleEmitter") == 0)
	assert(#findAll(built, "BasePart") <= 435)
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
	assert(not directory.CanCollide and directory.Senal.Texto.Text:find("005  Encarnación", 1, true))
	assert(threshold:PointToObjectSpace(directory.CFrame.Position).Y - directory.Size.Y / 2 > 10)
	local exhibits = built.Exhibidores
	local promptPositions = {}
	assert(#exhibits:GetChildren() == 5 and #findAll(exhibits, "ProximityPrompt") == 5)
	assert(#findAll(exhibits, "SurfaceLight") == 5 and #findAll(exhibits, "ParticleEmitter") == 0)
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
		{ slug = "tonalli-en-el-xolo", side = 1, z = 16.70 },
		{ slug = "encarnacion-de-xolotl", side = -1, z = 44.5 },
	}
	for _, station in sideExhibits do
		local exhibit = exhibits[station.slug]
		for _, piece in findAll(exhibit, "BasePart") do
			local localFrame = threshold:ToObjectSpace(piece.CFrame)
			local half = piece.Size / 2
			local xExtent = math.abs(localFrame.XVector.X) * half.X + math.abs(localFrame.YVector.X) * half.Y
				+ math.abs(localFrame.ZVector.X) * half.Z
			-- The wall assemblies sit behind the reading strips and walking corridors.
			assert(localFrame.X * station.side - xExtent > 19.4 and not piece.CanCollide and not piece.CanTouch)
		end
		local plaque = exhibit.Placa
		local promptOrigin = plaque.CFrame:PointToWorldSpace(plaque.PuntoDeLectura.Position)
		local reader = threshold:PointToWorldSpace(r.Vector3.new(station.side * 15, 4, station.z))
		assert((reader - promptOrigin).Magnitude < plaque.PuntoDeLectura[constants.promptName].MaxActivationDistance)
	end
	local spectral = exhibits["encarnacion-de-xolotl"]
	local background = spectral["Paño de piedra azul grisácea"]
	local backgroundZ = threshold:PointToObjectSpace(background.CFrame.Position).Z
	local priorPlaque = exhibits["itztlantli-en-el-nuevo-mundo"].Placa
	local priorEdge = threshold:PointToObjectSpace(priorPlaque.CFrame.Position).Z + priorPlaque.Size.X / 2
	assert(near(backgroundZ - background.Size.X / 2 - priorEdge, 0.35))
	local nextRelief
	for _, node in geometry["Relieves del valle"]:GetChildren() do
		local position = threshold:PointToObjectSpace(node.CFrame.Position)
		if node.Name == "Panel de pizarra" and position.X < 0 and near(position.Z, 51) then
			nextRelief = node
		end
	end
	assert(nextRelief)
	local nextEdge = threshold:PointToObjectSpace(nextRelief.CFrame.Position).Z - nextRelief.Size.Z / 2
	local plaqueEdge = threshold:PointToObjectSpace(spectral.Placa.CFrame.Position).Z + spectral.Placa.Size.X / 2
	assert(near(nextEdge - plaqueEdge, 0.2) and near(49 - plaqueEdge, 3))
	assert(spectral.Iluminacion.SurfaceLight.Range == 9 and not spectral.Iluminacion.SurfaceLight.Shadows)
	local memoryCount = 0
	for _, node in geometry["Viento, cempasúchil y memoria"]:GetChildren() do
		if node.Name == "Memoria" then
			local position = threshold:PointToObjectSpace(node.CFrame.Position)
			assert(near(position.X, -20.4) and math.abs(position.Y - 8.1) < 0.85 and math.abs(position.Z - 44.5) < 0.85)
			memoryCount += 1
		end
	end
	assert(memoryCount == 12)

	local panel = built[constants.introPanelName]
	local entryPrompt = panel.PuntoDeLectura[constants.introPromptName]
	local position = threshold:PointToObjectSpace(panel.CFrame.Position)
	assert((position - r.Vector3.new(-20.45, 4.35, 3.65)).Magnitude < 0.001)
	assert(near(panel.CFrame.LookVector:Dot(threshold.XVector), 1))
	assert(position.X + panel.Size.Z / 2 < -19.4 and not panel.CanCollide and not panel.CanTouch)
	assert(position.Z + panel.Size.X / 2 < 6.2)
	assert(panel.Cedula.Titulo.Text == load("Introduccion").title)
	assert(panel.Cedula.Extracto.Text == load("Introduccion").paragraphs[1])
	assert(entryPrompt.ActionText == "Leer introducción" and entryPrompt.RequiresLineOfSight and entryPrompt.ClickablePrompt)
	assert(#findAll(built, "ProximityPrompt") == 6)
	local introOrigin = panel.CFrame:PointToWorldSpace(entryPrompt.Parent.Position)
	assert((threshold:PointToWorldSpace(r.Vector3.new(-15, 4, 4)) - introOrigin).Magnitude < entryPrompt.MaxActivationDistance)
	for _, other in promptPositions do
		assert((introOrigin - other.position).Magnitude > entryPrompt.MaxActivationDistance + other.range)
	end
	local hearth = exhibits["el-calor-de-huehueteotl"]
	assert(hearth:FindFirstChild("Petate") and hearth:FindFirstChild("Fuego simbólico"))
	local eclipse = exhibits["itztlantli-en-el-nuevo-mundo"]
	assert(eclipse["Corona del eclipse"].Shape == r.Enum.PartType.Cylinder)
	assert(eclipse["Sombra del eclipse"].Shape == r.Enum.PartType.Cylinder)
	local solar = exhibits["tonalli-en-el-xolo"]
	assert(solar["Disco solar"].Shape == r.Enum.PartType.Cylinder)
	for i = 1, 3 do
		assert(solar:FindFirstChild("Cactus florido " .. i))
	end
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
reviewed.ImageIds["encarnacion-de-xolotl"] = "https://example.invalid/imagen.png"
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
local activations = {}
local inputType = r.Enum.UserInputType.Touch
r.implementMethod("Instance", "WaitForChild", function(node, name)
	return assert(node:FindFirstChild(name), name)
end)
r.implementProperty("GuiButton", "Activated", function(node)
	activations[node] = activations[node] or signal()
	return activations[node]
end)
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
local actions = {}
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
	UserInputService = { GetLastInputType = function() return inputType end },
	ContextActionService = {
		BindAction = function(_, name, callback)
			assert(not actions[name])
			actions[name] = callback
			bindings += 1
		end,
		UnbindAction = function(_, name)
			assert(actions[name])
			actions[name] = nil
			bindings -= 1
		end,
	},
	CollectionService = {
		GetTagged = function() return {} end,
		GetInstanceAddedSignal = signal,
		GetInstanceRemovedSignal = signal,
	},
}
local clientEnv = table.clone(r)
clientEnv.game = { GetService = function(_, name) return assert(clientServices[name], name) end }
clientEnv.require = function(name)
	if name == "ReaderView" and not modules.ReaderView then
		local path = "colectividad/src/client/ReaderView.luau"
		modules.ReaderView = luau.load(fs.readFile(path), { debugName = path, environment = clientEnv })()
	end
	return load(name)
end
clientEnv.script = { Parent = { ReaderView = "ReaderView" } }
local function runClient(name)
	local path = "colectividad/src/client/" .. name .. ".client.luau"
	luau.load(fs.readFile(path), { debugName = path, environment = clientEnv })()
end
runClient("Exhibit")
runClient("Introduction")
runClient("Exhibit")
runClient("Introduction")
assert(#playerGui:GetChildren() == 2 and promptTriggered:count() == 2)
local gui = playerGui[constants.guiName]
local introGui = playerGui[constants.introGuiName]
local activated = activations[gui.Ficha.Cerrar]
local introActivated = activations[introGui.Ficha.Cerrar]
assert(activated:count() == 1 and introActivated:count() == 1)
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
local tonalli = "tonalli-en-el-xolo"
local encarnacion = "encarnacion-de-xolotl"
for _, slug in { cauce, tonalli, encarnacion, itztlantli, calor, encarnacion, cauce } do
	promptTriggered:emit(prompts[slug], player)
	local expected = works[slug]
	assert(gui.Enabled and scroller.Obra.Text == expected[1] and scroller.Edicion.Text:find("1/1", 1, true))
	assert(scroller.Token.Text == expected[2] and scroller.Anuncio.Text == expected[3])
	assert(scroller.Explorador.Text == "Xolos Explorer" and bindings == 1)
end
prompts[tonalli]:SetAttribute(constants.artworkAttribute, cauce)
promptTriggered:emit(prompts[tonalli], player)
assert(scroller.Obra.Text == works[cauce][1] and bindings == 1)
activated:emit()
assert(not gui.Enabled and bindings == 0)
promptTriggered:emit(prompts[tonalli], player)
assert(not gui.Enabled and bindings == 0)
prompts[tonalli]:SetAttribute(constants.artworkAttribute, tonalli)
promptTriggered:emit(prompts[tonalli], player)
player.CharacterRemoving:emit()
assert(not gui.Enabled and bindings == 0)
local introPrompt = built[constants.introPanelName].PuntoDeLectura[constants.introPromptName]
local introCopy = load("Introduccion")
local introText = introGui.Ficha.Contenido
assert(introGui.ScreenInsets == r.Enum.ScreenInsets.CoreUISafeInsets and not introGui.ResetOnSpawn)
assert(introText.AutomaticCanvasSize == r.Enum.AutomaticSize.Y and introText.Selectable)
assert(introGui.Ficha.Cerrar.Size.Y.Offset >= 44 and introGui.Ficha.Cerrar.NextSelectionDown == introText)
assert(introText.Titulo.Text == introCopy.title and introText.Credito.Text == introCopy.credit)
for index, paragraph in introCopy.paragraphs do
	local label = introText["Parrafo" .. index]
	assert(label.Text == paragraph and label.TextWrapped and label.TextSize >= 16)
end
promptTriggered:emit(introPrompt, {})
promptTriggered:emit(part(hall, "ProximityPrompt", constants.introPromptName), player)
assert(not introGui.Enabled and bindings == 0)
promptTriggered:emit(introPrompt, player)
assert(introGui.Enabled and not gui.Enabled and bindings == 1)
promptTriggered:emit(prompts[encarnacion], player)
assert(gui.Enabled and not introGui.Enabled and bindings == 1 and scroller.Token.Text == works[encarnacion][2])
inputType = r.Enum.UserInputType.Gamepad1
promptTriggered:emit(introPrompt, player)
assert(introGui.Enabled and not gui.Enabled and bindings == 1)
assert(clientServices.GuiService.SelectedObject == introGui.Ficha.Cerrar)
actions.ColectividadCerrarIntroduccion(nil, r.Enum.UserInputState.Begin)
assert(not introGui.Enabled and not gui.Enabled and bindings == 0)
promptTriggered:emit(introPrompt, player)
introActivated:emit()
assert(not introGui.Enabled and bindings == 0)
promptTriggered:emit(introPrompt, player)
player.CharacterRemoving:emit()
assert(not introGui.Enabled and not gui.Enabled and bindings == 0)
print("OK: introducción accesible, foco exclusivo, cierre y reaparición")

print("OK: fichas correctas al alternar obras, aislamiento de prompts y una GUI y suscripción por lector")

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
	local clients = demoPlace.StarterPlayer.StarterPlayerScripts.ColectividadXoloitzcuintle
	assert(clients.Exhibit:IsA("LocalScript") and clients.Introduction:IsA("LocalScript"))
	assert(clients.ReaderView:IsA("ModuleScript") and sharedPackage.Introduccion:IsA("ModuleScript"))
	print("OK: artefacto Rojo y atributo de maqueta")
end
