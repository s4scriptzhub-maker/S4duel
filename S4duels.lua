-- [[ S4DUELS: ELITE S4INTSMODE - FULL SOURCE ]] --
-- [[ NO COMPRESSION - NO SPACE SAVING - FULL DRAG CAPABILITY ]] --

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local playerGui = Player:WaitForChild("PlayerGui")
local ConfigFile = "S4_ELITE_MAIN.json"
local SpeedFile = "S4_ELITE_SPEED.json"

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

-- === THEME COLORS ===
local SHINY_PURPLE = Color3.fromRGB(210, 80, 255)
local NEON_BLUE = Color3.fromRGB(0, 220, 255)
local ACTIVE_GREEN = Color3.fromRGB(0, 255, 150)
local BG_COLOR = Color3.fromRGB(10, 10, 15)
local ESP_COLOR = Color3.fromRGB(255, 0, 0)

-- === DATA PERSISTENCE ===
local function saveAllData()
    if writefile then
        pcall(function()
            writefile(ConfigFile, HttpService:JSONEncode(SavedSettings))
            writefile(SpeedFile, HttpService:JSONEncode(BatSettings))
        end)
    end
end

local function loadData()
    if isfile and isfile(ConfigFile) then
        pcall(function() SavedSettings = HttpService:JSONDecode(readfile(ConfigFile)) end)
    end
    if isfile and isfile(SpeedFile) then
        pcall(function() BatSettings = HttpService:JSONDecode(readfile(SpeedFile)) end)
    end
end

-- === UI FACTORY ===
local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "S4_S4INTS_V3_ULTIMATE"
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

local function makeDraggable(frame)
    local dragToggle, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if not guiLocked and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            dragToggle = true
            dragStart = input.Position
            startPos = frame.Position
            
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragToggle = false
                    connection:Disconnect()
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragToggle and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local function createBaseFrame(name, size, pos, accent, parent)
    local f = Instance.new("Frame", parent or screenGui)
    f.Name = name; f.Size = size; f.Position = pos
    f.BackgroundColor3 = BG_COLOR; f.BackgroundTransparency = 0.4
    f.BorderSizePixel = 0
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
    local s = Instance.new("UIStroke", f)
    s.Thickness = 1.5; s.Color = Color3.new(1,1,1)
    applyShinyEffect(s, accent or SHINY_PURPLE, Color3.new(1,1,1))
    return f, s
end

-- [1] PERSISTENT LOCK BUTTON
local lockFrame, lockStroke = createBaseFrame("PersistentLock", UDim2.new(0, 100, 0, 35), UDim2.new(0.5, -240, 0, 60), NEON_BLUE)
local lockBtn = Instance.new("TextButton", lockFrame)
lockBtn.Size = UDim2.new(1, 0, 1, 0); lockBtn.BackgroundTransparency = 1; lockBtn.Text = "LOCK GUI"; lockBtn.TextColor3 = Color3.new(1,1,1); lockBtn.Font = "GothamBold"; lockBtn.TextSize = 11
makeDraggable(lockFrame)

-- [2] S4HUB RETURN LABEL (TOP LEFT)
local returnFrame, returnStroke = createBaseFrame("ReturnLabel", UDim2.new(0, 100, 0, 35), UDim2.new(0, 15, 0, 15), NEON_BLUE)
local returnBtn = Instance.new("TextButton", returnFrame)
returnBtn.Size = UDim2.new(1, 0, 1, 0); returnBtn.BackgroundTransparency = 1; returnBtn.Text = "S4HUB"; returnBtn.TextColor3 = Color3.new(1,1,1); returnBtn.Font = "GothamBold"; returnBtn.TextSize = 14
makeDraggable(returnFrame)

-- [3] MAIN HEADER
local mainHeader = createBaseFrame("MainHeader", UDim2.new(0, 180, 0, 90), UDim2.new(0.5, -90, 0, 60), SHINY_PURPLE)
local mainTitle = Instance.new("TextLabel", mainHeader)
mainTitle.Size = UDim2.new(1, 0, 0, 45); mainTitle.Text = "S4DUELS"; mainTitle.TextColor3 = Color3.new(1,1,1); mainTitle.Font = "ArialBold"; mainTitle.TextSize = 26; mainTitle.BackgroundTransparency = 1
applyShinyEffect(Instance.new("UIStroke", mainTitle), SHINY_PURPLE, Color3.new(1,1,1))

