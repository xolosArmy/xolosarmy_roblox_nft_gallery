local gallery = Instance.new("Model", game.Workspace)
gallery.Name = "XolosArmyGallery"

local gallerySize = Vector3.new(60, 15, 50)
local floorHeight = 0.5

-- Function to create a part
local function createPart(size, position, material, color, anchored, transparency, parent)
    local part = Instance.new("Part")
    part.Size = size
    part.Position = position
    part.Material = material
    part.Color = color
    part.Anchored = anchored
    part.Transparency = transparency or 0
    part.Parent = parent
    return part
end

-- Create Gallery Structure
local floor = createPart(Vector3.new(gallerySize.X, floorHeight, gallerySize.Z), Vector3.new(0, -floorHeight / 2, 0), Enum.Material.Concrete, Color3.fromRGB(50, 50, 50), true, 0, gallery)
local ceiling = createPart(Vector3.new(gallerySize.X, floorHeight, gallerySize.Z), Vector3.new(0, gallerySize.Y, 0), Enum.Material.SmoothPlastic, Color3.fromRGB(200, 200, 200), true, 0, gallery)

local walls = {
    createPart(Vector3.new(gallerySize.X, gallerySize.Y, 1), Vector3.new(0, gallerySize.Y / 2, -gallerySize.Z / 2), Enum.Material.SmoothPlastic, Color3.fromRGB(255, 255, 255), true, 0, gallery),
    createPart(Vector3.new(gallerySize.X, gallerySize.Y, 1), Vector3.new(0, gallerySize.Y / 2, gallerySize.Z / 2), Enum.Material.SmoothPlastic, Color3.fromRGB(255, 255, 255), true, 0, gallery)
}

-- Background Music
local music = Instance.new("Sound", gallery)
music.SoundId = "rbxassetid://184793379" -- Replace with your own music ID
music.Looped = true
music.Volume = 0.6
music:Play()

-- NFT Data
local nftData = {
    {name = "Xolo Warrior", image = "rbxassetid://123456789", price = 100, description = "An ancient xoloitzcuintle warrior."},
    {name = "Cyber Xolo", image = "rbxassetid://987654321", price = 150, description = "A futuristic xolo with neon details."},
    {name = "Mystic Xolo", image = "rbxassetid://112233445", price = 200, description = "A mystical xolo guiding spirits."},
    {name = "XolosArmy Leader", image = "rbxassetid://554433221", price = 250, description = "The leader of the XolosArmy."}
}

-- NFT Leaderboard (Tracks Purchases)
local nftOwners = {}

-- Function to create NFT display with rotating light
local function createNFTDisplay(nft, position, parent)
    local frame = createPart(Vector3.new(8, 6, 0.5), position, Enum.Material.SmoothPlastic, Color3.fromRGB(30, 30, 30), true, 0, parent)

    -- Add image
    local decal = Instance.new("Decal")
    decal.Texture = nft.image
    decal.Face = Enum.NormalId.Front
    decal.Parent = frame

    -- Glow effect
    local highlight = Instance.new("Highlight", frame)
    highlight.FillColor = Color3.fromRGB(255, 215, 0)
    highlight.FillTransparency = 0.5

    -- Rotating Spotlight
    local spotlight = Instance.new("SpotLight", frame)
    spotlight.Brightness = 2
    spotlight.Range = 10
    spotlight.Angle = 90
    spotlight.Color = Color3.fromRGB(255, 200, 100)

    game:GetService("RunService").Stepped:Connect(function()
        spotlight.Parent.CFrame = spotlight.Parent.CFrame * CFrame.Angles(0, math.rad(1), 0)
    end)

    -- Buy Button
    local HttpService = game:GetService("HttpService")

local HttpService = game:GetService("HttpService")

