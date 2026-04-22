-- [[ S4DUELS: ULTIMATE BRAINROT ELITE EDITION ]] --
-- [[ PREMIUM TRANSLUCENT GUI, FLAWLESS FLIGHT, INSTANT STEAL ]] --

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local StarterGui = game:GetService("StarterGui")

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
    BatSpeed = 56, 
    WalkSpeed = 56, 
    CarrySpeed = 30 -- Max safely set to 32 via sliders
}
local States = {
    ["Bat Fucker"] = false,
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

-- === PREMIUM THEME COLORS ===
local SHINY_PURPLE = Color3.fromRGB(180, 100, 255)
local NEON_BLUE = Color3.fromRGB(0, 200, 255)
local ACTIVE_GREEN = Color3.fromRGB(50, 255, 150)
local BG_COLOR = Color3.fromRGB(15, 15, 20)
local ESP_COLOR = Color3.fromRGB(255, 50, 50)

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
        Title = "S4DUELS",
        Text = "Premium UI Successfully Loaded!",
        Duration = 5
    })
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
    
    task.spawn(function()
        local rotation = 0
        RunService.RenderStepped:Connect(function(deltaTime)
            rotation = (rotation + (deltaTime * 50)) % 360 
            gradient.Rotation = rotation
        end)
    end)
end

-- === FLAWLESS TOUCH, DRAG, AND CLICK ENGINE ===
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
            if guiLocked then return end 
            
            dragging = true
            hasMoved = false
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
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            if delta.Magnitude > 15 then 
                hasMoved = true 
            end
            
            if hasMoved then
                frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end
    end)

    trigger.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            if not hasMoved and onClick then
                onClick()
            end
        end
    end)
end

-- Slider Input Engine
local function makeSliderInteractive(sliderTrigger, sliderTrack, sliderFill, label, varKey, maxVal, prefix)
    local slidingInput = nil

    sliderTrigger.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if slidingInput then return end
            slidingInput = input
            
            local relX = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
            AdvancedSettings[varKey] = math.floor(relX * maxVal)
            sliderFill.Size = UDim2.new(relX, 0, 1, 0)
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
            AdvancedSettings[varKey] = math.floor(relX * maxVal)
            sliderFill.Size = UDim2.new(relX, 0, 1, 0)
            label.Text = prefix .. AdvancedSettings[varKey]
        end
    end)
end

local function createStyledFrame(name, size, pos, accentColor, parent)
    local frame = Instance.new("Frame", parent or screenGui)
    frame.Name = name
    frame.Size = size
    frame.Position = pos
    frame.BackgroundColor3 = BG_COLOR
    frame.BackgroundTransparency = 0.60 
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    
    local stroke = Instance.new("UIStroke", frame)
    stroke.Thickness = 1.5 
    stroke.Color = Color3.new(1, 1, 1)
    applyShinyGradient(stroke, accentColor or SHINY_PURPLE, Color3.new(1, 1, 1))
    
    return frame, stroke
end

-- ==========================================
-- ========== UI ELEMENT BUILDER ============
-- ==========================================

-- [1] MAIN HEADER MENU
local mainHeader, mainHeaderStroke = createStyledFrame("MainHeader", UDim2.new(0, 170, 0, 85), UDim2.new(0.5, -85, 0, 60), SHINY_PURPLE)
local headerTitle = Instance.new("TextLabel", mainHeader)
headerTitle.Size = UDim2.new(1, 0, 0, 35); headerTitle.Position = UDim2.new(0, 0, 0, 5)
headerTitle.Text = "S4DUELS"; headerTitle.TextColor3 = Color3.new(1, 1, 1); headerTitle.Font = Enum.Font.GothamBold; headerTitle.TextSize = 22; headerTitle.BackgroundTransparency = 1
applyShinyGradient(Instance.new("UIStroke", headerTitle), SHINY_PURPLE, Color3.new(1, 1, 1))

local statsLabel = Instance.new("TextLabel", mainHeader)
statsLabel.Size = UDim2.new(1, 0, 0, 20); statsLabel.Position = UDim2.new(0, 0, 0, 35)
statsLabel.Text = "FPS: -- | PING: --ms"; statsLabel.TextColor3 = Color3.new(0.85, 0.85, 0.85); statsLabel.Font = Enum.Font.GothamSemibold; statsLabel.TextSize = 10; statsLabel.BackgroundTransparency = 1

