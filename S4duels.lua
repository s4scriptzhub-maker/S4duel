local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- === PREMIUM CONFIGURATION ===
local NEON_PURPLE = Color3.fromRGB(190, 0, 255)
local NEON_BLUE = Color3.fromRGB(0, 200, 255)
local BG_COLOR = Color3.fromRGB(15, 12, 20) -- Deeper, sleeker background
local BG_TRANSPARENCY = 0.35
local BORDER_THICKNESS = 1.8 -- Thinner for a more refined look

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
screenGui.Name = "S4duels_Premium"
screenGui.ResetOnSpawn = false

local function createPremiumFrame(name, size, pos, accentColor)
    local frame = Instance.new("Frame", screenGui)
    frame.Name = name; frame.Size = size; frame.Position = pos
    frame.BackgroundColor3 = BG_COLOR
    frame.BackgroundTransparency = BG_TRANSPARENCY
    frame.BorderSizePixel = 0; frame.Active = true
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    
    -- Neon Border (Thin & High Intensity)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Thickness = BORDER_THICKNESS
    stroke.Color = accentColor or NEON_PURPLE
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    
    return frame, stroke
end

-- 1. LOCK GUI (Independent & Sleek)
local lockFrame, lockStroke = createPremiumFrame("LockContainer", UDim2.new(0, 100, 0, 35), UDim2.new(0.5, -240, 0, 50), NEON_BLUE)
makeDraggable(lockFrame)

local lockBtn = Instance.new("TextButton", lockFrame)
lockBtn.Size = UDim2.new(1, 0, 1, 0); lockBtn.BackgroundTransparency = 1
lockBtn.Text = "LOCK GUI"; lockBtn.TextColor3 = Color3.new(1, 1, 1)
lockBtn.Font = Enum.Font.GothamBold; lockBtn.TextSize = 12; lockBtn.TextStrokeTransparency = 0.8

-- 2. MAIN HEADER (S4duels)
local mainFrame = createPremiumFrame("MainHeader", UDim2.new(0, 200, 0, 85), UDim2.new(0.5, -100, 0, 50))
makeDraggable(mainFrame)

local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 35); title.Position = UDim2.new(0, 0, 0, 8)
title.Text = "S4duels"; title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold; title.TextSize = 22; title.BackgroundTransparency = 1

local stats = Instance.new("TextLabel", mainFrame)
stats.Size = UDim2.new(1, 0, 0, 20); stats.Position = UDim2.new(0, 0, 0, 42)
stats.TextColor3 = Color3.fromRGB(180, 180, 180); stats.Font = Enum.Font.Code; stats.TextSize = 12; stats.BackgroundTransparency = 1

local toggleBtn = Instance.new("TextButton", mainFrame)
toggleBtn.Size = UDim2.new(0, 80, 0, 26); toggleBtn.Position = UDim2.new(0.5, -40, 1, 10)
toggleBtn.BackgroundColor3 = BG_COLOR; toggleBtn.Text = "S4HUB"; toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Font = Enum.Font.GothamBold; toggleBtn.TextSize = 12; Instance.new("UICorner", toggleBtn)
local tStroke = Instance.new("UIStroke", toggleBtn); tStroke.Color = NEON_PURPLE; tStroke.Thickness = 1.2

-- 3. SETTINGS MENU (S4HUB)
local hubFrame = createPremiumFrame("S4HUB_Menu", UDim2.new(0, 420, 0, 300), UDim2.new(0.5, -210, 0.5, -150))
hubFrame.Visible = false
makeDraggable(hubFrame)

local hubTitle = Instance.new("TextLabel", hubFrame)
hubTitle.Size = UDim2.new(1, 0, 0, 50); hubTitle.Text = "S4HUB SETTINGS"
hubTitle.TextColor3 = Color3.new(1, 1, 1); hubTitle.Font = Enum.Font.GothamBold; hubTitle.TextSize = 20; hubTitle.BackgroundTransparency = 1

local scroll = Instance.new("ScrollingFrame", hubFrame)
scroll.Size = UDim2.new(1, -20, 1, -70); scroll.Position = UDim2.new(0, 10, 0, 60); scroll.BackgroundTransparency = 1; scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 2; scroll.ScrollBarImageColor3 = NEON_PURPLE
local grid = Instance.new("UIGridLayout", scroll)
grid.CellSize = UDim2.new(0.48, 0, 0, 45); grid.CellPadding = UDim2.new(0.03, 0, 0, 10)

-- Populate Buttons (Placeholders for your future logistics)
for i = 1, 8 do
    local btn = Instance.new("TextButton", scroll)
    btn.BackgroundColor3 = Color3.fromRGB(30, 25, 40); btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Text = "s4loading"; btn.Font = Enum.Font.GothamSemibold; btn.TextSize = 14
    Instance.new("UICorner", btn)
    local bStroke = Instance.new("UIStroke", btn); bStroke.Color = Color3.fromRGB(80, 80, 80); bStroke.Thickness = 1
end

-- === LOGIC ===
toggleBtn.MouseButton1Click:Connect(function() hubFrame.Visible = not hubFrame.Visible end)

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
