-- [[ S4DUELS: ULTIMATE BRAINROT ELITE EDITION ]] --
-- [[ FULLY OPTIMIZED, NO COMPRESSION, PERFECTED DRAG & PHYSICS ]] --

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")

local Player = Players.LocalPlayer
local playerGui = Player:WaitForChild("PlayerGui")

-- === FILE SYSTEM FOR SAVING ===
local MainConfigFile = "S4_ELITE_CONFIG.json"
local SpeedConfigFile = "S4_ELITE_SPEED.json"

-- === GLOBAL STATE MANAGEMENT ===
local BatSettings = { Speed = 56 }
local States = {
    ["Bat Fucker"] = false,
    ["ESP"] = false,
    ["Inf Jump"] = false,
    ["Unwalk"] = false,
    ["S4INTSMODE"] = false
}

local guiLocked = false
local ButtonRegistry = {} -- Stores UI elements to keep them synced across modes

-- === THEME COLORS ===
local SHINY_PURPLE = Color3.fromRGB(210, 80, 255)
local NEON_BLUE = Color3.fromRGB(0, 220, 255)
local ACTIVE_GREEN = Color3.fromRGB(0, 255, 150)
local BG_COLOR = Color3.fromRGB(10, 10, 15)
local ESP_COLOR = Color3.fromRGB(255, 0, 0)

-- === DATA PERSISTENCE ===
local function saveConfigs()
    if writefile then
        pcall(function()
            writefile(MainConfigFile, HttpService:JSONEncode(States))
            writefile(SpeedConfigFile, HttpService:JSONEncode(BatSettings))
        end)
    end
end

local function loadConfigs()
    if isfile and isfile(MainConfigFile) then
        pcall(function() 
            local data = HttpService:JSONDecode(readfile(MainConfigFile))
            for k, v in pairs(data) do States[k] = v end
        end)
    end
    if isfile and isfile(SpeedConfigFile) then
        pcall(function() 
            local data = HttpService:JSONDecode(readfile(SpeedConfigFile))
            if data.Speed then BatSettings.Speed = data.Speed end
        end)
    end
end

-- === UI EFFECTS & CREATION ===
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "S4DUELS_ULTIMATE_HUD"
screenGui.ResetOnSpawn = false
-- Safely parent the GUI
pcall(function()
    if gethui then
        screenGui.Parent = gethui()
    else
        screenGui.Parent = playerGui
    end
end)

local function applyShinyGradient(parent, color1, color2)
    local gradient = Instance.new("UIGradient", parent)
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, color1),
        ColorSequenceKeypoint.new(0.4, color1),
        ColorSequenceKeypoint.new(0.5, color2),
        ColorSequenceKeypoint.new(0.6, color1),
        ColorSequenceKeypoint.new(1, color1)
    })
    
    -- Smooth spinning animation
    task.spawn(function()
        local rotation = 0
        RunService.RenderStepped:Connect(function(deltaTime)
            rotation = (rotation + (deltaTime * 75)) % 360
            gradient.Rotation = rotation
        end)
    end)
end

-- === PERFECTED DRAG ENGINE ===
local function makeDraggable(frame, dragHandle)
    local trigger = dragHandle or frame
    local dragging = false
    local dragInput, mousePos, framePos

    trigger.InputBegan:Connect(function(input)
        if not guiLocked and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            dragging = true
            mousePos = input.Position
            framePos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    trigger.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            frame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end)
end

local function createStyledFrame(name, size, pos, accentColor, parent)
    local frame = Instance.new("Frame", parent or screenGui)
    frame.Name = name
    frame.Size = size
    frame.Position = pos
    frame.BackgroundColor3 = BG_COLOR
    frame.BackgroundTransparency = 0.35
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    
    local stroke = Instance.new("UIStroke", frame)
    stroke.Thickness = 1.5
    stroke.Color = Color3.new(1, 1, 1)
    applyShinyGradient(stroke, accentColor or SHINY_PURPLE, Color3.new(1, 1, 1))
    
    return frame, stroke
end

-- ==========================================
-- ========== UI ELEMENT BUILDER ============
-- ==========================================

