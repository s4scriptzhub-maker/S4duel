-- [[ S4DUELS: ULTIMATE BRAINROT ELITE EDITION ]] --
-- [[ PREMIUM UI, STABLE PHYSICS, NATIVE 22s CARRY LOGIC ]] --
-- [[ DEVELOPED FOR PREMIUM DISTRIBUTION ]] --

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")

-- Safely wait for the player to exist to prevent Infinite Yield crashes
local Player = Players.LocalPlayer
while not Player do
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    Player = Players.LocalPlayer
end

local playerGui = Player:WaitForChild("PlayerGui", 10)

-- === DESTROY OLD INSTANCES TO PREVENT OVERLAPPING ===
local guiName = "S4DUELS_ULTIMATE_HUD"
pcall(function()
    for _, v in pairs(game:GetService("CoreGui"):GetChildren()) do
        if v.Name == guiName then v:Destroy() end
    end
end)
if playerGui then
    for _, v in pairs(playerGui:GetChildren()) do
        if v.Name == guiName then v:Destroy() end
    end
end

-- === FILE SYSTEM FOR SAVING ===
local MainConfigFile = "S4_ELITE_CONFIG.json"
local SpeedConfigFile = "S4_ELITE_SPEED.json"

-- === GLOBAL STATE MANAGEMENT ===
local AdvancedSettings = { 
    BatSpeed = 55, 
    FlySpeed = 55,
    FlyCarrySpeed = 11, 
    WalkSpeed = 55, 
    CarrySpeed = 29 
}
local States = {
    ["Bat Fucker"] = false,
    ["Fly"] = false,
    ["S4BOOSTER"] = false,
    ["Instant Steal"] = false,
    ["ESP"] = false,
    ["Inf Jump"] = false,
    ["Unwalk"] = false,
    ["duelfucker"] = false
}

local guiLocked = false
local ButtonRegistry = {}
local FeatureCallbacks = {}

-- EVENT-DRIVEN CARRY STATE
local InternalCarryState = false
local carryStartTime = 0

-- === PREMIUM LUXURY THEME COLORS ===
local PRIMARY_ACCENT = Color3.fromRGB(138, 43, 226)   -- Electric Violet
local SECONDARY_ACCENT = Color3.fromRGB(0, 229, 255)  -- Cyan/Teal Glow
local ACTIVE_GLOW = Color3.fromRGB(0, 255, 170)       -- Premium Mint Green
local BG_DEEP = Color3.fromRGB(12, 12, 18)            -- Deep Midnight Glass
local TEXT_MAIN = Color3.fromRGB(240, 240, 245)
local ESP_COLOR = Color3.fromRGB(255, 50, 70)

local TWEEN_INFO = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

-- === EXECUTOR-SAFE DATA PERSISTENCE ===
local function saveConfigs()
    pcall(function()
        if type(writefile) == "function" then
            writefile(MainConfigFile, HttpService:JSONEncode(States))
            writefile(SpeedConfigFile, HttpService:JSONEncode(AdvancedSettings))
        end
    end)
end

local function loadConfigs()
    pcall(function()
        if type(isfile) == "function" and type(readfile) == "function" then
            if isfile(MainConfigFile) then
                local data = HttpService:JSONDecode(readfile(MainConfigFile))
                for k, v in pairs(data) do States[k] = v end
            end
            if isfile(SpeedConfigFile) then
                local data = HttpService:JSONDecode(readfile(SpeedConfigFile))
                if data.BatSpeed then AdvancedSettings.BatSpeed = data.BatSpeed end
                if data.FlySpeed then AdvancedSettings.FlySpeed = data.FlySpeed end
                if data.FlyCarrySpeed then AdvancedSettings.FlyCarrySpeed = data.FlyCarrySpeed end
                if data.WalkSpeed then AdvancedSettings.WalkSpeed = data.WalkSpeed end
                if data.CarrySpeed then AdvancedSettings.CarrySpeed = data.CarrySpeed end
            end
        end
    end)
end

-- === UI EFFECTS & CREATION ===
local screenGui = Instance.new("ScreenGui")
screenGui.Name = guiName
screenGui.ResetOnSpawn = false

pcall(function()
    if type(gethui) == "function" then
        screenGui.Parent = gethui()
    elseif game:GetService("CoreGui"):FindFirstChild("RobloxGui") then
        screenGui.Parent = game:GetService("CoreGui")
    end
end)
if not screenGui.Parent and playerGui then
    screenGui.Parent = playerGui
end

pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "S4DUELS ELITE",
        Text = "Premium Interface Successfully Injected.",
        Duration = 5
    })
end)

local function applyShinyGradient(parent, color1, color2)
    local gradient = Instance.new("UIGradient", parent)
    -- Adds a sharp "light reflection" angle to the stroke for a 3D glass edge look
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, color1),
        ColorSequenceKeypoint.new(0.4, color1),
        ColorSequenceKeypoint.new(0.5, Color3.new(1, 1, 1)), -- Bright reflection hotspot
        ColorSequenceKeypoint.new(0.6, color2),
        ColorSequenceKeypoint.new(1, color2)
    })
    
    task.spawn(function()
        local rotation = 0
        RunService.RenderStepped:Connect(function(deltaTime)
            rotation = (rotation + (deltaTime * 40)) % 360 
            gradient.Rotation = rotation
        end)
    end)
    return gradient
end

-- === FLAWLESS EXCLUSIVE TOUCH, DRAG, AND CLICK ENGINE ===
local activeDrag = nil

