local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local playerGui = Player:WaitForChild("PlayerGui")

-- === PREMIUM CONFIGURATION ===
local NEON_PURPLE = Color3.fromRGB(190, 0, 255)
local NEON_BLUE = Color3.fromRGB(0, 200, 255)
local BG_COLOR = Color3.fromRGB(10, 8, 15)
local BORDER_THICKNESS = 1.2 -- Premium thin lines

local guiLocked = false
local Connections = {}
local Enabled = {
    SpeedBoost = false,
    AntiRagdoll = false,
    SpinBot = false,
    AutoSteal = false,
    Optimizer = false,
    SpamBat = false,
    BatAimbot = false,
    Galaxy = false
}

-- Logistic Values from 22s Hub [cite: 2]
local Values = {
    BoostSpeed = 30,
    SpinSpeed = 30,
    STEAL_RADIUS = 20,
    STEAL_DURATION = 1.3,
    DEFAULT_GRAVITY = 196.2,
    GalaxyGravityPercent = 70
}

-- === CORE UTILITIES [cite: 6, 7] ===
local function getMovementDirection()
    local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
    return hum and hum.MoveDirection or Vector3.zero
end

local function findBat()
    local c = Player.Character
    if not c then return nil end
    for _, ch in ipairs(c:GetChildren()) do
        if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end
    end
    local bp = Player:FindFirstChildOfClass("Backpack")
    if bp then
        for _, ch in ipairs(bp:GetChildren()) do
            if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end
        end
    end
    return nil
end

-- === FUNCTIONAL LOGISTICS [cite: 1, 7, 11, 13, 27, 33] ===

-- 1. Anti-Ragdoll [cite: 27]
local function toggleAntiRagdoll(state)
    if not state then 
        if Connections.antiRagdoll then Connections.antiRagdoll:Disconnect() end
        return 
    end
    Connections.antiRagdoll = RunService.Heartbeat:Connect(function()
        local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
        if hum and (hum:GetState() == Enum.HumanoidStateType.Ragdoll or hum:GetState() == Enum.HumanoidStateType.FallingDown) then
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end
    end)
end

-- 2. Bat Aimbot [cite: 11]
local function toggleBatAimbot(state)
    if not state then
        if Connections.batAimbot then Connections.batAimbot:Disconnect() end
        return
    end
    Connections.batAimbot = RunService.Heartbeat:Connect(function()
        local h = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if not h then return end
        local nearest, dist = nil, math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local d = (p.Character.HumanoidRootPart.Position - h.Position).Magnitude
                if d < dist then dist = d nearest = p.Character.HumanoidRootPart end
            end
        end
        if nearest then
            local dir = (nearest.Position - h.Position).Unit
            h.AssemblyLinearVelocity = Vector3.new(dir.X * 55, h.AssemblyLinearVelocity.Y, dir.Z * 55)
        end
    end)
end

-- 3. Speed Boost [cite: 18]
local function toggleSpeed(state)
    if not state then
        if Connections.speed then Connections.speed:Disconnect() end
        return
    end
    Connections.speed = RunService.Heartbeat:Connect(function()
        local h = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        local md = getMovementDirection()
        if h and md.Magnitude > 0.1 then
            h.AssemblyLinearVelocity = Vector3.new(md.X * Values.BoostSpeed, h.AssemblyLinearVelocity.Y, md.Z * Values.BoostSpeed)
        end
    end)
end

-- === UI BUILDER ===
local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.ResetOnSpawn = false

local function createFrame(name, size, pos, accent)
    local f = Instance.new("Frame", screenGui)
    f.Name = name; f.Size = size; f.Position = pos
    f.BackgroundColor3 = BG_COLOR; f.BackgroundTransparency = 0.3
    f.BorderSizePixel = 0; Instance.new("UICorner", f).CornerRadius = UDim.new(0, 4)
    local s = Instance.new("UIStroke", f)
    s.Thickness = BORDER_THICKNESS; s.Color = accent or NEON_PURPLE
    return f, s
end

-- Dragging Logic
local function makeDraggable(frame)
    local dragging, dragStart, startPos
    frame.InputBegan:Connect(function(i)
        if not guiLocked and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then
            dragging = true; dragStart = i.Position; startPos = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging then
            local delta = i.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i) dragging = false end)
end

-- Main Components
local mainFrame = createFrame("Main", UDim2.new(0, 180, 0, 80), UDim2.new(0.5, -90, 0, 50))
makeDraggable(mainFrame)
local hubFrame = createFrame("Hub", UDim2.new(0, 400, 0, 300), UDim2.new(0.5, -200, 0.5, -150))
hubFrame.Visible = false
makeDraggable(hubFrame)

-- Functional Close Button
local closeBtn = Instance.new("TextButton", hubFrame)
closeBtn.Size = UDim2.new(0, 24, 0, 24); closeBtn.Position = UDim2.new(1, -30, 0, 10)
closeBtn.BackgroundColor3 = Color3.fromRGB(40, 10, 15); closeBtn.Text = "×"; closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Font = Enum.Font.GothamBold; Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)
closeBtn.MouseButton1Click:Connect(function() hubFrame.Visible = false end)

-- Settings Grid [cite: 2]
local scroll = Instance.new("ScrollingFrame", hubFrame)
scroll.Size = UDim2.new(1, -20, 1, -70); scroll.Position = UDim2.new(0, 10, 0, 60); scroll.BackgroundTransparency = 1
local grid = Instance.new("UIGridLayout", scroll)
grid.CellSize = UDim2.new(0.48, 0, 0, 40); grid.CellPadding = UDim2.new(0.03, 0, 0, 8)

for name, _ in pairs(Enabled) do
    local btn = Instance.new("TextButton", scroll)
    btn.Text = name; btn.BackgroundColor3 = Color3.fromRGB(20, 15, 25); btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamSemibold; btn.TextSize = 12; Instance.new("UICorner", btn)
    local bStroke = Instance.new("UIStroke", btn); bStroke.Color = Color3.fromRGB(60, 60, 70); bStroke.Thickness = 0.8

    btn.MouseButton1Click:Connect(function()
        Enabled[name] = not Enabled[name]
        bStroke.Color = Enabled[name] and NEON_PURPLE or Color3.fromRGB(60, 60, 70)
        
        -- Logic Triggers [cite: 7, 11, 18, 27]
        if name == "AntiRagdoll" then toggleAntiRagdoll(Enabled[name])
        elseif name == "BatAimbot" then toggleBatAimbot(Enabled[name])
        elseif name == "SpeedBoost" then toggleSpeed(Enabled[name])
        end
    end)
end

-- S4HUB Toggle
local toggle = Instance.new("TextButton", mainFrame)
toggle.Size = UDim2.new(0, 70, 0, 24); toggle.Position = UDim2.new(0.5, -35, 1, 10)
toggle.Text = "S4HUB"; toggle.BackgroundColor3 = BG_COLOR; toggle.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UIStroke", toggle).Color = NEON_PURPLE
toggle.MouseButton1Click:Connect(function() hubFrame.Visible = not hubFrame.Visible end)
