local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local shared = ReplicatedStorage:WaitForChild("ColectividadXoloitzcuintle")
local artworks = require(shared:WaitForChild("Artworks"))
local constants = require(shared:WaitForChild("ExhibitConstants"))
local ReaderView = require(script.Parent.ReaderView)
while shared:GetAttribute(constants.readyAttribute) ~= true do
	shared:GetAttributeChangedSignal(constants.readyAttribute):Wait()
end
if playerGui:FindFirstChild(constants.guiName) then
	return
end

local view = ReaderView.create(playerGui, constants.guiName, "ColectividadCerrarFicha")
local gui, close, hide, line = view.gui, view.close, view.hide, view.line
local parchment, amber, muted = ReaderView.colors.parchment, ReaderView.colors.amber, ReaderView.colors.muted

local title = line("Obra", 1, 25, parchment, Enum.Font.GothamBold)
local credit = line("Credito", 2, 16, muted)
local edition = line("Edicion", 3, 17, amber)
local summary = line("Lectura", 4, 17, parchment)
local explorer = line("Explorador", 5, 17, amber, Enum.Font.GothamBold)
local protocol = line("Coleccion", 6, 15, muted)
local token = line("Token", 7, 14, parchment, Enum.Font.Code)
local announcementLabel = line("ProtocoloAnuncio", 8, 15, muted)
local announcement = line("Anuncio", 9, 14, parchment, Enum.Font.Code)

local function show(artwork)
	title.Text = artwork.title
	credit.Text = artwork.credit
	edition.Text = "Edición " .. artwork.edition .. " · " .. artwork.date
	summary.Text = artwork.summary
	explorer.Text = artwork.explorerName
	protocol.Text = "NFT artístico · " .. artwork.collection .. "\n" .. artwork.protocol .. " · ID del token y minteo"
	token.Text = artwork.tokenId
	announcementLabel.Text = "Lanzamiento · " .. artwork.announcementProtocol .. " · ID de transacción"
	announcement.Text = artwork.announcementId
	view.show()
end

local function belongsToExhibit(node)
	local room = Workspace:FindFirstChild(constants.roomName)
	if not room or room:GetAttribute(constants.ownerAttribute) ~= constants.ownerId then
		return false
	end
	local displays = room:FindFirstChild(constants.displaysName)
	return displays ~= nil and node:IsDescendantOf(displays)
end

local connections = {
	close.Activated:Connect(hide),
	player.CharacterRemoving:Connect(hide),
	ProximityPromptService.PromptTriggered:Connect(function(prompt, triggeringPlayer)
		if triggeringPlayer ~= player or prompt.Name ~= constants.promptName or not belongsToExhibit(prompt) then
			return
		end
		local artworkId = prompt:GetAttribute(constants.artworkAttribute)
		local exhibit = prompt:FindFirstAncestorWhichIsA("Model")
		local artwork = artworks[artworkId]
		if artwork and exhibit and exhibit.Name == artworkId then
			show(artwork)
		end
	end),
}

local imageConnections = {}
local function watchImage(image)
	if not gui.Parent or not image:IsA("ImageLabel") or not belongsToExhibit(image) or imageConnections[image] then
		return
	end
	local placeholder = image.Parent:FindFirstChild("Estado")
	if not placeholder or not placeholder:IsA("TextLabel") then
		return
	end
	local function update()
		placeholder.Visible = not image.IsLoaded
	end
	imageConnections[image] = image:GetPropertyChangedSignal("IsLoaded"):Connect(update)
	update()
end

local function unwatchImage(image)
	local connection = imageConnections[image]
	if connection then
		connection:Disconnect()
		imageConnections[image] = nil
	end
end

table.insert(connections, CollectionService:GetInstanceAddedSignal(constants.imageTag):Connect(function(image)
	-- Streaming can replicate the image before its display hierarchy is fully available.
	task.defer(watchImage, image)
end))
table.insert(connections, CollectionService:GetInstanceRemovedSignal(constants.imageTag):Connect(unwatchImage))
for _, image in CollectionService:GetTagged(constants.imageTag) do
	watchImage(image)
end

gui.Destroying:Connect(function()
	hide()
	for _, connection in connections do
		connection:Disconnect()
	end
	for _, connection in imageConnections do
		connection:Disconnect()
	end
	table.clear(imageConnections)
end)
