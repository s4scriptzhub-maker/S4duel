-- [[ S4DUELS: ELITE BRAINROT EDITION ]] --
-- [[ FULL SOURCE - NO COMPRESSION ]] --

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local playerGui = Player:WaitForChild("PlayerGui")
local ConfigFile = "S4DUELS_Main_Config.json"
local SpeedConfigFile = "BatSpeed_Elite_Config.json"

-- === GLOBAL STATE ===
local SavedSettings = { Toggles = {} }
local BatSettings = { Speed = 56 }
local ActiveToggles = {}

local guiLocked = false
local batActive = false
local espActive = false
local infJumpActive = false
local unwalkActive = false
local saintsModeActive = false

-- === COLORS ===
local SHINY_PURPLE = Color3.fromRGB(210, 80, 255)
local NEON_BLUE = Color3.fromRGB(0, 220, 255)
local ACTIVE_GREEN = Color3.fromRGB(0, 255, 150)
local BG_COLOR = Color3.fromRGB(10, 10, 15)
local ESP_COLOR = Color3.fromRGB(255, 0, 0)

-- === CORE UTILITIES ===
local function saveMainConfig()
    if writefile then
        writefile(ConfigFile, HttpService:JSONEncode(SavedSettings))
    end
end

local function saveBatSpeed()
    if writefile then
        writefile(SpeedConfigFile, HttpService:JSONEncode(BatSettings))
    end
end

local function loadConfigs()
    if isfile and isfile(ConfigFile) then
        pcall(function() SavedSettings = HttpService:JSONDecode(readfile(ConfigFile)) end)
    end
    if isfile and isfile(SpeedConfigFile) then
        pcall(function() BatSettings = HttpService:JSONDecode(readfile(SpeedConfigFile)) end)
    end
end

-- === UI CONSTRUCTION ===
local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "S4_ULTIMATE_HUB"
screenGui.ResetOnSpawn = false

local function applyShinyEffect(instance, color1, color2)
    local grad = Instance.new("UIGradient", instance)
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, color1),
        ColorSequenceKeypoint.new(0.4, color1),
        ColorSequenceKeypoint.new(0.5, color2),
        ColorSequenceKeypoint.new(0.6, color1),
        ColorSequenceKeypoint.new(1, color1)
    })
    task.spawn(function()
        local rotation = 0
        RunService.RenderStepped:Connect(function(deltaTime)
            rotation = (rotation + (deltaTime * 65)) % 360
            grad.Rotation = rotation
        end)
    end)
    return grad
end

local function createBaseFrame(name, size, pos, accent)
    local f = Instance.new("Frame", screenGui)
    f.Name = name; f.Size = size; f.Position = pos
    f.BackgroundColor3 = BG_COLOR; f.BackgroundTransparency = 0.4
    f.BorderSizePixel = 0
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
    local s = Instance.new("UIStroke", f)
    s.Thickness = 1.5; s.Color = Color3.new(1,1,1)
    applyShinyEffect(s, accent or SHINY_PURPLE, Color3.new(1,1,1))
    return f, s
end

-- 1. TOP LEFT HUB ACCESS (FOR SAINTSMODE)
local returnFrame, returnStroke = createBaseFrame("ReturnHUD", UDim2.new(0, 100, 0, 35), UDim2.new(0, 15, 0, 15), NEON_BLUE)
local returnBtn = Instance.new("TextButton", returnFrame)
returnBtn.Size = UDim2.new(1, 0, 1, 0); returnBtn.BackgroundTransparency = 1; returnBtn.Text = "S4HUB"; returnBtn.TextColor3 = Color3.new(1,1,1); returnBtn.Font = "GothamBold"; returnBtn.TextSize = 14