local openSettingsBtn = Instance.new("TextButton", mainHeader)
openSettingsBtn.Size = UDim2.new(0, 110, 0, 25); openSettingsBtn.Position = UDim2.new(0.5, -55, 1, 5)
openSettingsBtn.Text = "S4HUB"; openSettingsBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 30); openSettingsBtn.BackgroundTransparency = 0.5; openSettingsBtn.TextColor3 = Color3.new(1, 1, 1); openSettingsBtn.Font = Enum.Font.GothamBold; openSettingsBtn.TextSize = 11
Instance.new("UICorner", openSettingsBtn).CornerRadius = UDim.new(0, 6)
local osbStroke = Instance.new("UIStroke", openSettingsBtn); osbStroke.Thickness = 1.2; osbStroke.Color = SHINY_PURPLE

-- [2] STATIC LOCK BUTTON
local lockFrame, lockStroke = createStyledFrame("LockGUI", UDim2.new(0, 85, 0, 35), UDim2.new(0.5, -215, 0, 35), NEON_BLUE)
local lockBtn = Instance.new("TextButton", lockFrame)
lockBtn.Size = UDim2.new(1, 0, 1, 0); lockBtn.BackgroundTransparency = 1
lockBtn.Text = "LOCK GUI"; lockBtn.TextColor3 = Color3.new(1, 1, 1); lockBtn.Font = Enum.Font.GothamBold; lockBtn.TextSize = 11

-- [3] TOP-LEFT RETURN BUTTON 
local returnFrame, returnStroke = createStyledFrame("ReturnHUB", UDim2.new(0, 110, 0, 40), UDim2.new(0, 15, 0, 15), NEON_BLUE)
local returnBtn = Instance.new("TextButton", returnFrame)
returnBtn.Size = UDim2.new(1, 0, 1, 0); returnBtn.BackgroundTransparency = 1
returnBtn.Text = "S4HUB"; returnBtn.TextColor3 = Color3.new(1, 1, 1); returnBtn.Font = Enum.Font.GothamBold; returnBtn.TextSize = 14
returnFrame.Visible = false

-- [4] S4HUB MAIN SETTINGS MENU
local hubMenu, hubMenuStroke = createStyledFrame("S4HUB_Menu", UDim2.new(0, 340, 0, 400), UDim2.new(0.5, -170, 0.5, -200), SHINY_PURPLE)
hubMenu.Visible = false

local hubTitle = Instance.new("TextLabel", hubMenu)
hubTitle.Size = UDim2.new(1, 0, 0, 40); hubTitle.Position = UDim2.new(0, 0, 0, 5)
hubTitle.Text = "S4HUB"; hubTitle.TextColor3 = Color3.new(1, 1, 1); hubTitle.Font = Enum.Font.GothamBold; hubTitle.TextSize = 24; hubTitle.BackgroundTransparency = 1
applyShinyGradient(Instance.new("UIStroke", hubTitle), SHINY_PURPLE, Color3.new(1, 1, 1))

local closeHubBtn = Instance.new("TextButton", hubMenu)
closeHubBtn.Size = UDim2.new(0, 24, 0, 24); closeHubBtn.Position = UDim2.new(1, -34, 0, 12)
closeHubBtn.Text = "X"; closeHubBtn.BackgroundColor3 = Color3.fromRGB(40, 15, 15); closeHubBtn.BackgroundTransparency = 0.5; closeHubBtn.TextColor3 = Color3.new(1, 1, 1); closeHubBtn.Font = Enum.Font.GothamBold; closeHubBtn.TextSize = 11
Instance.new("UICorner", closeHubBtn).CornerRadius = UDim.new(0, 6)

-- === TAB SYSTEM ===
local tabContainer = Instance.new("Frame", hubMenu)
tabContainer.Size = UDim2.new(1, -20, 0, 30)
tabContainer.Position = UDim2.new(0, 10, 0, 45)
tabContainer.BackgroundTransparency = 1