-- [1] PERSISTENT LOCK BUTTON
local lockFrame, lockStroke = createStyledFrame("LockGUI", UDim2.new(0, 100, 0, 35), UDim2.new(0.5, -250, 0, 60), NEON_BLUE)
local lockBtn = Instance.new("TextButton", lockFrame)
lockBtn.Size = UDim2.new(1, 0, 1, 0); lockBtn.BackgroundTransparency = 1
lockBtn.Text = "LOCK GUI"; lockBtn.TextColor3 = Color3.new(1, 1, 1); lockBtn.Font = Enum.Font.GothamBold; lockBtn.TextSize = 12
makeDraggable(lockFrame, lockBtn)

-- [2] S4HUB TOP-LEFT RETURN BUTTON (Visible in SaintsMode)
local returnFrame, returnStroke = createStyledFrame("ReturnHUB", UDim2.new(0, 120, 0, 40), UDim2.new(0, 15, 0, 15), NEON_BLUE)
local returnBtn = Instance.new("TextButton", returnFrame)
returnBtn.Size = UDim2.new(1, 0, 1, 0); returnBtn.BackgroundTransparency = 1
returnBtn.Text = "S4HUB"; returnBtn.TextColor3 = Color3.new(1, 1, 1); returnBtn.Font = Enum.Font.GothamBold; returnBtn.TextSize = 14
returnFrame.Visible = false
makeDraggable(returnFrame, returnBtn)

-- [3] MAIN HEADER MENU
local mainHeader, mainHeaderStroke = createStyledFrame("MainHeader", UDim2.new(0, 180, 0, 95), UDim2.new(0.5, -90, 0, 60), SHINY_PURPLE)
local headerTitle = Instance.new("TextLabel", mainHeader)
headerTitle.Size = UDim2.new(1, 0, 0, 40); headerTitle.Position = UDim2.new(0, 0, 0, 5)
headerTitle.Text = "S4DUELS"; headerTitle.TextColor3 = Color3.new(1, 1, 1); headerTitle.Font = Enum.Font.ArialBold; headerTitle.TextSize = 24; headerTitle.BackgroundTransparency = 1
applyShinyGradient(Instance.new("UIStroke", headerTitle), SHINY_PURPLE, Color3.new(1, 1, 1))

local statsLabel = Instance.new("TextLabel", mainHeader)
statsLabel.Size = UDim2.new(1, 0, 0, 20); statsLabel.Position = UDim2.new(0, 0, 0, 40)
statsLabel.Text = "FPS: -- | PING: --ms"; statsLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8); statsLabel.Font = Enum.Font.GothamSemibold; statsLabel.TextSize = 10; statsLabel.BackgroundTransparency = 1

local openSettingsBtn = Instance.new("TextButton", mainHeader)
openSettingsBtn.Size = UDim2.new(0, 110, 0, 28); openSettingsBtn.Position = UDim2.new(0.5, -55, 1, 10)
openSettingsBtn.Text = "SETTINGS"; openSettingsBtn.BackgroundColor3 = BG_COLOR; openSettingsBtn.TextColor3 = Color3.new(1, 1, 1); openSettingsBtn.Font = Enum.Font.GothamBold; openSettingsBtn.TextSize = 12
Instance.new("UICorner", openSettingsBtn).CornerRadius = UDim.new(0, 4)
local osbStroke = Instance.new("UIStroke", openSettingsBtn); osbStroke.Thickness = 1; osbStroke.Color = SHINY_PURPLE
makeDraggable(mainHeader, headerTitle)

-- [4] S4HUB MAIN SETTINGS MENU
local hubMenu, hubMenuStroke = createStyledFrame("S4HUB_Menu", UDim2.new(0, 450, 0, 500), UDim2.new(0.5, -225, 0.5, -250), SHINY_PURPLE)
hubMenu.Visible = false
makeDraggable(hubMenu)

local hubTitle = Instance.new("TextLabel", hubMenu)
hubTitle.Size = UDim2.new(1, 0, 0, 60); hubTitle.Position = UDim2.new(0, 0, 0, 10)
hubTitle.Text = "S4HUB"; hubTitle.TextColor3 = Color3.new(1, 1, 1); hubTitle.Font = Enum.Font.ArialBold; hubTitle.TextSize = 32; hubTitle.BackgroundTransparency = 1
applyShinyGradient(Instance.new("UIStroke", hubTitle), SHINY_PURPLE, Color3.new(1, 1, 1))

