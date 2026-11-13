local ReplicatedStorage = game:GetService("ReplicatedStorage")
local shared = ReplicatedStorage.ColectividadXoloitzcuintle
local artworks = require(shared.Artworks)
local constants = require(shared.ExhibitConstants)

local Displays = {}

local slots = {
	{
		artworkId = "cauce-del-itzcuintlan",
		center = Vector3.new(0, 7.65, 62.25),
		plaque = Vector3.new(7.7, 4.6, 62.18),
	},
}

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

local function buildSlot(parent, threshold, slot, artwork, contentId)
	local exhibit = Instance.new("Model")
	exhibit.Name = slot.artworkId
	exhibit.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
	exhibit.Parent = parent

	panelPart(exhibit, "Marco", threshold * CFrame.new(slot.center + Vector3.new(0, 0, 0.25)), Vector3.new(9.6, 9.6, 0.35), basalt)
	local art = panelPart(exhibit, "Obra", threshold * CFrame.new(slot.center), Vector3.new(9, 9, 0.2), obsidian)
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

	local plaque = panelPart(exhibit, "Placa", threshold * CFrame.new(slot.plaque), Vector3.new(5.5, 3.15, 0.22), basalt)
	local plaqueCanvas = canvas(plaque, "Ficha", Vector2.new(550, 315))
	label(plaqueCanvas, "Titulo", artwork.title, UDim2.fromScale(0.06, 0.08), UDim2.fromScale(0.88, 0.24), 35, parchment)
	label(plaqueCanvas, "Edicion", "Edición " .. artwork.edition .. " · xolosArmy Network", UDim2.fromScale(0.06, 0.33), UDim2.fromScale(0.88, 0.21), 24, amber)
	label(plaqueCanvas, "Lectura", "Lectura poética del Valle de México y del Itzcuintlan", UDim2.fromScale(0.06, 0.56), UDim2.fromScale(0.88, 0.31), 27, parchment)

	local promptOrigin = Instance.new("Attachment")
	promptOrigin.Name = "PuntoDeLectura"
	promptOrigin.Position = Vector3.new(0, -0.75, -0.5)
	promptOrigin.Parent = plaque

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = constants.promptName
	prompt.ObjectText = artwork.title
	prompt.ActionText = "Leer ficha"
	prompt.MaxActivationDistance = 9
	prompt.RequiresLineOfSight = true
	prompt.ClickablePrompt = true
	prompt:SetAttribute(constants.artworkAttribute, slot.artworkId)
	prompt.Parent = promptOrigin

	local lamp = panelPart(exhibit, "Iluminacion", threshold * CFrame.new(slot.center + Vector3.new(0, 5.1, -0.6)), Vector3.new(4.5, 0.24, 0.52), amber)
	lamp.Material = Enum.Material.Metal
	local light = Instance.new("SurfaceLight")
	light.Face = Enum.NormalId.Bottom
	light.Angle = 115
	light.Brightness = 1.5
	light.Color = Color3.fromRGB(255, 224, 175)
	light.Range = 13
	light.Parent = lamp
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
