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

local function buildEclipse(exhibit, frame)
	local backdrop = Color3.fromRGB(48, 34, 61)
	local violet = Color3.fromRGB(122, 91, 160)
	local darkViolet = Color3.fromRGB(72, 53, 91)

	panelPart(exhibit, "Paño de obsidiana", frame * CFrame.new(0, 0, 0.48),
		Vector3.new(10.6, 11.6, 0.26), backdrop)

	local eclipse = frame * CFrame.new(-6.05, 0, 0.12)
	local axis = CFrame.Angles(0, math.pi / 2, 0)
	local corona = panelPart(exhibit, "Corona del eclipse", eclipse * axis,
		Vector3.new(0.16, 2, 2), violet)
	corona.Shape = Enum.PartType.Cylinder
	corona.Material = Enum.Material.SmoothPlastic
	local shadow = panelPart(exhibit, "Sombra del eclipse", eclipse * CFrame.new(0.16, 0.12, -0.09) * axis,
		Vector3.new(0.16, 1.65, 1.65), obsidian)
	shadow.Shape = Enum.PartType.Cylinder

	for step = -4, 4 do
		local y = -4.65 - (math.abs(step) % 3) * 0.24
		panelPart(exhibit, "Trama de obsidiana", frame * CFrame.new(step * 0.9, y, 0.24),
			Vector3.new(0.9, 0.24, 0.18), if step % 3 == 0 then violet else darkViolet)
	end
end

local function buildTonalli(exhibit, frame)
	local clay = Color3.fromRGB(104, 58, 44)
	local solar = Color3.fromRGB(210, 150, 83)
	local cactusClay = Color3.fromRGB(172, 111, 81)
	local petals = Color3.fromRGB(223, 147, 108)

	panelPart(exhibit, "Paño de terracota", frame * CFrame.new(0.35, 0, 0.46),
		Vector3.new(11.3, 11.6, 0.28), clay)

	local sun = frame * CFrame.new(5.13, 1.5, 0.26)
	local disc = panelPart(exhibit, "Disco solar", sun * CFrame.Angles(0, math.pi / 2, 0),
		Vector3.new(0.14, 1.12, 1.12), solar)
	disc.Shape = Enum.PartType.Cylinder
	for ray = 0, 7 do
		panelPart(exhibit, "Rayo solar",
			sun * CFrame.Angles(0, 0, ray * math.pi / 4) * CFrame.new(0, 0.69, 0),
			Vector3.new(0.055, 0.15, 0.14), solar)
	end

	local heights = {0.88, 1.06, 0.96}
	for index, height in ipairs(heights) do
		local cactus = Instance.new("Model")
		cactus.Name = "Cactus florido " .. index
		cactus.Parent = exhibit

		local base = frame * CFrame.new((2 - index) * 2.7, -5.64, 0.24)
		panelPart(cactus, "Tallo", base * CFrame.new(0, height / 2, 0),
			Vector3.new(0.16, height, 0.16), cactusClay)
		for _, side in ipairs({-1, 1}) do
			local branchHeight = if side == -1 then 0.27 else 0.38
			local branch = base * CFrame.new(side * 0.22, height * 0.34, 0)
			panelPart(cactus, "Brazo", base * CFrame.new(side * 0.11, height * 0.34, 0),
				Vector3.new(0.24, 0.105, 0.16), cactusClay)
			panelPart(cactus, "Brote", branch * CFrame.new(0, branchHeight / 2, 0),
				Vector3.new(0.10, branchHeight, 0.16), cactusClay)
		end

		local bloom = base * CFrame.new(0, height + 0.12, -0.08)
		for petal = 0, 4 do
			local lobe = panelPart(cactus, "Pétalo",
				bloom * CFrame.Angles(0, 0, petal * 2 * math.pi / 5) * CFrame.new(0, 0.11, 0),
				Vector3.new(0.12, 0.17, 0.10), petals)
			lobe.Shape = Enum.PartType.Ball
		end
		local center = panelPart(cactus, "Centro de flor", bloom * CFrame.new(0, 0, -0.05),
			Vector3.new(0.13, 0.13, 0.10), solar)
		center.Shape = Enum.PartType.Ball
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
	{
		artworkId = "itztlantli-en-el-nuevo-mundo",
		artFrame = CFrame.new(-20.35, 6.9, 23) * CFrame.Angles(0, -math.pi / 2, 0),
		plaqueFrame = CFrame.new(-20.28, 4.6, 30.15) * CFrame.Angles(0, -math.pi / 2, 0),
		artSize = 8,
		plaqueWidth = 3.8,
		plaqueTitleSize = 30,
		promptRange = 7,
		lightColor = Color3.fromRGB(174, 133, 237),
		accent = Color3.fromRGB(208, 177, 244),
		decorate = buildEclipse,
	},
	{
		artworkId = "tonalli-en-el-xolo",
		artFrame = CFrame.new(20.35, 6.9, 11) * CFrame.Angles(0, math.pi / 2, 0),
		plaqueFrame = CFrame.new(20.28, 4.6, 16.7) * CFrame.Angles(0, math.pi / 2, 0),
		artSize = 8,
		plaqueWidth = 2.6,
		plaqueTitleSize = 24,
		promptRange = 6,
		lightColor = Color3.fromRGB(249, 204, 144),
		accent = Color3.fromRGB(218, 164, 110),
		decorate = buildTonalli,
	},
}

local function buildSlot(parent, threshold, slot, artwork, contentId)
	local exhibit = Instance.new("Model")
	exhibit.Name = slot.artworkId
	exhibit.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
	exhibit.Parent = parent

	local frame = threshold * slot.artFrame
	local accent = slot.accent or amber
	local edge = slot.artSize + 0.6
	panelPart(exhibit, "Marco", frame * CFrame.new(0, 0, 0.25), Vector3.new(edge, edge, 0.35), basalt)
	local art = panelPart(exhibit, "Obra", frame, Vector3.new(slot.artSize, slot.artSize, 0.2), obsidian)
	local artCanvas = canvas(art, "Obra", Vector2.new(900, 900))
	local placeholder = label(artCanvas, "Estado", "Imagen pendiente\nde autorización en Roblox", UDim2.fromScale(0.1, 0.25), UDim2.fromScale(0.8, 0.5), 49, accent, true)
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
	label(plaqueCanvas, "Titulo", artwork.title, UDim2.fromScale(0.06, 0.08), UDim2.fromScale(0.88, 0.24), slot.plaqueTitleSize or 35, parchment)
	label(plaqueCanvas, "Edicion", "Edición " .. artwork.edition .. " · xolosArmy Network", UDim2.fromScale(0.06, 0.33), UDim2.fromScale(0.88, 0.21), 24, accent)
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

	local lamp = panelPart(exhibit, "Iluminacion", frame * CFrame.new(0, slot.artSize / 2 + 0.6, -0.6), Vector3.new(4.5, 0.24, 0.52), accent)
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