local s4duelsTab = Instance.new("TextButton", tabContainer)
s4duelsTab.Size = UDim2.new(0.48, 0, 1, 0); s4duelsTab.Position = UDim2.new(0, 0, 0, 0)
s4duelsTab.BackgroundTransparency = 1; s4duelsTab.Text = "S4DUELS"; s4duelsTab.Font = Enum.Font.GothamBold; s4duelsTab.TextSize = 13

local serverTab = Instance.new("TextButton", tabContainer)
serverTab.Size = UDim2.new(0.48, 0, 1, 0); serverTab.Position = UDim2.new(0.52, 0, 0, 0)
serverTab.BackgroundTransparency = 1; serverTab.Text = "SERVER"; serverTab.Font = Enum.Font.GothamBold; serverTab.TextSize = 13

local s4duelsScroll = Instance.new("ScrollingFrame", hubMenu)
s4duelsScroll.Size = UDim2.new(1, -20, 1, -140); s4duelsScroll.Position = UDim2.new(0, 10, 0, 85)
s4duelsScroll.BackgroundTransparency = 1; s4duelsScroll.CanvasSize = UDim2.new(0, 0, 1.4, 0); s4duelsScroll.ScrollBarThickness = 3; s4duelsScroll.ScrollBarImageColor3 = SHINY_PURPLE
local s4Layout = Instance.new("UIGridLayout", s4duelsScroll)
s4Layout.CellSize = UDim2.new(0.48, 0, 0, 38); s4Layout.CellPadding = UDim2.new(0, 8, 0, 8)
Instance.new("UIPadding", s4duelsScroll).PaddingLeft = UDim.new(0, 2)

local serverScroll = Instance.new("ScrollingFrame", hubMenu)
serverScroll.Size = UDim2.new(1, -20, 1, -140); serverScroll.Position = UDim2.new(0, 10, 0, 85)
serverScroll.BackgroundTransparency = 1; serverScroll.CanvasSize = UDim2.new(0, 0, 1, 0); serverScroll.ScrollBarThickness = 3; serverScroll.ScrollBarImageColor3 = SHINY_PURPLE
serverScroll.Visible = false
local serverLayout = Instance.new("UIGridLayout", serverScroll)
serverLayout.CellSize = UDim2.new(0.48, 0, 0, 38); serverLayout.CellPadding = UDim2.new(0, 8, 0, 8)
Instance.new("UIPadding", serverScroll).PaddingLeft = UDim.new(0, 2)

local function switchTab(tabName)
    if tabName == "S4DUELS" then
        s4duelsScroll.Visible = true; serverScroll.Visible = false
        s4duelsTab.TextColor3 = NEON_BLUE; serverTab.TextColor3 = Color3.fromRGB(120, 120, 130)
    else
        s4duelsScroll.Visible = false; serverScroll.Visible = true
        s4duelsTab.TextColor3 = Color3.fromRGB(120, 120, 130); serverTab.TextColor3 = NEON_BLUE
    end
end
s4duelsTab.MouseButton1Click:Connect(function() switchTab("S4DUELS") end)
serverTab.MouseButton1Click:Connect(function() switchTab("SERVER") end)
switchTab("S4DUELS")

local globalSaveBtn = Instance.new("TextButton", hubMenu)
globalSaveBtn.Size = UDim2.new(0.9, 0, 0, 35); globalSaveBtn.Position = UDim2.new(0.05, 0, 1, -45)
globalSaveBtn.Text = "SAVE SETTINGS (S4HUB)"; globalSaveBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 20); globalSaveBtn.TextColor3 = Color3.new(1, 1, 1); globalSaveBtn.Font = Enum.Font.GothamBold; globalSaveBtn.TextSize = 12
Instance.new("UICorner", globalSaveBtn).CornerRadius = UDim.new(0, 8)
local gsbStroke = Instance.new("UIStroke", globalSaveBtn); gsbStroke.Thickness = 2; applyShinyGradient(gsbStroke, NEON_BLUE, Color3.new(1,1,1))

-- [5] BAT FUCKER SPEED SLIDER MENU
local speedMenu, speedMenuStroke = createStyledFrame("SpeedMenu", UDim2.new(0, 220, 0, 130), UDim2.new(0.5, 190, 0.5, -65), NEON_BLUE)
speedMenu.Visible = false; speedMenu.ZIndex = 50