-- 2. LOCK GUI BUTTON
local lockFrame, lockStroke = createBaseFrame("LockFrame", UDim2.new(0, 95, 0, 30), UDim2.new(0.5, -240, 0, 60), NEON_BLUE)
local lockBtn = Instance.new("TextButton", lockFrame)
lockBtn.Size = UDim2.new(1, 0, 1, 0); lockBtn.BackgroundTransparency = 1; lockBtn.Text = "LOCK GUI"; lockBtn.TextColor3 = Color3.new(1,1,1); lockBtn.Font = "GothamBold"; lockBtn.TextSize = 10

-- 3. MAIN HEADER & STATS
local mainHeader = createBaseFrame("MainHeader", UDim2.new(0, 180, 0, 85), UDim2.new(0.5, -90, 0, 60), SHINY_PURPLE)
local headerTitle = Instance.new("TextLabel", mainHeader)
headerTitle.Size = UDim2.new(1, 0, 0, 40); headerTitle.Text = "S4DUELS"; headerTitle.TextColor3 = Color3.new(1,1,1); headerTitle.Font = "ArialBold"; headerTitle.TextSize = 24; headerTitle.BackgroundTransparency = 1
applyShinyEffect(Instance.new("UIStroke", headerTitle), SHINY_PURPLE, Color3.new(1,1,1))

local statLabel = Instance.new("TextLabel", mainHeader)
statLabel.Size = UDim2.new(1, 0, 0, 20); statLabel.Position = UDim2.new(0, 0, 0, 40); statLabel.Text = "FPS: -- | PING: --"; statLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8); statLabel.TextSize = 10; statLabel.BackgroundTransparency = 1

local openHubBtn = Instance.new("TextButton", mainHeader)
openHubBtn.Size = UDim2.new(0, 90, 0, 25); openHubBtn.Position = UDim2.new(0.5, -45, 1, 10); openHubBtn.Text = "SETTINGS"; openHubBtn.BackgroundColor3 = BG_COLOR; openHubBtn.TextColor3 = Color3.new(1,1,1); openHubBtn.Font = "GothamBold"
Instance.new("UICorner", openHubBtn)

-- 4. HUB SETTINGS MENU
local hubMenu = createBaseFrame("HubMenu", UDim2.new(0, 420, 0, 450), UDim2.new(0.5, -210, 0.5, -225), SHINY_PURPLE)
hubMenu.Visible = false

local scrollFrame = Instance.new("ScrollingFrame", hubMenu)
scrollFrame.Size = UDim2.new(1, -30, 1, -160); scrollFrame.Position = UDim2.new(0, 15, 0, 80); scrollFrame.BackgroundTransparency = 1; scrollFrame.CanvasSize = UDim2.new(0, 0, 2, 0); scrollFrame.ScrollBarThickness = 2
Instance.new("UIGridLayout", scrollFrame).CellSize = UDim2.new(0.48, 0, 0, 45)

local saveAllBtn = Instance.new("TextButton", hubMenu)
saveAllBtn.Size = UDim2.new(0.9, 0, 0, 40); saveAllBtn.Position = UDim2.new(0.05, 0, 1, -55); saveAllBtn.Text = "SAVE ALL SETTINGS"; saveAllBtn.BackgroundColor3 = Color3.fromRGB(20,20,25); saveAllBtn.TextColor3 = Color3.new(1,1,1); saveAllBtn.Font = "GothamBold"
Instance.new("UICorner", saveAllBtn)

-- 5. SPEED CONFIG MENU (BAT FUCKER ONLY)
local speedMenu = createBaseFrame("SpeedConfig", UDim2.new(0, 220, 0, 140), UDim2.new(0.5, 60, 0.5, -70), NEON_BLUE)
speedMenu.Visible = false; speedMenu.ZIndex = 20

local speedTitle = Instance.new("TextLabel", speedMenu)
speedTitle.Size = UDim2.new(1,0,0,35); speedTitle.Text = "BAT SPEED: " .. BatSettings.Speed; speedTitle.TextColor3 = Color3.new(1,1,1); speedTitle.Font = "GothamBold"; speedTitle.BackgroundTransparency = 1; speedTitle.ZIndex = 21

