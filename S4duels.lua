local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local playerGui = Player:WaitForChild("PlayerGui")

-- === PREMIUM THEME ===
local NEON_PURPLE = Color3.fromRGB(180, 0, 255)
local NEON_BLUE = Color3.fromRGB(0, 180, 255)
local BG_COLOR = Color3.fromRGB(8, 8, 12)
local BORDER_WIDTH = 1.2

local guiLocked = false
local Features = {
    ["Speed Boost"] = false,
    ["Anti-Ragdoll"] = false,
    ["SpinBot"] = false,
    ["Bat Aimbot"] = false,
    ["Galaxy Mode"] = false,
    ["Optimizer"] = false
}

-- === LOGISTICS LOOPS ===
RunService.Heartbeat:Connect(function()
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if not hrp or not hum then return end

    -- 1. Speed Boost Logic
    if Features["Speed Boost"] and hum.MoveDirection.Magnitude > 0 then
        hrp.AssemblyLinearVelocity = Vector3.new(
            hum.MoveDirection.X * 32, 
            hrp.AssemblyLinearVelocity.Y, 
            hum.MoveDirection.Z * 32
        )
    end

    -- 2. Anti-Ragdoll Logic
    if Features["Anti-Ragdoll"] then
        local state = hum:GetState()
        if state == Enum.HumanoidStateType.Ragdoll or state == Enum.HumanoidStateType.FallingDown then
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end
    end

    -- 3. SpinBot Logic
    if Features["SpinBot"] then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(35), 0)
    end

    -- 4. Bat Aimbot (Aggressive Movement toward Nearest)
    if Features["Bat Aimbot"] then
        local target, dist = nil, 50
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local d = (p.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                if d < dist then dist = d target = p.Character.HumanoidRootPart end
            end
        end
        if target then
            local dir = (target.Position - hrp.Position).Unit
            hrp.AssemblyLinearVelocity = Vector3.new(dir.X * 50, hrp.AssemblyLinearVelocity.Y, dir.Z * 50)
        end
    end
end)

-- === UI BUILDER ===
local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "S4_Elite_Premium"
screenGui.ResetOnSpawn = false

local function createFrame(name, size, pos, color)
    local f = Instance.new("Frame", screenGui)
    f.Name = name; f.Size = size; f.Position = pos
    f.BackgroundColor3 = BG_COLOR; f.BackgroundTransparency = 0.25
    f.BorderSizePixel = 0; Instance.new("UICorner", f).CornerRadius = UDim.new(0, 3)
    local s = Instance.new("UIStroke", f)
    s.Thickness = BORDER_WIDTH; s.Color = color or NEON_PURPLE
    return f, s
end

-- 1. LOCK SYSTEM
local lockFrame, lockStroke = createFrame("Lock", UDim2.new(0, 90, 0, 32), UDim2.new(0.5, -240, 0, 50), NEON_BLUE)
local lockBtn = Instance.new("TextButton", lockFrame)
lockBtn.Size = UDim2.new(1, 0, 1, 0); lockBtn.BackgroundTransparency = 1; lockBtn.Text = "LOCK GUI"; lockBtn.TextColor3 = Color3.new(1, 1, 1); lockBtn.Font = Enum.Font.GothamBold; lockBtn.TextSize = 10

-- 2. MAIN HEADER
local mainFrame = createFrame("Main", UDim2.new(0, 180, 0, 85), UDim2.new(0.5, -90, 0, 50))
local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 35); title.Text = "S4duels"; title.TextColor3 = Color3.new(1,1,1); title.Font = Enum.Font.GothamBold; title.TextSize = 20; title.BackgroundTransparency = 1
local stats = Instance.new("TextLabel", mainFrame)
stats.Size = UDim2.new(1, 0, 0, 20); stats.Position = UDim2.new(0,0,0,38); stats.TextColor3 = Color3.fromRGB(150,150,150); stats.Font = Enum.Font.Code; stats.TextSize = 11; stats.BackgroundTransparency = 1
local toggleHub = Instance.new("TextButton", mainFrame)
toggleHub.Size = UDim2.new(0, 75, 0, 25); toggleHub.Position = UDim2.new(0.5, -37, 1, 10); toggleHub.BackgroundColor3 = Color3.fromRGB(15,15,20); toggleHub.Text = "S4HUB"; toggleHub.TextColor3 = Color3.new(1,1,1); toggleHub.Font = Enum.Font.GothamBold; toggleHub.TextSize = 11; Instance.new("UICorner", toggleHub)