local speedTitleLabel = Instance.new("TextLabel", speedMenu)
speedTitleLabel.Size = UDim2.new(1, 0, 0, 35); speedTitleLabel.Position = UDim2.new(0, 0, 0, 5)
speedTitleLabel.Text = "TRACKING SPEED: " .. AdvancedSettings.BatSpeed; speedTitleLabel.TextColor3 = Color3.new(1, 1, 1); speedTitleLabel.Font = Enum.Font.GothamBold; speedTitleLabel.TextSize = 12; speedTitleLabel.BackgroundTransparency = 1; speedTitleLabel.ZIndex = 51

local sliderTrack = Instance.new("Frame", speedMenu)
sliderTrack.Size = UDim2.new(0.8, 0, 0, 12); sliderTrack.Position = UDim2.new(0.1, 0, 0.45, 0)
sliderTrack.BackgroundColor3 = Color3.new(0.1, 0.1, 0.15); sliderTrack.BackgroundTransparency = 0.5; sliderTrack.ZIndex = 51; Instance.new("UICorner", sliderTrack)

local sliderFill = Instance.new("Frame", sliderTrack)
sliderFill.Size = UDim2.new(AdvancedSettings.BatSpeed / 70, 0, 1, 0)
sliderFill.BackgroundColor3 = NEON_BLUE; sliderFill.ZIndex = 52; Instance.new("UICorner", sliderFill)

local sliderTrigger = Instance.new("TextButton", sliderTrack)
sliderTrigger.Size = UDim2.new(1, 0, 1, 0); sliderTrigger.BackgroundTransparency = 1; sliderTrigger.Text = ""; sliderTrigger.ZIndex = 53

local confirmSpeedBtn = Instance.new("TextButton", speedMenu)
confirmSpeedBtn.Size = UDim2.new(0.8, 0, 0, 30); confirmSpeedBtn.Position = UDim2.new(0.1, 0, 0.70, 0)
confirmSpeedBtn.Text = "SAVE SPEED"; confirmSpeedBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 20); confirmSpeedBtn.BackgroundTransparency = 0.5; confirmSpeedBtn.TextColor3 = Color3.new(1, 1, 1); confirmSpeedBtn.Font = Enum.Font.GothamBold; confirmSpeedBtn.TextSize = 11; confirmSpeedBtn.ZIndex = 51
Instance.new("UICorner", confirmSpeedBtn).CornerRadius = UDim.new(0, 6)
local csbStroke = Instance.new("UIStroke", confirmSpeedBtn); csbStroke.Thickness = 1.2; csbStroke.Color = NEON_BLUE

-- [6] S4BOOSTER SPEED SETTINGS MENU
local boosterMenu, boosterMenuStroke = createStyledFrame("BoosterMenu", UDim2.new(0, 240, 0, 190), UDim2.new(0.5, 190, 0.5, 0), NEON_BLUE)
boosterMenu.Visible = false; boosterMenu.ZIndex = 50

local boosterTitle = Instance.new("TextLabel", boosterMenu)
boosterTitle.Size = UDim2.new(1, 0, 0, 30); boosterTitle.Position = UDim2.new(0, 0, 0, 5)
boosterTitle.Text = "S4BOOSTER CONFIG"; boosterTitle.TextColor3 = Color3.new(1, 1, 1); boosterTitle.Font = Enum.Font.GothamBold; boosterTitle.TextSize = 14; boosterTitle.BackgroundTransparency = 1; boosterTitle.ZIndex = 51

local wSpeedLabel = Instance.new("TextLabel", boosterMenu)
wSpeedLabel.Size = UDim2.new(1, 0, 0, 20); wSpeedLabel.Position = UDim2.new(0, 0, 0, 35)
wSpeedLabel.Text = "Walk Speed (0-70): " .. AdvancedSettings.WalkSpeed; wSpeedLabel.TextColor3 = Color3.new(0.9, 0.9, 0.9); wSpeedLabel.Font = Enum.Font.GothamSemibold; wSpeedLabel.TextSize = 11; wSpeedLabel.BackgroundTransparency = 1; wSpeedLabel.ZIndex = 51

