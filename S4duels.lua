local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local playerGui = Player:WaitForChild("PlayerGui")
local ConfigFile = "S4DUELS_Brainrot_Config.json"
local SpeedConfigFile = "BatSpeed_Config.json"

-- === SETTINGS STORAGE ===
local SavedSettings = { Toggles = {} }
local ActiveToggles = {} 
local BatSettings = { Speed = 56 }

-- === PREMIUM COLORS ===
local SHINY_PURPLE = Color3.fromRGB(210, 80, 255)
local NEON_BLUE = Color3.fromRGB(0, 220, 255)
local ACTIVE_GREEN = Color3.fromRGB(0, 255, 150)
local BG_COLOR = Color3.fromRGB(10, 10, 15)
local ESP_COLOR = Color3.fromRGB(255, 0, 0)

local guiLocked = false
local infJumpActive = false
local batActive = false
local espActive = false
local saintsModeActive = false

-- === UTILITY FUNCTIONS ===
local function saveConfigs()
    if writefile then 
        writefile(ConfigFile, HttpService:JSONEncode(SavedSettings))
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

-- === UI BUILDER ===
local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "S4_Brainrot_Elite"
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

local function createFrame(name, size, pos, accent)
    local f = Instance.new("Frame", screenGui)
    f.Name = name; f.Size = size; f.Position = pos
    f.BackgroundColor3 = BG_COLOR; f.BackgroundTransparency = 0.5
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 4)
    local s = Instance.new("UIStroke", f)
    s.Thickness = 1.2; s.Color = Color3.new(1,1,1)
    applyShinyEffect(s, accent or SHINY_PURPLE, Color3.new(1,1,1))
    return f, s
end

-- TOP LEFT RETURN BUTTON (S4HUB)
local returnBtnFrame, returnStroke = createFrame("ReturnBtn", UDim2.new(0, 100, 0, 35), UDim2.new(0, 10, 0, 10), NEON_BLUE)
local returnBtn = Instance.new("TextButton", returnBtnFrame)
returnBtn.Size = UDim2.new(1,0,1,0); returnBtn.Text = "S4HUB"; returnBtn.Font = "GothamBold"; returnBtn.TextColor3 = Color3.new(1,1,1); returnBtn.BackgroundTransparency = 1; returnBtn.TextSize = 14

-- MAIN UI ELEMENTS
local mainFrame = createFrame("Main", UDim2.new(0, 180, 0, 85), UDim2.new(0.5, -90, 0, 50), SHINY_PURPLE)
local hubFrame = createFrame("Hub", UDim2.new(0, 400, 0, 400), UDim2.new(0.5, -200, 0.5, -200), SHINY_PURPLE)
hubFrame.Visible = false

-- SAINTS HUD CONTAINER
local saintsHUD = Instance.new("Frame", screenGui)
saintsHUD.Size = UDim2.new(1, 0, 1, 0); saintsHUD.BackgroundTransparency = 1; saintsHUD.Visible = false

-- LIST OF ACTION BUTTONS FOR SAINTS MODE
local hudButtons = {}

local function createHudAction(text, pos, isToggle, func)
    local f, s = createFrame(text.."_HUD", UDim2.new(0, 130, 0, 40), pos, SHINY_PURPLE)
    f.Parent = saintsHUD
    local b = Instance.new("TextButton", f)
    b.Size = UDim2.new(1,0,1,0); b.Text = text; b.Font = "GothamBold"; b.TextColor3 = Color3.new(1,1,1); b.BackgroundTransparency = 1; b.TextSize = 11
    
    b.MouseButton1Click:Connect(function()
        if isToggle then
            ActiveToggles[text] = not ActiveToggles[text]
            s.Color = ActiveToggles[text] and ACTIVE_GREEN or Color3.new(1,1,1)
            func(ActiveToggles[text])
        else func() end
    end)
    return f
end

-- Positions for HUD Buttons
local h1 = createHudAction("Bat Fucker", UDim2.new(0.1, 0, 0.4, 0), true, function(s) batActive = s end)
local h2 = createHudAction("ESP", UDim2.new(0.1, 0, 0.5, 0), true, function(s) espActive = s end)
local h3 = createHudAction("Inf Jump", UDim2.new(0.8, 0, 0.4, 0), true, function(s) infJumpActive = s end)
local h4 = createHudAction("Unwalk", UDim2.new(0.8, 0, 0.5, 0), true, function(s) --[[Logic below]] end)

-- TOGGLE LOGIC FOR SAINTSMODE
local function toggleSaintsMode(state)
    saintsModeActive = state
    saintsHUD.Visible = state
    mainFrame.Visible = not state
    hubFrame.Visible = false
end

returnBtn.MouseButton1Click:Connect(function()
    toggleSaintsMode(false)
    mainFrame.Visible = true
end)

-- SETUP HUB INTERNALS
local scroll = Instance.new("ScrollingFrame", hubFrame)
scroll.Size = UDim2.new(1, -20, 1, -150); scroll.Position = UDim2.new(0, 10, 0, 70); scroll.BackgroundTransparency = 1; scroll.BorderSizePixel = 0
Instance.new("UIGridLayout", scroll).CellSize = UDim2.new(0.48, 0, 0, 40)

