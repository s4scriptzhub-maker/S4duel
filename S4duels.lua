-- S4DUELS V6: ELITE PLASMA GLASS FRAMEWORK (CLEAN MASTER)
-- WYNFUSCATE COMPATIBLE | NO MULTILINE STRINGS
-- PART 1: CORE ENGINE, CONFIG, & ROOT GUI

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

while not Player do
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    Player = Players.LocalPlayer
end

-- ==========================================
-- ========== CONFIG & SAVE SYSTEM ==========
-- ==========================================
local ConfigFile = "S4V6_EliteConfig.json"

local Config = {
    BatSpeed = 56,
    FlySpeed = 110,
    FlyCarrySpeed = 29,
    WalkSpeed = 56,
    CarrySpeed = 29,
    AutoDuelSpeed = 56,
    AutoDuelCarrySpeed = 29,
    SpeedBypassEnabled = false,
    BatFuckerMode = "Standard",
    AutoPlayLane = "Right" 
}

local function LoadSettings()
    if isfile and isfile(ConfigFile) then
        local success, data = pcall(function() return HttpService:JSONDecode(readfile(ConfigFile)) end)
        if success and data then
            for k, v in pairs(data) do
                if Config[k] ~= nil then Config[k] = v end
            end
        end
    end
end

local function SaveSettings()
    if writefile then
        pcall(function() writefile(ConfigFile, HttpService:JSONEncode(Config)) end)
    end
end

LoadSettings()

local States = {
    BatFucker = false,
    AimFucker = false,
    Fly = false,
    S4Booster = false,
    InstantSteal = false,
    AutoDuel = false,
    ESP = false,
    AntiRagdoll = false,
    DuelFuckerMode = false,
    Drop = false
}

-- Target Caches
local CurrentAimTarget = nil 
local CachedHoldingTool = false 
local MedusaUsedOnTarget = false
local guiLocked = false
local UIRegistry = {} 
local STROKE_THICKNESS = 1.8

-- ==========================================
-- ========== THEME CONFIGURATION ===========
-- ==========================================
local Theme = {
    Background = Color3.fromRGB(15, 10, 25),      
    PanelBg = Color3.fromRGB(35, 20, 55),         
    BorderNeon = Color3.fromRGB(200, 50, 255),    
    AccentFill = Color3.fromRGB(210, 50, 255),    
    TextWhite = Color3.fromRGB(245, 245, 250),
    TextDim = Color3.fromRGB(170, 150, 190),
    Danger = Color3.fromRGB(255, 50, 70),
    Success = Color3.fromRGB(40, 255, 120),
    InactiveBorder = Color3.fromRGB(70, 40, 90),
    BlueNeon = Color3.fromRGB(0, 240, 255),
    GlassTransparency = 0.55,
    PanelTransparency = 0.4
}

local TweenFast = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- ==========================================
-- ========== GUI CLEANUP & SETUP ===========
-- ==========================================
local GUI_NAME = "S4_V6_ELITE_HUD"
pcall(function()
    for _, v in pairs(CoreGui:GetChildren()) do if v.Name == GUI_NAME then v:Destroy() end end
    if Player:FindFirstChild("PlayerGui") then
        for _, v in pairs(Player.PlayerGui:GetChildren()) do if v.Name == GUI_NAME then v:Destroy() end end
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = GUI_NAME
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = gethui and gethui() or CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = Player:WaitForChild("PlayerGui") end

-- ==========================================
-- ========== PLASMA BORDER ENGINE ==========
-- ==========================================
local function ApplyPlasmaBorder(parent, isFunctional, customColor)
    local stroke = Instance.new("UIStroke", parent)
    stroke.Thickness = STROKE_THICKNESS
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    
    local gradient = Instance.new("UIGradient", stroke)
    
    local function updateColorSequence(baseColor)
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, baseColor),
            ColorSequenceKeypoint.new(0.4, baseColor),
            ColorSequenceKeypoint.new(0.5, Color3.new(1, 1, 1)), 
            ColorSequenceKeypoint.new(0.6, baseColor),
            ColorSequenceKeypoint.new(1, baseColor),
        })
    end
    
    local initialColor = customColor or (isFunctional and Theme.InactiveBorder or Theme.BorderNeon)
    updateColorSequence(initialColor)
    
    task.spawn(function()
        local flowOffset = 0
        RunService.RenderStepped:Connect(function(dt)
            flowOffset = (flowOffset + (dt * 150)) % 360 
            gradient.Rotation = flowOffset
        end)
    end)
    
    return gradient, updateColorSequence
