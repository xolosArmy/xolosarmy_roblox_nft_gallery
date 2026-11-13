local Geometry = {}

local stone = {
	obsidian = Color3.fromRGB(24, 30, 32),
	basalt = Color3.fromRGB(41, 48, 50),
	slate = Color3.fromRGB(58, 64, 61),
	earth = Color3.fromRGB(82, 67, 55),
	ochre = Color3.fromRGB(180, 120, 66),
	amber = Color3.fromRGB(247, 183, 97),
	bank = Color3.fromRGB(51, 111, 94),
	current = Color3.fromRGB(31, 141, 133),
	ripple = Color3.fromRGB(94, 197, 168),
}

local function part(parent, name, size, cf, color, material, solid, shape)
	local object = Instance.new("Part")
	object.Name = name
	object.Size = size
	object.CFrame = cf
	object.Color = color
	object.Material = material
	object.Shape = shape or Enum.PartType.Block
	object.Anchored = true
	object.CanCollide = solid == true
	object.CanTouch = false
	object.CanQuery = solid == true
	object.Parent = parent
	return object
end

local function group(parent, name)
	local model = Instance.new("Model")
	model.Name = name
	model.Parent = parent
	return model
end

local function riverX(z)
	return 3.5 * math.sin((z - 10) * math.pi / 19)
end

local function line(parent, name, root, a, b, width, height, color, material, overlap)
	local center = (a + b) / 2
	return part(parent, name, Vector3.new(width, height, (b - a).Magnitude + (overlap or 0.075)),
		root * CFrame.lookAt(center, b), color, material)
end

local function surfaceSign(board, face, copy, px)
	local gui = Instance.new("SurfaceGui")
	gui.Name = "Senal"
	gui.Face = face
	gui.LightInfluence = 0
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 48
	gui.Parent = board

	local label = Instance.new("TextLabel")
	label.Name = "Texto"
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(255, 231, 186)
	label.Font = Enum.Font.GothamMedium
	label.Text = copy
	label.TextSize = px
	label.Parent = gui
end

local function localLight(body, color, range, brightness)
	local light = Instance.new("PointLight")
	light.Color = color
	light.Range = range
	light.Brightness = brightness
	light.Shadows = false
	light.Parent = body
end

local function buildShell(parent, root, demo)
	local shell = group(parent, "Envolvente")
	local function block(name, x, y, z, w, h, d, color, material)
		return part(shell, name, Vector3.new(w, h, d), root * CFrame.new(x, y, z),
			color, material or Enum.Material.Basalt, true)
	end

	block("Piso continuo", 0, -0.5, 32, 44, 1, 64, stone.earth, Enum.Material.Slate)
	block("Cubierta", 0, 15.5, 32, 44, 1, 64, stone.obsidian)
	block("Muro de la obra", 0, 7.5, 63.5, 44, 15, 1, stone.basalt)
	for _, side in ipairs({-1, 1}) do
		block("Muro lateral", side * 21.5, 7.5, 32, 1, 15, 64, stone.basalt)
		block("Muro del umbral", side * 14, 7.5, 0.5, 16, 15, 1, stone.basalt)
		block("Jamba", side * 6.3, 5, 1.1, 0.6, 10, 1.8, stone.obsidian)
		part(shell, "Filete del umbral", Vector3.new(0.10, 7.7, 0.08),
			root * CFrame.new(side * 6.3, 5.05, 0.14), stone.amber, Enum.Material.Neon)
		for _, z in ipairs({8, 15, 22, 29, 36, 43, 50, 57}) do
			part(shell, "Junta de la orilla", Vector3.new(0.06, 0.012, 2.8),
				root * CFrame.new(side * 14, 0.009, z), stone.ochre, Enum.Material.SmoothPlastic)
		end
	end
	block("Dintel", 0, 12.5, 0.5, 12, 5, 1, stone.obsidian)

	local sign = part(shell, "Rotulo del umbral", Vector3.new(11.7, 1.05, 1.12),
		root * CFrame.new(0, 10.62, 0.5), stone.obsidian, Enum.Material.SmoothPlastic)
	surfaceSign(sign, Enum.NormalId.Front, "Colectividad Xoloitzcuintle", 37)
	local exit = if demo then "↓  Regreso al acceso de prueba" else "↓  Regreso al Museo del Itzcuintlan"
	surfaceSign(sign, Enum.NormalId.Back, exit, 30)

	for _, z in ipairs({3, 15, 29, 43, 58}) do
		block("Viga transversal", 0, 14.45, z, 42, 0.95, 0.66, stone.obsidian)
		for _, side in ipairs({-1, 1}) do
			local fixture = part(shell, "Luz de recorrido", Vector3.new(4.6, 0.09, 0.12),
				root * CFrame.new(side * 10.5, 13.93, z), stone.amber, Enum.Material.Neon)
			localLight(fixture, Color3.fromRGB(255, 211, 161), 20, 0.95)
		end
	end