local function makeInteractive(frame, trigger, isDraggable, onClick)
    if not isDraggable then
        trigger.MouseButton1Click:Connect(function()
            if onClick then onClick() end
        end)
        return
    end

    local dragging = false
    local hasMoved = false
    local dragStart, startPos, dragInput

    trigger.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            hasMoved = false 
            
            if guiLocked then return end 
            if activeDrag and activeDrag ~= frame then return end 
            
            activeDrag = frame
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            dragInput = input 
        end
    end)

    trigger.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and activeDrag == frame and input == dragInput then
            local delta = input.Position - dragStart
            if delta.Magnitude > 10 then 
                hasMoved = true 
            end
            
            if hasMoved then
                frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if dragging and activeDrag == frame then
                dragging = false
                activeDrag = nil
            end
        end
    end)

    trigger.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if not hasMoved and onClick then
                onClick()
            end
        end
    end)
end

-- Premium Slider Input Engine
local function makeSliderInteractive(sliderTrigger, sliderTrack, sliderFill, label, varKey, maxVal, prefix, minVal)
    local slidingInput = nil
    minVal = minVal or 0

    sliderTrigger.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if slidingInput then return end
            if activeDrag then return end 
            
            slidingInput = input
            
            local relX = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
            AdvancedSettings[varKey] = math.floor(minVal + relX * (maxVal - minVal))
            TweenService:Create(sliderFill, TWEEN_INFO, {Size = UDim2.new(relX, 0, 1, 0)}):Play()
            label.Text = prefix .. AdvancedSettings[varKey]
            
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    slidingInput = nil
                    connection:Disconnect()
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == slidingInput then
            local relX = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
            AdvancedSettings[varKey] = math.floor(minVal + relX * (maxVal - minVal))
            sliderFill.Size = UDim2.new(relX, 0, 1, 0) -- Direct update for responsiveness while dragging
            label.Text = prefix .. AdvancedSettings[varKey]
        end
    end)
end

local function createStyledFrame(name, size, pos, accentColor, parent)
    local frame = Instance.new("Frame", parent or screenGui)
    frame.Name = name
    frame.Size = size
    frame.Position = pos
    frame.BackgroundColor3 = BG_DEEP
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
    
    -- Subsurface gradient for glass depth
    local bgGrad = Instance.new("UIGradient", frame)
    bgGrad.Rotation = 90
    bgGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 35)), 
        ColorSequenceKeypoint.new(1, BG_DEEP)
    })
    
    local stroke = Instance.new("UIStroke", frame)
    stroke.Thickness = 2 
    stroke.Color = Color3.new(1, 1, 1)
    applyShinyGradient(stroke, accentColor or PRIMARY_ACCENT, SECONDARY_ACCENT)
    
    return frame, stroke
end

-- ==========================================
-- ========== UI ELEMENT BUILDER ============
-- ==========================================

-- [1] MAIN HEADER MENU
local mainHeader, mainHeaderStroke = createStyledFrame("MainHeader", UDim2.new(0, 180, 0, 85), UDim2.new(0.5, -90, 0, 60), PRIMARY_ACCENT)
local headerTitle = Instance.new("TextLabel", mainHeader)
headerTitle.Size = UDim2.new(1, 0, 0, 35); headerTitle.Position = UDim2.new(0, 0, 0, 5)
headerTitle.Text = "S4DUELS"; headerTitle.TextColor3 = TEXT_MAIN; headerTitle.Font = Enum.Font.GothamBlack; headerTitle.TextSize = 22; headerTitle.BackgroundTransparency = 1
applyShinyGradient(Instance.new("UIStroke", headerTitle), PRIMARY_ACCENT, SECONDARY_ACCENT)

local statsLabel = Instance.new("TextLabel", mainHeader)
statsLabel.Size = UDim2.new(1, 0, 0, 20); statsLabel.Position = UDim2.new(0, 0, 0, 35)
statsLabel.Text = "FPS: -- | PING: --ms"; statsLabel.TextColor3 = Color3.fromRGB(160, 160, 175); statsLabel.Font = Enum.Font.GothamSemibold; statsLabel.TextSize = 10; statsLabel.BackgroundTransparency = 1

local openSettingsBtn = Instance.new("TextButton", mainHeader)
openSettingsBtn.Size = UDim2.new(0, 120, 0, 26); openSettingsBtn.Position = UDim2.new(0.5, -60, 1, 6)
openSettingsBtn.Text = "LAUNCH HUB"; openSettingsBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 30); openSettingsBtn.TextColor3 = TEXT_MAIN; openSettingsBtn.Font = Enum.Font.GothamBold; openSettingsBtn.TextSize = 11
Instance.new("UICorner", openSettingsBtn).CornerRadius = UDim.new(0, 6)
local osbStroke = Instance.new("UIStroke", openSettingsBtn); osbStroke.Thickness = 1.5; osbStroke.Color = PRIMARY_ACCENT

-- [2] STATIC LOCK BUTTON
local lockFrame, lockStroke = createStyledFrame("LockGUI", UDim2.new(0, 85, 0, 35), UDim2.new(0.5, -235, 0, 35), SECONDARY_ACCENT)
local lockBtn = Instance.new("TextButton", lockFrame)
lockBtn.Size = UDim2.new(1, 0, 1, 0); lockBtn.BackgroundTransparency = 1
lockBtn.Text = "UNLOCK"; lockBtn.TextColor3 = TEXT_MAIN; lockBtn.Font = Enum.Font.GothamBold; lockBtn.TextSize = 11