local wTrack = Instance.new("Frame", boosterMenu)
wTrack.Size = UDim2.new(0.8, 0, 0, 10); wTrack.Position = UDim2.new(0.1, 0, 0.30, 0)
wTrack.BackgroundColor3 = Color3.new(0.1, 0.1, 0.15); wTrack.BackgroundTransparency = 0.5; wTrack.ZIndex = 51; Instance.new("UICorner", wTrack)

local wFill = Instance.new("Frame", wTrack)
wFill.Size = UDim2.new(AdvancedSettings.WalkSpeed / 70, 0, 1, 0)
wFill.BackgroundColor3 = NEON_BLUE; wFill.ZIndex = 52; Instance.new("UICorner", wFill)

local wTrigger = Instance.new("TextButton", wTrack)
wTrigger.Size = UDim2.new(1, 0, 1, 0); wTrigger.BackgroundTransparency = 1; wTrigger.Text = ""; wTrigger.ZIndex = 53

local cSpeedLabel = Instance.new("TextLabel", boosterMenu)
cSpeedLabel.Size = UDim2.new(1, 0, 0, 20); cSpeedLabel.Position = UDim2.new(0, 0, 0, 85)
cSpeedLabel.Text = "Carry Speed (0-32): " .. AdvancedSettings.CarrySpeed; cSpeedLabel.TextColor3 = Color3.new(0.9, 0.9, 0.9); cSpeedLabel.Font = Enum.Font.GothamSemibold; cSpeedLabel.TextSize = 11; cSpeedLabel.BackgroundTransparency = 1; cSpeedLabel.ZIndex = 51

local cTrack = Instance.new("Frame", boosterMenu)
cTrack.Size = UDim2.new(0.8, 0, 0, 10); cTrack.Position = UDim2.new(0.1, 0, 0.55, 0)
cTrack.BackgroundColor3 = Color3.new(0.1, 0.1, 0.15); cTrack.BackgroundTransparency = 0.5; cTrack.ZIndex = 51; Instance.new("UICorner", cTrack)

local cFill = Instance.new("Frame", cTrack)
cFill.Size = UDim2.new(AdvancedSettings.CarrySpeed / 32, 0, 1, 0)
cFill.BackgroundColor3 = NEON_BLUE; cFill.ZIndex = 52; Instance.new("UICorner", cFill)

local cTrigger = Instance.new("TextButton", cTrack)
cTrigger.Size = UDim2.new(1, 0, 1, 0); cTrigger.BackgroundTransparency = 1; cTrigger.Text = ""; cTrigger.ZIndex = 53

local confirmBoosterBtn = Instance.new("TextButton", boosterMenu)
confirmBoosterBtn.Size = UDim2.new(0.8, 0, 0, 32); confirmBoosterBtn.Position = UDim2.new(0.1, 0, 0.78, 0)
confirmBoosterBtn.Text = "SAVE SPEED"; confirmBoosterBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 20); confirmBoosterBtn.BackgroundTransparency = 0.5; confirmBoosterBtn.TextColor3 = Color3.new(1, 1, 1); confirmBoosterBtn.Font = Enum.Font.GothamBold; confirmBoosterBtn.TextSize = 11; confirmBoosterBtn.ZIndex = 51
Instance.new("UICorner", confirmBoosterBtn).CornerRadius = UDim.new(0, 6)
local cbbStroke = Instance.new("UIStroke", confirmBoosterBtn); cbbStroke.Thickness = 1.5; cbbStroke.Color = NEON_BLUE

