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

local function createSpiritHall(startPosition, parent)
        local hall = Instance.new("Model", parent)
        hall.Name = "SalaDeLosEspiritus"

        local corridorLength = 20
        local corridor = Instance.new("Part", hall)
        corridor.Size = Vector3.new(6, 1, corridorLength)
        corridor.Position = startPosition + Vector3.new(0, 0.5, corridorLength / 2)
        corridor.Anchored = true
        corridor.Material = Enum.Material.Slate
        corridor.Color = Color3.fromRGB(50, 50, 50)

        local wallHeight = 8
        local wallThickness = 1

        local leftWall = Instance.new("Part", hall)
        leftWall.Size = Vector3.new(wallThickness, wallHeight, corridorLength)
        leftWall.Position = corridor.Position + Vector3.new(-(corridor.Size.X / 2 + wallThickness / 2), wallHeight / 2, 0)
        leftWall.Anchored = true
        leftWall.Material = Enum.Material.Slate
        leftWall.Color = Color3.fromRGB(40, 40, 40)

        local rightWall = leftWall:Clone()
        rightWall.Position = corridor.Position + Vector3.new((corridor.Size.X / 2 + wallThickness / 2), wallHeight / 2, 0)
        rightWall.Parent = hall

        local roof = Instance.new("Part", hall)
        roof.Size = Vector3.new(corridor.Size.X, 1, corridorLength)
        roof.Position = corridor.Position + Vector3.new(0, wallHeight, 0)
        roof.Anchored = true
        roof.Material = Enum.Material.Slate
        roof.Color = Color3.fromRGB(35, 35, 35)

        local hallSizeX, hallSizeZ = 20, 24
        local hallCenter = startPosition + Vector3.new(0, 0, corridorLength + hallSizeZ / 2)

        local floor = Instance.new("Part", hall)
        floor.Size = Vector3.new(hallSizeX, 1, hallSizeZ)
        floor.Position = hallCenter + Vector3.new(0, 0.5, 0)
        floor.Anchored = true
        floor.Material = Enum.Material.Basalt
        floor.Color = Color3.fromRGB(45, 45, 45)

        local backWall = Instance.new("Part", hall)
        backWall.Size = Vector3.new(hallSizeX, wallHeight, wallThickness)
        backWall.Position = hallCenter + Vector3.new(0, wallHeight / 2, hallSizeZ / 2)
        backWall.Anchored = true
        backWall.Material = Enum.Material.Slate
        backWall.Color = Color3.fromRGB(40, 40, 40)

        local frontWall = backWall:Clone()
        frontWall.Position = hallCenter + Vector3.new(0, wallHeight / 2, -hallSizeZ / 2)
        frontWall.Parent = hall

        local leftHallWall = Instance.new("Part", hall)
        leftHallWall.Size = Vector3.new(wallThickness, wallHeight, hallSizeZ)
        leftHallWall.Position = hallCenter + Vector3.new(-(hallSizeX / 2), wallHeight / 2, 0)
        leftHallWall.Anchored = true
        leftHallWall.Material = Enum.Material.Slate
        leftHallWall.Color = Color3.fromRGB(40, 40, 40)

        local rightHallWall = leftHallWall:Clone()
        rightHallWall.Position = hallCenter + Vector3.new(hallSizeX / 2, wallHeight / 2, 0)
        rightHallWall.Parent = hall

        local ceiling = Instance.new("Part", hall)
        ceiling.Size = Vector3.new(hallSizeX, 1, hallSizeZ)
        ceiling.Position = hallCenter + Vector3.new(0, wallHeight, 0)
        ceiling.Anchored = true
        ceiling.Material = Enum.Material.Slate
        ceiling.Color = Color3.fromRGB(35, 35, 35)

        local walkway = Instance.new("Part", hall)
        walkway.Size = Vector3.new(4, 0.3, hallSizeZ - 8)
        walkway.Position = hallCenter + Vector3.new(0, 0.2, -2)
        walkway.Anchored = true
        walkway.Material = Enum.Material.Slate
        walkway.Color = Color3.fromRGB(70, 70, 70)

        local smoke = Instance.new("Smoke", walkway)
        smoke.Color = Color3.fromRGB(200, 200, 200)
        smoke.Opacity = 0.2
        smoke.RiseVelocity = 2

        local altar = Instance.new("Part", hall)
        altar.Size = Vector3.new(6, 2, 6)
        altar.Position = hallCenter + Vector3.new(0, 1, hallSizeZ / 2 - 4)
        altar.Anchored = true
        altar.Material = Enum.Material.Slate
        altar.Color = Color3.fromRGB(60, 60, 60)

        local statue = Instance.new("Part", hall)
        statue.Size = Vector3.new(2, 4, 2)
        statue.Position = altar.Position + Vector3.new(0, 3, 0)
        statue.Anchored = true
        statue.Material = Enum.Material.SmoothPlastic
        statue.Color = Color3.fromRGB(80, 80, 80)

        local muralLeft = Instance.new("Part", hall)
        muralLeft.Size = Vector3.new(4, 6, 0.5)
        muralLeft.Position = altar.Position + Vector3.new(-7, 3, 0)
        muralLeft.Anchored = true
        muralLeft.Material = Enum.Material.Slate
        muralLeft.Color = Color3.fromRGB(55, 55, 55)

        local muralRight = muralLeft:Clone()
        muralRight.Position = altar.Position + Vector3.new(7, 3, 0)
        muralRight.Parent = hall

        for z = -walkway.Size.Z / 2 + 2, walkway.Size.Z / 2, 6 do
                local candleLeft = Instance.new("Part", hall)
                candleLeft.Shape = Enum.PartType.Cylinder
                candleLeft.Size = Vector3.new(0.5, 1, 0.5)
                candleLeft.Position = walkway.Position + Vector3.new(-2, 0.5, z)
                candleLeft.Anchored = true
                candleLeft.Material = Enum.Material.SmoothPlastic
                candleLeft.Color = Color3.fromRGB(255, 200, 100)
                local light = Instance.new("PointLight", candleLeft)
                light.Brightness = 2
                light.Range = 5
                light.Color = Color3.fromRGB(255, 170, 80)

                local candleRight = candleLeft:Clone()
                candleRight.Position = walkway.Position + Vector3.new(2, 0.5, z)
                candleRight.Parent = hall
        end

        local ambient = Instance.new("Sound", hall)
        ambient.SoundId = "rbxassetid://912999977"
        ambient.Looped = true
        ambient.Volume = 0.3
        ambient:Play()

        return hall
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
createSpiritHall(interiorPosition + Vector3.new(0, 0, 25), gallery)
preloadNFTImages()
