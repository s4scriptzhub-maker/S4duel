local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local playerGui = Player:WaitForChild("PlayerGui")

-- === UI THEME ===
local NEON_PURPLE = Color3.fromRGB(180, 0, 255)
local NEON_BLUE = Color3.fromRGB(0, 180, 255)
local BG_COLOR = Color3.fromRGB(5, 5, 10)
local BORDER_THIN = 1.2

local guiLocked = false
local Features = {
    ["Speed Boost"] = false,
    ["Anti-Ragdoll"] = false,
    ["SpinBot"] = false,
    ["Galaxy Mode"] = false,
}

-- === LOGISTICS LOOP (Runs the actual cheats) ===
RunService.Heartbeat:Connect(function()
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    if Features["Speed Boost"] and hum.MoveDirection.Magnitude > 0 then
        hrp.AssemblyLinearVelocity = Vector3.new(hum.MoveDirection.X * 35, hrp.AssemblyLinearVelocity.Y, hum.MoveDirection.Z * 35)
    end

    if Features["Anti-Ragdoll"] then
        if hum:GetState() == Enum.HumanoidStateType.Ragdoll or hum:GetState() == Enum.HumanoidStateType.FallingDown then
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end
    end

    if Features["SpinBot"] then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(40), 0)
    end
end)

-- === UI CREATION ===
local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "S4_Elite_Fixed"
screenGui.ResetOnSpawn = false

local function createBaseFrame(name, size, pos, color)
    local f = Instance.new("Frame", screenGui)
    f.Name = name; f.Size = size; f.Position = pos
    f.BackgroundColor3 = BG_COLOR; f.BackgroundTransparency = 0.2
    f.BorderSizePixel = 0; f.Active = true -- Prevents clicking through to game
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 4)
    local s = Instance.new("UIStroke", f)
    s.Thickness = BORDER_THIN; s.Color = color or NEON_PURPLE
    return f, s
end

-- 1. LOCK GUI
local lockFrame, lockStroke = createBaseFrame("LockFrame", UDim2.new(0, 100, 0, 35), UDim2.new(0.5, -260, 0, 50), NEON_BLUE)
local lockBtn = Instance.new("TextButton", lockFrame)
lockBtn.Size = UDim2.new(1,0,1,0); lockBtn.BackgroundTransparency = 1; lockBtn.Text = "LOCK GUI"; lockBtn.TextColor3 = Color3.new(1,1,1); lockBtn.Font = Enum.Font.GothamBold; lockBtn.TextSize = 11

-- 2. MAIN HEADER (S4duels)
local mainFrame = createBaseFrame("MainHeader", UDim2.new(0, 200, 0, 90), UDim2.new(0.5, -100, 0, 50))
local mainTitle = Instance.new("TextLabel", mainFrame)
mainTitle.Size = UDim2.new(1,0,0,40); mainTitle.Text = "S4duels"; mainTitle.TextColor3 = Color3.new(1,1,1); mainTitle.Font = Enum.Font.GothamBold; mainTitle.TextSize = 22; mainTitle.BackgroundTransparency = 1
local stats = Instance.new("TextLabel", mainFrame)
stats.Size = UDim2.new(1,0,0,20); stats.Position = UDim2.new(0,0,0,40); stats.TextColor3 = Color3.fromRGB(160,160,160); stats.Font = Enum.Font.Code; stats.TextSize = 11; stats.BackgroundTransparency = 1
local openHub = Instance.new("TextButton", mainFrame)
openHub.Size = UDim2.new(0, 80, 0, 25); openHub.Position = UDim2.new(0.5, -40, 1, 10); openHub.BackgroundColor3 = Color3.fromRGB(20,20,30); openHub.Text = "S4HUB"; openHub.TextColor3 = Color3.new(1,1,1); openHub.Font = Enum.Font.GothamBold; Instance.new("UICorner", openHub)

-- 3. HUB MENU (S4HUB)
local hubFrame = createBaseFrame("S4HUB_Menu", UDim2.new(0, 420, 0, 300), UDim2.new(0.5, -210, 0.5, -150))
hubFrame.Visible = false
local hubTitle = Instance.new("TextLabel", hubFrame)
hubTitle.Size = UDim2.new(1, 0, 0, 50); hubTitle.Text = "S4HUB SETTINGS"; hubTitle.TextColor3 = Color3.new(1,1,1); hubTitle.Font = Enum.Font.GothamBold; hubTitle.TextSize = 18; hubTitle.BackgroundTransparency = 1

local closeHub = Instance.new("TextButton", hubFrame)
closeHub.Size = UDim2.new(0, 24, 0, 24); closeHub.Position = UDim2.new(1, -30, 0, 10); closeHub.BackgroundColor3 = Color3.fromRGB(60, 20, 25); closeHub.Text = "×"; closeHub.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", closeHub).CornerRadius = UDim.new(1,0)

local scroll = Instance.new("ScrollingFrame", hubFrame)
scroll.Size = UDim2.new(1, -20, 1, -70); scroll.Position = UDim2.new(0, 10, 0, 60); scroll.BackgroundTransparency = 1; scroll.BorderSizePixel = 0
local grid = Instance.new("UIGridLayout", scroll)
grid.CellSize = UDim2.new(0.48, 0, 0, 45); grid.CellPadding = UDim2.new(0.03, 0, 0, 10)

-- Populate Settings
for name, _ in pairs(Features) do
    local b = Instance.new("TextButton", scroll)
    b.Text = name; b.BackgroundColor3 = Color3.fromRGB(25, 22, 30); b.TextColor3 = Color3.new(1, 1, 1); b.Font = Enum.Font.GothamSemibold; b.TextSize = 12; Instance.new("UICorner", b)
    local s = Instance.new("UIStroke", b); s.Color = Color3.fromRGB(60,60,70); s.Thickness = 1
    
    b.MouseButton1Click:Connect(function()
        Features[name] = not Features[name]
        s.Color = Features[name] and NEON_PURPLE or Color3.fromRGB(60,60,70)
        b.BackgroundColor3 = Features[name] and Color3.fromRGB(40, 30, 60) or Color3.fromRGB(25, 22, 30)
        if name == "Galaxy Mode" then game.Lighting.Gravity = Features[name] and 80 or 196.2 end
    end)
end

-- === FIXED DRAG SYSTEM (Prevents UI disappearing) ===
local function applyDrag(f)
    local dragging, dragStart, startPos
    f.InputBegan:Connect(function(input)
        if not guiLocked and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            dragging = true; dragStart = input.Position; startPos = f.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            f.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function() dragging = false end)
end

applyDrag(mainFrame); applyDrag(hubFrame); applyDrag(lockFrame)

-- Button Connects
openHub.MouseButton1Click:Connect(function() hubFrame.Visible = not hubFrame.Visible end)
closeHub.MouseButton1Click:Connect(function() hubFrame.Visible = false end)
lockBtn.MouseButton1Click:Connect(function()
    guiLocked = not guiLocked
    lockBtn.Text = guiLocked and "LOCKED" or "LOCK GUI"
    lockStroke.Color = guiLocked and Color3.fromRGB(255, 50, 50) or NEON_BLUE
end)

-- Performance Update
task.spawn(function()
    while true do
        local fps = math.floor(1 / RunService.RenderStepped:Wait())
        stats.Text = string.format("FPS: %d  |  PING: %dms", fps, math.floor(Player:GetNetworkPing()*1000))
        task.wait(0.5)
    end
end)
