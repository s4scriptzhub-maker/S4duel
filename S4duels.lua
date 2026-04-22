-- [[ S4DUELS: ULTIMATE S4INTSMODE EDITION ]] --
-- [[ TOTAL SOURCE CODE - NO COMPRESSION - NO SPACE SAVING ]] --

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local playerGui = Player:WaitForChild("PlayerGui")
local ConfigFile = "S4_ULTIMATE_CONF.json"
local SpeedFile = "S4_SPEED_CONF.json"

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

-- === PREMIUM THEME COLORS ===
local SHINY_PURPLE = Color3.fromRGB(210, 80, 255)
local NEON_BLUE = Color3.fromRGB(0, 220, 255)
local ACTIVE_GREEN = Color3.fromRGB(0, 255, 150)
local BG_COLOR = Color3.fromRGB(10, 10, 15)
local ESP_COLOR = Color3.fromRGB(255, 0, 0)

-- === CORE DATA PERSISTENCE ===
local function saveAllData()
    if writefile then
        writefile(ConfigFile, HttpService:JSONEncode(SavedSettings))
        writefile(SpeedFile, HttpService:JSONEncode(BatSettings))
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

-- === ADVANCED UI FACTORY ===
local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "S4_S4INTS_ULTIMATE"
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

-- [1] LOCK BUTTON (STAYS ON BOTH MODES)
local lockFrame, lockStroke = createBaseFrame("PersistentLock", UDim2.new(0, 95, 0, 30), UDim2.new(0.5, -240, 0, 60), NEON_BLUE)
local lockBtn = Instance.new("TextButton", lockFrame)
lockBtn.Size = UDim2.new(1, 0, 1, 0); lockBtn.BackgroundTransparency = 1; lockBtn.Text = "LOCK GUI"; lockBtn.TextColor3 = Color3.new(1,1,1); lockBtn.Font = "GothamBold"; lockBtn.TextSize = 10

-- [2] TOP LEFT RETURN HUB (S4HUB Label)
local returnFrame, returnStroke = createBaseFrame("ReturnLabel", UDim2.new(0, 100, 0, 35), UDim2.new(0, 15, 0, 15), NEON_BLUE)
local returnBtn = Instance.new("TextButton", returnFrame)
returnBtn.Size = UDim2.new(1, 0, 1, 0); returnBtn.BackgroundTransparency = 1; returnBtn.Text = "S4HUB"; returnBtn.TextColor3 = Color3.new(1,1,1); returnBtn.Font = "GothamBold"; returnBtn.TextSize = 14

-- [3] MAIN HEADER
local mainHeader = createBaseFrame("MainHeader", UDim2.new(0, 180, 0, 85), UDim2.new(0.5, -90, 0, 60), SHINY_PURPLE)
local mainTitle = Instance.new("TextLabel", mainHeader)
mainTitle.Size = UDim2.new(1, 0, 0, 40); mainTitle.Text = "S4DUELS"; mainTitle.TextColor3 = Color3.new(1,1,1); mainTitle.Font = "ArialBold"; mainTitle.TextSize = 24; mainTitle.BackgroundTransparency = 1
applyShinyEffect(Instance.new("UIStroke", mainTitle), SHINY_PURPLE, Color3.new(1,1,1))

local statLabel = Instance.new("TextLabel", mainHeader)
statLabel.Size = UDim2.new(1, 0, 0, 20); statLabel.Position = UDim2.new(0, 0, 0, 40); statLabel.Text = "FPS: -- | PING: --"; statLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8); statLabel.TextSize = 10; statLabel.BackgroundTransparency = 1

local openSettingsBtn = Instance.new("TextButton", mainHeader)
openSettingsBtn.Size = UDim2.new(0, 90, 0, 25); openSettingsBtn.Position = UDim2.new(0.5, -45, 1, 10); openSettingsBtn.Text = "SETTINGS"; openSettingsBtn.BackgroundColor3 = BG_COLOR; openSettingsBtn.TextColor3 = Color3.new(1,1,1); openSettingsBtn.Font = "GothamBold"
Instance.new("UICorner", openSettingsBtn)