local sliderBar = Instance.new("Frame", speedMenu)
sliderBar.Size = UDim2.new(0.8, 0, 0, 12); sliderBar.Position = UDim2.new(0.1, 0, 0.45, 0); sliderBar.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1); sliderBar.ZIndex = 21

local sliderFill = Instance.new("Frame", sliderBar)
sliderFill.Size = UDim2.new(BatSettings.Speed/70, 0, 1, 0); sliderFill.BackgroundColor3 = NEON_BLUE; sliderFill.ZIndex = 22

local sliderTrigger = Instance.new("TextButton", sliderBar)
sliderTrigger.Size = UDim2.new(1,0,1,0); sliderTrigger.BackgroundTransparency = 1; sliderTrigger.Text = ""; sliderTrigger.ZIndex = 23

local saveSpeedOnly = Instance.new("TextButton", speedMenu)
saveSpeedOnly.Size = UDim2.new(0.8, 0, 0, 30); saveSpeedOnly.Position = UDim2.new(0.1, 0, 0.75, 0); saveSpeedOnly.Text = "SAVE SPEED"; saveSpeedOnly.BackgroundColor3 = Color3.new(0,0,0); saveSpeedOnly.TextColor3 = Color3.new(1,1,1); saveSpeedOnly.Font = "GothamBold"; saveSpeedOnly.ZIndex = 21
Instance.new("UICorner", saveSpeedOnly)

-- 6. SAINTSMODE HUD (INDIVIDUAL BUTTONS)
local saintsHUD = Instance.new("Frame", screenGui)
saintsHUD.Size = UDim2.new(1, 0, 1, 0); saintsHUD.BackgroundTransparency = 1; saintsHUD.Visible = false

local hudButtons = {} -- Store references for syncing

local function createTacticalButton(text, pos, isToggle, callback)
    local f, s = createBaseFrame(text.."_Tactical", UDim2.new(0, 140, 0, 45), pos, SHINY_PURPLE)
    f.Parent = saintsHUD
    local b = Instance.new("TextButton", f)
    b.Size = UDim2.new(1,0,1,0); b.BackgroundTransparency = 1; b.Text = text; b.TextColor3 = Color3.new(1,1,1); b.Font = "GothamBold"; b.TextSize = 12
    
    hudButtons[text] = {Frame = f, Stroke = s}

    b.MouseButton1Click:Connect(function()
        if isToggle then
            ActiveToggles[text] = not ActiveToggles[text]
            s.Color = ActiveToggles[text] and ACTIVE_GREEN or Color3.new(1,1,1)
            callback(ActiveToggles[text])
        else
            callback()
        end
    end)
    return f
end

-- === FEATURE LOGIC ===

-- ESP Logic
local function updateESP()
    if not espActive then
        for _, v in pairs(Players:GetPlayers()) do
            if v.Character then
                if v.Character:FindFirstChild("S4_ESP") then v.Character.S4_ESP:Destroy() end
                if v.Character:FindFirstChild("S4_TAG") then v.Character.S4_TAG:Destroy() end
            end
        end
        return
    end

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= Player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            if not v.Character:FindFirstChild("S4_ESP") then
                local hl = Instance.new("Highlight", v.Character); hl.Name = "S4_ESP"; hl.FillColor = ESP_COLOR; hl.OutlineColor = Color3.new(1,1,1)
                local bb = Instance.new("BillboardGui", v.Character); bb.Name = "S4_TAG"; bb.Size = UDim2.new(0,100,0,30); bb.AlwaysOnTop = true; bb.StudsOffset = Vector3.new(0,3,0)
                local tl = Instance.new("TextLabel", bb); tl.Size = UDim2.new(1,0,1,0); tl.BackgroundTransparency = 1; tl.Text = v.Name; tl.TextColor3 = ESP_COLOR; tl.Font = "GothamBold"; tl.TextSize = 14; tl.TextStrokeTransparency = 0
            end
        end
    end