-- [3] TOP-LEFT RETURN BUTTON 
local returnFrame, returnStroke = createStyledFrame("ReturnHUB", UDim2.new(0, 120, 0, 42), UDim2.new(0, 15, 0, 15), SECONDARY_ACCENT)
local returnBtn = Instance.new("TextButton", returnFrame)
returnBtn.Size = UDim2.new(1, 0, 1, 0); returnBtn.BackgroundTransparency = 1
returnBtn.Text = "S4HUB"; returnBtn.TextColor3 = TEXT_MAIN; returnBtn.Font = Enum.Font.GothamBlack; returnBtn.TextSize = 14
returnFrame.Visible = false

-- [4] S4HUB MAIN SETTINGS MENU
local hubMenu, hubMenuStroke = createStyledFrame("S4HUB_Menu", UDim2.new(0, 340, 0, 340), UDim2.new(0.5, -170, 0.5, -170), PRIMARY_ACCENT)
hubMenu.Visible = false

local hubTitle = Instance.new("TextLabel", hubMenu)
hubTitle.Size = UDim2.new(1, 0, 0, 45); hubTitle.Position = UDim2.new(0, 0, 0, 5)
hubTitle.Text = "S4HUB ELITE"; hubTitle.TextColor3 = TEXT_MAIN; hubTitle.Font = Enum.Font.GothamBlack; hubTitle.TextSize = 24; hubTitle.BackgroundTransparency = 1
applyShinyGradient(Instance.new("UIStroke", hubTitle), PRIMARY_ACCENT, SECONDARY_ACCENT)

local titleSeparator = Instance.new("Frame", hubMenu)
titleSeparator.Size = UDim2.new(0.9, 0, 0, 1); titleSeparator.Position = UDim2.new(0.05, 0, 0, 45)
titleSeparator.BackgroundColor3 = Color3.new(1,1,1); titleSeparator.BorderSizePixel = 0
applyShinyGradient(Instance.new("UIGradient", titleSeparator), PRIMARY_ACCENT, Color3.new(0,0,0))

local closeHubBtn = Instance.new("TextButton", hubMenu)
closeHubBtn.Size = UDim2.new(0, 26, 0, 26); closeHubBtn.Position = UDim2.new(1, -36, 0, 10)
closeHubBtn.Text = "X"; closeHubBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 25); closeHubBtn.TextColor3 = TEXT_MAIN; closeHubBtn.Font = Enum.Font.GothamBlack; closeHubBtn.TextSize = 13
Instance.new("UICorner", closeHubBtn).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", closeHubBtn).Color = Color3.fromRGB(255, 60, 80)

-- === TAB SYSTEM WITH PREMIUM OUTLINES ===
local tabContainer = Instance.new("Frame", hubMenu)
tabContainer.Size = UDim2.new(1, -30, 0, 34)
tabContainer.Position = UDim2.new(0, 15, 0, 55)
tabContainer.BackgroundTransparency = 1

local s4duelsTab = Instance.new("TextButton", tabContainer)
s4duelsTab.Size = UDim2.new(0.48, 0, 1, 0); s4duelsTab.Position = UDim2.new(0, 0, 0, 0)
s4duelsTab.BackgroundColor3 = Color3.fromRGB(20, 20, 30); s4duelsTab.BackgroundTransparency = 0.2
Instance.new("UICorner", s4duelsTab).CornerRadius = UDim.new(0, 6)
s4duelsTab.Text = "S4DUELS"; s4duelsTab.Font = Enum.Font.GothamBold; s4duelsTab.TextSize = 13
local s4TabStroke = Instance.new("UIStroke", s4duelsTab)
s4TabStroke.Thickness = 1.5; s4TabStroke.Color = SECONDARY_ACCENT

local serverTab = Instance.new("TextButton", tabContainer)
serverTab.Size = UDim2.new(0.48, 0, 1, 0); serverTab.Position = UDim2.new(0.52, 0, 0, 0)
serverTab.BackgroundColor3 = Color3.fromRGB(20, 20, 30); serverTab.BackgroundTransparency = 0.2
Instance.new("UICorner", serverTab).CornerRadius = UDim.new(0, 6)
serverTab.Text = "SERVER"; serverTab.Font = Enum.Font.GothamBold; serverTab.TextSize = 13
local serverTabStroke = Instance.new("UIStroke", serverTab)
serverTabStroke.Thickness = 1.5; serverTabStroke.Color = Color3.fromRGB(80, 80, 90)

local s4duelsScroll = Instance.new("ScrollingFrame", hubMenu)
s4duelsScroll.Size = UDim2.new(1, -20, 1, -145); s4duelsScroll.Position = UDim2.new(0, 10, 0, 95)
s4duelsScroll.BackgroundTransparency = 1; s4duelsScroll.CanvasSize = UDim2.new(0, 0, 1.4, 0); s4duelsScroll.ScrollBarThickness = 4; s4duelsScroll.ScrollBarImageColor3 = PRIMARY_ACCENT
local s4Layout = Instance.new("UIGridLayout", s4duelsScroll)
s4Layout.CellSize = UDim2.new(0.48, 0, 0, 38); s4Layout.CellPadding = UDim2.new(0, 8, 0, 10)
Instance.new("UIPadding", s4duelsScroll).PaddingLeft = UDim.new(0, 5)

