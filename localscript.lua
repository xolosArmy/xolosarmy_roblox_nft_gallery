local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = game.Players.LocalPlayer

-- Crea la GUI para los NFTs
local gui = Instance.new("ScreenGui")
gui.Name = "NFTGui"
gui.ResetOnSpawn = false
gui.Parent = player.PlayerGui

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 340, 0, 180)
frame.Position = UDim2.new(0.5, -170, 0.75, -90)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Visible = false
frame.Name = "MainFrame"
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(0,170,255)

local title = Instance.new("TextLabel", frame)
title.Name = "NFTTitle"
title.Size = UDim2.new(1, 0, 0, 36)
title.Position = UDim2.new(0,0,0,0)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(0, 170, 255)

local description = Instance.new("TextLabel", frame)
description.Name = "NFTDesc"
description.Size = UDim2.new(1, -20, 0, 82)
description.Position = UDim2.new(0, 10, 0, 44)
description.TextWrapped = true
description.TextYAlignment = Enum.TextYAlignment.Top
description.TextScaled = true
description.BackgroundTransparency = 1
description.TextColor3 = Color3.new(1, 1, 1)
description.Font = Enum.Font.Gotham

local button = Instance.new("TextButton", frame)
button.Name = "NFTLink"
button.Size = UDim2.new(1, -40, 0, 32)
button.Position = UDim2.new(0, 20, 1, -40)
button.Text = "Copiar enlace de NFT"
button.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
button.TextColor3 = Color3.new(1, 1, 1)
button.Font = Enum.Font.GothamBold
button.TextScaled = true

local close = Instance.new("TextButton", frame)
close.Name = "Close"
close.Size = UDim2.new(0, 30, 0, 30)
close.Position = UDim2.new(1, -35, 0, 5)
close.Text = "✕"
close.BackgroundColor3 = Color3.fromRGB(60,60,60)
close.TextColor3 = Color3.new(1,1,1)
close.Font = Enum.Font.GothamBold
close.TextScaled = true

close.MouseButton1Click:Connect(function()
	frame.Visible = false
end)

-- Links reales de Cashtab
local nftLinks = {
	["Eco de Mictlán"] = "https://cashtab.com/#/token/2fe71f60ddea05a11cab4dd33973376f109c83807691ae3c10380331df13c5d00",
	["Xolo de las Llamas"] = "https://cashtab.com/#/token/93a0c38a7d60573ab41da34aa3f6dd83a2a49a95515b34ff1493e4dfdf7bf1d5",
	["Vigilante del Amanecer"] = "https://cashtab.com/#/token/5121242b287d90b111635f4bc2e10914c4909b1a74701929e07d143203a49f50",
	["Centinela del Crepúsculo"] = "https://cashtab.com/#/token/fe96165c2323d5421d598f3dd2f06f89961b7e63372fb29798fedf508c7d74d0",
}

ReplicatedStorage:WaitForChild("ShowNFTInfo").OnClientEvent:Connect(function(name, desc)
	frame.NFTTitle.Text = name
	frame.NFTDesc.Text = desc
	frame.Visible = true
	local link = nftLinks[name]
	button.MouseButton1Click:Connect(function()
		if link then
			setclipboard(link)
			button.Text = "¡Enlace copiado!"
			wait(1.2)
			button.Text = "Copiar enlace de NFT"
		end
	end)
end)