local function purchaseNFT(player, nft)
    local url = "https://your-server.com/generate-payment"  -- Reemplaza con tu servidor
    local requestData = {
        player = player.Name,
        nft = nft.name,
        price = nft.price
    }

    local jsonRequest = HttpService:JSONEncode(requestData)

    local success, response = pcall(function()
        return HttpService:PostAsync(url, jsonRequest, Enum.HttpContentType.ApplicationJson)
    end)

    if success then
        local responseData = HttpService:JSONDecode(response)
        if responseData and responseData.payment_link then
            player:SendNotification("Pago Requerido", "Haz click para comprar el NFT", responseData.payment_link)
        else
            player:SendNotification("Error", "No se pudo generar el pago.")
        end
    else
        player:SendNotification("Error", "No se pudo conectar con el servidor.")
    end
end

local button = Instance.new("ClickDetector", frame)
button.MaxActivationDistance = 10

button.MouseClick:Connect(function(player)
    purchaseNFT(player, nft)
end)


-- ClickDetector Setup
local button = Instance.new("ClickDetector", frame)
button.MaxActivationDistance = 10

button.MouseClick:Connect(function(player)
    purchaseNFT(player, nft)
end)

    local function getUserNFTs(player)
    local url = "https://your-server.com/nfts/" .. player.UserId

    local success, response = pcall(function()
        return HttpService:GetAsync(url)
    end)

    if success then
        local nftData = HttpService:JSONDecode(response)
        return nftData
    else
        warn("No se pudieron obtener los NFTs")
        return nil
    end
end




-- Generate NFT displays
for i, nft in pairs(nftData) do
    createNFTDisplay(nft, Vector3.new(-15 + (i - 1) * 12, 5, -gallerySize.Z / 2 + 1), gallery)
end

-- Animated NPC Guide
local npc = Instance.new("Model", gallery)
npc.Name = "GuideNPC"

local npcPart = createPart(Vector3.new(2, 5, 2), Vector3.new(0, 2.5, gallerySize.Z / 2 - 5), Enum.Material.SmoothPlastic, Color3.fromRGB(200, 100, 50), true, 0, npc)
local head = createPart(Vector3.new(2, 2, 2), npcPart.Position + Vector3.new(0, 3, 0), Enum.Material.SmoothPlastic, Color3.fromRGB(255, 200, 150), true, 0, npc)
head.Name = "Head"

local gui = Instance.new("BillboardGui", head)
gui.Size = UDim2.new(5, 0, 2, 0)
gui.StudsOffset = Vector3.new(0, 2, 0)
local text = Instance.new("TextLabel", gui)
text.Size = UDim2.new(1, 0, 1, 0)
text.Text = "Welcome to the XolosArmy NFT Gallery! Click an NFT to learn more."
text.TextScaled = true
text.BackgroundTransparency = 1
text.TextColor3 = Color3.fromRGB(255, 255, 255)

-- NPC Animation
local npcAnim = game:GetService("RunService").Stepped:Connect(function()
    npcPart.CFrame = npcPart.CFrame * CFrame.Angles(0, math.rad(0.5), 0)
end)

-- Leaderboard Display
local HttpService = game:GetService("HttpService")

local function fetchNFTOwnership()
    local url = "https://your-external-server.com/get-ownership" -- Replace with your backend

    local success, response = pcall(function()
        return HttpService:GetAsync(url)
    end)

    if success then
        local ownershipData = HttpService:JSONDecode(response)
        return ownershipData
    else
        warn("Failed to fetch NFT ownership")
        return nil
    end
end

-- Update leaderboard display
game:GetService("RunService").Stepped:Connect(function()
    local ownershipData = fetchNFTOwnership()
    if ownershipData then
        local leaderboardInfo = "NFT Owners:\n"
        for owner, nfts in pairs(ownershipData) do
            leaderboardInfo = leaderboardInfo .. owner .. ": " .. #nfts .. " NFTs\n"
        end
        leaderboardText.Text = leaderboardInfo
    end
end)


print("XolosArmy NFT Gallery with Leaderboard, NPC, and Animations Loaded!")