local serverScroll = Instance.new("ScrollingFrame", hubMenu)
serverScroll.Size = UDim2.new(1, -20, 1, -145); serverScroll.Position = UDim2.new(0, 10, 0, 95)
serverScroll.BackgroundTransparency = 1; serverScroll.CanvasSize = UDim2.new(0, 0, 1, 0); serverScroll.ScrollBarThickness = 4; serverScroll.ScrollBarImageColor3 = PRIMARY_ACCENT
serverScroll.Visible = false
local serverLayout = Instance.new("UIGridLayout", serverScroll)
serverLayout.CellSize = UDim2.new(0.48, 0, 0, 38); serverLayout.CellPadding = UDim2.new(0, 8, 0, 10)
Instance.new("UIPadding", serverScroll).PaddingLeft = UDim.new(0, 5)

local function switchTab(tabName)
    if tabName == "S4DUELS" then
        s4duelsScroll.Visible = true; serverScroll.Visible = false
        TweenService:Create(s4duelsTab, TWEEN_INFO, {TextColor3 = SECONDARY_ACCENT}):Play()
        TweenService:Create(serverTab, TWEEN_INFO, {TextColor3 = Color3.fromRGB(150, 150, 160)}):Play()
        TweenService:Create(s4TabStroke, TWEEN_INFO, {Color = SECONDARY_ACCENT}):Play()
        TweenService:Create(serverTabStroke, TWEEN_INFO, {Color = Color3.fromRGB(80, 80, 90)}):Play()
    else
        s4duelsScroll.Visible = false; serverScroll.Visible = true
        TweenService:Create(s4duelsTab, TWEEN_INFO, {TextColor3 = Color3.fromRGB(150, 150, 160)}):Play()
        TweenService:Create(serverTab, TWEEN_INFO, {TextColor3 = SECONDARY_ACCENT}):Play()
        TweenService:Create(s4TabStroke, TWEEN_INFO, {Color = Color3.fromRGB(80, 80, 90)}):Play()
        TweenService:Create(serverTabStroke, TWEEN_INFO, {Color = SECONDARY_ACCENT}):Play()
    end
end
s4duelsTab.MouseButton1Click:Connect(function() switchTab("S4DUELS") end)
serverTab.MouseButton1Click:Connect(function() switchTab("SERVER") end)
switchTab("S4DUELS")

local globalSaveBtn = Instance.new("TextButton", hubMenu)
globalSaveBtn.Size = UDim2.new(0.9, 0, 0, 36); globalSaveBtn.Position = UDim2.new(0.05, 0, 1, -42)
globalSaveBtn.Text = "SAVE SETTINGS"; globalSaveBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 22); globalSaveBtn.TextColor3 = TEXT_MAIN; globalSaveBtn.Font = Enum.Font.GothamBlack; globalSaveBtn.TextSize = 13
Instance.new("UICorner", globalSaveBtn).CornerRadius = UDim.new(0, 8)
local gsbStroke = Instance.new("UIStroke", globalSaveBtn); gsbStroke.Thickness = 2; applyShinyGradient(gsbStroke, SECONDARY_ACCENT, Color3.new(1,1,1))

-- [5] PREMIUM SLIDER MENUS
local function createSettingsMenu(name, width, height, titleText)
    local menu, stroke = createStyledFrame(name, UDim2.new(0, width, 0, height), UDim2.new(0.5, 180, 0.5, -height/2), SECONDARY_ACCENT)
    menu.Visible = false; menu.ZIndex = 50
    
    local title = Instance.new("TextLabel", menu)
    title.Size = UDim2.new(1, 0, 0, 35); title.Position = UDim2.new(0, 0, 0, 5)
    title.Text = titleText; title.TextColor3 = TEXT_MAIN; title.Font = Enum.Font.GothamBlack; title.TextSize = 13; title.BackgroundTransparency = 1; title.ZIndex = 51
    
    local btn = Instance.new("TextButton", menu)
    btn.Size = UDim2.new(0.85, 0, 0, 32); btn.Position = UDim2.new(0.075, 0, 1, -40)
    btn.Text = "APPLY"; btn.BackgroundColor3 = Color3.fromRGB(20, 20, 30); btn.TextColor3 = TEXT_MAIN; btn.Font = Enum.Font.GothamBold; btn.TextSize = 12; btn.ZIndex = 51
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", btn).Color = SECONDARY_ACCENT; Instance.new("UIStroke", btn).Thickness = 1.5
    
    return menu, title, btn
end

