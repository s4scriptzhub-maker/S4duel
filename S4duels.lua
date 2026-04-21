local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local playerGui = Player:WaitForChild("PlayerGui")

-- === LOGISTICS FROM 22s HUB ===
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

local Values = {
    BoostSpeed = 30,
    SpinSpeed = 30,
    STEAL_RADIUS = 20,
    STEAL_DURATION = 1.3,
    DEFAULT_GRAVITY = 196.2,
    GalaxyGravityPercent = 70
}

local Connections = {}

-- Helper to find the Bat tool in Character or Backpack [cite: 6, 7]
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

-- === FUNCTIONAL LOGIC (CONNECTED TO BUTTONS) ===

-- 1. Speed Boost Logistics [cite: 18]
local function toggleSpeed(state)
    if not state then 
        if Connections.speed then Connections.speed:Disconnect() Connections.speed = nil end
        return 
    end
    Connections.speed = RunService.Heartbeat:Connect(function()
        local h = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
        if h and hum and hum.MoveDirection.Magnitude > 0.1 then
            local md = hum.MoveDirection
            h.AssemblyLinearVelocity = Vector3.new(md.X * Values.BoostSpeed, h.AssemblyLinearVelocity.Y, md.Z * Values.BoostSpeed)
        end
    end)
end

-- 2. Anti-Ragdoll Logistics [cite: 27]
local function toggleAntiRagdoll(state)
    if not state then
        if Connections.antiRagdoll then Connections.antiRagdoll:Disconnect() Connections.antiRagdoll = nil end
        return
    end
    Connections.antiRagdoll = RunService.Heartbeat:Connect(function()
        local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            local s = hum:GetState()
            if s == Enum.HumanoidStateType.Ragdoll or s == Enum.HumanoidStateType.FallingDown then
                hum:ChangeState(Enum.HumanoidStateType.Running)
            end
        end
    end)
end

-- 3. Bat Aimbot Logistics [cite: 10, 11]
local function toggleBatAimbot(state)
    if not state then
        if Connections.batAimbot then Connections.batAimbot:Disconnect() Connections.batAimbot = nil end
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

-- === UI BUILDER ===
local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 180, 0, 80)
mainFrame.Position = UDim2.new(0.5, -90, 0, 50)
mainFrame.BackgroundColor3 = Color3.fromRGB(10, 8, 15)
local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Color = Color3.fromRGB(190, 0, 255)
mainStroke.Thickness = 1.2

local hubFrame = Instance.new("Frame", screenGui)
hubFrame.Size = UDim2.new(0, 400, 0, 300)
hubFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
hubFrame.BackgroundColor3 = Color3.fromRGB(10, 8, 15)
hubFrame.Visible = false
local hubStroke = Instance.new("UIStroke", hubFrame)
hubStroke.Color = Color3.fromRGB(190, 0, 255)
hubStroke.Thickness = 1.2

-- Close Button
local closeBtn = Instance.new("TextButton", hubFrame)
closeBtn.Size = UDim2.new(0, 24, 0, 24); closeBtn.Position = UDim2.new(1, -30, 0, 10)
closeBtn.Text = "×"; closeBtn.BackgroundColor3 = Color3.fromRGB(40, 10, 15); closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.MouseButton1Click:Connect(function() hubFrame.Visible = false end)

-- Settings List
local scroll = Instance.new("ScrollingFrame", hubFrame)
scroll.Size = UDim2.new(1, -20, 1, -60); scroll.Position = UDim2.new(0, 10, 0, 50); scroll.BackgroundTransparency = 1
local grid = Instance.new("UIGridLayout", scroll)
grid.CellSize = UDim2.new(0.48, 0, 0, 40)

-- Connect Each Button to Logistics
for name, _ in pairs(Enabled) do
    local btn = Instance.new("TextButton", scroll)
    btn.Text = name; btn.BackgroundColor3 = Color3.fromRGB(20, 15, 25); btn.TextColor3 = Color3.new(1,1,1)
    local bStroke = Instance.new("UIStroke", btn); bStroke.Color = Color3.fromRGB(60, 60, 70)

    btn.MouseButton1Click:Connect(function()
        Enabled[name] = not Enabled[name]
        
        -- Visual Feedback
        btn.BackgroundColor3 = Enabled[name] and Color3.fromRGB(50, 30, 70) or Color3.fromRGB(20, 15, 25)
        bStroke.Color = Enabled[name] and Color3.fromRGB(190, 0, 255) or Color3.fromRGB(60, 60, 70)
        
        -- Logic Trigger (Actually runs the functions)
        if name == "SpeedBoost" then toggleSpeed(Enabled[name])
        elseif name == "AntiRagdoll" then toggleAntiRagdoll(Enabled[name])
        elseif name == "BatAimbot" then toggleBatAimbot(Enabled[name])
        end
    end)
end

-- Open Hub Toggle
local toggle = Instance.new("TextButton", mainFrame)
toggle.Size = UDim2.new(0, 80, 0, 30); toggle.Position = UDim2.new(0.5, -40, 0.5, -15)
toggle.Text = "S4HUB"; toggle.BackgroundColor3 = Color3.fromRGB(20, 15, 25); toggle.TextColor3 = Color3.new(1,1,1)
toggle.MouseButton1Click:Connect(function() hubFrame.Visible = not hubFrame.Visible end)