-- 3. SETTINGS MENU
local hubFrame = createFrame("Hub", UDim2.new(0, 420, 0, 320), UDim2.new(0.5, -210, 0.5, -160))
hubFrame.Visible = false
local closeHub = Instance.new("TextButton", hubFrame)
closeHub.Size = UDim2.new(0, 26, 0, 26); closeHub.Position = UDim2.new(1, -34, 0, 8); closeHub.BackgroundColor3 = Color3.fromRGB(45, 15, 20); closeHub.Text = "×"; closeHub.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", closeHub).CornerRadius = UDim.new(1,0)

local scroll = Instance.new("ScrollingFrame", hubFrame)
scroll.Size = UDim2.new(1, -20, 1, -70); scroll.Position = UDim2.new(0, 10, 0, 60); scroll.BackgroundTransparency = 1; scroll.BorderSizePixel = 0; scroll.ScrollBarThickness = 1
local grid = Instance.new("UIGridLayout", scroll)
grid.CellSize = UDim2.new(0.48, 0, 0, 42); grid.CellPadding = UDim2.new(0.03, 0, 0, 10)

-- Populate Buttons
for name, _ in pairs(Features) do
    local b = Instance.new("TextButton", scroll)
    b.Text = name; b.BackgroundColor3 = Color3.fromRGB(20, 18, 25); b.TextColor3 = Color3.new(1, 1, 1); b.Font = Enum.Font.GothamSemibold; b.TextSize = 12; Instance.new("UICorner", b)
    local s = Instance.new("UIStroke", b); s.Color = Color3.fromRGB(50,50,60); s.Thickness = 0.8
    
    b.MouseButton1Click:Connect(function()
        Features[name] = not Features[name]
        s.Color = Features[name] and NEON_PURPLE or Color3.fromRGB(50,50,60)
        b.BackgroundColor3 = Features[name] and Color3.fromRGB(30, 20, 45) or Color3.fromRGB(20, 18, 25)
        
        -- Special trigger for Galaxy/Optimizer
        if name == "Galaxy Mode" then game.Lighting.Gravity = Features[name] and 100 or 196.2 end
    end)
end

-- === DRAGGING & LOGIC ===
local function drag(f)
    local d, i, st, sp
    f.InputBegan:Connect(function(inp)
        if not guiLocked and (inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch) then
            d = true; st = inp.Position; sp = f.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if d then
            local delta = inp.Position - st
            f.Position = UDim2.new(sp.X.Scale, sp.X.Offset + delta.X, sp.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function() d = false end)
end

drag(mainFrame); drag(hubFrame); drag(lockFrame)

toggleHub.MouseButton1Click:Connect(function() hubFrame.Visible = not hubFrame.Visible end)
closeHub.MouseButton1Click:Connect(function() hubFrame.Visible = false end)
lockBtn.MouseButton1Click:Connect(function()
    guiLocked = not guiLocked
    lockBtn.Text = guiLocked and "LOCKED" or "LOCK GUI"
    lockStroke.Color = guiLocked and Color3.fromRGB(255, 50, 50) or NEON_BLUE
end)

task.spawn(function()
    while true do
        local fps = math.floor(1 / RunService.RenderStepped:Wait())
        stats.Text = string.format("FPS: %d  |  PING: %dms", fps, math.floor(Player:GetNetworkPing()*1000))
        task.wait(0.5)
    end
end)
