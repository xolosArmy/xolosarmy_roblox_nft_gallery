local environment = Instance.new("Model", game.Workspace)
environment.Name = "TenochtitlanExpansion"

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Remote events for interactions
local ShowMuseumInfo = ReplicatedStorage:FindFirstChild("ShowMuseumInfo") or Instance.new("RemoteEvent", ReplicatedStorage)
ShowMuseumInfo.Name = "ShowMuseumInfo"

local ShowKennelInfo = ReplicatedStorage:FindFirstChild("ShowKennelInfo") or Instance.new("RemoteEvent", ReplicatedStorage)
ShowKennelInfo.Name = "ShowKennelInfo"

local function createPlaza(size, position)
    local plaza = Instance.new("Part", environment)
    plaza.Size = Vector3.new(size, 1, size)
    plaza.Position = position
    plaza.Anchored = true
    plaza.Material = Enum.Material.Sandstone
    plaza.Color = Color3.fromRGB(210, 180, 140)
    return plaza
end

local function createCanal(length, width, position)
    local canal = Instance.new("Part", environment)
    canal.Size = Vector3.new(length, 1, width)
    canal.Position = position
    canal.Anchored = true
    canal.Material = Enum.Material.Water
    canal.Color = Color3.fromRGB(28, 92, 142)
    return canal
end

local function createMuseum(position)
    local museum = Instance.new("Model", environment)
    museum.Name = "InteractiveMuseum"

    local floor = Instance.new("Part", museum)
    floor.Size = Vector3.new(40, 1, 30)
    floor.Position = position
    floor.Anchored = true
    floor.Material = Enum.Material.SmoothPlastic
    floor.Color = Color3.fromRGB(193, 142, 111)

    local artifact = Instance.new("Part", museum)
    artifact.Size = Vector3.new(4, 4, 1)
    artifact.Position = position + Vector3.new(0, 3, 0)
    artifact.Anchored = true
    artifact.Material = Enum.Material.SmoothPlastic
    artifact.Color = Color3.fromRGB(150, 50, 50)

    local prompt = Instance.new("ProximityPrompt", artifact)
    prompt.ActionText = "Ver Historia"
    prompt.ObjectText = "Artefacto"
    prompt.MaxActivationDistance = 10
    prompt.Triggered:Connect(function(player)
        ShowMuseumInfo:FireClient(player, "Artefacto de Tenochtitlan", "Fragmento historico que relata la grandeza de la ciudad.")
    end)

    return museum
end

local function createGallery(position)
    local galleryModel = Instance.new("Model", environment)
    galleryModel.Name = "ArtGallery"

    local base = Instance.new("Part", galleryModel)
    base.Size = Vector3.new(40, 1, 20)
    base.Position = position
    base.Anchored = true
    base.Material = Enum.Material.SmoothPlastic
    base.Color = Color3.fromRGB(100, 100, 100)

    local frame = Instance.new("Part", galleryModel)
    frame.Size = Vector3.new(5, 5, 0.5)
    frame.Position = position + Vector3.new(0, 3, 9)
    frame.Anchored = true
    frame.Material = Enum.Material.SmoothPlastic
    frame.Color = Color3.fromRGB(30, 30, 30)

    local decal = Instance.new("Decal", frame)
    decal.Texture = "rbxassetid://127951867096643"

    local prompt = Instance.new("ProximityPrompt", frame)
    prompt.ActionText = "Ver información"
    prompt.ObjectText = "Galería"
    prompt.MaxActivationDistance = 10
    prompt.Triggered:Connect(function(player)
        ShowMuseumInfo:FireClient(player, "Galería", "Obras inspiradas en la grandeza de Tenochtitlan.")
    end)

    return galleryModel
end

local function createKennel(position)
    local kennel = Instance.new("Model", environment)
    kennel.Name = "XoloKennel"

    local base = Instance.new("Part", kennel)
    base.Size = Vector3.new(30, 1, 20)
    base.Position = position
    base.Anchored = true
    base.Material = Enum.Material.WoodPlanks
    base.Color = Color3.fromRGB(140, 90, 60)

    local dog = Instance.new("Part", kennel)
    dog.Name = "XoloDog"
    dog.Shape = Enum.PartType.Ball
    dog.Size = Vector3.new(2, 2, 2)
    dog.Position = position + Vector3.new(0, 2, 0)
    dog.Anchored = false
    dog.Material = Enum.Material.SmoothPlastic
    dog.Color = Color3.fromRGB(50, 50, 50)

    local prompt = Instance.new("ProximityPrompt", dog)
    prompt.ActionText = "Conocer"
    prompt.ObjectText = "Xolo Ramirez"
    prompt.MaxActivationDistance = 8
    prompt.Triggered:Connect(function(player)
        ShowKennelInfo:FireClient(player, "Xolo Ramirez", "Perro ancestral criado con cariño dentro de Tenochtitlan.")
    end)

    return kennel
end

-- Construct the environment
createPlaza(120, Vector3.new(0, 0, 0))
createCanal(120, 10, Vector3.new(0, -1, 30))
createCanal(120, 10, Vector3.new(0, -1, -30))
createMuseum(Vector3.new(60, 0, 0))
createGallery(Vector3.new(-60, 0, 0))
createKennel(Vector3.new(0, 0, 60))
