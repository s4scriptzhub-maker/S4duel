local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- 1. Main Container
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "S4duels_TopUI"
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

-- 2. Main Hub Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainBanner"
mainFrame.Size = UDim2.new(0, 320, 0, 90)
mainFrame.Position = UDim2.new(0.5, -160, 0, 40)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = mainFrame

-- Outer Glow/Stroke
local stroke = Instance.new("UIStroke")
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(80, 50, 150)
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
stroke.Parent = mainFrame

-- 3. The Title (S4duels)
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.Position = UDim2.new(0, 0, 0, 10)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "S4duels"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 28
titleLabel.Parent = mainFrame

-- Purple Gradient for Title
local titleGradient = Instance.new("UIGradient")
titleGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 100, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 200, 255))
})
titleGradient.Parent = titleLabel

-- 4. Stats Label (FPS/Ping)
local statsLabel = Instance.new("TextLabel")
statsLabel.Name = "Stats"
statsLabel.Size = UDim2.new(1, 0, 0, 25)
statsLabel.Position = UDim2.new(0, 0, 0, 50)
statsLabel.BackgroundTransparency = 1
statsLabel.Text = "FPS: 00 | PING: 00ms"
statsLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
statsLabel.Font = Enum.Font.Code
statsLabel.TextSize = 14
statsLabel.Parent = mainFrame

-- 5. Toggle Button (Decorative/Visual)
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleButton"
toggleBtn.Size = UDim2.new(0, 60, 0, 25)
toggleBtn.Position = UDim2.new(0.5, -30, 1, 5)
toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
toggleBtn.Text = "Toggle"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamSemibold
toggleBtn.TextSize = 12
toggleBtn.Parent = mainFrame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 5)
btnCorner.Parent = toggleBtn

-- === LOGIC: Performance Counters ===
local lastUpdate = 0
RunService.RenderStepped:Connect(function(deltaTime)
	lastUpdate = lastUpdate + deltaTime
	if lastUpdate >= 0.5 then -- Update every half second
		local fps = math.floor(1 / deltaTime)
		local ping = math.floor(player:GetNetworkPing() * 2000) -- Convert to ms
		statsLabel.Text = string.format("FPS: %d  |  PING: %dms", fps, ping)
		lastUpdate = 0
	end
end)