local statLabel = Instance.new("TextLabel", mainHeader)
statLabel.Size = UDim2.new(1, 0, 0, 20); statLabel.Position = UDim2.new(0, 0, 0, 45); statLabel.Text = "FPS: -- | PING: --"; statLabel.TextColor3 = Color3.new(0.7, 0.7, 0.7); statLabel.TextSize = 10; statLabel.BackgroundTransparency = 1

local openSettingsBtn = Instance.new("TextButton", mainHeader)
openSettingsBtn.Size = UDim2.new(0, 100, 0, 28); openSettingsBtn.Position = UDim2.new(0.5, -50, 1, 10); openSettingsBtn.Text = "SETTINGS"; openSettingsBtn.BackgroundColor3 = BG_COLOR; openSettingsBtn.TextColor3 = Color3.new(1,1,1); openSettingsBtn.Font = "GothamBold"; openSettingsBtn.TextSize = 11
Instance.new("UICorner", openSettingsBtn)
makeDraggable(mainHeader)

-- [4] S4HUB SETTINGS MENU
local hubMenu = createBaseFrame("S4HUB_Menu", UDim2.new(0, 450, 0, 500), UDim2.new(0.5, -225, 0.5, -250), SHINY_PURPLE)
hubMenu.Visible = false
makeDraggable(hubMenu)

local hubTitleLabel = Instance.new("TextLabel", hubMenu)
hubTitleLabel.Size = UDim2.new(1, 0, 0, 70); hubTitleLabel.Text = "S4HUB"; hubTitleLabel.TextColor3 = Color3.new(1,1,1); hubTitleLabel.Font = "ArialBold"; hubTitleLabel.TextSize = 34; hubTitleLabel.BackgroundTransparency = 1
applyShinyEffect(Instance.new("UIStroke", hubTitleLabel), SHINY_PURPLE, Color3.new(1,1,1))

local scrollFrame = Instance.new("ScrollingFrame", hubMenu)
scrollFrame.Size = UDim2.new(1, -40, 1, -200); scrollFrame.Position = UDim2.new(0, 20, 0, 90); scrollFrame.BackgroundTransparency = 1; scrollFrame.CanvasSize = UDim2.new(0, 0, 2, 0); scrollFrame.ScrollBarThickness = 2
Instance.new("UIGridLayout", scrollFrame).CellSize = UDim2.new(0.48, 0, 0, 50); Instance.new("UIPadding", scrollFrame).PaddingLeft = UDim.new(0, 5)

local globalSaveBtn = Instance.new("TextButton", hubMenu)
globalSaveBtn.Size = UDim2.new(0.9, 0, 0, 45); globalSaveBtn.Position = UDim2.new(0.05, 0, 1, -65); globalSaveBtn.Text = "SAVE CURRENT CONFIG"; globalSaveBtn.BackgroundColor3 = Color3.fromRGB(20,20,30); globalSaveBtn.TextColor3 = Color3.new(1,1,1); globalSaveBtn.Font = "GothamBold"
Instance.new("UICorner", globalSaveBtn)

-- [5] SPEED CONFIG (BAT FUCKER)
local speedMenu = createBaseFrame("BatSpeedUI", UDim2.new(0, 240, 0, 150), UDim2.new(0.5, 240, 0.5, -75), NEON_BLUE)
speedMenu.Visible = false; speedMenu.ZIndex = 100
makeDraggable(speedMenu)

local speedTitle = Instance.new("TextLabel", speedMenu)
speedTitle.Size = UDim2.new(1,0,0,40); speedTitle.Text = "TRACKING SPEED: " .. BatSettings.Speed; speedTitle.TextColor3 = Color3.new(1,1,1); speedTitle.Font = "GothamBold"; speedTitle.BackgroundTransparency = 1; speedTitle.ZIndex = 101

local sliderTrack = Instance.new("Frame", speedMenu)
sliderTrack.Size = UDim2.new(0.8, 0, 0, 14); sliderTrack.Position = UDim2.new(0.1, 0, 0.45, 0); sliderTrack.BackgroundColor3 = Color3.new(0.05, 0.05, 0.05); sliderTrack.ZIndex = 101

local sliderFill = Instance.new("Frame", sliderTrack)
sliderFill.Size = UDim2.new(BatSettings.Speed/70, 0, 1, 0); sliderFill.BackgroundColor3 = NEON_BLUE; sliderFill.ZIndex = 102