end

-- ==========================================
-- ====== SMART DRAG VS CLICK ENGINE ========
-- ==========================================
local function MakeFloatingDraggable(frame, button, onClick)
    local dragging = false
    local hasMoved = false
    local dragInput = nil
    local dragStart, startPos

    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if guiLocked and frame.Name ~= "TopHeader" and frame.Name ~= "MainWindow" then return end 
            if dragging then return end 
            
            dragging = true
            hasMoved = false
            dragInput = input
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    dragInput = nil
                    if not hasMoved and onClick then onClick() end
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            if delta.Magnitude > 5 then
                hasMoved = true
                frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end
    end)
end

-- ==========================================
-- ========== PREMIUM HEADER ================
-- ==========================================
local TopHeader = Instance.new("Frame", ScreenGui)
TopHeader.Name = "TopHeader"
TopHeader.Size = UDim2.new(0, 200, 0, 60)
TopHeader.Position = UDim2.new(0.5, -100, 0, 20)
TopHeader.BackgroundColor3 = Theme.Background
TopHeader.BackgroundTransparency = Theme.GlassTransparency
TopHeader.BorderSizePixel = 0
Instance.new("UICorner", TopHeader).CornerRadius = UDim.new(0, 4)

ApplyPlasmaBorder(TopHeader, false)

local HeaderTitle = Instance.new("TextLabel", TopHeader)
HeaderTitle.Size = UDim2.new(1, 0, 0, 25)
HeaderTitle.Position = UDim2.new(0, 0, 0, 5)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Text = "S4DUELS"
HeaderTitle.TextColor3 = Theme.TextWhite
HeaderTitle.Font = Enum.Font.GothamBlack
HeaderTitle.TextSize = 20

local StatsLabel = Instance.new("TextLabel", TopHeader)
StatsLabel.Size = UDim2.new(1, 0, 0, 15)
StatsLabel.Position = UDim2.new(0, 0, 0, 35)
StatsLabel.BackgroundTransparency = 1
StatsLabel.Text = "FPS: -- | PING: --ms"
StatsLabel.TextColor3 = Theme.TextDim
StatsLabel.Font = Enum.Font.GothamBold
StatsLabel.TextSize = 11

local ToggleHubBtn = Instance.new("TextButton", TopHeader)
ToggleHubBtn.Size = UDim2.new(0, 100, 0, 26)
ToggleHubBtn.Position = UDim2.new(0.5, -50, 1, 8) 
ToggleHubBtn.BackgroundColor3 = Theme.PanelBg
ToggleHubBtn.BackgroundTransparency = Theme.PanelTransparency
ToggleHubBtn.Text = "S4HUB"
ToggleHubBtn.TextColor3 = Theme.AccentFill
ToggleHubBtn.Font = Enum.Font.GothamBlack
ToggleHubBtn.TextSize = 13
Instance.new("UICorner", ToggleHubBtn).CornerRadius = UDim.new(0, 4)
ApplyPlasmaBorder(ToggleHubBtn, false)

MakeFloatingDraggable(TopHeader, TopHeader)

-- ==========================================
-- ========== MAIN HUB WINDOW ===============
-- ==========================================
local MainWindow = Instance.new("Frame", ScreenGui)
MainWindow.Name = "MainWindow"
MainWindow.Size = UDim2.new(0, 380, 0, 320)
MainWindow.Position = UDim2.new(0.5, -190, 0.5, -160)
MainWindow.BackgroundColor3 = Theme.Background
MainWindow.BackgroundTransparency = Theme.GlassTransparency
MainWindow.BorderSizePixel = 0
MainWindow.Visible = false 
Instance.new("UICorner", MainWindow).CornerRadius = UDim.new(0, 4)

ApplyPlasmaBorder(MainWindow, false)

ToggleHubBtn.Activated:Connect(function()
    if not States.DuelFuckerMode then MainWindow.Visible = not MainWindow.Visible end
end)

local TitleBar = Instance.new("Frame", MainWindow)
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Theme.PanelBg
TitleBar.BackgroundTransparency = Theme.PanelTransparency
TitleBar.BorderSizePixel = 0
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 4)

