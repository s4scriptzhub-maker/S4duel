local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- === PREMIUM CONFIGURATION ===
local NEON_PURPLE = Color3.fromRGB(190, 0, 255)
local NEON_BLUE = Color3.fromRGB(0, 200, 255)
local BG_COLOR = Color3.fromRGB(10, 8, 15) -- Slightly darker for more contrast
local BG_TRANSPARENCY = 0.35
local BORDER_THICKNESS = 1.4 -- Extra thin premium lines

local guiLocked = false

-- === SMOOTH DRAGGING SYSTEM ===
local function makeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if guiLocked then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- === PREMIUM UI BUILDER ===
local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "S4duels_Premium_Final"
screenGui.ResetOnSpawn = false

local function createPremiumFrame(name, size, pos, accentColor)
    local frame = Instance.new("Frame", screenGui)
    frame.Name = name; frame.Size = size; frame.Position = pos
    frame.BackgroundColor3 = BG_COLOR
    frame.BackgroundTransparency = BG_TRANSPARENCY
    frame.BorderSizePixel = 0; frame.Active = true
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4) -- Sharper corners for premium look
    
    local stroke = Instance.new("UIStroke", frame)
    stroke.Thickness = BORDER_THICKNESS
    stroke.Color = accentColor or NEON_PURPLE
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    
    return frame, stroke
end

-- 1. LOCK GUI (Independent)
local lockFrame, lockStroke = createPremiumFrame("LockContainer", UDim2.new(0, 90, 0, 32), UDim2.new(0.5, -240, 0, 50), NEON_BLUE)
makeDraggable(lockFrame)

local lockBtn = Instance.new("TextButton", lockFrame)
lockBtn.Size = UDim2.new(1, 0, 1, 0); lockBtn.BackgroundTransparency = 1
lockBtn.Text = "LOCK GUI"; lockBtn.TextColor3 = Color3.new(1, 1, 1)
lockBtn.Font = Enum.Font.GothamBold; lockBtn.TextSize = 11

-- 2. MAIN HEADER (S4duels)
local mainFrame = createPremiumFrame("MainHeader", UDim2.new(0, 180, 0, 80), UDim2.new(0.5, -90, 0, 50))
makeDraggable(mainFrame)

local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 30); title.Position = UDim2.new(0, 0, 0, 10)
title.Text = "S4duels"; title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold; title.TextSize = 20; title.BackgroundTransparency = 1

local stats = Instance.new("TextLabel", mainFrame)
stats.Size = UDim2.new(1, 0, 0, 20); stats.Position = UDim2.new(0, 0, 0, 38)
stats.TextColor3 = Color3.fromRGB(150, 150, 150); stats.Font = Enum.Font.Code; stats.TextSize = 11; stats.BackgroundTransparency = 1

local toggleBtn = Instance.new("TextButton", mainFrame)
toggleBtn.Size = UDim2.new(0, 70, 0, 24); toggleBtn.Position = UDim2.new(0.5, -35, 1, 10)
toggleBtn.BackgroundColor3 = BG_COLOR; toggleBtn.Text = "S4HUB"; toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Font = Enum.Font.GothamBold; toggleBtn.TextSize = 11; Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0,4)
local tStroke = Instance.new("UIStroke", toggleBtn); tStroke.Color = NEON_PURPLE; tStroke.Thickness = 1

-- 3. SETTINGS MENU (S4HUB)
local hubFrame = createPremiumFrame("S4HUB_Menu", UDim2.new(0, 400, 0, 280), UDim2.new(0.5, -200, 0.5, -140))
hubFrame.Visible = false
makeDraggable(hubFrame)

-- PREMIUM CLOSE BUTTON
local closeSettings = Instance.new("TextButton", hubFrame)
closeSettings.Size = UDim2.new(0, 24, 0, 24)
closeSettings.Position = UDim2.new(1, -30, 0, 10)
closeSettings.BackgroundColor3 = Color3.fromRGB(40, 10, 15)
closeSettings.BackgroundTransparency = 0.2
closeSettings.Text = "×"
closeSettings.TextColor3 = Color3.new(1, 1, 1)
closeSettings.Font = Enum.Font.GothamBold
closeSettings.TextSize = 18
Instance.new("UICorner", closeSettings).CornerRadius = UDim.new(1, 0)
local cStroke = Instance.new("UIStroke", closeSettings)
cStroke.Color = Color3.fromRGB(255, 50, 70)
cStroke.Thickness = 1.2

local hubTitle = Instance.new("TextLabel", hubFrame)
hubTitle.Size = UDim2.new(1, 0, 0, 45); hubTitle.Text = "S4HUB SETTINGS"
hubTitle.TextColor3 = Color3.new(1, 1, 1); hubTitle.Font = Enum.Font.GothamBold; hubTitle.TextSize = 18; hubTitle.BackgroundTransparency = 1

local scroll = Instance.new("ScrollingFrame", hubFrame)
scroll.Size = UDim2.new(1, -20, 1, -65); scroll.Position = UDim2.new(0, 10, 0, 55); scroll.BackgroundTransparency = 1; scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 1; scroll.ScrollBarImageColor3 = NEON_PURPLE
local grid = Instance.new("UIGridLayout", scroll)
grid.CellSize = UDim2.new(0.48, 0, 0, 40); grid.CellPadding = UDim2.new(0.03, 0, 0, 8)

-- Placeholder Buttons
for i = 1, 8 do
    local btn = Instance.new("TextButton", scroll)
    btn.BackgroundColor3 = Color3.fromRGB(25, 20, 35); btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Text = "s4loading"; btn.Font = Enum.Font.GothamSemibold; btn.TextSize = 13
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,4)
    local bStroke = Instance.new("UIStroke", btn); bStroke.Color = Color3.fromRGB(60, 60, 70); bStroke.Thickness = 0.8
end

-- === LOGIC ===
toggleBtn.MouseButton1Click:Connect(function() hubFrame.Visible = not hubFrame.Visible end)
closeSettings.MouseButton1Click:Connect(function() hubFrame.Visible = false end)

lockBtn.MouseButton1Click:Connect(function()
    guiLocked = not guiLocked
    lockBtn.Text = guiLocked and "LOCKED" or "LOCK GUI"
    lockStroke.Color = guiLocked and Color3.fromRGB(255, 50, 50) or NEON_BLUE
end)

task.spawn(function()
    while true do
        local fps = math.floor(1 / RunService.RenderStepped:Wait())
        local ping = math.floor(player:GetNetworkPing() * 1000)
        stats.Text = string.format("FPS: %d  |  PING: %dms", fps, ping)
        task.wait(0.5)
    end
end)