end

local function buildRiver(parent, root)
	local river = group(parent, "Cauce")
	for z = 10, 47 do
		local a, b = riverX(z), riverX(z + 1)
		-- Raise neighboring segments by fractions of a stud so overlapping bends do not flicker.
		local bankY = 0.025 + (z % 3) * 0.001
		local waterY = 0.057 + (z % 3) * 0.001
		line(river, "Orilla", root, Vector3.new(a, bankY, z), Vector3.new(b, bankY, z + 1),
			5.1, 0.05, stone.bank, Enum.Material.Slate, 0.31)
		local color = stone.current:Lerp(stone.bank, 0.18 + 0.10 * math.cos(z * 0.35))
		line(river, "Agua", root, Vector3.new(a, waterY, z), Vector3.new(b, waterY, z + 1),
			4.55, 0.035, color, Enum.Material.SmoothPlastic, 0.29)
	end

	for z = 11, 46, 5 do
		for band = -1, 1 do
			local offset = band * 0.86
			local startZ = z + band * 0.52
			local endZ = startZ + 2.45
			line(river, "Reflejo", root, Vector3.new(riverX(startZ) + offset, 0.085, startZ),
				Vector3.new(riverX(endZ) + offset, 0.085, endZ), 0.052, 0.016,
				stone.ripple, Enum.Material.SmoothPlastic)
		end
	end
end

local function sculpture(parent, root, index, z, scale, stride, yaw)
	local xolo = group(parent, "Xolo " .. index)
	local heading = math.atan((riverX(z + 0.25) - riverX(z - 0.25)) / 0.5) + yaw
	local pose = root * CFrame.new(riverX(z), 0.085, z) * CFrame.Angles(0, heading, 0)

	local function facet(name, w, h, d, x, y, depth, rx, rz, color, shape)
		local cf = pose * CFrame.new(x * scale, y * scale, depth * scale)
			* CFrame.Angles(math.rad(rx), 0, math.rad(rz))
		return part(xolo, name, Vector3.new(w, h, d) * scale, cf,
			color or stone.obsidian, Enum.Material.Slate, false, shape)
	end

	local oval = Enum.PartType.Ball
	facet("Torso", 1.04, 1.04, 2.15, 0, 1.42, -0.26, 7, 0, stone.obsidian, oval)
	facet("Pecho", 0.91, 1.19, 1.0, 0, 1.53, 0.57, -14, 0, stone.basalt, oval)
	facet("Cuello", 0.67, 1.19, 0.75, 0, 2.08, 0.82, 24, 0, stone.obsidian, oval)
	facet("Cabeza", 0.78, 0.66, 0.87, 0, 2.56, 1.12, 5, 0, stone.basalt, oval)
	facet("Hocico", 0.52, 0.36, 0.79, 0, 2.44, 1.63, 10, 0, stone.obsidian, oval)
	facet("Nariz", 0.28, 0.21, 0.24, 0, 2.49, 1.99, 3, 0)
	facet("Cola", 0.19, 0.18, 0.83, 0, 1.65, -1.49, 32, 0, stone.basalt, oval)
	facet("Punta de cola", 0.13, 0.13, 0.57, 0, 1.91, -1.89, 54, 0, stone.basalt, oval)
	for _, side in ipairs({-1, 1}) do
		facet("Oreja", 0.28, 0.92, 0.38, side * 0.27, 3.02, 0.96, 2, -side * 14,
			stone.obsidian, Enum.PartType.Wedge)
		facet("Ojo", 0.12, 0.1, 0.11, side * 0.36, 2.59, 1.33, 0, 0, stone.amber, oval)
		for _, front in ipairs({-1, 1}) do
			local pawZ = front * 0.72 + side * front * stride
			facet("Pata", 0.26, 1.12, 0.26, side * 0.34, 0.65,
				front * 0.72 + side * front * stride / 2, -side * front * stride * 40,
				0, stone.obsidian, oval)
			facet("Huella", 0.34, 0.16, 0.46, side * 0.34, 0.10, pawZ + 0.13, 0, 0)
		end
	end

	local collarColor = index == 3 and Color3.fromRGB(170, 69, 97) or stone.ochre
	facet("Acento del cuello", 0.34, 0.14, 0.12, 0, 1.98, 1.20, 0, 0, collarColor)