local sliderBtn = Instance.new("TextButton", sliderTrack)
sliderBtn.Size = UDim2.new(1,0,1,0); sliderBtn.BackgroundTransparency = 1; sliderBtn.Text = ""; sliderBtn.ZIndex = 103

local closeSpeedBtn = Instance.new("TextButton", speedMenu)
closeSpeedBtn.Size = UDim2.new(0.8, 0, 0, 35); closeSpeedBtn.Position = UDim2.new(0.1, 0, 0.78, 0); closeSpeedBtn.Text = "CONFIRM"; closeSpeedBtn.BackgroundColor3 = Color3.new(0,0,0); closeSpeedBtn.TextColor3 = Color3.new(1,1,1); closeSpeedBtn.Font = "GothamBold"; closeSpeedBtn.ZIndex = 101
Instance.new("UICorner", closeSpeedBtn)

-- [6] S4INTSMODE HUD CONTAINER
local saintsHUD = Instance.new("Frame", screenGui)
saintsHUD.Size = UDim2.new(1, 0, 1, 0); saintsHUD.BackgroundTransparency = 1; saintsHUD.Visible = false

local hudReferences = {}

local function createUltimateButton(text, pos, isToggle, parent, callback)
    local frame, stroke = createBaseFrame(text.."_Ultimate", UDim2.new(0, 145, 0, 48), pos, SHINY_PURPLE, parent)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1,0,1,0); btn.BackgroundTransparency = 1; btn.Text = text; btn.TextColor3 = Color3.new(1,1,1); btn.Font = "GothamBold"; btn.TextSize = 12
    
    if parent == saintsHUD then
        makeDraggable(frame)
    end

    if text == "Bat Fucker" and parent == scrollFrame then
        local gear = Instance.new("TextButton", frame)
        gear.Size = UDim2.new(0, 24, 0, 24); gear.Position = UDim2.new(1, -30, 0.5, -12); gear.Text = "⚙️"; gear.BackgroundTransparency = 1; gear.TextColor3 = Color3.new(1,1,1); gear.TextSize = 16
        gear.MouseButton1Click:Connect(function() speedMenu.Visible = not speedMenu.Visible end)
    end

    btn.MouseButton1Click:Connect(function()
        if isToggle then
            ActiveToggles[text] = not ActiveToggles[text]
            stroke.Color = ActiveToggles[text] and ACTIVE_GREEN or Color3.new(1,1,1)
            
            -- Sync colors across modes
            if hudReferences[text] then
                for _, ref in pairs(hudReferences[text]) do
                    ref.Stroke.Color = stroke.Color
                end
            end
            callback(ActiveToggles[text])
        else
            callback()
        end
    end)
    
    if not hudReferences[text] then hudReferences[text] = {} end
    table.insert(hudReferences[text], {Frame = frame, Stroke = stroke})
    return frame
end

-- === CORE LOGIC ===

local function handleESP()
    if not espActive then
        for _, v in pairs(Players:GetPlayers()) do
            if v.Character then
                if v.Character:FindFirstChild("S4_Highlight") then v.Character.S4_Highlight:Destroy() end
                if v.Character:FindFirstChild("S4_Tag") then v.Character.S4_Tag:Destroy() end
            end
        end
        return
    end
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= Player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            if not v.Character:FindFirstChild("S4_Highlight") then
                local hl = Instance.new("Highlight", v.Character); hl.Name = "S4_Highlight"; hl.FillColor = ESP_COLOR
                local bg = Instance.new("BillboardGui", v.Character); bg.Name = "S4_Tag"; bg.Size = UDim2.new(0,100,0,30); bg.AlwaysOnTop = true; bg.StudsOffset = Vector3.new(0,3,0)
                local tl = Instance.new("TextLabel", bg); tl.Size = UDim2.new(1,0,1,0); tl.BackgroundTransparency = 1; tl.Text = v.Name; tl.TextColor3 = ESP_COLOR; tl.Font = "GothamBold"; tl.TextSize = 13; tl.TextStrokeTransparency = 0
            end
        end
    end
end