local function addPremiumSlider(menu, yPos, labelText, varKey, minVal, maxVal, prefix)
    local label = Instance.new("TextLabel", menu)
    label.Size = UDim2.new(1, 0, 0, 20); label.Position = UDim2.new(0, 0, 0, yPos)
    label.Text = prefix .. AdvancedSettings[varKey]; label.TextColor3 = Color3.fromRGB(200, 200, 210); label.Font = Enum.Font.GothamSemibold; label.TextSize = 11; label.BackgroundTransparency = 1; label.ZIndex = 51
    
    local track = Instance.new("Frame", menu)
    track.Size = UDim2.new(0.85, 0, 0, 8); track.Position = UDim2.new(0.075, 0, 0, yPos + 22)
    track.BackgroundColor3 = Color3.fromRGB(30, 30, 40); track.ZIndex = 51; Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)
    
    local fill = Instance.new("Frame", track)
    fill.Size = UDim2.new((AdvancedSettings[varKey] - minVal) / (maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = SECONDARY_ACCENT; fill.ZIndex = 52; Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    
    local thumb = Instance.new("Frame", fill)
    thumb.Size = UDim2.new(0, 14, 0, 14); thumb.Position = UDim2.new(1, -7, 0.5, -7)
    thumb.BackgroundColor3 = Color3.new(1, 1, 1); thumb.ZIndex = 53; Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)
    
    local trigger = Instance.new("TextButton", track)
    trigger.Size = UDim2.new(1, 0, 2, 0); trigger.Position = UDim2.new(0, 0, -0.5, 0); trigger.BackgroundTransparency = 1; trigger.Text = ""; trigger.ZIndex = 54
    
    makeSliderInteractive(trigger, track, fill, label, varKey, maxVal, prefix, minVal)
end

local speedMenu, speedTitle, confirmSpeedBtn = createSettingsMenu("SpeedMenu", 230, 130, "BAT FUCKER ENGINE")
addPremiumSlider(speedMenu, 40, "TRACKING SPEED: ", "BatSpeed", 0, 70, "TRACKING SPEED: ")
makeInteractive(speedMenu, speedTitle, true, nil)
makeInteractive(confirmSpeedBtn, confirmSpeedBtn, false, function() saveConfigs(); speedMenu.Visible = false end)

local flyMenu, flyTitle, confirmFlyBtn = createSettingsMenu("FlyMenu", 240, 180, "FLIGHT DYNAMICS")
addPremiumSlider(flyMenu, 40, "Fly Speed (0-70): ", "FlySpeed", 0, 70, "Fly Speed (0-70): ")
addPremiumSlider(flyMenu, 90, "Fly Carry Speed (1-30): ", "FlyCarrySpeed", 1, 30, "Fly Carry Speed (1-30): ")
makeInteractive(flyMenu, flyTitle, true, nil)
makeInteractive(confirmFlyBtn, confirmFlyBtn, false, function() saveConfigs(); flyMenu.Visible = false end)

local boosterMenu, boosterTitle, confirmBoosterBtn = createSettingsMenu("BoosterMenu", 240, 180, "S4BOOSTER CONFIG")
addPremiumSlider(boosterMenu, 40, "Walk Speed (0-70): ", "WalkSpeed", 0, 70, "Walk Speed (0-70): ")
addPremiumSlider(boosterMenu, 90, "Carry Speed (0-32): ", "CarrySpeed", 0, 32, "Carry Speed (0-32): ")
makeInteractive(boosterMenu, boosterTitle, true, nil)
makeInteractive(confirmBoosterBtn, confirmBoosterBtn, false, function() saveConfigs(); boosterMenu.Visible = false end)

-- [7] duelfucker HUD
local duelFuckerHUD = Instance.new("Frame", screenGui)
duelFuckerHUD.Size = UDim2.new(1, 0, 1, 0); duelFuckerHUD.BackgroundTransparency = 1; duelFuckerHUD.Visible = false

-- ==========================================
-- ======== CENTRAL STATE SYNCHRONIZER ======
-- ==========================================

local function syncUIState(featureName)
    local isActive = States[featureName]
    local targetColor = isActive and ACTIVE_GLOW or Color3.new(1, 1, 1)
    
    if ButtonRegistry[featureName] then
        for _, obj in pairs(ButtonRegistry[featureName]) do
            TweenService:Create(obj.stroke, TWEEN_INFO, {Color = targetColor}):Play()
            if isActive then
                TweenService:Create(obj.bg, TWEEN_INFO, {BackgroundColor3 = Color3.fromRGB(30, 35, 45)}):Play()
            else
                TweenService:Create(obj.bg, TWEEN_INFO, {BackgroundColor3 = BG_DEEP}):Play()
            end
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
    local isDraggable = false

    if parent == s4duelsScroll or parent == serverScroll then
        frame = Instance.new("Frame", parent)
        frame.BackgroundColor3 = BG_DEEP; frame.BorderSizePixel = 0
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
        stroke = Instance.new("UIStroke", frame); stroke.Thickness = 1.5; stroke.Color = Color3.new(1,1,1)
    else
        frame, stroke = createStyledFrame(text.."_duelfucker", UDim2.new(0, 135, 0, 44), position, PRIMARY_ACCENT, parent)
        isDraggable = true
    end

    local actionBtn = Instance.new("TextButton", frame)
    actionBtn.Size = UDim2.new(1, 0, 1, 0); actionBtn.BackgroundTransparency = 1
    actionBtn.Text = text; actionBtn.TextColor3 = TEXT_MAIN; actionBtn.Font = Enum.Font.GothamBold; actionBtn.TextSize = 11

    if text == "Bat Fucker" then
        local gearIcon = Instance.new("TextButton", frame)
        gearIcon.Size = UDim2.new(0, 26, 0, 26); gearIcon.Position = UDim2.new(1, -28, 0.5, -13)
        gearIcon.Text = "⚙️"; gearIcon.BackgroundTransparency = 1; gearIcon.TextColor3 = Color3.new(1, 1, 1); gearIcon.TextSize = 15; gearIcon.ZIndex = 5
        makeInteractive(gearIcon, gearIcon, false, function() speedMenu.Visible = not speedMenu.Visible end)
    elseif text == "Fly" then
        local gearIcon = Instance.new("TextButton", frame)
        gearIcon.Size = UDim2.new(0, 26, 0, 26); gearIcon.Position = UDim2.new(1, -28, 0.5, -13)
        gearIcon.Text = "⚙️"; gearIcon.BackgroundTransparency = 1; gearIcon.TextColor3 = Color3.new(1, 1, 1); gearIcon.TextSize = 15; gearIcon.ZIndex = 5
        makeInteractive(gearIcon, gearIcon, false, function() flyMenu.Visible = not flyMenu.Visible end)
    elseif text == "S4BOOSTER" then
        local gearIcon = Instance.new("TextButton", frame)
        gearIcon.Size = UDim2.new(0, 26, 0, 26); gearIcon.Position = UDim2.new(1, -28, 0.5, -13)
        gearIcon.Text = "⚙️"; gearIcon.BackgroundTransparency = 1; gearIcon.TextColor3 = Color3.new(1, 1, 1); gearIcon.TextSize = 15; gearIcon.ZIndex = 5
        makeInteractive(gearIcon, gearIcon, false, function() boosterMenu.Visible = not boosterMenu.Visible end)
    end

    FeatureCallbacks[text] = callback

    makeInteractive(frame, actionBtn, isDraggable, function()
        if isToggle then
            local newState = toggleFeature(text)
            if callback then callback(newState) end
        else
            task.spawn(function()
                TweenService:Create(stroke, TweenInfo.new(0.1), {Color = SECONDARY_ACCENT}):Play()
                task.wait(0.15)
                TweenService:Create(stroke, TweenInfo.new(0.2), {Color = Color3.new(1, 1, 1)}):Play()
            end)
            if callback then callback() end
        end
    end)

    if not ButtonRegistry[text] then ButtonRegistry[text] = {} end
    table.insert(ButtonRegistry[text], {stroke = stroke, bg = frame})
    return frame
end

-- ==========================================
-- ========== FEATURE LOGIC & PHYSICS =======
-- ==========================================

local function handleBoosterToggle(state)
    if state then
        -- Manual Override: Turning S4BOOSTER ON resets a stuck Carry Speed
        InternalCarryState = false
    end
    if not state and Player.Character and Player.Character:FindFirstChild("Humanoid") then
        Player.Character.Humanoid.WalkSpeed = 16
    end
end

-- Reset on Death
Player.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid").Died:Connect(function()
        States["Bat Fucker"] = false
        States["Fly"] = false
        syncUIState("Bat Fucker")
        syncUIState("Fly")
    end)
