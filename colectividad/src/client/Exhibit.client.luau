local CollectionService = game:GetService("CollectionService")
local ContextActionService = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local shared = ReplicatedStorage:WaitForChild("ColectividadXoloitzcuintle")
local artworks = require(shared:WaitForChild("Artworks"))
local constants = require(shared:WaitForChild("ExhibitConstants"))
while shared:GetAttribute(constants.readyAttribute) ~= true do
	shared:GetAttributeChangedSignal(constants.readyAttribute):Wait()
end
if playerGui:FindFirstChild(constants.guiName) then
	return
end

local closeAction = "ColectividadCerrarFicha"
local parchment = Color3.fromRGB(249, 235, 207)
local amber = Color3.fromRGB(236, 186, 120)
local muted = Color3.fromRGB(221, 209, 187)

local gui = Instance.new("ScreenGui")
gui.Name = constants.guiName
gui.DisplayOrder = 15
gui.ResetOnSpawn = false
gui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
gui.Enabled = false
gui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Name = "Ficha"
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.fromScale(0.92, 0.85)
panel.BackgroundColor3 = Color3.fromRGB(28, 30, 29)
panel.BorderSizePixel = 0
panel.Parent = gui

local panelLimit = Instance.new("UISizeConstraint")
panelLimit.MaxSize = Vector2.new(590, 620)
panelLimit.Parent = panel

local close = Instance.new("TextButton")
close.Name = "Cerrar"
close.AnchorPoint = Vector2.new(1, 0)
close.Position = UDim2.new(1, -10, 0, 9)
close.Size = UDim2.fromOffset(86, 45)
close.Text = "Cerrar"
close.TextColor3 = parchment
close.TextSize = 17
close.Font = Enum.Font.GothamBold
close.BorderSizePixel = 0
close.BackgroundColor3 = Color3.fromRGB(76, 60, 43)
close.Parent = panel

local scroller = Instance.new("ScrollingFrame")
scroller.Name = "Contenido"
scroller.Position = UDim2.fromOffset(0, 61)
scroller.Size = UDim2.new(1, 0, 1, -61)
scroller.BorderSizePixel = 0
scroller.BackgroundTransparency = 1
scroller.CanvasSize = UDim2.fromScale(0, 0)
scroller.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroller.ScrollingDirection = Enum.ScrollingDirection.Y
scroller.ScrollBarThickness = 6
scroller.ScrollBarImageColor3 = amber
scroller.Selectable = true
scroller.Parent = panel

local padding = Instance.new("UIPadding")
padding.PaddingLeft = UDim.new(0, 18)
padding.PaddingRight = UDim.new(0, 18)
padding.PaddingBottom = UDim.new(0, 19)
padding.Parent = scroller

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 10)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = scroller

local function line(name, order, size, color, font)
	local text = Instance.new("TextLabel")
	text.Name = name
	text.LayoutOrder = order
	text.Size = UDim2.new(1, -6, 0, 0)
	text.AutomaticSize = Enum.AutomaticSize.Y
	text.BackgroundTransparency = 1
	text.TextColor3 = color
	text.Font = font or Enum.Font.GothamMedium
	text.TextSize = size
	text.TextWrapped = true
	text.TextXAlignment = Enum.TextXAlignment.Left
	text.TextYAlignment = Enum.TextYAlignment.Top
	text.Parent = scroller
	return text
end

local title = line("Obra", 1, 25, parchment, Enum.Font.GothamBold)
local credit = line("Credito", 2, 16, muted)
local edition = line("Edicion", 3, 17, amber)
local summary = line("Lectura", 4, 17, parchment)
local explorer = line("Explorador", 5, 17, amber, Enum.Font.GothamBold)
local protocol = line("Coleccion", 6, 15, muted)
local token = line("Token", 7, 14, parchment, Enum.Font.Code)
local announcementLabel = line("ProtocoloAnuncio", 8, 15, muted)
local announcement = line("Anuncio", 9, 14, parchment, Enum.Font.Code)

close.NextSelectionDown = scroller
scroller.NextSelectionUp = close

local previousSelection
local function hide()
	if not gui.Enabled then
		return
	end
	if GuiService.SelectedObject == close or GuiService.SelectedObject == scroller then
		GuiService.SelectedObject = if previousSelection and previousSelection.Parent then previousSelection else nil
	end
	previousSelection = nil
	gui.Enabled = false
	ContextActionService:UnbindAction(closeAction)
end

local function closeWithButton(_, state)
	if state == Enum.UserInputState.Begin then
		hide()
	end
	return Enum.ContextActionResult.Sink
end

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
	scroller.CanvasPosition = Vector2.zero

	if not gui.Enabled then
		previousSelection = GuiService.SelectedObject
		gui.Enabled = true
		ContextActionService:BindAction(closeAction, closeWithButton, false, Enum.KeyCode.ButtonB, Enum.KeyCode.Backspace)
	end

	if string.find(UserInputService:GetLastInputType().Name, "Gamepad", 1, true) then
		GuiService.SelectedObject = close
	end
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
		local artwork = artworks[prompt:GetAttribute(constants.artworkAttribute)]
		if artwork then
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
