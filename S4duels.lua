local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- === PREMIUM CONFIGURATION ===
local NEON_PURPLE = Color3.fromRGB(190, 0, 255)
local NEON_BLUE = Color3.fromRGB(0, 200, 255)
local BG_COLOR = Color3.fromRGB(10, 8, 15)
local BG_TRANSPARENCY = 0.35
local BORDER_THICKNESS = 1.4

local guiLocked = false

-- === FEATURES STATE (FROM 22s HUB) ===
local Features = {
    ["Speed Boost"] = false,
    ["Anti-Ragdoll"] = false,
    ["SpinBot"] = false,
    ["Auto Steal"] = false,
    ["Optimizer"] = false,
    ["Spam Bat"] = false,
    ["Bat Aimbot"] = false,
    ["Galaxy Mode"] = false
}

-- === DRAGGING SYSTEM ===
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

-- === UI BUILDER ===
local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "S4duels_22s_Premium"
screenGui.ResetOnSpawn = false

local function createPremiumFrame(name, size, pos, accentColor)
    local frame = Instance.new("Frame", screenGui)
    frame.Name = name; frame.Size = size; frame.Position = pos
    frame.BackgroundColor3 = BG_COLOR; frame.BackgroundTransparency = BG_TRANSPARENCY
    frame.BorderSizePixel = 0; frame.Active = true
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Thickness = BORDER_THICKNESS; stroke.Color = accentColor or NEON_PURPLE
    return frame, stroke
end

-- 1. LOCK GUI
local lockFrame, lockStroke = createPremiumFrame("LockContainer", UDim2.new(0, 90, 0, 32), UDim2.new(0.5, -240, 0, 50), NEON_BLUE)
makeDraggable(lockFrame)
local lockBtn = Instance.new("TextButton", lockFrame)
lockBtn.Size = UDim2.new(1, 0, 1, 0); lockBtn.BackgroundTransparency = 1; lockBtn.Text = "LOCK GUI"; lockBtn.TextColor3 = Color3.new(1, 1, 1); lockBtn.Font = Enum.Font.GothamBold; lockBtn.TextSize = 11

-- 2. MAIN HEADER
local mainFrame = createPremiumFrame("MainHeader", UDim2.new(0, 180, 0, 80), UDim2.new(0.5, -90, 0, 50))
makeDraggable(mainFrame)
local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 30); title.Position = UDim2.new(0, 0, 0, 10); title.Text = "S4duels"; title.TextColor3 = Color3.new(1, 1, 1); title.Font = Enum.Font.GothamBold; title.TextSize = 20; title.BackgroundTransparency = 1
local stats = Instance.new("TextLabel", mainFrame)
stats.Size = UDim2.new(1, 0, 0, 20); stats.Position = UDim2.new(0, 0, 0, 38); stats.TextColor3 = Color3.fromRGB(150, 150, 150); stats.Font = Enum.Font.Code; stats.TextSize = 11; stats.BackgroundTransparency = 1

local toggleBtn = Instance.new("TextButton", mainFrame)
toggleBtn.Size = UDim2.new(0, 70, 0, 24); toggleBtn.Position = UDim2.new(0.5, -35, 1, 10); toggleBtn.BackgroundColor3 = BG_COLOR; toggleBtn.Text = "S4HUB"; toggleBtn.TextColor3 = Color3.new(1, 1, 1); toggleBtn.Font = Enum.Font.GothamBold; toggleBtn.TextSize = 11; Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0,4)

-- 3. SETTINGS MENU
local hubFrame = createPremiumFrame("S4HUB_Menu", UDim2.new(0, 400, 0, 320), UDim2.new(0.5, -200, 0.5, -160))
hubFrame.Visible = false
makeDraggable(hubFrame)

local closeBtn = Instance.new("TextButton", hubFrame)
closeBtn.Size = UDim2.new(0, 24, 0, 24); closeBtn.Position = UDim2.new(1, -30, 0, 10); closeBtn.BackgroundColor3 = Color3.fromRGB(40, 10, 15); closeBtn.Text = "×"; closeBtn.TextColor3 = Color3.new(1, 1, 1); closeBtn.Font = Enum.Font.GothamBold; Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)
local hubTitle = Instance.new("TextLabel", hubFrame)
hubTitle.Size = UDim2.new(1, 0, 0, 45); hubTitle.Text = "S4HUB SETTINGS"; hubTitle.TextColor3 = Color3.new(1, 1, 1); hubTitle.Font = Enum.Font.GothamBold; hubTitle.TextSize = 16; hubTitle.BackgroundTransparency = 1

local scroll = Instance.new("ScrollingFrame", hubFrame)
scroll.Size = UDim2.new(1, -20, 1, -70); scroll.Position = UDim2.new(0, 10, 0, 55); scroll.BackgroundTransparency = 1; scroll.BorderSizePixel = 0; scroll.ScrollBarThickness = 1
local grid = Instance.new("UIGridLayout", scroll)
grid.CellSize = UDim2.new(0.48, 0, 0, 40); grid.CellPadding = UDim2.new(0.03, 0, 0, 8)

-- === POPULATE BUTTONS WITH 22s LOGISTICS ===
for name, _ in pairs(Features) do
    local btn = Instance.new("TextButton", scroll)
    btn.BackgroundColor3 = Color3.fromRGB(20, 15, 25); btn.TextColor3 = Color3.new(1, 1, 1); btn.Text = name; btn.Font = Enum.Font.GothamSemibold; btn.TextSize = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,4)
    local bStroke = Instance.new("UIStroke", btn); bStroke.Color = Color3.fromRGB(60, 60, 70); bStroke.Thickness = 0.8

    btn.MouseButton1Click:Connect(function()
        Features[name] = not Features[name]
        btn.BackgroundColor3 = Features[name] and Color3.fromRGB(50, 30, 70) or Color3.fromRGB(20, 15, 25)
        bStroke.Color = Features[name] and NEON_PURPLE or Color3.fromRGB(60, 60, 70)
        
        -- Logical triggers based on 22s hub file
        if name == "Optimizer" and Features[name] then
            -- Simple render optimization
            for _, v in pairs(game:GetDescendants()) do
                if v:IsA("PostProcessEffect") then v.Enabled = false end
            end
        elseif name == "Anti-Ragdoll" then
            player.Character.Humanoid.PlatformStand = false
        end
    end)
end

-- === GLOBAL LOGIC ===
toggleBtn.MouseButton1Click:Connect(function() hubFrame.Visible = not hubFrame.Visible end)
closeBtn.MouseButton1Click:Connect(function() hubFrame.Visible = false end)
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