end

local function buildReliefs(parent, root)
	local reliefs = group(parent, "Relieves del valle")
	for _, side in ipairs({-1, 1}) do
		for bay, z in ipairs({11, 23, 37, 51}) do
			if side == 1 and z == 37 then
				continue -- This wall bay houses El calor de Huehueteotl.
			end
			local panel = root * CFrame.new(side * 20.65, 4.4, z)
			part(reliefs, "Panel de pizarra", Vector3.new(0.32, 7.2, 9.6), panel,
				stone.obsidian, Enum.Material.Slate)
			part(reliefs, "Filete de cobre", Vector3.new(0.33, 0.06, 9.1),
				panel * CFrame.new(-side * 0.17, -3.25, 0), stone.ochre, Enum.Material.SmoothPlastic)
			for i = 1, 4 do
				local height = 1.3 + ((i * 3 + bay * 2 + side) % 5) * 0.73
				local ridge = root * CFrame.new(side * (20.34 - i * 0.08), 1.2 + height / 2, z - 4 + i * 1.56)
					* CFrame.Angles(0, i % 2 * math.pi, 0)
				part(reliefs, "Perfil montañoso", Vector3.new(0.37, height, 3.1), ridge,
					stone.slate:Lerp(stone.earth, i / 7), Enum.Material.Basalt, false, Enum.PartType.Wedge)
			end
		end
	end

	local motifs = group(parent, "Viento, cempasúchil y memoria")
	for i = 1, 3 do
		local x, y, z = -20.35, 6.8 + i * 0.22, 10 + i * 0.25
		local a, b = Vector3.new(x, y, z - 1.2), Vector3.new(x, y, z + 0.8)
		line(motifs, "Viento", root, a, b, 0.075, 0.075, stone.ochre, Enum.Material.SmoothPlastic)
		line(motifs, "Viento", root, b, b + Vector3.new(0, 0.26, 0.42), 0.075, 0.075,
			stone.ochre, Enum.Material.SmoothPlastic)
	end

	for petal = 1, 9 do
		local angle = petal * math.pi * 2 / 9
		local frame = root * CFrame.new(20.39, 6.9, 23) * CFrame.Angles(angle, 0, 0)
			* CFrame.new(0, 0.45, 0)
		part(motifs, "Cempasúchil", Vector3.new(0.08, 0.53, 0.18), frame,
			stone.amber, Enum.Material.SmoothPlastic, false, Enum.PartType.Ball)
	end
	for ring = 1, 3 do
		local radius = ring * 0.28
		for edge = 0, 3 do
			local a, b = edge * math.pi / 2, (edge + 1) * math.pi / 2
			line(motifs, "Memoria", root, Vector3.new(-20.4, 6.9 + math.cos(a) * radius, 37 + math.sin(a) * radius),
				Vector3.new(-20.4, 6.9 + math.cos(b) * radius, 37 + math.sin(b) * radius),
				0.065, 0.065, stone.ochre, Enum.Material.SmoothPlastic)
		end
	end
end

function Geometry.build(room, threshold, demo)
	local geometry = group(room, "Arquitectura")
	buildShell(geometry, threshold, demo)
	buildRiver(geometry, threshold)
	buildReliefs(geometry, threshold)
	local procession = group(geometry, "Procesion")
	for index, z in ipairs({13, 21, 29, 37, 45}) do
		local scales = {1, 0.94, 1.06, 0.96, 0.90}
		local strides = {0.26, -0.15, 0.02, -0.32, 0.34}
		local turns = {0.12, -0.18, 0.04, 0.30, -0.1}
		sculpture(procession, threshold, index, z, scales[index], strides[index], turns[index])
	end
end

return Geometry
