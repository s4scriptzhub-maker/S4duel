local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- === CONFIGURATION ===
local NEON_PURPLE = Color3.fromRGB(180, 0, 255)
local NEON_BLUE = Color3.fromRGB(0, 180, 255)
local BG_COLOR = Color3.fromRGB(25, 20, 35)
local BG_TRANSPARENCY = 0.4

local guiLocked = false

-- === CORE SCREEN GUI ===
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "S4duels_Final_V2"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- === UNIVERSAL DRAGGING FUNCTION (MOBILE & PC) ===
local function makeDraggable(frame)
	local dragging = false
	local dragInput, dragStart, startPos

	frame.InputBegan:Connect(function(input)
		if guiLocked then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	frame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input == dragInput then
			if guiLocked then dragging = false return end
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

-- === STYLED FRAME CREATOR ===
local function createStyledFrame(name, size, pos, strokeColor)
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.Size = size
	frame.Position = pos
	frame.BackgroundColor3 = BG_COLOR
	frame.BackgroundTransparency = BG_TRANSPARENCY
	frame.BorderSizePixel = 0
	frame.Active = true 
	frame.Parent = screenGui

	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 2
	stroke.Color = strokeColor or NEON_PURPLE
	stroke.Parent = frame

	return frame, stroke
end

-- === 1. INDEPENDENT LOCK BUTTON (Moves alone) ===
local lockFrame, lockStroke = createStyledFrame("LockContainer", UDim2.new(0, 110, 0, 40), UDim2.new(0.5, -230, 0, 50), NEON_BLUE)
makeDraggable(lockFrame)

local lockBtn = Instance.new("TextButton")
lockBtn.Size = UDim2.new(1, 0, 1, 0)
lockBtn.BackgroundTransparency = 1
lockBtn.Text = "Lock GUI"
lockBtn.TextColor3 = Color3.new(1, 1, 1)
lockBtn.Font = Enum.Font.GothamBold
lockBtn.TextSize = 14
lockBtn.Parent = lockFrame

-- === 2. MAIN HEADER (S4duels + Toggle attached) ===
local mainFrame = createStyledFrame("MainHeader", UDim2.new(0, 220, 0, 80), UDim2.new(0.5, -110, 0, 50))
makeDraggable(mainFrame)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.Position = UDim2.new(0, 0, 0, 8)
title.Text = "S4duels"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 24
title.BackgroundTransparency = 1
title.Parent = mainFrame

local statsLabel = Instance.new("TextLabel")
statsLabel.Size = UDim2.new(1, 0, 0, 20)
statsLabel.Position = UDim2.new(0, 0, 0, 40)
statsLabel.Text = "FPS: 0 | PING: 0ms"
statsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statsLabel.Font = Enum.Font.Code
statsLabel.BackgroundTransparency = 1
statsLabel.Parent = mainFrame

-- Toggle Button (Nested INSIDE mainFrame so it moves with it)
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 90, 0, 30)
toggleBtn.Position = UDim2.new(0.5, -45, 1, 5) -- Positioned just below the header
toggleBtn.BackgroundColor3 = BG_COLOR
toggleBtn.BackgroundTransparency = BG_TRANSPARENCY
toggleBtn.Text = "Toggle"
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 14
toggleBtn.Parent = mainFrame

local tStroke = Instance.new("UIStroke", toggleBtn)
tStroke.Color = NEON_PURPLE
tStroke.Thickness = 2
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)

-- === 3. S4HUB SETTINGS MENU (Independent) ===
local settingsFrame = createStyledFrame("S4HUB", UDim2.new(0, 420, 0, 300), UDim2.new(0.5, -210, 0.5, -150))
settingsFrame.Visible = false
makeDraggable(settingsFrame)

local settingsTitle = Instance.new("TextLabel")
settingsTitle.Size = UDim2.new(1, 0, 0, 50)
settingsTitle.Text = "S4HUB"
settingsTitle.Font = Enum.Font.GothamBold
settingsTitle.TextColor3 = Color3.new(1, 1, 1)
settingsTitle.TextSize = 22
settingsTitle.BackgroundTransparency = 1
settingsTitle.Parent = settingsFrame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -40, 0, 10)
closeBtn.BackgroundColor3 = Color3.fromRGB(60, 20, 20)
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.TextSize = 22
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = settingsFrame
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", closeBtn).Color = NEON_PURPLE

-- GRID LAYOUT
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -30, 1, -70)
scroll.Position = UDim2.new(0, 15, 0, 60)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.Parent = settingsFrame

local grid = Instance.new("UIGridLayout")
grid.CellSize = UDim2.new(0.48, 0, 0, 45)
grid.CellPadding = UDim2.new(0.04, 0, 0, 10)
grid.Parent = scroll

for i = 1, 8 do
	local btn = Instance.new("TextButton")
	btn.BackgroundColor3 = Color3.fromRGB(50, 45, 65)
	btn.Text = "s4loading"
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.GothamSemibold
	btn.TextSize = 16
	btn.Parent = scroll
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
end

-- === LOGIC ===
toggleBtn.MouseButton1Click:Connect(function()
	settingsFrame.Visible = not settingsFrame.Visible
end)

closeBtn.MouseButton1Click:Connect(function()
	settingsFrame.Visible = false
end)

lockBtn.MouseButton1Click:Connect(function()
	guiLocked = not guiLocked
	if guiLocked then
		lockBtn.Text = "Locked"
		lockStroke.Color = Color3.fromRGB(255, 80, 80) -- Red for Locked
	else
		lockBtn.Text = "Lock GUI"
		lockStroke.Color = NEON_BLUE -- Blue for Unlocked
	end
end)

-- Performance Update
task.spawn(function()
	while true do
		local fps = math.floor(1 / RunService.RenderStepped:Wait())
		local ping = math.floor(player:GetNetworkPing() * 2000)
		statsLabel.Text = string.format("FPS: %d  |  PING: %dms", fps, ping)
		task.wait(0.5)
	end
end)