-- [4] FULL SETTINGS MENU (S4HUB)
local hubMenu = createBaseFrame("S4HUB_Menu", UDim2.new(0, 420, 0, 480), UDim2.new(0.5, -210, 0.5, -240), SHINY_PURPLE)
hubMenu.Visible = false

local hubTitle = Instance.new("TextLabel", hubMenu)
hubTitle.Size = UDim2.new(1, 0, 0, 60); hubTitle.Text = "S4HUB"; hubTitle.TextColor3 = Color3.new(1,1,1); hubTitle.Font = "ArialBold"; hubTitle.TextSize = 30; hubTitle.BackgroundTransparency = 1
applyShinyEffect(Instance.new("UIStroke", hubTitle), SHINY_PURPLE, Color3.new(1,1,1))

local scrollFrame = Instance.new("ScrollingFrame", hubMenu)
scrollFrame.Size = UDim2.new(1, -30, 1, -180); scrollFrame.Position = UDim2.new(0, 15, 0, 80); scrollFrame.BackgroundTransparency = 1; scrollFrame.CanvasSize = UDim2.new(0, 0, 1.5, 0); scrollFrame.ScrollBarThickness = 2
Instance.new("UIGridLayout", scrollFrame).CellSize = UDim2.new(0.48, 0, 0, 45)

local globalSaveBtn = Instance.new("TextButton", hubMenu)
globalSaveBtn.Size = UDim2.new(0.9, 0, 0, 40); globalSaveBtn.Position = UDim2.new(0.05, 0, 1, -60); globalSaveBtn.Text = "SAVE SETTINGS"; globalSaveBtn.BackgroundColor3 = Color3.fromRGB(20,20,30); globalSaveBtn.TextColor3 = Color3.new(1,1,1); globalSaveBtn.Font = "GothamBold"
Instance.new("UICorner", globalSaveBtn)

-- [5] BAT FUCKER SPEED CONFIG
local speedMenu = createBaseFrame("BatSpeedUI", UDim2.new(0, 220, 0, 140), UDim2.new(0.5, 230, 0.5, -70), NEON_BLUE)
speedMenu.Visible = false; speedMenu.ZIndex = 50

local speedTitle = Instance.new("TextLabel", speedMenu)
speedTitle.Size = UDim2.new(1,0,0,35); speedTitle.Text = "SPEED: " .. BatSettings.Speed; speedTitle.TextColor3 = Color3.new(1,1,1); speedTitle.Font = "GothamBold"; speedTitle.BackgroundTransparency = 1; speedTitle.ZIndex = 51

local sliderTrack = Instance.new("Frame", speedMenu)
sliderTrack.Size = UDim2.new(0.8, 0, 0, 12); sliderTrack.Position = UDim2.new(0.1, 0, 0.45, 0); sliderTrack.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1); sliderTrack.ZIndex = 51

local sliderFill = Instance.new("Frame", sliderTrack)
sliderFill.Size = UDim2.new(BatSettings.Speed/70, 0, 1, 0); sliderFill.BackgroundColor3 = NEON_BLUE; sliderFill.ZIndex = 52

local sliderBtn = Instance.new("TextButton", sliderTrack)
sliderBtn.Size = UDim2.new(1,0,1,0); sliderBtn.BackgroundTransparency = 1; sliderBtn.Text = ""; sliderBtn.ZIndex = 53

