local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local playerGui = Player:WaitForChild("PlayerGui")

-- === CONFIGURATION ===
local NEON_PURPLE = Color3.fromRGB(190, 0, 255)
local NEON_BLUE = Color3.fromRGB(0, 200, 255)
local BG_COLOR = Color3.fromRGB(5, 4, 8)
local TRANSPARENCY = 0.55 -- Increased transparency for a glass look

local guiLocked = false

-- === UI BUILDER ===
local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "S4duels_Final"
screenGui.ResetOnSpawn = false

local function createFrame(name, size, pos, accent, thick)
    local f = Instance.new("Frame", screenGui)
    f.Name = name; f.Size = size; f.Position = pos
    f.BackgroundColor3 = BG_COLOR
    f.BackgroundTransparency = TRANSPARENCY
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 4)
    
    local s = Instance.new("UIStroke", f)
    s.Thickness = thick or 3.5 -- Kept the thicker premium neon lines
    s.Color = accent or NEON_PURPLE
    return f, s
end

-- 1. LOCK SYSTEM (Restored & Fixed)
local lockFrame, lockStroke = createFrame("Lock", UDim2.new(0, 95, 0, 32), UDim2.new(0.5, -240, 0, 50), NEON_BLUE, 2.5)
local lockBtn = Instance.new("TextButton", lockFrame)
lockBtn.Size = UDim2.new(1, 0, 1, 0); lockBtn.BackgroundTransparency = 1; lockBtn.Text = "LOCK GUI"; lockBtn.TextColor3 = Color3.new(1,1,1); lockBtn.Font = Enum.Font.GothamBold; lockBtn.TextSize = 11

-- 2. MAIN HEADER (Bolder Style)
local mainFrame = createFrame("Main", UDim2.new(0, 180, 0, 85), UDim2.new(0.5, -90, 0, 50), NEON_PURPLE, 4)
local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 35); title.Text = "S4DUELS"; title.TextColor3 = Color3.new(1,1,1); title.Font = Enum.Font.GothamBold; title.TextSize = 24; title.BackgroundTransparency = 1

local stats = Instance.new("TextLabel", mainFrame)
stats.Size = UDim2.new(1, 0, 0, 15); stats.Position = UDim2.new(0,0,0,42); stats.TextColor3 = Color3.fromRGB(200,200,200); stats.TextSize = 8.5; stats.BackgroundTransparency = 1

local toggleHub = Instance.new("TextButton", mainFrame)
toggleHub.Size = UDim2.new(0, 70, 0, 24); toggleHub.Position = UDim2.new(0.5, -35, 1, 10); toggleHub.Text = "S4HUB"; toggleHub.BackgroundColor3 = Color3.fromRGB(15,15,20); toggleHub.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", toggleHub)

-- 3. HUB MENU (S4HUB Title)
local hubFrame = createFrame("Hub", UDim2.new(0, 400, 0, 300), UDim2.new(0.5, -200, 0.5, -150), NEON_PURPLE, 3.8)
hubFrame.Visible = false

local closeHub = Instance.new("TextButton", hubFrame)
closeHub.Size = UDim2.new(0, 24, 0, 24); closeHub.Position = UDim2.new(1, -30, 0, 10); closeHub.Text = "×"; closeHub.BackgroundColor3 = Color3.fromRGB(45,15,20); closeHub.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", closeHub).CornerRadius = UDim.new(1,0)

local hubTitle = Instance.new("TextLabel", hubFrame)
hubTitle.Size = UDim2.new(1, 0, 0, 50); hubTitle.Text = "S4HUB"; hubTitle.TextColor3 = Color3.new(1,1,1); hubTitle.Font = Enum.Font.GothamBold; hubTitle.TextSize = 26; hubTitle.BackgroundTransparency = 1

local scroll = Instance.new("ScrollingFrame", hubFrame)
scroll.Size = UDim2.new(1, -20, 1, -85); scroll.Position = UDim2.new(0, 10, 0, 70); scroll.BackgroundTransparency = 1; scroll.BorderSizePixel = 0
Instance.new("UIGridLayout", scroll).CellSize = UDim2.new(0.48, 0, 0, 40)

-- Populate Hub with placeholders
for i = 1, 8 do
    local btn = Instance.new("TextButton", scroll)
    btn.Text = "s4loading"; btn.BackgroundColor3 = Color3.fromRGB(22, 18, 30); btn.BackgroundTransparency = 0.2
    btn.TextColor3 = Color3.new(1,1,1); btn.Font = Enum.Font.GothamSemibold; Instance.new("UICorner", btn)
    local bStroke = Instance.new("UIStroke", btn); bStroke.Color = Color3.fromRGB(70, 70, 80)
end

-- === INTERACTIONS ===
lockBtn.MouseButton1Click:Connect(function()
    guiLocked = not guiLocked
    lockBtn.Text = guiLocked and "LOCKED" or "LOCK GUI"
    lockStroke.Color = guiLocked and Color3.fromRGB(255, 50, 50) or NEON_BLUE
end)

toggleHub.MouseButton1Click:Connect(function() hubFrame.Visible = not hubFrame.Visible end)
closeHub.MouseButton1Click:Connect(function() hubFrame.Visible = false end)

-- DRAG LOGIC
local function drag(f)
    local d, st, sp
    f.InputBegan:Connect(function(i) 
        if not guiLocked and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then 
            d = true; st = i.Position; sp = f.Position 
        end 
    end)
    UserInputService.InputChanged:Connect(function(i) 
        if d then 
            local del = i.Position - st
            f.Position = UDim2.new(sp.X.Scale, sp.X.Offset + del.X, sp.Y.Scale, sp.Y.Offset + del.Y) 
        end 
    end)
    UserInputService.InputEnded:Connect(function() d = false end)
end

drag(mainFrame); drag(hubFrame); drag(lockFrame)

-- Stats Loop
task.spawn(function()
    while true do
        stats.Text = string.format("FPS: %d | PING: %dms", math.floor(1/RunService.RenderStepped:Wait()), math.floor(Player:GetNetworkPing()*1000))
        task.wait(0.5)
    end
end)