-- BUTTON BUILDER
local function createHubButton(text, isToggle, func)
    local b = Instance.new("TextButton", scroll)
    b.Text = text; b.BackgroundColor3 = BG_COLOR; b.TextColor3 = Color3.new(1,1,1); b.Font = "GothamBold"
    Instance.new("UICorner", b)
    local bs = Instance.new("UIStroke", b); bs.Thickness = 1.2; applyShinyEffect(bs, SHINY_PURPLE, Color3.new(1,1,1))
    
    b.MouseButton1Click:Connect(function()
        if isToggle then
            ActiveToggles[text] = not ActiveToggles[text]
            bs.Color = ActiveToggles[text] and ACTIVE_GREEN or Color3.new(1,1,1)
            func(ActiveToggles[text])
        else func() end
    end)
end

-- ADD ACTIONS TO HUB
createHubButton("S4INTSMODE", true, toggleSaintsMode)
createHubButton("Bat Fucker", true, function(s) batActive = s end)
createHubButton("ESP", true, function(s) espActive = s end)
createHubButton("Inf Jump", true, function(s) infJumpActive = s end)
createHubButton("Unwalk", true, function(state)
    local char = Player.Character
    if state then
        if char:FindFirstChild("Animate") then char.Animate.Disabled = true end
        for _, t in pairs(char.Humanoid:GetPlayingAnimationTracks()) do t:Stop() end
    else
        if char:FindFirstChild("Animate") then char.Animate.Disabled = false end
    end
end)
createHubButton("Rejoin Server", false, function() TeleportService:Teleport(game.PlaceId) end)
createHubButton("Server Hop", false, function() --[[Hop Logic]] end)
createHubButton("Kick Self", false, function() Player:Kick() end)

-- BAT FUCKER & PHYSICS LOOP
local batMover, batGyro = nil, nil
RunService.RenderStepped:Connect(function()
    if espActive then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= Player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                if not v.Character:FindFirstChild("S4Highlight") then
                    local hl = Instance.new("Highlight", v.Character); hl.Name = "S4Highlight"; hl.FillColor = ESP_COLOR
                    local bg = Instance.new("BillboardGui", v.Character); bg.Name = "S4Tag"; bg.Size = UDim2.new(0,100,0,20); bg.AlwaysOnTop = true; bg.StudsOffset = Vector3.new(0,3,0)
                    local tl = Instance.new("TextLabel", bg); tl.Size = UDim2.new(1,0,1,0); tl.Text = v.Name; tl.TextColor3 = ESP_COLOR; tl.BackgroundTransparency = 1; tl.Font = "GothamBold"
                end
            end
        end
    end

    if batActive and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        local myHrp = Player.Character.HumanoidRootPart
        local target = nil
        local dist = math.huge
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= Player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character.Humanoid.Health > 0 then
                local d = (myHrp.Position - v.Character.HumanoidRootPart.Position).Magnitude
                if d < dist then dist = d; target = v.Character.HumanoidRootPart end
            end
        end

        if target then
            if not batMover then batMover = Instance.new("BodyVelocity", myHrp); batMover.MaxForce = Vector3.new(math.huge,math.huge,math.huge) end
            if not batGyro then batGyro = Instance.new("BodyGyro", myHrp); batGyro.MaxTorque = Vector3.new(math.huge,math.huge,math.huge); batGyro.P = 20000 end
            batMover.Velocity = (target.Position - myHrp.Position).Unit * BatSettings.Speed
            batGyro.CFrame = CFrame.lookAt(myHrp.Position, target.Position)
            Player.Character.Humanoid.PlatformStand = true
        end
    else
        if batMover then batMover:Destroy(); batMover = nil end
        if batGyro then batGyro:Destroy(); batGyro = nil end
        if Player.Character and Player.Character:FindFirstChild("Humanoid") then Player.Character.Humanoid.PlatformStand = false end
    end
    
    if infJumpActive and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        Player.Character.HumanoidRootPart.Velocity = Vector3.new(Player.Character.HumanoidRootPart.Velocity.X, 45, Player.Character.HumanoidRootPart.Velocity.Z)
    end
end)

-- OPEN HUB BUTTON
local openBtn = Instance.new("TextButton", mainFrame)
openBtn.Size = UDim2.new(0, 80, 0, 30); openBtn.Position = UDim2.new(0.5, -40, 1, 10); openBtn.Text = "S4HUB"; openBtn.BackgroundColor3 = BG_COLOR; openBtn.TextColor3 = Color3.new(1,1,1)
openBtn.MouseButton1Click:Connect(function() hubFrame.Visible = not hubFrame.Visible end)

-- DRAG LOGIC
local function drag(f)
    local d, st, sp
    f.InputBegan:Connect(function(i) if (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then d = true; st = i.Position; sp = f.Position end end)
    UserInputService.InputChanged:Connect(function(i) if d then local del = i.Position - st; f.Position = UDim2.new(sp.X.Scale, sp.X.Offset + del.X, sp.Y.Scale, sp.Y.Offset + del.Y) end end)
    UserInputService.InputEnded:Connect(function() d = false end)
end
drag(mainFrame); drag(hubFrame); drag(h1); drag(h2); drag(h3); drag(h4)
