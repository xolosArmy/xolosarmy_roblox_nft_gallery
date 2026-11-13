local ReplicatedStorage = game:GetService("ReplicatedStorage")
local shared = ReplicatedStorage.ColectividadXoloitzcuintle
local artworks = require(shared.Artworks)
local constants = require(shared.ExhibitConstants)

local Displays = {}

local basalt = Color3.fromRGB(37, 35, 34)
local obsidian = Color3.fromRGB(22, 24, 24)
local amber = Color3.fromRGB(228, 171, 98)
local parchment = Color3.fromRGB(249, 235, 207)

local function panelPart(parent, name, frame, size, color)
	local part = Instance.new("Part")
	part.Name = name
	part.CFrame = frame
	part.Size = size
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Material = Enum.Material.Slate
	part.Color = color
	part.Parent = parent
	return part
end

local function canvas(part, name, size)
	local surface = Instance.new("SurfaceGui")
	surface.Name = name
	surface.Face = Enum.NormalId.Front
	surface.SizingMode = Enum.SurfaceGuiSizingMode.FixedSize
	surface.CanvasSize = size
	surface.LightInfluence = 0
	surface.MaxDistance = 72
	surface.Parent = part
	return surface
end

local function label(parent, name, value, position, size, fontSize, color, centered)
	local node = Instance.new("TextLabel")
	node.Name = name
	node.Position = position
	node.Size = size
	node.BackgroundTransparency = 1
	node.Font = Enum.Font.GothamMedium
	node.Text = value
	node.TextColor3 = color
	node.TextSize = fontSize
	node.TextWrapped = true
	node.TextXAlignment = if centered then Enum.TextXAlignment.Center else Enum.TextXAlignment.Left
	node.Parent = parent
	return node
end

local function buildHearth(exhibit, frame)
	local backdrop = Color3.fromRGB(86, 49, 37)
	local fiber = Color3.fromRGB(179, 125, 78)
	local darkFiber = Color3.fromRGB(128, 81, 52)
	local ember = Color3.fromRGB(229, 116, 58)

	panelPart(exhibit, "Paño de arcilla", frame * CFrame.new(0, 0, 0.45),
		Vector3.new(10.6, 11.6, 0.28), backdrop)
	local weave = frame * CFrame.new(0, -4.9, -0.08)
	panelPart(exhibit, "Petate", weave, Vector3.new(8.6, 1.08, 0.12), darkFiber)
	for strand = -11, 11 do
		panelPart(exhibit, "Urdimbre", weave * CFrame.new(strand * 0.36, 0, -0.075),
			Vector3.new(0.09, 1.03, 0.035), fiber)
	end
	for row = -2, 2 do
		local band = panelPart(exhibit, "Trama", weave * CFrame.new(0, row * 0.2, -0.1),
			Vector3.new(8.45, 0.075, 0.035), if row % 2 == 0 then fiber else darkFiber)
		band.Material = Enum.Material.Fabric
	end

	local mark = frame * CFrame.new(-6.7, -2.3, 0.2)
	panelPart(exhibit, "Placa del brasero", mark, Vector3.new(2.05, 2.5, 0.2), backdrop)
	for level = 0, 2 do
		panelPart(exhibit, "Brasero", mark * CFrame.new(0, -0.92 + level * 0.14, -0.15),
			Vector3.new(0.55 + level * 0.32, 0.14, 0.16), fiber)
	end
	for index = -1, 1 do
		local flame = panelPart(exhibit, "Fuego simbólico",
			mark * CFrame.new(index * 0.37, 0.1 - math.abs(index) * 0.2, -0.15)
				* CFrame.Angles(0, 0, index * 0.36),
			Vector3.new(0.18, 1.05 - math.abs(index) * 0.24, 0.13), ember)
		flame.Material = Enum.Material.Neon
	end
end

local slots = {
	{
		artworkId = "cauce-del-itzcuintlan",
		artFrame = CFrame.new(0, 7.65, 62.25),
		plaqueFrame = CFrame.new(7.7, 4.6, 62.18),
		artSize = 9,
		plaqueWidth = 5.5,
		promptRange = 9,
		lightColor = Color3.fromRGB(255, 224, 175),
	},
	{
		artworkId = "el-calor-de-huehueteotl",
		artFrame = CFrame.new(20.35, 6.9, 37) * CFrame.Angles(0, math.pi / 2, 0),
		plaqueFrame = CFrame.new(20.28, 4.6, 30.05) * CFrame.Angles(0, math.pi / 2, 0),
		artSize = 8,
		plaqueWidth = 4.5,
		promptRange = 7,
		lightColor = Color3.fromRGB(255, 174, 108),
		decorate = buildHearth,
	},
}