local TitleText = Instance.new("TextLabel", TitleBar)
TitleText.Size = UDim2.new(1, -20, 1, 0)
TitleText.Position = UDim2.new(0, 15, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "S4HUB V6: ELITE"
TitleText.TextColor3 = Theme.TextWhite
TitleText.Font = Enum.Font.GothamBlack
TitleText.TextSize = 14
TitleText.TextXAlignment = Enum.TextXAlignment.Left

local CloseButton = Instance.new("TextButton", TitleBar)
CloseButton.Size = UDim2.new(0, 35, 0, 35)
CloseButton.Position = UDim2.new(1, -35, 0, 0)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "✕"
CloseButton.TextColor3 = Theme.Danger
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 18
CloseButton.Activated:Connect(function() MainWindow.Visible = false end)

MakeFloatingDraggable(MainWindow, TitleBar)
-- ==========================================
-- ========== TOP TABS & CONTENT ============
-- ==========================================
local TabContainer = Instance.new("Frame", MainWindow)
TabContainer.Size = UDim2.new(1, -20, 0, 36)
TabContainer.Position = UDim2.new(0, 10, 0, 45) 
TabContainer.BackgroundColor3 = Theme.PanelBg
TabContainer.BackgroundTransparency = 0.5
TabContainer.BorderSizePixel = 0
Instance.new("UICorner", TabContainer).CornerRadius = UDim.new(0, 4)

local ContentArea = Instance.new("Frame", MainWindow)
ContentArea.Size = UDim2.new(1, -20, 1, -95)
ContentArea.Position = UDim2.new(0, 10, 0, 85)
ContentArea.BackgroundTransparency = 1

local Tabs = {}

local function CreateTab(tabName, xPositionScale)
    local TabBtn = Instance.new("TextButton", TabContainer)
    TabBtn.Size = UDim2.new(0.5, 0, 1, 0)
    TabBtn.Position = UDim2.new(xPositionScale, 0, 0, 0)
    TabBtn.BackgroundColor3 = Theme.AccentFill
    TabBtn.BackgroundTransparency = 1 
    TabBtn.Text = tabName
    TabBtn.TextColor3 = Theme.TextDim
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.TextSize = 13
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 4)
    
    local Indicator = Instance.new("Frame", TabBtn)
    Indicator.Size = UDim2.new(0.6, 0, 0, 3)
    Indicator.Position = UDim2.new(0.2, 0, 1, -3)
    Indicator.BackgroundColor3 = Theme.AccentFill
    Indicator.BackgroundTransparency = 1 
    Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)

    local TabContent = Instance.new("ScrollingFrame", ContentArea)
    TabContent.Size = UDim2.new(1, 0, 1, 0)
    TabContent.BackgroundTransparency = 1
    TabContent.ScrollBarThickness = 2
    TabContent.ScrollBarImageColor3 = Theme.AccentFill
    TabContent.Visible = false
    TabContent.CanvasSize = UDim2.new(0, 0, 2.5, 0) 
    
    local Layout = Instance.new("UIGridLayout", TabContent)
    Layout.CellSize = UDim2.new(0.48, 0, 0, 42)
    Layout.CellPadding = UDim2.new(0, 10, 0, 10)

    table.insert(Tabs, {Btn = TabBtn, Content = TabContent, Indicator = Indicator})

    TabBtn.Activated:Connect(function()
        for _, tab in pairs(Tabs) do
            tab.Content.Visible = false
            TweenService:Create(tab.Btn, TweenFast, {BackgroundTransparency = 1, TextColor3 = Theme.TextDim}):Play()
            TweenService:Create(tab.Indicator, TweenFast, {BackgroundTransparency = 1}):Play()
        end
        TabContent.Visible = true
        TweenService:Create(TabBtn, TweenFast, {BackgroundTransparency = 0.3, TextColor3 = Theme.TextWhite}):Play()
        TweenService:Create(Indicator, TweenFast, {BackgroundTransparency = 0}):Play()
    end)

    return TabContent
end

local TabS4Duels = CreateTab("S4DUELS", 0)
local TabServer = CreateTab("SERVER", 0.5)

Tabs[1].Btn.TextColor3 = Theme.TextWhite
Tabs[1].Btn.BackgroundTransparency = 0.3
Tabs[1].Indicator.BackgroundTransparency = 0
Tabs[1].Content.Visible = true