end)

-- === DIRECT O(1) INSTANT STEAL AURA ENGINE ===
local cachedPrompts = {}

local function isTargetPrompt(prompt)
    local actionText = tostring(prompt.ActionText)
    -- DIRECT STRING MATCHING: O(1) Efficiency. Zero Lag. 
    if actionText == "Steal" or actionText == "Rob" or actionText == "Collect" then
        return true
    end
    return false
end

for _, obj in pairs(workspace:GetDescendants()) do
    if obj:IsA("ProximityPrompt") then
        table.insert(cachedPrompts, obj)
    end
end

workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("ProximityPrompt") then
        table.insert(cachedPrompts, obj)
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        if States["Instant Steal"] and Player.Character then
            local hrp = Player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                for i = #cachedPrompts, 1, -1 do
                    local prompt = cachedPrompts[i]
                    if not prompt or not prompt.Parent then
                        table.remove(cachedPrompts, i)
                    elseif prompt.Enabled and isTargetPrompt(prompt) then 
                        local part = prompt.Parent
                        
                        prompt.RequiresLineOfSight = false
                        prompt.HoldDuration = 0 
                        
                        local promptPos = nil
                        if part:IsA("BasePart") then
                            promptPos = part.Position
                        elseif part:IsA("Attachment") then
                            promptPos = part.WorldPosition
                        elseif part:IsA("Model") and part.PrimaryPart then
                            promptPos = part.PrimaryPart.Position
                        elseif part:IsA("Model") then
                            promptPos = part:GetPivot().Position
                        end
                        
                        if promptPos then
                            local distance = (promptPos - hrp.Position).Magnitude
                            if distance <= prompt.MaxActivationDistance + 5 then
                                
                                local isStealing = prompt:GetAttribute("S4_Stealing")
                                if not isStealing then
                                    prompt:SetAttribute("S4_Stealing", true)
                                    task.spawn(function()
                                        pcall(function()
                                            if type(fireproximityprompt) == "function" then
                                                fireproximityprompt(prompt, 1)
                                                fireproximityprompt(prompt, 0)
                                            end
                                            
                                            prompt:InputHoldBegin()
                                            task.wait(0.15) 
                                            prompt:InputHoldEnd()
                                        end)
                                        task.wait(0.3)
                                        if prompt then prompt:SetAttribute("S4_Stealing", nil) end
                                    end)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

local function applyFPSBoost()
    local Lighting = game:GetService("Lighting")
    local Workspace = game:GetService("Workspace")
    local Terrain = Workspace:FindFirstChildOfClass("Terrain")

    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.ShadowSoftness = 0
    if sethiddenproperty then
        pcall(function() sethiddenproperty(Lighting, "Technology", Enum.Technology.Compatibility) end)
    end
    
    for _, v in pairs(Lighting:GetDescendants()) do
        if v:IsA("PostEffect") or v:IsA("Atmosphere") then v:Destroy() end
    end

    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and not v:IsA("Terrain") then
            v.Material = Enum.Material.SmoothPlastic
            v.Reflectance = 0
            v.CastShadow = false
        elseif v:IsA("Decal") or v:IsA("Texture") then
            v.Transparency = 1
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v.Lifetime = NumberRange.new(0)
        elseif v:IsA("Explosion") then
            v.Visible = false
        elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") or v:IsA("Sparkles") then
            v.Enabled = false
        elseif v:IsA("MeshPart") then
            v.Material = Enum.Material.SmoothPlastic
            v.Reflectance = 0
            v.CastShadow = false
        end
    end

    if Terrain then
        Terrain.WaterWaveSize = 0; Terrain.WaterWaveSpeed = 0
        Terrain.WaterReflectance = 0; Terrain.WaterTransparency = 0
        Terrain.Decoration = false
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
                txt.TextSize = 13
                txt.TextStrokeTransparency = 0
            end
        end
    end