local closeHubBtn = Instance.new("TextButton", hubMenu)
closeHubBtn.Size = UDim2.new(0, 30, 0, 30); closeHubBtn.Position = UDim2.new(1, -40, 0, 15)
closeHubBtn.Text = "X"; closeHubBtn.BackgroundColor3 = Color3.fromRGB(40, 10, 10); closeHubBtn.TextColor3 = Color3.new(1, 1, 1); closeHubBtn.Font = Enum.Font.GothamBold; closeHubBtn.TextSize = 14
Instance.new("UICorner", closeHubBtn).CornerRadius = UDim.new(0, 6)

local scrollFrame = Instance.new("ScrollingFrame", hubMenu)
scrollFrame.Size = UDim2.new(1, -30, 1, -170); scrollFrame.Position = UDim2.new(0, 15, 0, 80)
scrollFrame.BackgroundTransparency = 1; scrollFrame.CanvasSize = UDim2.new(0, 0, 1.5, 0); scrollFrame.ScrollBarThickness = 4; scrollFrame.ScrollBarImageColor3 = SHINY_PURPLE
local gridLayout = Instance.new("UIGridLayout", scrollFrame)
gridLayout.CellSize = UDim2.new(0.48, 0, 0, 48); gridLayout.CellPadding = UDim2.new(0, 8, 0, 8)
Instance.new("UIPadding", scrollFrame).PaddingLeft = UDim.new(0, 2)

local globalSaveBtn = Instance.new("TextButton", hubMenu)
globalSaveBtn.Size = UDim2.new(0.9, 0, 0, 45); globalSaveBtn.Position = UDim2.new(0.05, 0, 1, -60)
globalSaveBtn.Text = "SAVE CURRENT CONFIG"; globalSaveBtn.BackgroundColor3 = BG_COLOR; globalSaveBtn.TextColor3 = Color3.new(1, 1, 1); globalSaveBtn.Font = Enum.Font.GothamBold; globalSaveBtn.TextSize = 14
Instance.new("UICorner", globalSaveBtn).CornerRadius = UDim.new(0, 6)
local gsbStroke = Instance.new("UIStroke", globalSaveBtn); gsbStroke.Thickness = 1.5; applyShinyGradient(gsbStroke, NEON_BLUE, Color3.new(1,1,1))

-- [5] BAT FUCKER SPEED SLIDER MENU
local speedMenu, speedMenuStroke = createStyledFrame("SpeedMenu", UDim2.new(0, 250, 0, 150), UDim2.new(0.5, 240, 0.5, -75), NEON_BLUE)
speedMenu.Visible = false; speedMenu.ZIndex = 50
makeDraggable(speedMenu)

local speedTitleLabel = Instance.new("TextLabel", speedMenu)
speedTitleLabel.Size = UDim2.new(1, 0, 0, 40); speedTitleLabel.Position = UDim2.new(0, 0, 0, 10)
speedTitleLabel.Text = "TRACKING SPEED: " .. BatSettings.Speed; speedTitleLabel.TextColor3 = Color3.new(1, 1, 1); speedTitleLabel.Font = Enum.Font.GothamBold; speedTitleLabel.TextSize = 14; speedTitleLabel.BackgroundTransparency = 1; speedTitleLabel.ZIndex = 51

local sliderTrack = Instance.new("Frame", speedMenu)
sliderTrack.Size = UDim2.new(0.8, 0, 0, 14); sliderTrack.Position = UDim2.new(0.1, 0, 0.45, 0)
sliderTrack.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1); sliderTrack.ZIndex = 51; Instance.new("UICorner", sliderTrack)

local sliderFill = Instance.new("Frame", sliderTrack)
sliderFill.Size = UDim2.new(BatSettings.Speed / 70, 0, 1, 0)
sliderFill.BackgroundColor3 = NEON_BLUE; sliderFill.ZIndex = 52; Instance.new("UICorner", sliderFill)

local sliderTrigger = Instance.new("TextButton", sliderTrack)
sliderTrigger.Size = UDim2.new(1, 0, 1, 0); sliderTrigger.BackgroundTransparency = 1; sliderTrigger.Text = ""; sliderTrigger.ZIndex = 53