-- ==========================================
-- ========== SPEED CUSTOMIZER MENUS ========
-- ==========================================
local function createSpeedMenu(titleText, height)
    local menu = Instance.new("Frame", ScreenGui)
    menu.Size = UDim2.new(0, 260, 0, height)
    menu.Position = UDim2.new(0.5, -130, 0.5, -(height/2))
    menu.BackgroundColor3 = Theme.Background
    menu.BackgroundTransparency = 0.4 
    menu.Visible = false
    menu.ZIndex = 50
    Instance.new("UICorner", menu).CornerRadius = UDim.new(0, 6)
    
    ApplyPlasmaBorder(menu, false)

    local title = Instance.new("TextLabel", menu)
    title.Size = UDim2.new(1, 0, 0, 35)
    title.Position = UDim2.new(0, 15, 0, 5)
    title.Text = titleText
    title.TextColor3 = Theme.BorderNeon
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.BackgroundTransparency = 1
    title.ZIndex = 51
    
    local closeBtn = Instance.new("TextButton", menu)
    closeBtn.Size = UDim2.new(0, 35, 0, 35)
    closeBtn.Position = UDim2.new(1, -40, 0, 5)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Theme.Danger
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 18
    closeBtn.BackgroundTransparency = 1
    closeBtn.ZIndex = 51
    closeBtn.Activated:Connect(function() menu.Visible = false end)
    
    local menuDragBtn = Instance.new("TextButton", menu)
    menuDragBtn.Size = UDim2.new(1, -40, 0, 35)
    menuDragBtn.BackgroundTransparency = 1
    menuDragBtn.Text = ""
    menuDragBtn.ZIndex = 51
    MakeFloatingDraggable(menu, menuDragBtn)
    
    local saveBtn = Instance.new("TextButton", menu)
    saveBtn.Size = UDim2.new(0.8, 0, 0, 30)
    saveBtn.Position = UDim2.new(0.1, 0, 1, -40)
    saveBtn.BackgroundColor3 = Theme.PanelBg
    saveBtn.TextColor3 = Theme.TextWhite
    saveBtn.Font = Enum.Font.GothamBold
    saveBtn.TextSize = 12
    saveBtn.Text = "Save Config"
    saveBtn.ZIndex = 51
    Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0, 4)
    ApplyPlasmaBorder(saveBtn, false)
    
    saveBtn.Activated:Connect(function()
        SaveSettings()
        saveBtn.Text = "SAVED!"
        saveBtn.TextColor3 = Theme.Success
        task.wait(1)
        saveBtn.Text = "Save Config"
        saveBtn.TextColor3 = Theme.TextWhite
    end)
    
    return menu
end

local function addSpeedSlider(menu, yPos, labelStr, varKey, minVal, maxVal)
    local label = Instance.new("TextLabel", menu)
    label.Size = UDim2.new(1, -30, 0, 20)
    label.Position = UDim2.new(0, 15, 0, yPos)
    label.BackgroundTransparency = 1
    label.Text = labelStr .. ": " .. Config[varKey]
    label.TextColor3 = Theme.TextWhite
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 51

    local track = Instance.new("TextButton", menu)
    track.Size = UDim2.new(1, -30, 0, 12) 
    track.Position = UDim2.new(0, 15, 0, yPos + 24)
    track.BackgroundColor3 = Color3.fromRGB(20, 5, 30)
    track.Text = ""
    track.ZIndex = 51
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local initRel = (Config[varKey] - minVal) / (maxVal - minVal)
    
    local fill = Instance.new("Frame", track)
    fill.Size = UDim2.new(initRel, 0, 1, 0)
    fill.BackgroundColor3 = Theme.AccentFill
    fill.ZIndex = 52
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local dragging = false
    local dragInput = nil
    
    local function update(input)
        local rel = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local val = math.floor(minVal + rel * (maxVal - minVal))
        Config[varKey] = val
        fill.Size = UDim2.new(rel, 0, 1, 0)
        label.Text = labelStr .. ": " .. val
    end
    
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true 
            dragInput = input 
            update(input)
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false dragInput = nil end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then update(input) end
    end)
end