end

local function applyUnwalk(state)
    local char = Player.Character
    if char then
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
end

-- === MOBILE & PC SAFE INFINITE JUMP ===
UserInputService.JumpRequest:Connect(function()
    if States["Inf Jump"] and Player.Character then
        local hrp = Player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 50, hrp.AssemblyLinearVelocity.Z)
        end
    end
end)

-- ==========================================
-- ========== MENU & BUTTON POPULATION ======
-- ==========================================

local function activateDuelFuckerMode(state)
    States["duelfucker"] = state
    duelFuckerHUD.Visible = state
    returnFrame.Visible = state
    mainHeader.Visible = not state
    hubMenu.Visible = false
    syncUIState("duelfucker")
end

-- [TAB 1: S4DUELS COMBAT/MOVEMENT]
createSyncedButton("duelfucker", true, s4duelsScroll, nil, activateDuelFuckerMode)
createSyncedButton("Bat Fucker", true, s4duelsScroll, nil, nil)
createSyncedButton("Fly", true, s4duelsScroll, nil, nil)
createSyncedButton("S4BOOSTER", true, s4duelsScroll, nil, handleBoosterToggle)
createSyncedButton("Instant Steal", true, s4duelsScroll, nil, nil) 
createSyncedButton("Inf Jump", true, s4duelsScroll, nil, nil)
createSyncedButton("Unwalk", true, s4duelsScroll, nil, applyUnwalk)
createSyncedButton("FPS Booster", false, s4duelsScroll, nil, applyFPSBoost)
createSyncedButton("Taunt", false, s4duelsScroll, nil, function()
    if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        local channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
        if channel then channel:SendAsync("S4DUELS ON TOP") end
    else
        local rme = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
        if rme and rme:FindFirstChild("SayMessageRequest") then rme.SayMessageRequest:FireServer("S4DUELS ON TOP", "All") end
    end
end)

-- [TAB 2: SERVER UTILITIES]
createSyncedButton("ESP", true, serverScroll, nil, nil)
createSyncedButton("Rejoin", false, serverScroll, nil, function() TeleportService:Teleport(game.PlaceId, Player) end)
createSyncedButton("Server Hop", false, serverScroll, nil, function() TeleportService:Teleport(game.PlaceId) end)
createSyncedButton("Kick Self", false, serverScroll, nil, function() Player:Kick("S4DUELS Manual Disconnect") end)

-- [POPULATE duelfucker HUD]
createSyncedButton("Bat Fucker", true, duelFuckerHUD, UDim2.new(0.05, 0, 0.3, 0), nil)
createSyncedButton("S4BOOSTER", true, duelFuckerHUD, UDim2.new(0.05, 0, 0.4, 0), handleBoosterToggle)
createSyncedButton("ESP", true, duelFuckerHUD, UDim2.new(0.05, 0, 0.5, 0), nil)
createSyncedButton("Fly", true, duelFuckerHUD, UDim2.new(0.45, 0, 0.3, 0), nil)
createSyncedButton("Inf Jump", true, duelFuckerHUD, UDim2.new(0.85, 0, 0.3, 0), nil)
createSyncedButton("Unwalk", true, duelFuckerHUD, UDim2.new(0.85, 0, 0.4, 0), applyUnwalk)
createSyncedButton("Instant Steal", true, duelFuckerHUD, UDim2.new(0.85, 0, 0.5, 0), nil)

-- ==========================================
-- ========== BINDINGS & SETUP ==============
-- ==========================================

makeInteractive(lockFrame, lockBtn, false, function()
    guiLocked = not guiLocked
    lockBtn.Text = guiLocked and "LOCKED" or "UNLOCK"
    TweenService:Create(lockStroke, TWEEN_INFO, {Color = guiLocked and Color3.fromRGB(255, 50, 80) or SECONDARY_ACCENT}):Play()
end)

makeInteractive(returnFrame, returnBtn, true, function() activateDuelFuckerMode(false) end)
makeInteractive(mainHeader, headerTitle, true, nil)
makeInteractive(openSettingsBtn, openSettingsBtn, false, function() hubMenu.Visible = not hubMenu.Visible end)
makeInteractive(hubMenu, hubTitle, true, nil)
makeInteractive(closeHubBtn, closeHubBtn, false, function() hubMenu.Visible = false end)
makeInteractive(globalSaveBtn, globalSaveBtn, false, saveConfigs)

-- ==========================================
-- ========== HEARTBEAT PHYSICS ENGINE ======
-- ==========================================
local function safeFlightCleanup(char)
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if hrp then
        local att = hrp:FindFirstChild("StealthAtt")
        local lv = hrp:FindFirstChild("StealthLV")
        local ao = hrp:FindFirstChild("StealthAO")
        if att then att:Destroy() end
        if lv then lv:Destroy() end
        if ao then ao:Destroy() end
    end
    if hum then
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
    end
end

