local shared = game:GetService("ReplicatedStorage").ColectividadXoloitzcuintle
local copy = require(shared.Introduccion)
local constants = require(shared.ExhibitConstants)

local Introduction = {}

local function label(parent, name, text, top, height, font, size, color)
	local node = Instance.new("TextLabel")
	node.Name = name
	node.Position = UDim2.fromScale(0.07, top)
	node.Size = UDim2.fromScale(0.86, height)
	node.BackgroundTransparency = 1
	node.Font = font
	node.Text = text
	node.TextSize = size
	node.TextColor3 = color
	node.TextWrapped = true
	node.TextXAlignment = Enum.TextXAlignment.Left
	node.Parent = parent
end

function Introduction.build(room, threshold)
	local panel = Instance.new("Part")
	panel.Name = constants.introPanelName
	panel.Size = Vector3.new(4.6, 4.1, 0.24)
	panel.CFrame = threshold * CFrame.new(-20.45, 4.35, 3.65) * CFrame.Angles(0, -math.pi / 2, 0)
	panel.Anchored = true
	panel.CanCollide = false
	panel.CanTouch = false
	panel.CanQuery = false
	panel.Material = Enum.Material.Slate
	panel.Color = Color3.fromRGB(38, 43, 42)
	panel.Parent = room

	local surface = Instance.new("SurfaceGui")
	surface.Name = "Cedula"
	surface.Face = Enum.NormalId.Front
	surface.SizingMode = Enum.SurfaceGuiSizingMode.FixedSize
	surface.CanvasSize = Vector2.new(460, 410)
	surface.LightInfluence = 0
	surface.MaxDistance = 52
	surface.Parent = panel

	local pale = Color3.fromRGB(249, 235, 207)
	local brass = Color3.fromRGB(239, 187, 112)
	label(surface, "Titulo", copy.title, 0.08, 0.33, Enum.Font.GothamBold, 35, brass)
	label(surface, "Extracto", copy.paragraphs[1], 0.46, 0.40, Enum.Font.GothamMedium, 25, pale)

	local origin = Instance.new("Attachment")
	origin.Name = "PuntoDeLectura"
	origin.Position = Vector3.new(0, -0.6, -0.5)
	origin.Parent = panel

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = constants.introPromptName
	prompt.ActionText = "Leer introducción"
	prompt.ObjectText = "Xólotl"
	prompt.MaxActivationDistance = 6
	prompt.RequiresLineOfSight = true
	prompt.ClickablePrompt = true
	prompt.Parent = origin
end

return Introduction
