local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local playerGui = Player:WaitForChild("PlayerGui")

-- === CONFIGURATION ===
local NEON_PURPLE = Color3.fromRGB(190, 0, 255)
local NEON_BLUE = Color3.fromRGB(0, 200, 255)
local BG_COLOR = Color3.fromRGB(8, 6, 12)

local guiLocked = false
local boosterEnabled = false
local normalSpeed = 60
local carrySpeed = 29

-- === LOGISTICS: EXECUTION DETECTION ===
local function isGrabExecuting()
    local char = Player.Character
    if not char then return false end

    -- 1. Detect ProximityPrompt Execution (The Grab/Steal trigger)
    for _, obj in pairs(game.Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Enabled then
            -- If the prompt is currently being "held" or triggered by the player
            if obj:GetCurrentKeyboardModifierKey() or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                local dist = (char.HumanoidRootPart.Position - obj.Parent:GetPivot().Position).Magnitude
                if dist < 15 then return true end
            end
        end
    end

    -- 2. Visual Check (Is the Brainrot Model physically on the player?)
    local checkParts = {char:FindFirstChild("Head"), char:FindFirstChild("UpperTorso")}
    for _, limb in pairs(checkParts) do
        if limb then
            for _, child in pairs(limb:GetChildren()) do
                if (child:IsA("Model") or child:IsA("BasePart")) and not child:IsA("Accessory") then
                    return true
                end
            end
        end
    end

    return false
end

-- === ENGINE ===
RunService.Heartbeat:Connect(function()
    if not boosterEnabled then return end
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if hrp and hum and hum.MoveDirection.Magnitude > 0.1 then
        local target = isGrabExecuting() and carrySpeed or normalSpeed
        local vel = hum.MoveDirection * target
        hrp.AssemblyLinearVelocity = Vector3.new(vel.X, hrp.AssemblyLinearVelocity.Y, vel.Z)
    end
end)

-- === UI BUILDER ===
local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.ResetOnSpawn = false

local function createFrame(name, size, pos, accent, thick)
    local f = Instance.new("Frame", screenGui)
    f.Name = name; f.Size = size; f.Position = pos
    f.BackgroundColor3 = BG_COLOR; f.BackgroundTransparency = 0.2
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 4)
    local s = Instance.new("UIStroke", f)
    s.Thickness = thick or 2.2 -- Thicker neon lines
    s.Color = accent or NEON_PURPLE
    return f, s
end

-- 1. FIXED LOCK SYSTEM
local lockFrame, lockStroke = createFrame("Lock", UDim2.new(0, 95, 0, 32), UDim2.new(0.5, -240, 0, 50), NEON_BLUE, 1.8)
local lockBtn = Instance.new("TextButton", lockFrame)
lockBtn.Size = UDim2.new(1, 0, 1, 0); lockBtn.BackgroundTransparency = 1; lockBtn.Text = "LOCK GUI"; lockBtn.TextColor3 = Color3.new(1,1,1); lockBtn.Font = "GothamBold"; lockBtn.TextSize = 11

-- 2. MAIN HEADER (REFINED)
local mainFrame, mainStroke = createFrame("Main", UDim2.new(0, 180, 0, 85), UDim2.new(0.5, -90, 0, 50), NEON_PURPLE, 2.5)
local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 35); title.Text = "S4DUELS"; title.TextColor3 = Color3.new(1,1,1)
title.Font = "ArialBold"; title.TextSize = 22; title.BackgroundTransparency = 1 -- Bolder Title

local stats = Instance.new("TextLabel", mainFrame)
stats.Size = UDim2.new(1, 0, 0, 15); stats.Position = UDim2.new(0,0,0,40)
stats.TextColor3 = Color3.fromRGB(180,180,180); stats.TextSize = 9; stats.BackgroundTransparency = 1 -- Smaller Stats

local toggleHub = Instance.new("TextButton", mainFrame)
toggleHub.Size = UDim2.new(0, 70, 0, 24); toggleHub.Position = UDim2.new(0.5, -35, 1, 10)
toggleHub.Text = "S4HUB"; toggleHub.BackgroundColor3 = BG_COLOR; toggleHub.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", toggleHub)