RunService.Heartbeat:Connect(function(deltaTime)
    local char = Player.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        
        if hum and hrp then

            -- FLIGHT ENGINES PRIORITY: Bat Fucker -> Fly -> S4BOOSTER
            if States["Bat Fucker"] then
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                
                if hum:GetState() ~= Enum.HumanoidStateType.Freefall then
                    hum:ChangeState(Enum.HumanoidStateType.Freefall)
                end
                
                local targetHrp = nil
                local shortestDist = math.huge

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

                if targetHrp then
                    local targetPos = targetHrp.Position
                    local predictedPos = targetPos + (targetHrp.AssemblyLinearVelocity * 0.1)
                    local direction = (predictedPos - hrp.Position).Unit
                    local distance = (predictedPos - hrp.Position).Magnitude

                    local att = hrp:FindFirstChild("StealthAtt")
                    if not att then
                        att = Instance.new("Attachment")
                        att.Name = "StealthAtt"
                        att.Parent = hrp
                    end
                    
                    local lv = hrp:FindFirstChild("StealthLV")
                    if not lv then
                        lv = Instance.new("LinearVelocity")
                        lv.Name = "StealthLV"
                        lv.Attachment0 = att
                        lv.MaxForce = math.huge
                        lv.Parent = hrp
                    end

                    local ao = hrp:FindFirstChild("StealthAO")
                    if not ao then
                        ao = Instance.new("AlignOrientation")
                        ao.Name = "StealthAO"
                        ao.Mode = Enum.OrientationAlignmentMode.OneAttachment
                        ao.Attachment0 = att
                        ao.RigidityEnabled = true
                        ao.Parent = hrp
                    end
                    
                    local lookAtPos = Vector3.new(targetPos.X, hrp.Position.Y, targetPos.Z)
                    ao.CFrame = CFrame.lookAt(hrp.Position, lookAtPos)

                    if distance > 4 then
                        lv.VectorVelocity = direction * AdvancedSettings.BatSpeed
                    else
                        lv.VectorVelocity = targetHrp.AssemblyLinearVelocity + (direction * 2)
                    end
                else
                    safeFlightCleanup(char)
                end
                
            elseif States["Fly"] then
                -- FREE FLY ENGINE
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                
                if hum:GetState() ~= Enum.HumanoidStateType.Freefall then
                    hum:ChangeState(Enum.HumanoidStateType.Freefall)
                end
                
                local att = hrp:FindFirstChild("StealthAtt")
                if not att then
                    att = Instance.new("Attachment")
                    att.Name = "StealthAtt"
                    att.Parent = hrp
                end
                
                local lv = hrp:FindFirstChild("StealthLV")
                if not lv then
                    lv = Instance.new("LinearVelocity")
                    lv.Name = "StealthLV"
                    lv.Attachment0 = att
                    lv.MaxForce = math.huge
                    lv.Parent = hrp
                end

                local ao = hrp:FindFirstChild("StealthAO")
                if not ao then
                    ao = Instance.new("AlignOrientation")
                    ao.Name = "StealthAO"
                    ao.Mode = Enum.OrientationAlignmentMode.OneAttachment
                    ao.Attachment0 = att
                    ao.RigidityEnabled = true
                    ao.Parent = hrp
                end
                
                local cam = workspace.CurrentCamera
                ao.CFrame = cam.CFrame

                local moveDir = hum.MoveDirection
                if moveDir.Magnitude > 0 then
                    local flatLook = Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z)
                    if flatLook.Magnitude > 0 then 
                        flatLook = flatLook.Unit 
                    else 
                        flatLook = Vector3.new(0, 0, 1) 
                    end
                    
                    local forwardMag = moveDir:Dot(flatLook)
                    local rightMag = moveDir:Dot(cam.CFrame.RightVector)
                    
                    local flyDir = (cam.CFrame.LookVector * forwardMag + cam.CFrame.RightVector * rightMag)
                    if flyDir.Magnitude > 0 then 
                        flyDir = flyDir.Unit 
                    end
                    
                    -- NATIVE FLY CARRY DETECTION
                    local targetSpeed = AdvancedSettings.FlySpeed
                    if Player:GetAttribute("Stealing") then
                        targetSpeed = AdvancedSettings.FlyCarrySpeed
                    end
                    
                    lv.VectorVelocity = flyDir * targetSpeed
                else
                    lv.VectorVelocity = Vector3.new(0, 0, 0)
                end
                
            else
                safeFlightCleanup(char)

                -- S4BOOSTER (NATIVE CARRY DETECTION)
                if States["S4BOOSTER"] and hum.MoveDirection.Magnitude > 0 then
                    
                    local targetSpeed = AdvancedSettings.WalkSpeed
                    
                    -- The game natively adds the "Stealing" attribute to your Player when carrying the brainrot
                    if Player:GetAttribute("Stealing") then
                        targetSpeed = AdvancedSettings.CarrySpeed
                    end
                    
                    local velocityDir = hum.MoveDirection * targetSpeed
                    hrp.AssemblyLinearVelocity = Vector3.new(velocityDir.X, hrp.AssemblyLinearVelocity.Y, velocityDir.Z)
                end
            end
        end
    end
end)

-- ==========================================
-- ======== RENDERSTEPPED UI ENGINE =========
-- ==========================================
local lastFpsUpdate = 0
local frameCount = 0

RunService.RenderStepped:Connect(function(deltaTime)
    frameCount = frameCount + 1
    if tick() - lastFpsUpdate >= 0.5 then
        local fps = math.floor(frameCount / (tick() - lastFpsUpdate))
        local ping = math.floor(Player:GetNetworkPing() * 1000)
        statsLabel.Text = string.format("FPS: %d | PING: %dms", fps, ping)
        frameCount = 0
        lastFpsUpdate = tick()
    end

    runESP()
end)

-- Execute Initialization
loadConfigs()

for feature, state in pairs(States) do
    syncUIState(feature)
    if state and FeatureCallbacks[feature] then
        task.spawn(FeatureCallbacks[feature], state)
    end
end