local confirmSpeedBtn = Instance.new("TextButton", speedMenu)
confirmSpeedBtn.Size = UDim2.new(0.8, 0, 0, 35); confirmSpeedBtn.Position = UDim2.new(0.1, 0, 0.75, 0)
confirmSpeedBtn.Text = "CONFIRM SPEED"; confirmSpeedBtn.BackgroundColor3 = BG_COLOR; confirmSpeedBtn.TextColor3 = Color3.new(1, 1, 1); confirmSpeedBtn.Font = Enum.Font.GothamBold; confirmSpeedBtn.TextSize = 12; confirmSpeedBtn.ZIndex = 51
Instance.new("UICorner", confirmSpeedBtn)
local csbStroke = Instance.new("UIStroke", confirmSpeedBtn); csbStroke.Thickness = 1.2; csbStroke.Color = NEON_BLUE

-- [6] S4INTSMODE HUD (Container for draggable buttons)
local saintsHUD = Instance.new("Frame", screenGui)
saintsHUD.Size = UDim2.new(1, 0, 1, 0); saintsHUD.BackgroundTransparency = 1; saintsHUD.Visible = false

-- ==========================================
-- ======== CENTRAL STATE SYNCHRONIZER ======
-- ==========================================

local function syncUIState(featureName)
    local isActive = States[featureName]
    local targetColor = isActive and ACTIVE_GREEN or Color3.new(1, 1, 1)
    
    if ButtonRegistry[featureName] then
        for _, stroke in pairs(ButtonRegistry[featureName]) do
            stroke.Color = targetColor
        end
    end
end

local function toggleFeature(featureName, forceState)
    if forceState ~= nil then
        States[featureName] = forceState
    else
        States[featureName] = not States[featureName]
    end
    syncUIState(featureName)
    return States[featureName]
end

-- ==========================================
-- ========== BUTTON FACTORY ================
-- ==========================================

local function createSyncedButton(text, isToggle, parent, position, callback)
    local frame, stroke
    
    if parent == scrollFrame then
        -- Settings Menu layout (Uses UI Grid Layout)
        frame = Instance.new("Frame", parent)
        frame.BackgroundColor3 = BG_COLOR; frame.BackgroundTransparency = 0.35; frame.BorderSizePixel = 0
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
        stroke = Instance.new("UIStroke", frame); stroke.Thickness = 1.5; stroke.Color = Color3.new(1,1,1)
        applyShinyGradient(stroke, SHINY_PURPLE, Color3.new(1, 1, 1))
    else
        -- S4INTSMODE Tactical layout (Absolute positioning, completely draggable)
        frame, stroke = createStyledFrame(text.."_S4INTS", UDim2.new(0, 145, 0, 48), position, SHINY_PURPLE, parent)
        local btnHandle = Instance.new("TextButton", frame) -- Invisible handle to drag without blocking main click
        btnHandle.Size = UDim2.new(1, 0, 1, 0); btnHandle.BackgroundTransparency = 1; btnHandle.Text = ""
        makeDraggable(frame, btnHandle)
    end

    -- The actual click button
    local actionBtn = Instance.new("TextButton", frame)
    actionBtn.Size = UDim2.new(1, 0, 1, 0); actionBtn.BackgroundTransparency = 1
    actionBtn.Text = text; actionBtn.TextColor3 = Color3.new(1, 1, 1); actionBtn.Font = Enum.Font.GothamBold; actionBtn.TextSize = 13

    -- If Bat Fucker, inject the Gear Icon
    if text == "Bat Fucker" then
        local gearIcon = Instance.new("TextButton", frame)
        gearIcon.Size = UDim2.new(0, 26, 0, 26); gearIcon.Position = UDim2.new(1, -30, 0.5, -13)
        gearIcon.Text = "⚙️"; gearIcon.BackgroundTransparency = 1; gearIcon.TextColor3 = Color3.new(1, 1, 1); gearIcon.TextSize = 16; gearIcon.ZIndex = 5
        gearIcon.MouseButton1Click:Connect(function() speedMenu.Visible = not speedMenu.Visible end)
    end

    -- Register stroke for syncing
    if not ButtonRegistry[text] then ButtonRegistry[text] = {} end
    table.insert(ButtonRegistry[text], stroke)

    -- Click Logic
    actionBtn.MouseButton1Click:Connect(function()
        if isToggle then
            local newState = toggleFeature(text)
            if callback then callback(newState) end
        else
            -- One-time action flash effect
            task.spawn(function()
                stroke.Color = Color3.new(1, 1, 1)
                task.wait(0.2)
                stroke.Color = Color3.new(1, 1, 1) -- Resets to standard gradient
            end)
            if callback then callback() end
        end
    end)