local function addToggleSetting(menu, yPos, labelStr, varKey)
    local label = Instance.new("TextLabel", menu)
    label.Size = UDim2.new(1, -60, 0, 20)
    label.Position = UDim2.new(0, 15, 0, yPos)
    label.BackgroundTransparency = 1
    label.Text = labelStr
    label.TextColor3 = Theme.TextWhite
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 51
    
    local toggleBtn = Instance.new("TextButton", menu)
    toggleBtn.Size = UDim2.new(0, 40, 0, 20)
    toggleBtn.Position = UDim2.new(1, -55, 0, yPos)
    toggleBtn.BackgroundColor3 = Config[varKey] and Theme.AccentFill or Theme.Background
    toggleBtn.Text = Config[varKey] and "ON" or "OFF"
    toggleBtn.TextColor3 = Theme.TextWhite
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 10
    toggleBtn.ZIndex = 51
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 4)
    ApplyPlasmaBorder(toggleBtn, false)
    
    toggleBtn.Activated:Connect(function()
        Config[varKey] = not Config[varKey]
        toggleBtn.BackgroundColor3 = Config[varKey] and Theme.AccentFill or Theme.Background
        toggleBtn.Text = Config[varKey] and "ON" or "OFF"
    end)
end

local MenuBat = createSpeedMenu("BAT FUCKER SPEEDS", 130)
addSpeedSlider(MenuBat, 45, "Tracking Speed", "BatSpeed", 20, 125)

local MenuFly = createSpeedMenu("FLY SPEEDS (OP)", 220)
addSpeedSlider(MenuFly, 45, "Fly Speed", "FlySpeed", 20, 125)
addSpeedSlider(MenuFly, 105, "Fly Carry Speed", "FlyCarrySpeed", 0, 50) 
addToggleSetting(MenuFly, 155, "Speed Bypass (Invis Cloak)", "SpeedBypassEnabled")

local MenuAutoDuel = createSpeedMenu("AUTO DUEL SPEEDS", 190)
addSpeedSlider(MenuAutoDuel, 45, "Attack Speed", "AutoDuelSpeed", 20, 125)
addSpeedSlider(MenuAutoDuel, 105, "Return Speed", "AutoDuelCarrySpeed", 0, 50)

local MenuS4 = createSpeedMenu("S4BOOSTER SPEEDS", 190)
addSpeedSlider(MenuS4, 45, "Walk Speed", "WalkSpeed", 20, 125)
addSpeedSlider(MenuS4, 105, "Carry Speed", "CarrySpeed", 0, 50)

-- ==========================================
-- ======== DUELFUCKER HUD (FLOATING) =======
-- ==========================================
local DuelFuckerHUD = Instance.new("Frame", ScreenGui)
DuelFuckerHUD.Name = "DuelFuckerHUD"
DuelFuckerHUD.Size = UDim2.new(1, 0, 1, 0)
DuelFuckerHUD.BackgroundTransparency = 1
DuelFuckerHUD.Visible = false

local function CreateFloatingButton(text, stateKey, defaultPos, isBlueLine)
    local frame = Instance.new("Frame", DuelFuckerHUD)
    frame.Size = UDim2.new(0, 140, 0, 42)
    frame.Position = defaultPos
    frame.BackgroundColor3 = Theme.Background
    frame.BackgroundTransparency = Theme.GlassTransparency
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    
    local _, updateShine = ApplyPlasmaBorder(frame, true, isBlueLine and Theme.BlueNeon or Theme.InactiveBorder)

    if isBlueLine and stateKey ~= "LockGUI" then
        updateShine(Theme.BlueNeon) 
    end

    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = text
    btn.TextColor3 = Theme.TextWhite
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12

    local function HandleClick()
        if stateKey == "LockGUI" then
            guiLocked = not guiLocked
            btn.Text = guiLocked and "LOCKED" or "LOCK GUI"
            updateShine(guiLocked and Theme.Danger or Theme.BlueNeon)
            return
        elseif stateKey == "ReturnHub" then
            States.DuelFuckerMode = false
            DuelFuckerHUD.Visible = false
            TopHeader.Visible = true 
            MainWindow.Visible = true
            if UIRegistry["DuelFuckerMode"] then
                for _, f in pairs(UIRegistry["DuelFuckerMode"]) do f(false) end
            end
            return
        elseif stateKey == "Drop" then
            if Player:GetAttribute("Stealing") then
                local char = Player.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if root then
                    task.spawn(function()
                        local vel = root.AssemblyLinearVelocity
                        root.AssemblyLinearVelocity = vel * 10000 + Vector3.new(0, 10000, 0)
                        RunService.RenderStepped:Wait()
                        if root and root.Parent then root.AssemblyLinearVelocity = vel end
                        RunService.Stepped:Wait()
                        if root and root.Parent then root.AssemblyLinearVelocity = vel + Vector3.new(0, 0.1, 0) end
                    end)
                end
            end
            return
        end

        States[stateKey] = not States[stateKey]
        
        if stateKey == "AutoDuel" and not States[stateKey] then
            local char = Player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then root.AssemblyLinearVelocity = Vector3.zero end
        end

        if UIRegistry[stateKey] then
            for _, func in pairs(UIRegistry[stateKey]) do func(States[stateKey]) end
        end
    end

    MakeFloatingDraggable(frame, btn, HandleClick)

    if stateKey ~= "LockGUI" and stateKey ~= "ReturnHub" and stateKey ~= "Drop" then
        if not UIRegistry[stateKey] then UIRegistry[stateKey] = {} end
        table.insert(UIRegistry[stateKey], function(state)
            if state then
                TweenService:Create(btn, TweenFast, {TextColor3 = Theme.Success}):Play()
                TweenService:Create(frame, TweenFast, {BackgroundColor3 = Theme.PanelBg, BackgroundTransparency = 0.3}):Play()
                updateShine(Theme.AccentFill)
            else
                TweenService:Create(btn, TweenFast, {TextColor3 = Theme.TextWhite}):Play()
                TweenService:Create(frame, TweenFast, {BackgroundColor3 = Theme.Background, BackgroundTransparency = Theme.GlassTransparency}):Play()
                updateShine(Theme.InactiveBorder)
            end
        end)
    end