local batV, batG = nil, nil
local function handleBatFucker()
    if not batActive then
        if batV then batV:Destroy(); batV = nil end
        if batG then batG:Destroy(); batG = nil end
        if Player.Character and Player.Character:FindFirstChild("Humanoid") then Player.Character.Humanoid.PlatformStand = false end
        return
    end
    local char = Player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    local target = nil
    local dist = math.huge
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= Player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character.Humanoid.Health > 0 then
            local d = (hrp.Position - v.Character.HumanoidRootPart.Position).Magnitude
            if d < dist then dist = d; target = v.Character.HumanoidRootPart end
        end
    end
    if target then
        if not batV then batV = Instance.new("BodyVelocity", hrp); batV.MaxForce = Vector3.new(math.huge, math.huge, math.huge) end
        if not batG then batG = Instance.new("BodyGyro", hrp); batG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge); batG.P = 40000 end
        char.Humanoid.PlatformStand = true
        batV.Velocity = (target.Position - hrp.Position).Unit * BatSettings.Speed
        batG.CFrame = CFrame.lookAt(hrp.Position, target.Position)
        for _, p in pairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
    else
        if batV then batV.Velocity = Vector3.new(0,0,0) end
    end
end

-- === POPULATE MODES ===

-- 1. S4HUB Settings Buttons (Modified to look like HUD buttons)
createUltimateButton("S4INTSMODE", true, scrollFrame, function(s)
    saintsModeActive = s
    saintsHUD.Visible = s
    mainHeader.Visible = not s
    hubMenu.Visible = false
end)
createUltimateButton("Bat Fucker", true, scrollFrame, function(s) batActive = s end)
createUltimateButton("ESP", true, scrollFrame, function(s) espActive = s end)
createUltimateButton("Inf Jump", true, scrollFrame, function(s) infJumpActive = s end)
createUltimateButton("Unwalk", true, scrollFrame, function(s) 
    unwalkActive = s
    if Player.Character and Player.Character:FindFirstChild("Animate") then Player.Character.Animate.Disabled = s end
end)
createUltimateButton("Rejoin", false, scrollFrame, function() TeleportService:Teleport(game.PlaceId, Player) end)
createUltimateButton("Server Hop", false, scrollFrame, function() TeleportService:Teleport(game.PlaceId) end)
createUltimateButton("Kick Self", false, scrollFrame, function() Player:Kick("S4 DISCONNECT") end)

-- 2. SAINTS HUD Tactical Buttons (Individual/Draggable)
createUltimateButton("Bat Fucker", UDim2.new(0.05, 0, 0.4, 0), true, saintsHUD, function(s) batActive = s end)
createUltimateButton("ESP", UDim2.new(0.05, 0, 0.5, 0), true, saintsHUD, function(s) espActive = s end)
createUltimateButton("Inf Jump", UDim2.new(0.85, 0, 0.4, 0), true, saintsHUD, function(s) infJumpActive = s end)
createUltimateButton("Unwalk", UDim2.new(0.85, 0, 0.5, 0), true, saintsHUD, function(s) 
    unwalkActive = s
    if Player.Character and Player.Character:FindFirstChild("Animate") then Player.Character.Animate.Disabled = s end
end)

-- === SLIDER ===
sliderBtn.MouseButton1Down:Connect(function()
    local move; move = UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local relX = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
            BatSettings.Speed = math.floor(relX * 70)
            sliderFill.Size = UDim2.new(relX, 0, 1, 0)
            speedTitle.Text = "TRACKING SPEED: " .. BatSettings.Speed
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then move:Disconnect() end
    end)
end)

-- === CONTROLS ===
lockBtn.MouseButton1Click:Connect(function()
    guiLocked = not guiLocked
    lockBtn.Text = guiLocked and "LOCKED" or "LOCK GUI"
    lockStroke.Color = guiLocked and Color3.fromRGB(255, 50, 50) or NEON_BLUE
end)

returnBtn.MouseButton1Click:Connect(function()
    saintsModeActive = false
    saintsHUD.Visible = false
    mainHeader.Visible = true
end)

openSettingsBtn.MouseButton1Click:Connect(function() hubMenu.Visible = not hubMenu.Visible end)
globalSaveBtn.MouseButton1Click:Connect(saveAllData)
closeSpeedBtn.MouseButton1Click:Connect(function() saveAllData(); speedMenu.Visible = false end)

-- === MAIN LOOP ===
RunService.RenderStepped:Connect(function()
    statLabel.Text = string.format("FPS: %d | PING: %dms", math.floor(1/RunService.RenderStepped:Wait()), math.floor(Player:GetNetworkPing()*1000))
    handleESP()
    handleBatFucker()
    if infJumpActive and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            Player.Character.HumanoidRootPart.Velocity = Vector3.new(Player.Character.HumanoidRootPart.Velocity.X, 45, Player.Character.HumanoidRootPart.Velocity.Z)
        end
    end
end)

loadData()