local closeSpeedBtn = Instance.new("TextButton", speedMenu)
closeSpeedBtn.Size = UDim2.new(0.8, 0, 0, 30); closeSpeedBtn.Position = UDim2.new(0.1, 0, 0.75, 0); closeSpeedBtn.Text = "CONFIRM"; closeSpeedBtn.BackgroundColor3 = Color3.new(0,0,0); closeSpeedBtn.TextColor3 = Color3.new(1,1,1); closeSpeedBtn.Font = "GothamBold"; closeSpeedBtn.ZIndex = 51
Instance.new("UICorner", closeSpeedBtn)

-- [6] S4INTSMODE HUD (TACTICAL INDIVIDUAL BUTTONS)
local saintsHUD = Instance.new("Frame", screenGui)
saintsHUD.Size = UDim2.new(1, 0, 1, 0); saintsHUD.BackgroundTransparency = 1; saintsHUD.Visible = false

local hudReferences = {} -- For syncing states

local function createHUDButton(text, pos, isToggle, callback)
    local frame, stroke = createBaseFrame(text.."_HUD", UDim2.new(0, 140, 0, 45), pos, SHINY_PURPLE)
    frame.Parent = saintsHUD
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1,0,1,0); btn.BackgroundTransparency = 1; btn.Text = text; btn.TextColor3 = Color3.new(1,1,1); btn.Font = "GothamBold"; btn.TextSize = 12
    
    hudReferences[text] = {Frame = frame, Stroke = stroke}

    btn.MouseButton1Click:Connect(function()
        if isToggle then
            ActiveToggles[text] = not ActiveToggles[text]
            stroke.Color = ActiveToggles[text] and ACTIVE_GREEN or Color3.new(1,1,1)
            callback(ActiveToggles[text])
        else
            callback()
        end
    end)
    return frame
end

-- Populate Tactical HUD
createHUDButton("Bat Fucker", UDim2.new(0.1, 0, 0.4, 0), true, function(s) batActive = s end)
createHUDButton("ESP", UDim2.new(0.1, 0, 0.5, 0), true, function(s) espActive = s end)
createHUDButton("Inf Jump", UDim2.new(0.8, 0, 0.4, 0), true, function(s) infJumpActive = s end)
createHUDButton("Unwalk", UDim2.new(0.8, 0, 0.5, 0), true, function(s) 
    unwalkActive = s
    if Player.Character and Player.Character:FindFirstChild("Animate") then
        Player.Character.Animate.Disabled = s
    end
end)

-- === FEATURE FUNCTIONS ===

local function handleESP()
    if not espActive then
        for _, v in pairs(Players:GetPlayers()) do
            if v.Character then
                if v.Character:FindFirstChild("S4_Highlight") then v.Character.S4_Highlight:Destroy() end
                if v.Character:FindFirstChild("S4_Name") then v.Character.S4_Name:Destroy() end
            end
        end
        return
    end

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= Player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            if not v.Character:FindFirstChild("S4_Highlight") then
                local hl = Instance.new("Highlight", v.Character); hl.Name = "S4_Highlight"; hl.FillColor = ESP_COLOR
                local bg = Instance.new("BillboardGui", v.Character); bg.Name = "S4_Name"; bg.Size = UDim2.new(0,100,0,30); bg.AlwaysOnTop = true; bg.StudsOffset = Vector3.new(0,3,0)
                local tl = Instance.new("TextLabel", bg); tl.Size = UDim2.new(1,0,1,0); tl.BackgroundTransparency = 1; tl.Text = v.Name; tl.TextColor3 = ESP_COLOR; tl.Font = "GothamBold"; tl.TextSize = 13
            end
        end
    end
end