end

local function CreateDropdownFloatingButton(mainText, stateKeyMain, configKey, opt1, opt2, defaultPos)
    local container = Instance.new("Frame", DuelFuckerHUD)
    container.Size = UDim2.new(0, 140, 0, 42)
    container.Position = defaultPos
    container.BackgroundTransparency = 1
    
    local mainFrame = Instance.new("Frame", container)
    mainFrame.Size = UDim2.new(1, 0, 0, 42)
    mainFrame.BackgroundColor3 = Theme.Background
    mainFrame.BackgroundTransparency = Theme.GlassTransparency
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 6)
    
    local _, updateShine = ApplyPlasmaBorder(mainFrame, true, Theme.InactiveBorder)
    
    local btnMain = Instance.new("TextButton", mainFrame)
    btnMain.Size = UDim2.new(1, -30, 1, 0)
    btnMain.BackgroundTransparency = 1
    btnMain.Text = mainText
    btnMain.TextColor3 = Theme.TextWhite
    btnMain.Font = Enum.Font.GothamBold
    btnMain.TextSize = 12
    
    local arrowBtn = Instance.new("TextButton", mainFrame)
    arrowBtn.Size = UDim2.new(0, 30, 1, 0)
    arrowBtn.Position = UDim2.new(1, -30, 0, 0)
    arrowBtn.BackgroundTransparency = 1
    arrowBtn.Text = "▼"
    arrowBtn.TextColor3 = Theme.TextDim
    arrowBtn.TextSize = 14
    
    local subFrame = Instance.new("Frame", container)
    subFrame.Size = UDim2.new(1, 0, 0, 36)
    subFrame.Position = UDim2.new(0, 0, 0, 46)
    subFrame.BackgroundColor3 = Theme.PanelBg
    subFrame.BackgroundTransparency = Theme.GlassTransparency
    subFrame.Visible = false
    Instance.new("UICorner", subFrame).CornerRadius = UDim.new(0, 6)
    ApplyPlasmaBorder(subFrame, false)
    
    local btnOpt1 = Instance.new("TextButton", subFrame)
    btnOpt1.Size = UDim2.new(0.5, 0, 1, 0)
    btnOpt1.BackgroundTransparency = 1
    btnOpt1.Text = opt1
    btnOpt1.TextColor3 = Config[configKey] == opt1 and Theme.AccentFill or Theme.TextWhite
    btnOpt1.Font = Enum.Font.GothamBold
    btnOpt1.TextSize = 11
    
    local btnOpt2 = Instance.new("TextButton", subFrame)
    btnOpt2.Size = UDim2.new(0.5, 0, 1, 0)
    btnOpt2.Position = UDim2.new(0.5, 0, 0, 0)
    btnOpt2.BackgroundTransparency = 1
    btnOpt2.Text = opt2
    btnOpt2.TextColor3 = Config[configKey] == opt2 and Theme.AccentFill or Theme.TextWhite
    btnOpt2.Font = Enum.Font.GothamBold
    btnOpt2.TextSize = 11

    local divider = Instance.new("Frame", subFrame)
    divider.Size = UDim2.new(0, 2, 0.6, 0)
    divider.Position = UDim2.new(0.5, -1, 0.2, 0)
    divider.BackgroundColor3 = Theme.InactiveBorder
    divider.BorderSizePixel = 0

    btnOpt1.Activated:Connect(function()
        Config[configKey] = opt1
        btnOpt1.TextColor3 = Theme.AccentFill
        btnOpt2.TextColor3 = Theme.TextWhite
    end)
    btnOpt2.Activated:Connect(function()
        Config[configKey] = opt2
        btnOpt2.TextColor3 = Theme.AccentFill
        btnOpt1.TextColor3 = Theme.TextWhite
    end)
    
    arrowBtn.Activated:Connect(function()
        subFrame.Visible = not subFrame.Visible
        arrowBtn.Text = subFrame.Visible and "▲" or "▼"
    end)
    
    local function HandleMainClick()
        States[stateKeyMain] = not States[stateKeyMain]
        
        if stateKeyMain == "AutoDuel" and not States[stateKeyMain] then
            local char = Player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then root.AssemblyLinearVelocity = Vector3.zero end
        end
        
        if UIRegistry[stateKeyMain] then
            for _, func in pairs(UIRegistry[stateKeyMain]) do func(States[stateKeyMain]) end
        end
    end

    MakeFloatingDraggable(container, btnMain, HandleMainClick)

    if not UIRegistry[stateKeyMain] then UIRegistry[stateKeyMain] = {} end
    table.insert(UIRegistry[stateKeyMain], function(state)
        if state then
            TweenService:Create(btnMain, TweenFast, {TextColor3 = Theme.Success}):Play()
            TweenService:Create(mainFrame, TweenFast, {BackgroundColor3 = Theme.PanelBg, BackgroundTransparency = 0.3}):Play()
            updateShine(Theme.AccentFill)
        else
            TweenService:Create(btnMain, TweenFast, {TextColor3 = Theme.TextWhite}):Play()
            TweenService:Create(mainFrame, TweenFast, {BackgroundColor3 = Theme.Background, BackgroundTransparency = Theme.GlassTransparency}):Play()
            updateShine(Theme.InactiveBorder)
        end
    end)
