-- Runs source modules with Lune datatypes. World queries are controlled test doubles.
local fs = require("@lune/fs")
local luau = require("@lune/luau")
local process = require("@lune/process")
local r = require("@lune/roblox")

local env = table.clone(r)
local paths = {
	Geometry = "server/Geometry",
	Displays = "server/Displays",
	Room = "server/Room",
	Settings = "server/Settings",
	Artworks = "shared/Artworks",
	ExhibitConstants = "shared/ExhibitConstants",
}
local shared = { Artworks = "Artworks", ExhibitConstants = "ExhibitConstants" }
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
env.script = { Parent = { Displays = "Displays", Geometry = "Geometry" } }
env.RaycastParams = { new = function() return {} end }
env.OverlapParams = { new = function() return {} end }

local modules = {}
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
local artwork = load("Artworks")["cauce-del-itzcuintlan"]
assert(artwork.edition == "1/1" and artwork.explorerName == "Xolos Explorer")
assert(artwork.tokenId == "750d49cd41749b550acbe59a8e81e4bcfcec5f74b2b49ae5d29145d17cad2ced")
assert(artwork.announcementId == "4ae0b1fadced2eb706bfa6845f56a1cb7b99b25843d915facc27125f3ffce06e")
assert(artwork.collection == "xolosArmy Community")
assert(room.install(settings, false) == nil)
rejects(function() room.install(settings, true) end, "Studio sin publicar")
studio = true

local function verifyRoom(built, threshold)
	local geometry = built.Arquitectura
	assert(#geometry.Procesion:GetChildren() == 5)
	assert(#findAll(geometry, "PointLight") == 10)
	assert(#findAll(geometry, "ParticleEmitter") == 0)
	assert(#findAll(built, "BasePart") <= 340)
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
	local prompts = findAll(built, "ProximityPrompt")
	assert(#prompts == 1 and prompts[1].MaxActivationDistance == 9)
	assert(prompts[1]:GetAttribute(constants.artworkAttribute) == "cauce-del-itzcuintlan")
	local art = built.Exhibidores["cauce-del-itzcuintlan"].Obra
	assert(art.Size.X == art.Size.Y and art.Size.X == 9 and art.Obra.Face == r.Enum.NormalId.Front)
	assert(art.Obra.Estado.Text:find("autorización", 1, true))
	assert(art.Obra:FindFirstChild("Imagen") == nil)
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
reviewed.ImageIds["cauce-del-itzcuintlan"] = "https://example.invalid/imagen.png"
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

if process.args[1] then
	local demoPlace = r.deserializePlace(fs.readFile(process.args[1]))
	local bootstrap = demoPlace.ServerScriptService.ColectividadXoloitzcuintle.Bootstrap
	assert(bootstrap:IsA("Script") and bootstrap:GetAttribute("Demo") == true)
	assert(demoPlace.ReplicatedStorage.ColectividadXoloitzcuintle.Artworks:IsA("ModuleScript"))
	assert(demoPlace.StarterPlayer.StarterPlayerScripts.ColectividadXoloitzcuintle.Exhibit:IsA("LocalScript"))
	print("OK: artefacto Rojo y atributo de maqueta")
end