local batVelocity, batRotation = nil, nil
local function handleBatFucker()
    if not batActive then
        if batVelocity then batVelocity:Destroy(); batVelocity = nil end
        if batRotation then batRotation:Destroy(); batRotation = nil end
        if Player.Character and Player.Character:FindFirstChild("Humanoid") then Player.Character.Humanoid.PlatformStand = false end
        return
    end

    local char = Player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    local hum = char.Humanoid

    local target = nil
    local minD = math.huge
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= Player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character.Humanoid.Health > 0 then
            local d = (hrp.Position - v.Character.HumanoidRootPart.Position).Magnitude
            if d < minD then minD = d; target = v.Character.HumanoidRootPart end
        end
    end

    if target then
        if not batVelocity then
            batVelocity = Instance.new("BodyVelocity", hrp)
            batVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        end
        if not batRotation then
            batRotation = Instance.new("BodyGyro", hrp)
            batRotation.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            batRotation.P = 30000
        end
        hum.PlatformStand = true
        batVelocity.Velocity = (target.Position - hrp.Position).Unit * BatSettings.Speed
        batRotation.CFrame = CFrame.lookAt(hrp.Position, target.Position)
        
        -- Noclip to avoid wall resets
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    else
        if batVelocity then batVelocity.Velocity = Vector3.new(0,0,0) end
    end
end

-- === HUB BUTTON BUILDER ===

local function createMenuAction(text, isToggle, callback)
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
            -- Sync with Tactical HUD
            if hudReferences[text] then hudReferences[text].Stroke.Color = bs.Color end
            callback(ActiveToggles[text])
        else
            callback()
        end
    end)
end

-- Mode Switcher
local function setSaintsMode(state)
    saintsModeActive = state
    saintsHUD.Visible = state
    mainHeader.Visible = not state
    hubMenu.Visible = false
    -- Lock button remains visible in both modes naturally
end

-- Populate S4HUB Actions
createMenuAction("S4INTSMODE", true, setSaintsMode)
createMenuAction("Bat Fucker", true, function(s) batActive = s end)
createMenuAction("ESP", true, function(s) espActive = s end)
createMenuAction("Inf Jump", true, function(s) infJumpActive = s end)
createMenuAction("Unwalk", true, function(s) 
    unwalkActive = s
    if Player.Character and Player.Character:FindFirstChild("Animate") then Player.Character.Animate.Disabled = s end
end)
createMenuAction("Rejoin", false, function() TeleportService:Teleport(game.PlaceId, Player) end)
createMenuAction("Server Hop", false, function() TeleportService:Teleport(game.PlaceId) end)
createMenuAction("Kick Self", false, function() Player:Kick("S4DUELS DISCONNECT") end)

-- === SLIDER LOGIC ===
sliderBtn.MouseButton1Down:Connect(function()
    local move; move = UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local relX = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
            BatSettings.Speed = math.floor(relX * 70)
            sliderFill.Size = UDim2.new(relX, 0, 1, 0)
            speedTitle.Text = "SPEED: " .. BatSettings.Speed
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then move:Disconnect() end
    end)
end)

-- === INTERACTION BINDINGS ===
globalSaveBtn.MouseButton1Click:Connect(saveAllData)
closeSpeedBtn.MouseButton1Click:Connect(function() saveAllData(); speedMenu.Visible = false end)
returnBtn.MouseButton1Click:Connect(function() setSaintsMode(false) end)
openSettingsBtn.MouseButton1Click:Connect(function() hubMenu.Visible = not hubMenu.Visible end)

lockBtn.MouseButton1Click:Connect(function()
    guiLocked = not guiLocked
    lockBtn.Text = guiLocked and "LOCKED" or "LOCK GUI"
    lockStroke.Color = guiLocked and Color3.fromRGB(255, 50, 50) or NEON_BLUE
end)

-- === RUNTIME ENGINE ===
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

-- === UNIVERSAL DRAG SYSTEM ===
local function makeDraggable(frame)
    local dragToggle, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if not guiLocked and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            dragToggle = true; dragStart = input.Position; startPos = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragToggle then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function() dragToggle = false end)
end

makeDraggable(mainHeader); makeDraggable(hubMenu); makeDraggable(lockFrame); makeDraggable(speedMenu); makeDraggable(returnFrame)
for _, hud in pairs(hudReferences) do makeDraggable(hud.Frame) end

loadData()