local function buildSlot(parent, threshold, slot, artwork, contentId)
	local exhibit = Instance.new("Model")
	exhibit.Name = slot.artworkId
	exhibit.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
	exhibit.Parent = parent

	local frame = threshold * slot.artFrame
	local edge = slot.artSize + 0.6
	panelPart(exhibit, "Marco", frame * CFrame.new(0, 0, 0.25), Vector3.new(edge, edge, 0.35), basalt)
	local art = panelPart(exhibit, "Obra", frame, Vector3.new(slot.artSize, slot.artSize, 0.2), obsidian)
	local artCanvas = canvas(art, "Obra", Vector2.new(900, 900))
	local placeholder = label(artCanvas, "Estado", "Imagen pendiente\nde autorización en Roblox", UDim2.fromScale(0.1, 0.25), UDim2.fromScale(0.8, 0.5), 49, amber, true)
	if contentId then
		-- The label stays behind the texture while the asset loads.
		local image = Instance.new("ImageLabel")
		image.Name = "Imagen"
		image.Size = UDim2.fromScale(1, 1)
		image.BackgroundTransparency = 1
		image.ScaleType = Enum.ScaleType.Fit
		image.Image = contentId
		image.ZIndex = 2
		image.Parent = artCanvas
		image:AddTag(constants.imageTag)
		-- Hide the placeholder on clients only after the texture loads.
		placeholder.Text = "Imagen de la obra\nCargando o no disponible"
	end

	local plaque = panelPart(exhibit, "Placa", threshold * slot.plaqueFrame, Vector3.new(slot.plaqueWidth, 3.15, 0.22), basalt)
	local plaqueCanvas = canvas(plaque, "Ficha", Vector2.new(slot.plaqueWidth * 100, 315))
	label(plaqueCanvas, "Titulo", artwork.title, UDim2.fromScale(0.06, 0.08), UDim2.fromScale(0.88, 0.24), 35, parchment)
	label(plaqueCanvas, "Edicion", "Edición " .. artwork.edition .. " · xolosArmy Network", UDim2.fromScale(0.06, 0.33), UDim2.fromScale(0.88, 0.21), 24, amber)
	label(plaqueCanvas, "Lectura", artwork.plaque, UDim2.fromScale(0.06, 0.56), UDim2.fromScale(0.88, 0.31), 27, parchment)

	local promptOrigin = Instance.new("Attachment")
	promptOrigin.Name = "PuntoDeLectura"
	promptOrigin.Position = Vector3.new(0, -0.75, -0.5)
	promptOrigin.Parent = plaque

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = constants.promptName
	prompt.ObjectText = artwork.title
	prompt.ActionText = "Leer ficha"
	prompt.MaxActivationDistance = slot.promptRange
	prompt.RequiresLineOfSight = true
	prompt.ClickablePrompt = true
	prompt:SetAttribute(constants.artworkAttribute, slot.artworkId)
	prompt.Parent = promptOrigin

	local lamp = panelPart(exhibit, "Iluminacion", frame * CFrame.new(0, slot.artSize / 2 + 0.6, -0.6), Vector3.new(4.5, 0.24, 0.52), amber)
	lamp.Material = Enum.Material.Metal
	local light = Instance.new("SurfaceLight")
	light.Face = Enum.NormalId.Bottom
	light.Angle = 115
	light.Brightness = 1.5
	light.Color = slot.lightColor
	light.Range = 13
	light.Parent = lamp

	if slot.decorate then
		slot.decorate(exhibit, frame)
	end
end

function Displays.build(room, threshold, imageIds)
	local displays = Instance.new("Folder")
	displays.Name = constants.displaysName
	displays.Parent = room

	for _, slot in slots do
		local artwork = assert(artworks[slot.artworkId], "Faltan los datos de " .. slot.artworkId)
		local contentId = imageIds[slot.artworkId]
		if contentId ~= nil and contentId ~= "" then
			assert(type(contentId) == "string" and contentId:match("^rbxassetid://[1-9]%d*$"), "ID de imagen inválido para " .. slot.artworkId)
		else
			contentId = nil
		end
		buildSlot(displays, threshold, slot, artwork, contentId)
	end
end

return Displays