-- [7] duelfucker HUD (Container for draggable buttons)
local duelFuckerHUD = Instance.new("Frame", screenGui)
duelFuckerHUD.Size = UDim2.new(1, 0, 1, 0); duelFuckerHUD.BackgroundTransparency = 1; duelFuckerHUD.Visible = false

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
    local isDraggable = false

    if parent == s4duelsScroll or parent == serverScroll then
        frame = Instance.new("Frame", parent)
        frame.BackgroundColor3 = BG_COLOR; frame.BackgroundTransparency = 0.60; frame.BorderSizePixel = 0
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
        stroke = Instance.new("UIStroke", frame); stroke.Thickness = 1.5; stroke.Color = Color3.new(1,1,1)
        applyShinyGradient(stroke, SHINY_PURPLE, Color3.new(1, 1, 1))
    else
        frame, stroke = createStyledFrame(text.."_duelfucker", UDim2.new(0, 130, 0, 42), position, SHINY_PURPLE, parent)
        isDraggable = true
    end

    local actionBtn = Instance.new("TextButton", frame)
    actionBtn.Size = UDim2.new(1, 0, 1, 0); actionBtn.BackgroundTransparency = 1
    actionBtn.Text = text; actionBtn.TextColor3 = Color3.new(1, 1, 1); actionBtn.Font = Enum.Font.GothamBold; actionBtn.TextSize = 11

    if text == "Bat Fucker" then
        local gearIcon = Instance.new("TextButton", frame)
        gearIcon.Size = UDim2.new(0, 24, 0, 24); gearIcon.Position = UDim2.new(1, -26, 0.5, -12)
        gearIcon.Text = "⚙️"; gearIcon.BackgroundTransparency = 1; gearIcon.TextColor3 = Color3.new(1, 1, 1); gearIcon.TextSize = 14; gearIcon.ZIndex = 5
        makeInteractive(gearIcon, gearIcon, false, function() speedMenu.Visible = not speedMenu.Visible end)
    end
    
    if text == "S4BOOSTER" then
        local gearIcon = Instance.new("TextButton", frame)
        gearIcon.Size = UDim2.new(0, 24, 0, 24); gearIcon.Position = UDim2.new(1, -26, 0.5, -12)
        gearIcon.Text = "⚙️"; gearIcon.BackgroundTransparency = 1; gearIcon.TextColor3 = Color3.new(1, 1, 1); gearIcon.TextSize = 14; gearIcon.ZIndex = 5
        makeInteractive(gearIcon, gearIcon, false, function() boosterMenu.Visible = not boosterMenu.Visible end)
    end

    FeatureCallbacks[text] = callback

    makeInteractive(frame, actionBtn, isDraggable, function()
        if isToggle then
            local newState = toggleFeature(text)
            if callback then callback(newState) end
        else
            task.spawn(function()
                stroke.Color = Color3.new(1, 1, 1)
                task.wait(0.2)
                stroke.Color = Color3.new(1, 1, 1)
            end)
            if callback then callback() end
        end
    end)

    if not ButtonRegistry[text] then ButtonRegistry[text] = {} end
    table.insert(ButtonRegistry[text], stroke)
    return frame
end

-- ==========================================
-- ========== FEATURE LOGIC & PHYSICS =======
-- ==========================================

-- === INSTANT STEAL (PROXIMITY BYPASS) ===
local function applyInstantSteal(state)
    if state then
        -- Modify all existing prompts instantly
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                obj.HoldDuration = 0
            end
        end
    end
end

-- Hook into Workspace to instantly strip the timer off any newly dropped items
workspace.DescendantAdded:Connect(function(descendant)
    if States["Instant Steal"] and descendant:IsA("ProximityPrompt") then
        descendant.HoldDuration = 0
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

local function handleBoosterToggle(state)
    if not state and Player.Character and Player.Character:FindFirstChild("Humanoid") then
        Player.Character.Humanoid.WalkSpeed = 16
    end
end

local function isCarryingBrainrot()
    local success, isEnabled = pcall(function()
        return StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Backpack)
    end)
    if success and isEnabled == false then return true end
    return false
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
createSyncedButton("S4BOOSTER", true, s4duelsScroll, nil, handleBoosterToggle)
createSyncedButton("Instant Steal", true, s4duelsScroll, nil, applyInstantSteal)
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
createSyncedButton("Instant Steal", true, duelFuckerHUD, UDim2.new(0.85, 0, 0.5, 0), applyInstantSteal)
createSyncedButton("ESP", true, duelFuckerHUD, UDim2.new(0.05, 0, 0.5, 0), nil)
createSyncedButton("Inf Jump", true, duelFuckerHUD, UDim2.new(0.85, 0, 0.3, 0), nil)
createSyncedButton("Unwalk", true, duelFuckerHUD, UDim2.new(0.85, 0, 0.4, 0), applyUnwalk)

