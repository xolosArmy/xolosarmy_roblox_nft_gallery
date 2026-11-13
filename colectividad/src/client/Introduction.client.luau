local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local shared = ReplicatedStorage:WaitForChild("ColectividadXoloitzcuintle")
local copy = require(shared:WaitForChild("Introduccion"))
local constants = require(shared:WaitForChild("ExhibitConstants"))
local ReaderView = require(script.Parent.ReaderView)
while shared:GetAttribute(constants.readyAttribute) ~= true do
	shared:GetAttributeChangedSignal(constants.readyAttribute):Wait()
end
if playerGui:FindFirstChild(constants.introGuiName) then
	return
end

local view = ReaderView.create(playerGui, constants.introGuiName, "ColectividadCerrarIntroduccion")
local gui, close, hide, line = view.gui, view.close, view.hide, view.line
local parchment, amber, muted = ReaderView.colors.parchment, ReaderView.colors.amber, ReaderView.colors.muted

line("Titulo", 1, 25, amber, Enum.Font.GothamBold).Text = copy.title
for index, paragraph in copy.paragraphs do
	line("Parrafo" .. index, index + 1, 17, parchment).Text = paragraph
end
line("Credito", #copy.paragraphs + 2, 16, muted).Text = copy.credit

local connections = {
	close.Activated:Connect(hide),
	player.CharacterRemoving:Connect(hide),
	ProximityPromptService.PromptTriggered:Connect(function(prompt, triggeringPlayer)
		if triggeringPlayer ~= player or prompt.Name ~= constants.introPromptName then
			return
		end
		local room = Workspace:FindFirstChild(constants.roomName)
		if not room or room:GetAttribute(constants.ownerAttribute) ~= constants.ownerId then
			return
		end
		local board = room:FindFirstChild(constants.introPanelName)
		local point = board and board:FindFirstChild("PuntoDeLectura")
		if point and point:FindFirstChild(constants.introPromptName) == prompt then
			view.show()
		end
	end),
}

gui.Destroying:Connect(function()
	hide()
	for _, connection in connections do
		connection:Disconnect()
	end
end)
