-- Exports the room built by the production geometry module for offline review.
local fs = require("@lune/fs")
local luau = require("@lune/luau")
local process = require("@lune/process")
local roblox = require("@lune/roblox")
local serde = require("@lune/serde")

local outputPath = assert(process.args[1], "Uso: lune run colectividad/tools/export_preview.luau ruta.json")
local environment = table.clone(roblox)
local function loadModule(path, extra)
	return luau.load(fs.readFile("colectividad/src/" .. path), {
		debugName = path,
		environment = extra or environment,
	})()
end

local room = roblox.Instance.new("Model")
room.Name = "Colectividad"
loadModule("server/Geometry.luau").build(room, roblox.CFrame.identity)
local catalog = serde.decode("json", fs.readFile("colectividad/src/shared/Catalogo.json"))
environment.script = { Parent = { Catalogo = "shared/Catalogo.json" } }
local displayEnvironment = table.clone(environment)
displayEnvironment.game = {
	GetService = function()
		return {
			ColectividadXoloitzcuintle = {
				Artworks = "shared/Artworks.luau",
				ExhibitConstants = "shared/ExhibitConstants.luau",
				Introduccion = "shared/Introduccion.luau",
			},
		}
	end,
}
local function requireModule(path)
	if path == "shared/Catalogo.json" then
		return catalog
	end
	return loadModule(path)
end
environment.require = requireModule
displayEnvironment.require = requireModule
loadModule("server/Displays.luau", displayEnvironment).build(room, roblox.CFrame.identity, {})
loadModule("server/Introduction.luau", displayEnvironment).build(room, roblox.CFrame.identity)

local function vector(value)
	return { value.X, value.Y, value.Z }
end

local elements = {}
for _, object in ipairs(room:GetDescendants()) do
	if object:IsA("BasePart") then
		local element = {
			name = object.Name,
			group = object.Parent.Name,
			size = vector(object.Size),
			transform = { object.CFrame:GetComponents() },
			color = { object.Color.R, object.Color.G, object.Color.B },
			shape = object.Shape.Name,
			material = object.Material.Name,
			collidable = object.CanCollide,
			signs = {},
		}
		for _, child in ipairs(object:GetChildren()) do
			if child:IsA("Attachment") and child:FindFirstChildWhichIsA("ProximityPrompt") then
				element.prompt = vector(object.CFrame:PointToWorldSpace(child.Position))
			elseif child:IsA("SurfaceGui") then
				local sign = { face = child.Face.Name, labels = {} }
				for _, label in ipairs(child:GetChildren()) do
					if label:IsA("TextLabel") then
						table.insert(sign.labels, {
							text = label.Text,
							x = label.Position.X.Scale,
							y = label.Position.Y.Scale,
							w = label.Size.X.Scale,
							h = label.Size.Y.Scale,
							size = label.TextSize,
						})
					end
				end
				table.insert(element.signs, sign)
			end
		end
		table.insert(elements, element)
	end
end

fs.writeFile(outputPath, serde.encode("json", { parts = elements, catalog = catalog.items }))
print(`{#elements} piezas exportadas desde los módulos Luau`)