-- ==========================================
-- ========== BINDINGS & SETUP ==============
-- ==========================================

makeInteractive(lockFrame, lockBtn, false, function()
    guiLocked = not guiLocked
    lockBtn.Text = guiLocked and "LOCKED" or "LOCK GUI"
    lockStroke.Color = guiLocked and Color3.fromRGB(255, 50, 50) or NEON_BLUE
end)

makeInteractive(returnFrame, returnBtn, true, function() activateDuelFuckerMode(false) end)
makeInteractive(mainHeader, headerTitle, true, nil)
makeInteractive(openSettingsBtn, openSettingsBtn, false, function() hubMenu.Visible = not hubMenu.Visible end)
makeInteractive(hubMenu, hubTitle, true, nil)
makeInteractive(closeHubBtn, closeHubBtn, false, function() hubMenu.Visible = false end)
makeInteractive(globalSaveBtn, globalSaveBtn, false, saveConfigs)

makeSliderInteractive(sliderTrigger, sliderTrack, sliderFill, speedTitleLabel, "BatSpeed", 70, "TRACKING SPEED: ")
makeInteractive(speedMenu, speedTitleLabel, true, nil)
makeInteractive(confirmSpeedBtn, confirmSpeedBtn, false, function() saveConfigs(); speedMenu.Visible = false end)

makeSliderInteractive(wTrigger, wTrack, wFill, wSpeedLabel, "WalkSpeed", 70, "Walk Speed (0-70): ")
makeSliderInteractive(cTrigger, cTrack, cFill, cSpeedLabel, "CarrySpeed", 32, "Carry Speed (0-32): ")
makeInteractive(boosterMenu, boosterTitle, true, nil)
makeInteractive(confirmBoosterBtn, confirmBoosterBtn, false, function() saveConfigs(); boosterMenu.Visible = false end)

-- ==========================================
-- ========== HEARTBEAT PHYSICS ENGINE ======
-- ==========================================
local function safeFlightCleanup(char)
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local att = hrp:FindFirstChild("StealthAtt")
        local lv = hrp:FindFirstChild("StealthLV")
        if att then att:Destroy() end
        if lv then lv:Destroy() end
    end
end

RunService.Heartbeat:Connect(function(deltaTime)
    -- BAT FUCKER (ZERO-FOOTPRINT ANTI-CHEAT BYPASS)
    if States["Bat Fucker"] and Player.Character then
        local hrp = Player.Character:FindFirstChild("HumanoidRootPart")
        local hum = Player.Character:FindFirstChild("Humanoid")
        
        if hrp and hum then
            if hum:GetState() ~= Enum.HumanoidStateType.Physics then
                hum:ChangeState(Enum.HumanoidStateType.Physics)
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
                
                hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(targetPos.X, hrp.Position.Y, targetPos.Z))

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

                if distance > 4 then
                    lv.VectorVelocity = direction * AdvancedSettings.BatSpeed
                else
                    lv.VectorVelocity = targetHrp.AssemblyLinearVelocity + (direction * 2)
                end
            else
                safeFlightCleanup(Player.Character)
            end
        end
    else
        if Player.Character then
            safeFlightCleanup(Player.Character)
        end

        -- S4BOOSTER (LINEAR VELOCITY OVERRIDE)
        if States["S4BOOSTER"] and Player.Character then
            local hum = Player.Character:FindFirstChild("Humanoid")
            local hrp = Player.Character:FindFirstChild("HumanoidRootPart")
            
            if hum and hrp and hum.MoveDirection.Magnitude > 0 then
                local isCarrying = isCarryingBrainrot()
                local targetSpeed = isCarrying and AdvancedSettings.CarrySpeed or AdvancedSettings.WalkSpeed
                
                local velocityDir = hum.MoveDirection * targetSpeed
                hrp.AssemblyLinearVelocity = Vector3.new(velocityDir.X, hrp.AssemblyLinearVelocity.Y, velocityDir.Z)
            end
        end
    end
end)

Player.CharacterAdded:Connect(function(char)
    char.Humanoid.Died:Connect(function()
        States["Bat Fucker"] = false
        syncUIState("Bat Fucker")
        safeFlightCleanup(char)
    end)
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
