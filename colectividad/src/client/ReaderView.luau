local ContextActionService = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local activeReader

local ReaderView = {}
local parchment = Color3.fromRGB(249, 235, 207)
local amber = Color3.fromRGB(236, 186, 120)
local muted = Color3.fromRGB(221, 209, 187)
ReaderView.colors = table.freeze({ parchment = parchment, amber = amber, muted = muted })

function ReaderView.create(playerGui, name, closeAction)
	local gui = Instance.new("ScreenGui")
	gui.Name = name
	gui.DisplayOrder = 15
	gui.ResetOnSpawn = false
	gui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
	gui.Enabled = false

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
		if activeReader == hide then
			activeReader = nil
		end
		ContextActionService:UnbindAction(closeAction)
	end

	local function closeWithButton(_, state)
		if state == Enum.UserInputState.Begin then
			hide()
		end
		return Enum.ContextActionResult.Sink
	end

	local function show()
		scroller.CanvasPosition = Vector2.zero

		if not gui.Enabled then
			if activeReader then
				activeReader()
			end
			activeReader = hide
			previousSelection = GuiService.SelectedObject
			gui.Enabled = true
			ContextActionService:BindAction(closeAction, closeWithButton, false, Enum.KeyCode.ButtonB, Enum.KeyCode.Backspace)
		end

		if string.find(UserInputService:GetLastInputType().Name, "Gamepad", 1, true) then
			GuiService.SelectedObject = close
		end
	end
	gui.Parent = playerGui
	return {
		gui = gui,
		close = close,
		line = line,
		show = show,
		hide = hide,
	}
end

return ReaderView