end

-- ==========================================
-- ========== FEATURE LOGIC & PHYSICS =======
-- ==========================================

local batVelocity, batGyro = nil, nil

local function runBatFuckerPhysics()
    if not States["Bat Fucker"] then
        if batVelocity then batVelocity:Destroy(); batVelocity = nil end
        if batGyro then batGyro:Destroy(); batGyro = nil end
        if Player.Character and Player.Character:FindFirstChild("Humanoid") then
            Player.Character.Humanoid.PlatformStand = false
        end
        return
    end

    local char = Player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChild("Humanoid") then return end

    local hrp = char.HumanoidRootPart
    local hum = char.Humanoid
    local targetHrp = nil
    local shortestDist = math.huge

    -- Scan for nearest valid target
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= Player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") then
            if v.Character.Humanoid.Health > 0 then
                local dist = (hrp.Position - v.Character.HumanoidRootPart.Position).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    targetHrp = v.Character.HumanoidRootPart
                end
            end
        end
    end

    -- Execute 3D Flight tracking
    if targetHrp then
        if not batVelocity or not batVelocity.Parent then
            batVelocity = Instance.new("BodyVelocity")
            batVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            batVelocity.Parent = hrp
        end
        if not batGyro or not batGyro.Parent then
            batGyro = Instance.new("BodyGyro")
            batGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            batGyro.P = 50000 -- Intense rotation force to never miss
            batGyro.Parent = hrp
        end

        hum.PlatformStand = true -- Bypasses walking physics
        
        -- Calculate direction and apply speed directly to target
        local direction = (targetHrp.Position - hrp.Position).Unit
        batVelocity.Velocity = direction * BatSettings.Speed
        batGyro.CFrame = CFrame.lookAt(hrp.Position, targetHrp.Position)

        -- Noclip to fly through walls/floors safely
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    else
        -- Hover in place if target dies or disappears
        if batVelocity then batVelocity.Velocity = Vector3.new(0, 0, 0) end
    end
end

local function runESP()
    if not States["ESP"] then
        for _, v in pairs(Players:GetPlayers()) do
            if v.Character then
                if v.Character:FindFirstChild("S4_ESP_HL") then v.Character.S4_ESP_HL:Destroy() end
                if v.Character:FindFirstChild("S4_ESP_TAG") then v.Character.S4_ESP_TAG:Destroy() end
            end
        end
        return
    end

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= Player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            if not v.Character:FindFirstChild("S4_ESP_HL") then
                local hl = Instance.new("Highlight", v.Character)
                hl.Name = "S4_ESP_HL"
                hl.FillColor = ESP_COLOR
                hl.OutlineColor = Color3.new(1, 1, 1)

                local bb = Instance.new("BillboardGui", v.Character)
                bb.Name = "S4_ESP_TAG"
                bb.Size = UDim2.new(0, 150, 0, 30)
                bb.AlwaysOnTop = true
                bb.StudsOffset = Vector3.new(0, 3.5, 0)
                
                local txt = Instance.new("TextLabel", bb)
                txt.Size = UDim2.new(1, 0, 1, 0)
                txt.BackgroundTransparency = 1
                txt.Text = v.Name
                txt.TextColor3 = ESP_COLOR
                txt.Font = Enum.Font.GothamBold
                txt.TextSize = 14
                txt.TextStrokeTransparency = 0
            end
        end
    end
end

local function applyUnwalk(state)
    local char = Player.Character
    if not char then return end
    
    local anim = char:FindFirstChild("Animate")
    local hum = char:FindFirstChild("Humanoid")

    if state then
        if anim then anim.Disabled = true end
        if hum then
            for _, t in pairs(hum:GetPlayingAnimationTracks()) do t:Stop() end
        end
    else
        if anim then anim.Disabled = false end
    end
end

-- ==========================================
-- ========== MENU & BUTTON POPULATION ======
-- ==========================================