end

-- Bat Fucker Logic (Smooth 3D Flight)
local batMover = nil
local batGyro = nil

local function runBatFucker()
    if not batActive then
        if batMover then batMover:Destroy(); batMover = nil end
        if batGyro then batGyro:Destroy(); batGyro = nil end
        if Player.Character and Player.Character:FindFirstChild("Humanoid") then Player.Character.Humanoid.PlatformStand = false end
        return
    end

    local char = Player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    local hum = char.Humanoid

    local target = nil
    local shortestDist = math.huge
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= Player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character.Humanoid.Health > 0 then
            local d = (hrp.Position - v.Character.HumanoidRootPart.Position).Magnitude
            if d < shortestDist then shortestDist = d; target = v.Character.HumanoidRootPart end
        end
    end

    if target then
        if not batMover then
            batMover = Instance.new("BodyVelocity", hrp)
            batMover.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        end
        if not batGyro then
            batGyro = Instance.new("BodyGyro", hrp)
            batGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            batGyro.P = 25000
        end

        hum.PlatformStand = true
        batMover.Velocity = (target.Position - hrp.Position).Unit * BatSettings.Speed
        batGyro.CFrame = CFrame.lookAt(hrp.Position, target.Position)
        
        -- Noclip while active to prevent death from walls
        for _, p in pairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    else
        if batMover then batMover.Velocity = Vector3.new(0,0,0) end
    end
end

-- === UI INTERACTION SETUP ===

local function createMenuButton(text, isToggle, callback)
    local b = Instance.new("TextButton", scrollFrame)
    b.Text = text; b.BackgroundColor3 = BG_COLOR; b.TextColor3 = Color3.new(1,1,1); b.Font = "GothamBold"; b.TextSize = 12
    Instance.new("UICorner", b)
    local bs = Instance.new("UIStroke", b); bs.Thickness = 1.2; applyShinyEffect(bs, SHINY_PURPLE, Color3.new(1,1,1))

    if text == "Bat Fucker" then
        local gear = Instance.new("TextButton", b)
        gear.Size = UDim2.new(0, 20, 0, 20); gear.Position = UDim2.new(1, -25, 0.5, -10); gear.Text = "⚙️"; gear.BackgroundTransparency = 1; gear.TextColor3 = Color3.new(1,1,1)
        gear.MouseButton1Click:Connect(function() speedMenu.Visible = not speedMenu.Visible end)
    end

    b.MouseButton1Click:Connect(function()
        if isToggle then
            ActiveToggles[text] = not ActiveToggles[text]
            bs.Color = ActiveToggles[text] and ACTIVE_GREEN or Color3.new(1,1,1)
            -- Sync SaintsMode button color
            if hudButtons[text] then hudButtons[text].Stroke.Color = bs.Color end
            callback(ActiveToggles[text])
        else
            callback()
        end
    end)
end

-- SAINTSMODE Toggle Logic
local function applySaintsMode(state)
    saintsModeActive = state
    saintsHUD.Visible = state
    mainHeader.Visible = not state
    lockFrame.Visible = not state
    hubMenu.Visible = false
end

-- POPULATE MENU
createMenuButton("S4INTSMODE", true, applySaintsMode)
createMenuButton("Bat Fucker", true, function(s) batActive = s end)
createMenuButton("ESP", true, function(s) espActive = s end)
createMenuButton("Inf Jump", true, function(s) infJumpActive = s end)
createMenuButton("Unwalk", true, function(s)
    unwalkActive = s
    local char = Player.Character
    if s and char then
        if char:FindFirstChild("Animate") then char.Animate.Disabled = true end
        for _, t in pairs(char.Humanoid:GetPlayingAnimationTracks()) do t:Stop() end
    elseif char then
        if char:FindFirstChild("Animate") then char.Animate.Disabled = false end
    end
end)
createMenuButton("Rejoin Server", false, function() TeleportService:Teleport(game.PlaceId, Player) end)
createMenuButton("Server Hop", false, function() TeleportService:Teleport(game.PlaceId) end)
createMenuButton("Kick Self", false, function() Player:Kick("S4DUELS: Brainrot Forced Disconnect") end)