end

CreateFloatingButton("S4HUB", "ReturnHub", UDim2.new(0, 15, 0, 15), true)
CreateFloatingButton("LOCK GUI", "LockGUI", UDim2.new(0, 15, 0, 65), true)

CreateDropdownFloatingButton("Auto Play", "AutoDuel", "AutoPlayLane", "Left", "Right", UDim2.new(0.5, 0, 0.1, 0))
CreateDropdownFloatingButton("Bat Fucker", "BatFucker", "BatFuckerMode", "Standard", "Auto", UDim2.new(0.3, 0, 0.1, 0))
CreateFloatingButton("Fly", "Fly", UDim2.new(0.7, 0, 0.1, 0), false)

CreateFloatingButton("AIM FUCKER", "AimFucker", UDim2.new(0.5, 0, 0.8, 0), false)
CreateFloatingButton("Instant Steal", "InstantSteal", UDim2.new(0.3, 0, 0.8, 0), false)
CreateFloatingButton("Unwalk", "Unwalk", UDim2.new(0.7, 0, 0.8, 0), false)
CreateFloatingButton("Drop", "Drop", UDim2.new(0.5, 0, 0.65, 0), false)

-- ==========================================
-- ========== POPULATE HUB TABS =============
-- ==========================================
local function CreateHubButton(parent, text, stateKey, hasGear, callback)
    local BtnContainer = Instance.new("Frame", parent)
    BtnContainer.BackgroundTransparency = 1

    local Btn = Instance.new("TextButton", BtnContainer)
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundColor3 = Theme.Background
    Btn.BackgroundTransparency = Theme.GlassTransparency
    Btn.Text = ""
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
    
    local _, updateShine = ApplyPlasmaBorder(Btn, true, Theme.InactiveBorder)

    local Label = Instance.new("TextLabel", Btn)
    Label.Size = UDim2.new(1, -20, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Theme.TextWhite
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Center

    if hasGear then
        local GearBtn = Instance.new("TextButton", Btn)
        GearBtn.Size = UDim2.new(0, 20, 0, 20)
        GearBtn.Position = UDim2.new(1, -22, 1, -22)
        GearBtn.BackgroundColor3 = Theme.PanelBg
        GearBtn.BackgroundTransparency = 1
        GearBtn.Text = "⚙️"
        GearBtn.TextSize = 12
        GearBtn.ZIndex = 5
        
        GearBtn.Activated:Connect(function()
            MenuBat.Visible = false; MenuFly.Visible = false; MenuS4.Visible = false; MenuAutoDuel.Visible = false
            if stateKey == "BatFucker" then MenuBat.Visible = true
            elseif stateKey == "Fly" then MenuFly.Visible = true
            elseif stateKey == "AutoDuel" then MenuAutoDuel.Visible = true
            elseif stateKey == "S4Booster" then MenuS4.Visible = true end
        end)
    end

    if stateKey then
        Btn.Activated:Connect(function()
            if stateKey == "DuelFuckerMode" then
                States.DuelFuckerMode = true
                MainWindow.Visible = false
                TopHeader.Visible = false
                DuelFuckerHUD.Visible = true
            else
                States[stateKey] = not States[stateKey]
                if callback then callback(States[stateKey]) end
            end

            if UIRegistry[stateKey] then
                for _, func in pairs(UIRegistry[stateKey]) do func(States[stateKey]) end
            end
        end)

        if not UIRegistry[stateKey] then UIRegistry[stateKey] = {} end
        table.insert(UIRegistry[stateKey], function(state)
            if state then
                TweenService:Create(Btn, TweenFast, {BackgroundColor3 = Theme.PanelBg, BackgroundTransparency = 0.3}):Play()
                updateShine(Theme.AccentFill) 
            else
                TweenService:Create(Btn, TweenFast, {BackgroundColor3 = Theme.Background, BackgroundTransparency = Theme.GlassTransparency}):Play()
                updateShine(Theme.InactiveBorder) 
            end
        end)
    else
        Btn.Activated:Connect(function()
            task.spawn(function()
                TweenService:Create(Btn, TweenFast, {BackgroundColor3 = Theme.PanelBg, BackgroundTransparency = 0.3}):Play()
                updateShine(Theme.AccentFill)
                task.wait(0.15)
                TweenService:Create(Btn, TweenFast, {BackgroundColor3 = Theme.Background, BackgroundTransparency = Theme.GlassTransparency}):Play()
                updateShine(Theme.InactiveBorder)
            end)
            if callback then callback() end
        end)
    end
end

CreateHubButton(TabS4Duels, "duelfucker", "DuelFuckerMode", false)
CreateHubButton(TabS4Duels, "Auto Play", "AutoDuel", true) 
CreateHubButton(TabS4Duels, "AIM FUCKER", "AimFucker", false) 
CreateHubButton(TabS4Duels, "Bat Fucker", "BatFucker", true)
CreateHubButton(TabS4Duels, "Fly", "Fly", true)
CreateHubButton(TabS4Duels, "S4BOOSTER", "S4Booster", true)
CreateHubButton(TabS4Duels, "Instant Steal", "InstantSteal", false)
CreateHubButton(TabS4Duels, "Unwalk", "Unwalk", false)
CreateHubButton(TabS4Duels, "Anti Ragdoll", "AntiRagdoll", false)
CreateHubButton(TabS4Duels, "ESP", "ESP", false)

CreateHubButton(TabServer, "FPS Booster", nil, false, function()
    local Lighting = game:GetService("Lighting")
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.Brightness = 0
    pcall(function() Lighting.Technology = Enum.Technology.Compatibility end)
    for _, v in pairs(Lighting:GetChildren()) do
        if v:IsA("PostEffect") or v:IsA("Atmosphere") or v:IsA("Sky") or v:IsA("Clouds") then v:Destroy() end
    end
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Material = Enum.Material.SmoothPlastic
            v.Reflectance = 0
            v.CastShadow = false
        end
    end
end)

CreateHubButton(TabServer, "Taunt Chat", nil, false, function()
    local TextChatService = game:GetService("TextChatService")
    if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        local channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
        if channel then channel:SendAsync("S4DUELS ON TOP") end
    else
        local rme = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
        if rme and rme:FindFirstChild("SayMessageRequest") then 
            rme.SayMessageRequest:FireServer("S4DUELS ON TOP", "All") 
        end
    end
end)
CreateHubButton(TabServer, "Rejoin Server", nil, false, function() game:GetService("TeleportService"):Teleport(game.PlaceId, Player) end)
CreateHubButton(TabServer, "Server Hop", nil, false, function() game:GetService("TeleportService"):Teleport(game.PlaceId) end)
CreateHubButton(TabServer, "Kick Self", nil, false, function() Player:Kick("S4DUELS Manual Disconnect - Evading Anti-Cheat.") end)
