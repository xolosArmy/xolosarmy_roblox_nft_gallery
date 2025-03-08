local HttpService = game:GetService("HttpService")

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

-- Function to create NFT display
local function createNFTDisplay(nft, position, parent)
    local frame = createPart(Vector3.new(8, 6, 0.5), position, Enum.Material.SmoothPlastic, Color3.fromRGB(30, 30, 30), true, 0, parent)

    -- Add NFT image
    local decal = Instance.new("Decal")
    decal.Texture = nft.image
    decal.Face = Enum.NormalId.Front
    decal.Parent = frame

    -- Glow effect
    local highlight = Instance.new("Highlight", frame)
    highlight.FillColor = Color3.fromRGB(255, 215, 0)
    highlight.FillTransparency = 0.5

    -- Buy Button
    local button = Instance.new("ClickDetector", frame)
    button.MaxActivationDistance = 10

    button.MouseClick:Connect(function(player)
        local url = "https://your-server.com/generate-payment"  -- Replace with your backend
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
    end)
end

-- Generate NFT displays
for i, nft in pairs(nftData) do
    createNFTDisplay(nft, Vector3.new(-15 + (i - 1) * 12, 5, -gallerySize.Z / 2 + 1), gallery)
end

-- Fetch NFT ownership data
local function fetchNFTOwnership()
    local url = "https://your-external-server.com/get-ownership" -- Replace with your backend

    local success, response = pcall(function()
        return HttpService:GetAsync(url)
    end)

    if success then
        return HttpService:JSONDecode(response)
    else
        warn("Failed to fetch NFT ownership")
        return nil
    end
end

-- Leaderboard Display (Updates every 5 seconds)
local leaderboardPart = createPart(Vector3.new(8, 6, 0.5), Vector3.new(20, 5, -gallerySize.Z / 2 + 1), Enum.Material.SmoothPlastic, Color3.fromRGB(50, 50, 50), true, 0, gallery)

local leaderboardGui = Instance.new("SurfaceGui", leaderboardPart)
leaderboardGui.CanvasSize = Vector2.new(500, 500)
local leaderboardText = Instance.new("TextLabel", leaderboardGui)
leaderboardText.Size = UDim2.new(1, 0, 1, 0)
leaderboardText.TextScaled = true
leaderboardText.BackgroundTransparency = 1
leaderboardText.TextColor3 = Color3.fromRGB(255, 255, 255)

spawn(function()
    while true do
        
