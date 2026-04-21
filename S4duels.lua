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
screenGui.Name = "S4duels_Interface"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- === DRAGGING FUNCTIONALITY ===
local function makeDraggable(frame)
	local dragging, dragInput, dragStart, startPos
	frame.InputBegan:Connect(function(input)
		if not guiLocked and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
		end
	end)
	frame.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
	end)
end

-- === CREATE STYLED FRAME ===
local function createStyledFrame(name, size, pos)
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.Size = size
	frame.Position = pos
	frame.BackgroundColor3 = BG_COLOR
	frame.BackgroundTransparency = BG_TRANSPARENCY
	frame.BorderSizePixel = 0
	frame.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = frame

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 2
	stroke.Color = NEON_PURPLE
	stroke.Parent = frame

	return frame, stroke
end

-- === MAIN HEADER ===
local mainFrame, mainStroke = createStyledFrame("MainHeader", UDim2.new(0, 300, 0, 90), UDim2.new(0.5, -150, 0, 50))
makeDraggable(mainFrame)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 10)
title.Text = "S4duels"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 26
title.BackgroundTransparency = 1
title.Parent = mainFrame

local statsLabel = Instance.new("TextLabel")
statsLabel.Size = UDim2.new(1, 0, 0, 20)
statsLabel.Position = UDim2.new(0, 0, 0, 45)
statsLabel.Text = "FPS: 0 | PING: 0ms"
statsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statsLabel.Font = Enum.Font.Code
statsLabel.BackgroundTransparency = 1
statsLabel.Parent = mainFrame

-- === LOCK BUTTON ===
local lockBtn = Instance.new("TextButton")
lockBtn.Size = UDim2.new(0, 80, 0, 25)
lockBtn.Position = UDim2.new(0, -90, 0, 0)
lockBtn.BackgroundColor3 = BG_COLOR
lockBtn.BackgroundTransparency = BG_TRANSPARENCY
lockBtn.Text = "Lock GUI"
lockBtn.TextColor3 = Color3.new(1, 1, 1)
lockBtn.Font = Enum.Font.GothamBold
lockBtn.TextSize = 12
lockBtn.Parent = mainFrame

local lockCorner = Instance.new("UICorner")
lockCorner.CornerRadius = UDim.new(0, 5)
lockCorner.Parent = lockBtn

local lockStroke = Instance.new("UIStroke")
lockStroke.Color = NEON_BLUE
lockStroke.Thickness = 2
lockStroke.Parent = lockBtn

-- === SETTINGS MENU ===
local settingsFrame, settingsStroke = createStyledFrame("Settings", UDim2.new(0, 250, 0, 350), UDim2.new(0.5, -125, 0.5, -175))
settingsFrame.Visible = false
makeDraggable(settingsFrame)

local settingsTitle = Instance.new("TextLabel")
settingsTitle.Size = UDim2.new(1, 0, 0, 40)
settingsTitle.Text = "Settings"
settingsTitle.Font = Enum.Font.GothamBold
settingsTitle.TextColor3 = Color3.new(1, 1, 1)
settingsTitle.BackgroundTransparency = 1
settingsTitle.Parent = settingsFrame

local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0, 5)
list.HorizontalAlignment = Enum.HorizontalAlignment.Center
list.Parent = settingsFrame

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 45)
padding.Parent = settingsFrame

for i = 1, 8 do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.9, 0, 0, 30)
	btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
	btn.Text = "s4loading"
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.Gotham
	btn.Parent = settingsFrame
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
end

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0.9, 0, 0, 30)
closeBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
closeBtn.Text = "Close"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Parent = settingsFrame
Instance.new("UICorner", closeBtn)

-- === TOGGLE LOGIC ===
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 60, 0, 25)
toggleBtn.Position = UDim2.new(0.5, -30, 1, 5)
toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
toggleBtn.Text = "Toggle"
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Parent = mainFrame
Instance.new("UICorner", toggleBtn)

local function toggleSettings()
	settingsFrame.Visible = not settingsFrame.Visible
end

toggleBtn.MouseButton1Click:Connect(toggleSettings)
closeBtn.MouseButton1Click:Connect(function() settingsFrame.Visible = false end)

-- === LOCK LOGIC ===
lockBtn.MouseButton1Click:Connect(function()
	guiLocked = not guiLocked
	lockBtn.Text = guiLocked and "Locked" or "Lock GUI"
end)

-- === PERFORMANCE UPDATE (Every 0.5s) ===
spawn(function()
	while task.wait(0.5) do
		local fps = math.floor(1 / RunService.RenderStepped:Wait())
		local ping = math.floor(player:GetNetworkPing() * 2000)
		statsLabel.Text = string.format("FPS: %d  |  PING: %dms", fps, ping)
	end
end)