local function activateSaintsMode(state)
    States["S4INTSMODE"] = state
    saintsHUD.Visible = state
    returnFrame.Visible = state
    mainHeader.Visible = not state
    hubMenu.Visible = false
    syncUIState("S4INTSMODE")
end

-- [POPULATE S4HUB SETTINGS]
createSyncedButton("S4INTSMODE", true, scrollFrame, nil, activateSaintsMode)
createSyncedButton("Bat Fucker", true, scrollFrame, nil, nil)
createSyncedButton("ESP", true, scrollFrame, nil, nil)
createSyncedButton("Inf Jump", true, scrollFrame, nil, nil)
createSyncedButton("Unwalk", true, scrollFrame, nil, applyUnwalk)
createSyncedButton("Taunt", false, scrollFrame, nil, function()
    if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        local channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
        if channel then channel:SendAsync("S4DUELS ON TOP") end
    else
        local rme = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
        if rme and rme:FindFirstChild("SayMessageRequest") then rme.SayMessageRequest:FireServer("S4DUELS ON TOP", "All") end
    end
end)
createSyncedButton("Rejoin", false, scrollFrame, nil, function() TeleportService:Teleport(game.PlaceId, Player) end)
createSyncedButton("Server Hop", false, scrollFrame, nil, function() TeleportService:Teleport(game.PlaceId) end)
createSyncedButton("Kick Self", false, scrollFrame, nil, function() Player:Kick("S4DUELS Manual Disconnect") end)

-- [POPULATE S4INTSMODE HUD]
-- Positioned dynamically, entirely draggable by the user.
createSyncedButton("Bat Fucker", true, saintsHUD, UDim2.new(0.05, 0, 0.4, 0), nil)
createSyncedButton("ESP", true, saintsHUD, UDim2.new(0.05, 0, 0.5, 0), nil)
createSyncedButton("Inf Jump", true, saintsHUD, UDim2.new(0.85, 0, 0.4, 0), nil)
createSyncedButton("Unwalk", true, saintsHUD, UDim2.new(0.85, 0, 0.5, 0), applyUnwalk)

-- ==========================================
-- ========== EVENT BINDINGS ================
-- ==========================================

-- Slider Engine for Bat Speed
sliderTrigger.MouseButton1Down:Connect(function()
    local moveConnection
    moveConnection = UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local relX = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
            BatSettings.Speed = math.floor(relX * 70)
            sliderFill.Size = UDim2.new(relX, 0, 1, 0)
            speedTitleLabel.Text = "TRACKING SPEED: " .. BatSettings.Speed
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if moveConnection then moveConnection:Disconnect() end
        end
    end)
end)

lockBtn.MouseButton1Click:Connect(function()
    guiLocked = not guiLocked
    lockBtn.Text = guiLocked and "LOCKED" or "LOCK GUI"
    lockStroke.Color = guiLocked and Color3.fromRGB(255, 50, 50) or NEON_BLUE
end)

returnBtn.MouseButton1Click:Connect(function()
    toggleFeature("S4INTSMODE", false)
    activateSaintsMode(false)
end)

openSettingsBtn.MouseButton1Click:Connect(function() hubMenu.Visible = not hubMenu.Visible end)
closeHubBtn.MouseButton1Click:Connect(function() hubMenu.Visible = false end)
globalSaveBtn.MouseButton1Click:Connect(saveConfigs)
confirmSpeedBtn.MouseButton1Click:Connect(function() saveConfigs(); speedMenu.Visible = false end)

-- ==========================================
-- ========== MASTER RUNTIME LOOP ===========
-- ==========================================
RunService.RenderStepped:Connect(function()
    -- 1. Performance Stats
    statsLabel.Text = string.format("FPS: %d | PING: %dms", math.floor(1 / RunService.RenderStepped:Wait()), math.floor(Player:GetNetworkPing() * 1000))
    
    -- 2. ESP Loop
    runESP()
    
    -- 3. Bat Fucker Physics Loop
    runBatFuckerPhysics()
    
    -- 4. Infinite Jump Loop (Smooth float)
    if States["Inf Jump"] and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = Player.Character.HumanoidRootPart
            hrp.Velocity = Vector3.new(hrp.Velocity.X, 45, hrp.Velocity.Z)
        end
    end
end)

-- Initialize Data on Start
loadConfigs()
