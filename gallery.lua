local gallery = Instance.new("Model", game.Workspace)
gallery.Name = "XolosArmyPyramidGallery"

local ContentProvider = game:GetService("ContentProvider")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Crear RemoteEvent para interacción NFT si no existe
local ShowNFTInfo = ReplicatedStorage:FindFirstChild("ShowNFTInfo") or Instance.new("RemoteEvent", ReplicatedStorage)
ShowNFTInfo.Name = "ShowNFTInfo"

Lighting.Ambient = Color3.fromRGB(255, 235, 180)
Lighting.OutdoorAmbient = Color3.fromRGB(255, 235, 180)

local nftData = {
	{name = "Eco de Mictlán", image = "rbxassetid://127060949306583", description = "Primer NFT de la colección."},
	{name = "Xolo de las Llamas", image = "rbxassetid://114618891546754", description = "Segundo NFT en exhibición."},
	{name = "Vigilante del Amanecer", image = "rbxassetid://127951867096643", description = "Tercer NFT exclusivo de XolosArmy."},
	{name = "Centinela del Crepúsculo", image = "rbxassetid://90112642641418", description = "Cuarto NFT único de la colección."}
}

local function preloadNFTImages()
	local assets = {}
	for _, nft in pairs(nftData) do
		table.insert(assets, nft.image)
	end
	ContentProvider:PreloadAsync(assets)
end

local function createPyramid(baseSize, height, position, parent)
	local pyramid = Instance.new("Model", parent)
	pyramid.Name = "PyramidStructure"

	local base = Instance.new("Part", pyramid)
	base.Size = Vector3.new(baseSize, 2, baseSize)
	base.Position = position
	base.Material = Enum.Material.Sand
	base.Color = Color3.fromRGB(190, 165, 125)
	base.Anchored = true

	local floor = Instance.new("Part", pyramid)
	floor.Size = Vector3.new(baseSize - 10, 1, baseSize - 10)
	floor.Position = position + Vector3.new(0, 3, 0)
	floor.Material = Enum.Material.SmoothPlastic
	floor.Color = Color3.fromRGB(120, 100, 80)
	floor.Anchored = true

	for i = 0, 3 do
		local step = Instance.new("Part", pyramid)
		step.Size = Vector3.new(10, 1, 5)
		step.Position = position + Vector3.new(0, i, -baseSize / 2 + 5 + i * 2)
		step.Material = Enum.Material.Sand
		step.Color = Color3.fromRGB(200, 170, 120)
		step.Anchored = true
	end

	local light = Instance.new("PointLight", floor)
	light.Brightness = 2
	light.Range = 20
	light.Color = Color3.fromRGB(255, 255, 100)

	return pyramid, floor.Position
end

local function createTeleportPad(position, destination)
	local pad = Instance.new("Part", game.Workspace)
	pad.Size = Vector3.new(8, 1, 8)
	pad.Position = position + Vector3.new(0, 0.5, 0)
	pad.Color = Color3.fromRGB(0, 0, 255)
	pad.Material = Enum.Material.Neon
	pad.Anchored = true

	local sign = Instance.new("Part", game.Workspace)
	sign.Size = Vector3.new(6, 2, 0.5)
	sign.Position = pad.Position + Vector3.new(0, 3, 0)
	sign.Anchored = true
	sign.Color = Color3.fromRGB(255, 255, 255)

	local signGui = Instance.new("BillboardGui", sign)
	signGui.Size = UDim2.new(5, 0, 2, 0)
	signGui.StudsOffset = Vector3.new(0, 2, 0)

	local text = Instance.new("TextLabel", signGui)
	text.Size = UDim2.new(1, 0, 1, 0)
	text.Text = "Step Here to Enter Pyramid"
	text.TextScaled = true
	text.BackgroundTransparency = 1
	text.TextColor3 = Color3.fromRGB(0, 0, 0)

	pad.Touched:Connect(function(hit)
		local character = hit.Parent
		if character and character:FindFirstChild("HumanoidRootPart") then
			character:SetPrimaryPartCFrame(CFrame.new(destination))
		end
	end)

	return pad
end

local function createNFTDisplay(nft, position, parent)
	local pillar = Instance.new("Part", parent)
	pillar.Size = Vector3.new(4, 10, 4)
	pillar.Position = position
	pillar.Material = Enum.Material.Marble
	pillar.Color = Color3.fromRGB(200, 200, 200)
	pillar.Anchored = true

	local frame = Instance.new("Part", parent)
	frame.Size = Vector3.new(5, 5, 0.5)
	frame.Position = position + Vector3.new(0, 6, 2.5)
	frame.Material = Enum.Material.SmoothPlastic
	frame.Color = Color3.fromRGB(30, 30, 30)
	frame.Anchored = true

	local decal = Instance.new("Decal", frame)
	decal.Texture = nft.image
	decal.Face = Enum.NormalId.Front

	-- Aquí va el prompt para la GUI
	local prompt = Instance.new("ProximityPrompt", frame)
	prompt.ActionText = "Ver NFT"
	prompt.ObjectText = nft.name
	prompt.HoldDuration = 0.5
	prompt.MaxActivationDistance = 10

	prompt.Triggered:Connect(function(player)
		ShowNFTInfo:FireClient(player, nft.name, nft.description)
	end)
end

local function createNPC(position, parent)
	local npc = Instance.new("Model", parent)
	npc.Name = "GuideNPC"

	local body = Instance.new("Part", npc)
	body.Size = Vector3.new(2, 5, 2)
	body.Position = position
	body.Anchored = true
	body.Material = Enum.Material.SmoothPlastic
	body.Color = Color3.fromRGB(200, 100, 50)

	local head = Instance.new("Part", npc)
	head.Size = Vector3.new(2, 2, 2)
	head.Position = position + Vector3.new(0, 3, 0)
	head.Anchored = true
	head.Material = Enum.Material.SmoothPlastic
	head.Color = Color3.fromRGB(255, 200, 150)

	local billboard = Instance.new("BillboardGui", head)
	billboard.Size = UDim2.new(0, 200, 0, 50)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.Adornee = head
	billboard.AlwaysOnTop = true

	local textLabel = Instance.new("TextLabel", billboard)
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = "¡Hola! Acércate a los NFTs para interactuar."
	textLabel.TextScaled = true
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.Font = Enum.Font.SourceSansBold

	local prompt = Instance.new("ProximityPrompt", head)
	prompt.ActionText = "Leer instrucciones"
	prompt.ObjectText = "Guía"
	prompt.HoldDuration = 1
	prompt.MaxActivationDistance = 10
	prompt.PromptText = "Presiona para ver cómo interactuar con los NFTs"
	prompt.Triggered:Connect(function(player)
		-- Podrías mostrar otra GUI aquí si quieres.
	end)
end

-- Crear galería y objetos
local pyramid, interiorPosition = createPyramid(60, 30, Vector3.new(0, 0, 0), gallery)
createTeleportPad(Vector3.new(0, 3, -30), interiorPosition + Vector3.new(0, 3, 0))
for i, nft in pairs(nftData) do
	createNFTDisplay(nft, interiorPosition + Vector3.new(-20 + (i - 1) * 10, 0, 0), gallery)
end
createNPC(interiorPosition + Vector3.new(0, 2.5, 10), gallery)
preloadNFTImages()
