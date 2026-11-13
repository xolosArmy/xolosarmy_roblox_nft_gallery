local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage.ColectividadXoloitzcuintle
local constants = require(shared.ExhibitConstants)
local Room = require(script.Parent.Room)
local settings = require(script.Parent.Settings)

local success, roomOrError = pcall(Room.install, settings, script:GetAttribute("Demo") == true)
if not success then
	warn("[Colectividad Xoloitzcuintle] " .. tostring(roomOrError))
elseif roomOrError then
	shared:SetAttribute(constants.readyAttribute, true)
end