-- POPULATE SAINTS HUD
createTacticalButton("Bat Fucker", UDim2.new(0.05, 0, 0.4, 0), true, function(s) batActive = s end)
createTacticalButton("ESP", UDim2.new(0.05, 0, 0.5, 0), true, function(s) espActive = s end)
createTacticalButton("Inf Jump", UDim2.new(0.85, 0, 0.4, 0), true, function(s) infJumpActive = s end)
createTacticalButton("Unwalk", UDim2.new(0.85, 0, 0.5, 0), true, function(s)
    unwalkActive = s
    local char = Player.Character
    if s and char then
        if char:FindFirstChild("Animate") then char.Animate.Disabled = true end
    elseif char then
        if char:FindFirstChild("Animate") then char.Animate.Disabled = false end
    end
end)

-- SLIDER LOGIC
sliderTrigger.MouseButton1Down:Connect(function()
    local moveCon; moveCon = UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local relX = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
            BatSettings.Speed = math.floor(relX * 70)
            sliderFill.Size = UDim2.new(relX, 0, 1, 0)
            speedTitle.Text = "BAT SPEED: " .. BatSettings.Speed
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then moveCon:Disconnect() end
    end)
end)

-- SAVE HANDLERS
saveAllBtn.MouseButton1Click:Connect(saveMainConfig)
saveSpeedOnly.MouseButton1Click:Connect(function() saveBatSpeed(); speedMenu.Visible = false end)
returnBtn.MouseButton1Click:Connect(function() applySaintsMode(false) end)
openHubBtn.MouseButton1Click:Connect(function() hubMenu.Visible = not hubMenu.Visible end)
lockBtn.MouseButton1Click:Connect(function()
    guiLocked = not guiLocked
    lockBtn.Text = guiLocked and "LOCKED" or "LOCK GUI"
    lockStroke.Color = guiLocked and Color3.fromRGB(255, 50, 50) or NEON_BLUE
end)

-- === MAIN RUNTIME LOOP ===
RunService.RenderStepped:Connect(function()
    -- Update Header Stats
    statLabel.Text = string.format("FPS: %d | PING: %dms", math.floor(1/RunService.RenderStepped:Wait()), math.floor(Player:GetNetworkPing()*1000))
    
    -- ESP Update
    updateESP()
    
    -- Bat Fucker Physics
    runBatFucker()
    
    -- Inf Jump
    if infJumpActive and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            Player.Character.HumanoidRootPart.Velocity = Vector3.new(Player.Character.HumanoidRootPart.Velocity.X, 45, Player.Character.HumanoidRootPart.Velocity.Z)
        end
    end
end)

-- === DRAG LOGIC ===
local function makeDraggable(f)
    local d, st, sp
    f.InputBegan:Connect(function(i) 
        if not guiLocked and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then 
            d = true; st = i.Position; sp = f.Position 
        end 
    end)
    UserInputService.InputChanged:Connect(function(i) 
        if d then 
            local delta = i.Position - st
            f.Position = UDim2.new(sp.X.Scale, sp.X.Offset + delta.X, sp.Y.Scale, sp.Y.Offset + delta.Y) 
        end 
    end)
    UserInputService.InputEnded:Connect(function() d = false end)
end

makeDraggable(mainHeader); makeDraggable(hubMenu); makeDraggable(lockFrame); makeDraggable(speedMenu); makeDraggable(returnFrame)
for _, hud in pairs(hudButtons) do makeDraggable(hud.Frame) end

loadConfigs()