-- 3. HUB MENU
local hubFrame = createFrame("Hub", UDim2.new(0, 400, 0, 300), UDim2.new(0.5, -200, 0.5, -150), NEON_PURPLE, 2.2)
hubFrame.Visible = false
local closeHub = Instance.new("TextButton", hubFrame)
closeHub.Size = UDim2.new(0, 24, 0, 24); closeHub.Position = UDim2.new(1, -30, 0, 10); closeHub.Text = "×"; closeHub.BackgroundColor3 = Color3.fromRGB(40,10,15); closeHub.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", closeHub).CornerRadius = UDim.new(1,0)

local scroll = Instance.new("ScrollingFrame", hubFrame)
scroll.Size = UDim2.new(1, -20, 1, -70); scroll.Position = UDim2.new(0, 10, 0, 60); scroll.BackgroundTransparency = 1; scroll.BorderSizePixel = 0
Instance.new("UIGridLayout", scroll).CellSize = UDim2.new(0.48, 0, 0, 40)

-- 4. BOOSTER BUTTON
local boosterBtn = Instance.new("TextButton", scroll)
boosterBtn.Text = "S4booster"; boosterBtn.BackgroundColor3 = Color3.fromRGB(20, 18, 25); boosterBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", boosterBtn)
local bStroke = Instance.new("UIStroke", boosterBtn); bStroke.Color = Color3.fromRGB(60, 60, 70)

-- Gear Icon
local gear = Instance.new("TextButton", boosterBtn)
gear.Size = UDim2.new(0, 20, 0, 20); gear.Position = UDim2.new(1, -25, 0.5, -10); gear.Text = "⚙"; gear.TextColor3 = NEON_BLUE; gear.BackgroundTransparency = 1

-- 5. SUB SETTINGS
local subSet = createFrame("BoosterSettings", UDim2.new(0, 180, 0, 140), UDim2.new(0.5, 210, 0.5, -70), NEON_BLUE, 1.5)
subSet.Visible = false

local function addInp(t, v, y)
    local l = Instance.new("TextLabel", subSet); l.Text = t; l.Position = UDim2.new(0, 10, 0, y); l.Size = UDim2.new(0, 70, 0, 20); l.TextColor3 = Color3.new(0.7,0.7,0.7); l.BackgroundTransparency = 1; l.TextSize = 10
    local i = Instance.new("TextBox", subSet); i.Text = tostring(v); i.Position = UDim2.new(0, 90, 0, y); i.Size = UDim2.new(0, 70, 0, 20); i.BackgroundColor3 = Color3.fromRGB(20,20,25); i.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", i)
    return i
end
local ni = addInp("Normal:", normalSpeed, 20); local ci = addInp("Carry:", carrySpeed, 55)
local save = Instance.new("TextButton", subSet); save.Size = UDim2.new(0.8, 0, 0, 25); save.Position = UDim2.new(0.1, 0, 1, -35); save.Text = "SAVE"; save.BackgroundColor3 = Color3.fromRGB(30,40,30); save.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", save)

-- === LOGIC CONNECTIONS ===
lockBtn.MouseButton1Click:Connect(function()
    guiLocked = not guiLocked
    lockBtn.Text = guiLocked and "LOCKED" or "LOCK GUI"
    lockStroke.Color = guiLocked and Color3.fromRGB(255, 50, 50) or NEON_BLUE
end)

boosterBtn.MouseButton1Click:Connect(function()
    boosterEnabled = not boosterEnabled
    bStroke.Color = boosterEnabled and NEON_PURPLE or Color3.fromRGB(60, 60, 70)
end)

gear.MouseButton1Click:Connect(function() subSet.Visible = not subSet.Visible end)
toggleHub.MouseButton1Click:Connect(function() hubFrame.Visible = not hubFrame.Visible end)
closeHub.MouseButton1Click:Connect(function() hubFrame.Visible = false; subSet.Visible = false end)
save.MouseButton1Click:Connect(function()
    normalSpeed = tonumber(ni.Text) or 60; carrySpeed = tonumber(ci.Text) or 29
    save.Text = "SAVED"; task.wait(0.5); save.Text = "SAVE"
end)

-- DRAG LOGIC (Fixed for Lock)
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
drag(mainFrame); drag(hubFrame); drag(lockFrame); drag(subSet)

task.spawn(function()
    while true do
        stats.Text = string.format("FPS: %d | PING: %dms", math.floor(1/RunService.RenderStepped:Wait()), math.floor(Player:GetNetworkPing()*1000))
        task.wait(0.5)
    end
end)
