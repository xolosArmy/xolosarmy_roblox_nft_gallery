local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local constants = require(ReplicatedStorage.ColectividadXoloitzcuintle.ExhibitConstants)
local Displays = require(script.Parent.Displays)
local Geometry = require(script.Parent.Geometry)
local Introduction = require(script.Parent.Introduction)

local Room = {}

local function uniqueChild(parent, name)
	local match
	for _, child in parent:GetChildren() do
		if child.Name == name then
			assert(match == nil, "Hay más de una instancia llamada " .. name .. " en " .. parent:GetFullName())
			match = child
		end
	end
	return match
end

local function resolveThreshold(settings)
	local model = Workspace
	assert(#settings.AnchorModelPath > 0, "Falta la ruta del modelo del Museo del Itzcuintlan")
	for _, name in settings.AnchorModelPath do
		model = assert(uniqueChild(model, name), "Falta la instancia " .. name .. " en la ruta del museo")
	end
	assert(model:IsA("Model"), "La ruta del museo debe terminar en un Model")

	local threshold
	for _, child in model:GetDescendants() do
		if child.Name == "ColectividadThreshold" then
			assert(threshold == nil, "El modelo tiene más de una instancia ColectividadThreshold")
			threshold = child
		end
	end
	assert(threshold and threshold:IsA("Attachment"), "Falta el Attachment ColectividadThreshold en el modelo")
	assert(threshold.Parent:IsA("BasePart") and threshold.Parent.Anchored, "El soporte del umbral debe estar anclado")

	local frame = threshold.WorldCFrame
	local expected = settings.ExpectedThresholdCFrame
	assert(typeof(expected) == "CFrame", "Falta ExpectedThresholdCFrame")
	assert((frame.Position - expected.Position).Magnitude <= 0.05, "El umbral cambió de posición")
	assert(frame.UpVector:Dot(Vector3.yAxis) >= 0.99999, "El eje vertical del umbral debe coincidir con el del mundo")
	assert(frame.ZVector:Dot(expected.ZVector) >= 0.99999, "El umbral cambió de orientación")
	return frame
end

local function assertFreeVolume(frame, size, params, name)
	local parts = Workspace:GetPartBoundsInBox(frame, size, params)
	if #parts > 0 then
		error(name .. " intersecta " .. parts[1]:GetFullName())
	end
end

local function checkClearance(frame)
	local floorQuery = RaycastParams.new()
	floorQuery.RespectCanCollide = true
	floorQuery.IgnoreWater = true

	for _, x in { -5, 0, 5 } do
		for _, z in { -0.4, -2.75 } do
			local floorHit = Workspace:Raycast(frame:PointToWorldSpace(Vector3.new(x, 0.8, z)), Vector3.new(0, -1.6, 0), floorQuery)
			assert(floorHit and math.abs(floorHit.Position.Y - frame.Position.Y) <= 0.2
				and floorHit.Normal:Dot(Vector3.yAxis) >= 0.98, "El acceso del museo no tiene un piso continuo al nivel del umbral")
		end
	end

	local volumeQuery = OverlapParams.new()
	volumeQuery.RespectCanCollide = true
	-- The opening is checked separately across the seam. Terrain and the full route require a visual Studio check.
	volumeQuery.MaxParts = 1
	assertFreeVolume(frame * CFrame.new(0, 8.125, 32.025), Vector3.new(44, 15.75, 63.95), volumeQuery, "El volumen reservado")
	assertFreeVolume(frame * CFrame.new(0, 5.125, -1.5), Vector3.new(12, 9.75, 3.2), volumeQuery, "El acceso")
end

local function buildDemoApproach(room)
	local approach = Instance.new("Folder")
	approach.Name = "AccesoDePrueba"
	approach.Parent = room

	local function part(className, name, size, frame)
		local node = Instance.new(className)
		node.Name = name
		node.Size = size
		node.CFrame = frame
		node.Anchored = true
		node.Material = Enum.Material.Slate
		node.Color = Color3.fromRGB(76, 63, 53)
		node.Parent = approach
		return node
	end

	part("Part", "Piso", Vector3.new(12, 1, 12), CFrame.new(0, -0.5, -6))
	part("Part", "LimiteIzquierdo", Vector3.new(0.45, 7, 12), CFrame.new(-5.775, 3.5, -6))
	part("Part", "LimiteDerecho", Vector3.new(0.45, 7, 12), CFrame.new(5.775, 3.5, -6))
	part("Part", "Fondo", Vector3.new(11.1, 7, 0.45), CFrame.new(0, 3.5, -11.775))
	local spawn = part("SpawnLocation", "Inicio", Vector3.new(3, 0.5, 3), CFrame.new(0, -0.25, -8) * CFrame.Angles(0, math.pi, 0))
	spawn.Transparency = 1
	spawn.CanCollide = false
	spawn.Neutral = true
	spawn.Enabled = true
	spawn.Duration = 0
end

function Room.install(settings, demo)
	if demo then
		assert(RunService:IsStudio() and game.PlaceId == 0 and game.GameId == 0, "La maqueta solo funciona en un Place local de Studio sin publicar")
	else
		local placeId, universeId = settings.TestPlaceId, settings.TestUniverseId
		if placeId <= 0 or universeId <= 0 or game.PlaceId ~= placeId or game.GameId ~= universeId then
			return nil
		end
		assert(settings.ReviewedClearance == true, "Falta la revisión del acceso y volumen en la copia de prueba")
	end

	local existing = uniqueChild(Workspace, constants.roomName)
	if existing then
		assert(existing:IsA("Model") and existing:GetAttribute(constants.ownerAttribute) == constants.ownerId, "El nombre de la sala ya está ocupado")
		return existing
	end

	local threshold = CFrame.identity
	if demo then
		for _, child in Workspace:GetChildren() do
			assert(child:IsA("Terrain") or child:IsA("Camera"), "La maqueta requiere un Workspace vacío")
		end
	else
		threshold = resolveThreshold(settings)
		checkClearance(threshold)
	end

	local room = Instance.new("Model")
	room.Name = constants.roomName
	room:SetAttribute(constants.ownerAttribute, constants.ownerId)
	room.WorldPivot = threshold

	local success, problem = pcall(function()
		if demo then
			buildDemoApproach(room)
		end
		Geometry.build(room, threshold, demo)
		Displays.build(room, threshold, settings.ImageIds)
		Introduction.build(room, threshold)
	end)
	if not success then
		room:Destroy()
		error(problem, 0)
	end

	room.Parent = Workspace
	return room
end

return Room
