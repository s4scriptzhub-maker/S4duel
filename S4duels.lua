-- [[ S4DUELS V5.0: EVIL HUB AESTHETICS ]] --
-- [[ AUTO DUEL AI + PURE AIM BYPASS + V3 PHYSICS ]] --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

while not Player do
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    Player = Players.LocalPlayer
end

-- ==========================================
-- ========== GLOBAL CONFIGURATION ==========
-- ==========================================
local Config = {
    BatSpeed = 55,
    FlySpeed = 54,
    FlyCarrySpeed = 25,
    WalkSpeed = 55,
    CarrySpeed = 29
}

local States = {
    BatFucker = false,
    AimFucker = false,
    Fly = false,
    S4Booster = false,
    InstantSteal = false,
    AutoDuel = false,
    ESP = false,
    InfJump = false,
    Unwalk = false,
    AntiRagdoll = false,
    DuelFuckerMode = false
}

-- Duels Coordinates
local POS_L = {
    Vector3.new(-477.195556640625, -6.065402984619141, 92.81834411621094),
    Vector3.new(-483.3575439453125, -5.037250518798828, 95.46223449707031),
    Vector3.new(-476.0683898925781, -6.628986358642578, 93.31355285644531),
    Vector3.new(-477.0289001464844, -6.148730278015137, 28.182092666625977)
}

local POS_R = {
    Vector3.new(-475.7699890136719, -6.570000171661377, 26.760000228881836),
    Vector3.new(-483.45159912109375, -5.037250518798828, 24.486499786376953),
    Vector3.new(-476.4311828613281, -6.447589874267578, 26.645410537719727),
    Vector3.new(-476.23638916015625, -6.6419878005981445, 91.72139739990234)
}

local BaseL_Center = POS_L[1]
local BaseR_Center = POS_R[1]

-- Premium Sharp Purplish Colors (Evil Hub Style)
local Theme = {
    Background = Color3.fromRGB(25, 10, 40),      
    PanelBg = Color3.fromRGB(45, 20, 65),         
    PurpleNeon = Color3.fromRGB(210, 50, 255),    
    BlueNeon = Color3.fromRGB(0, 240, 255),       
    TextWhite = Color3.fromRGB(245, 245, 250),
    TextDim = Color3.fromRGB(170, 150, 190),
    Danger = Color3.fromRGB(255, 50, 70),
    Success = Color3.fromRGB(40, 255, 120),
    InactiveStroke = Color3.fromRGB(70, 40, 90)
}

local TweenFast = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local guiLocked = false
local UIRegistry = {}
local STROKE_THICKNESS = 1.2

-- ==========================================
-- ========== UNIVERSAL SILENT AIM ==========
-- ==========================================
local CurrentAimTarget = nil 

local function isHoldingTool()
    return Player.Character and Player.Character:FindFirstChildOfClass("Tool") ~= nil
end

local OriginalIndex = nil
OriginalIndex = hookmetamethod(game, "__index", function(self, key)
    if not checkcaller() and States.AimFucker and CurrentAimTarget and isHoldingTool() and tostring(self) == "Mouse" then
        if key == "Hit" then return CurrentAimTarget.CFrame end
        if key == "Target" then return CurrentAimTarget end
        if key == "UnitRay" then 
            local camPos = Camera.CFrame.Position
            return Ray.new(camPos, (CurrentAimTarget.Position - camPos).Unit) 
        end
    end
    return OriginalIndex(self, key)
end)

local OriginalNamecall = nil
OriginalNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if not checkcaller() and States.AimFucker and CurrentAimTarget and isHoldingTool() then
        local caller = getcallingscript and getcallingscript()
        if caller and typeof(caller) == "Instance" and (string.find(caller.Name, "Camera") or string.find(caller.Name, "Popper") or string.find(caller.Name, "Zoom")) then
            return OriginalNamecall(self, ...)
        end

        local selfStr = tostring(self)
        
        if method == "Raycast" and selfStr == "Workspace" then
            if typeof(args[1]) == "Vector3" and typeof(args[2]) == "Vector3" then
                local origin = args[1]
                local dir = args[2]
                
                local head = Player.Character and Player.Character:FindFirstChild("Head")
                if head then
                    local dirToHead = (head.Position - origin).Unit
                    if dirToHead:Dot(dir.Unit) > 0.99 then
                        return OriginalNamecall(self, unpack(args))
                    end
                end

                local direction = (CurrentAimTarget.Position - origin).Unit * dir.Magnitude
                args[2] = direction
                return OriginalNamecall(self, unpack(args))
            end
        end

        if string.find(method, "FindPartOnRay") and selfStr == "Workspace" then
            if typeof(args[1]) == "Ray" then
                local origin = args[1].Origin
                local head = Player.Character and Player.Character:FindFirstChild("Head")
                if head then
                    local dirToHead = (head.Position - origin).Unit
                    if dirToHead:Dot(args[1].Direction.Unit) > 0.99 then
                        return OriginalNamecall(self, unpack(args))
                    end
                end

                local magnitude = args[1].Direction.Magnitude
                local direction = (CurrentAimTarget.Position - origin).Unit * magnitude
                args[1] = Ray.new(origin, direction)
                return OriginalNamecall(self, unpack(args))
            end
        end
    end

    return OriginalNamecall(self, ...)
end)

-- ==========================================
-- ========== GUI CLEANUP & SETUP ===========
-- ==========================================
local GUI_NAME = "S4_V4_EVILHUB_HUD"

pcall(function()
    for _, v in pairs(CoreGui:GetChildren()) do
        if v.Name == GUI_NAME then v:Destroy() end
    end
    if Player:FindFirstChild("PlayerGui") then
        for _, v in pairs(Player.PlayerGui:GetChildren()) do
            if v.Name == GUI_NAME then v:Destroy() end
        end
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = GUI_NAME
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = gethui and gethui() or CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = Player:WaitForChild("PlayerGui") end

-- ==========================================
-- ========== LIVE SHINY ENGINE =============
-- ==========================================
local function applyShinyGradient(parent, color1)
    local gradient = Instance.new("UIGradient", parent)
    
    local function updateColor(color)
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, color),
            ColorSequenceKeypoint.new(0.4, color),
            ColorSequenceKeypoint.new(0.5, Color3.new(1, 1, 1)), 
            ColorSequenceKeypoint.new(0.6, color),
            ColorSequenceKeypoint.new(1, color)
        })
    end
    updateColor(color1)
    
    task.spawn(function()
        local rot = 0
        RunService.RenderStepped:Connect(function(dt)
            rot = (rot + (dt * 150)) % 360 
            gradient.Rotation = rot
        end)
    end)
    return gradient, updateColor
end

-- ==========================================
-- ====== FLAWLESS MULTI-TOUCH ENGINE =======
-- ==========================================
local function MakeDraggable(frame, handle)
    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then return end 
            dragging = true
            dragInput = input
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    dragInput = nil
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- ==========================================
-- ========== PREMIUM HEADER ================
-- ==========================================
local TopHeader = Instance.new("Frame", ScreenGui)
TopHeader.Size = UDim2.new(0, 200, 0, 60)
TopHeader.Position = UDim2.new(0.5, -100, 0, 20)
TopHeader.BackgroundColor3 = Theme.Background
TopHeader.BackgroundTransparency = 0.55
TopHeader.BorderSizePixel = 0
Instance.new("UICorner", TopHeader).CornerRadius = UDim.new(0, 4)

local HeaderStroke = Instance.new("UIStroke", TopHeader)
HeaderStroke.Thickness = STROKE_THICKNESS
applyShinyGradient(HeaderStroke, Theme.PurpleNeon)

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
ToggleHubBtn.BackgroundTransparency = 0.4
ToggleHubBtn.Text = "S4HUB"
ToggleHubBtn.TextColor3 = Theme.PurpleNeon
ToggleHubBtn.Font = Enum.Font.GothamBlack
ToggleHubBtn.TextSize = 13
Instance.new("UICorner", ToggleHubBtn).CornerRadius = UDim.new(0, 4)
local ToggleStroke = Instance.new("UIStroke", ToggleHubBtn)
ToggleStroke.Thickness = STROKE_THICKNESS
applyShinyGradient(ToggleStroke, Theme.PurpleNeon)

MakeDraggable(TopHeader, TopHeader)

-- ==========================================
-- ========== MAIN HUB WINDOW ===============
-- ==========================================
local MainWindow = Instance.new("Frame", ScreenGui)
MainWindow.Size = UDim2.new(0, 380, 0, 320)
MainWindow.Position = UDim2.new(0.5, -190, 0.5, -160)
MainWindow.BackgroundColor3 = Theme.Background
MainWindow.BackgroundTransparency = 0.55
MainWindow.BorderSizePixel = 0
MainWindow.Visible = false
Instance.new("UICorner", MainWindow).CornerRadius = UDim.new(0, 4)

local MainStroke = Instance.new("UIStroke", MainWindow)
MainStroke.Thickness = STROKE_THICKNESS
applyShinyGradient(MainStroke, Theme.PurpleNeon)

ToggleHubBtn.Activated:Connect(function()
    if not States.DuelFuckerMode then 
        MainWindow.Visible = not MainWindow.Visible 
    end
end)

local TitleBar = Instance.new("Frame", MainWindow)
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Theme.PanelBg
TitleBar.BackgroundTransparency = 0.4
TitleBar.BorderSizePixel = 0
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 4)

local TitleText = Instance.new("TextLabel", TitleBar)
TitleText.Size = UDim2.new(1, -20, 1, 0)
TitleText.Position = UDim2.new(0, 15, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "S4HUB ELITE"
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

MakeDraggable(MainWindow, TitleBar)

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
    TabBtn.BackgroundTransparency = 1
    TabBtn.Text = tabName
    TabBtn.TextColor3 = Theme.TextDim
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.TextSize = 13
    
    local Indicator = Instance.new("Frame", TabBtn)
    Indicator.Size = UDim2.new(0.6, 0, 0, 3)
    Indicator.Position = UDim2.new(0.2, 0, 1, -3)
    Indicator.BackgroundColor3 = Theme.PurpleNeon
    Indicator.BackgroundTransparency = 1
    Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)

    local TabContent = Instance.new("ScrollingFrame", ContentArea)
    TabContent.Size = UDim2.new(1, 0, 1, 0)
    TabContent.BackgroundTransparency = 1
    TabContent.ScrollBarThickness = 2
    TabContent.ScrollBarImageColor3 = Theme.PurpleNeon
    TabContent.Visible = false
    TabContent.CanvasSize = UDim2.new(0, 0, 1.5, 0)
    
    local Layout = Instance.new("UIGridLayout", TabContent)
    Layout.CellSize = UDim2.new(0.48, 0, 0, 42)
    Layout.CellPadding = UDim2.new(0, 10, 0, 10)

    table.insert(Tabs, {Btn = TabBtn, Content = TabContent, Indicator = Indicator})

    TabBtn.Activated:Connect(function()
        for _, tab in pairs(Tabs) do
            tab.Content.Visible = false
            TweenService:Create(tab.Btn, TweenFast, {TextColor3 = Theme.TextDim}):Play()
            TweenService:Create(tab.Indicator, TweenFast, {BackgroundTransparency = 1}):Play()
        end
        TabContent.Visible = true
        TweenService:Create(TabBtn, TweenFast, {TextColor3 = Theme.TextWhite}):Play()
        TweenService:Create(Indicator, TweenFast, {BackgroundTransparency = 0}):Play()
    end)

    return TabContent
end

local TabS4Duels = CreateTab("S4DUELS", 0)
local TabServer = CreateTab("SERVER", 0.5)

Tabs[1].Btn.TextColor3 = Theme.TextWhite
Tabs[1].Indicator.BackgroundTransparency = 0
Tabs[1].Content.Visible = true

-- ==========================================
-- ======== DUELFUCKER HUD (FLOATING) =======
-- ==========================================
local DuelFuckerHUD = Instance.new("Frame", ScreenGui)
DuelFuckerHUD.Size = UDim2.new(1, 0, 1, 0)
DuelFuckerHUD.BackgroundTransparency = 1
DuelFuckerHUD.Visible = false

local function MakeFloatingDraggable(frame, button, onClick)
    local dragging = false
    local hasMoved = false
    local dragInput = nil
    local dragStart, startPos

    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if guiLocked then return end
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
                    if not hasMoved and onClick then 
                        onClick() 
                    end
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            if delta.Magnitude > 5 then
                hasMoved = true
                if not guiLocked then
                    frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                end
            end
        end
    end)
end

local function CreateFloatingButton(text, stateKey, defaultPos, isBlueLine, canDrag)
    local frame = Instance.new("Frame", DuelFuckerHUD)
    frame.Size = UDim2.new(0, 140, 0, 42)
    frame.Position = defaultPos
    frame.BackgroundColor3 = Theme.Background
    frame.BackgroundTransparency = 0.55
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)
    
    local stroke = Instance.new("UIStroke", frame)
    stroke.Thickness = STROKE_THICKNESS
    local baseColor = isBlueLine and Theme.BlueNeon or Theme.InactiveStroke
    local activeColor = isBlueLine and Theme.BlueNeon or Theme.PurpleNeon
    local _, updateShine = applyShinyGradient(stroke, baseColor)

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
        end

        States[stateKey] = not States[stateKey]

        if UIRegistry[stateKey] then
            for _, func in pairs(UIRegistry[stateKey]) do func(States[stateKey]) end
        end
    end

    if canDrag == false then
        btn.Activated:Connect(HandleClick)
    else
        MakeFloatingDraggable(frame, btn, HandleClick)
    end

    if stateKey ~= "LockGUI" and stateKey ~= "ReturnHub" then
        if not UIRegistry[stateKey] then UIRegistry[stateKey] = {} end
        table.insert(UIRegistry[stateKey], function(state)
            if state then
                TweenService:Create(btn, TweenFast, {TextColor3 = Theme.Success}):Play()
                TweenService:Create(frame, TweenFast, {BackgroundColor3 = Theme.PanelBg, BackgroundTransparency = 0.2}):Play()
                updateShine(activeColor)
            else
                TweenService:Create(btn, TweenFast, {TextColor3 = Theme.TextWhite}):Play()
                TweenService:Create(frame, TweenFast, {BackgroundColor3 = Theme.Background, BackgroundTransparency = 0.55}):Play()
                updateShine(Theme.InactiveStroke)
            end
        end)
    end
end

CreateFloatingButton("S4HUB", "ReturnHub", UDim2.new(0, 15, 0, 15), true, true)
CreateFloatingButton("LOCK GUI", "LockGUI", UDim2.new(0, 15, 0, 65), true, false)

CreateFloatingButton("Auto Duel", "AutoDuel", UDim2.new(0.5, 0, 0.1, 0), false, true)
CreateFloatingButton("Bat Fucker", "BatFucker", UDim2.new(0.3, 0, 0.1, 0), false, true)
CreateFloatingButton("Fly", "Fly", UDim2.new(0.7, 0, 0.1, 0), false, true)

CreateFloatingButton("AIM FUCKER", "AimFucker", UDim2.new(0.5, 0, 0.8, 0), false, true)
CreateFloatingButton("Instant Steal", "InstantSteal", UDim2.new(0.3, 0, 0.8, 0), false, true)
CreateFloatingButton("Unwalk", "Unwalk", UDim2.new(0.7, 0, 0.8, 0), false, true)

-- ==========================================
-- ========== SPEED CUSTOMIZER MENUS ========
-- ==========================================
local function createSpeedMenu(titleText)
    local menu = Instance.new("Frame", MainWindow)
    menu.Size = UDim2.new(0, 240, 0, 180)
    menu.Position = UDim2.new(0.5, -120, 0.5, -90)
    menu.BackgroundColor3 = Theme.Background
    menu.BackgroundTransparency = 0.1
    menu.Visible = false
    menu.ZIndex = 50
    Instance.new("UICorner", menu).CornerRadius = UDim.new(0, 4)
    
    local mStroke = Instance.new("UIStroke", menu)
    mStroke.Thickness = STROKE_THICKNESS
    applyShinyGradient(mStroke, Theme.PurpleNeon)

    local title = Instance.new("TextLabel", menu)
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 15, 0, 5)
    title.Text = titleText
    title.TextColor3 = Theme.TextWhite
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 13
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.BackgroundTransparency = 1
    title.ZIndex = 51
    
    local closeBtn = Instance.new("TextButton", menu)
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Theme.Danger
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    closeBtn.BackgroundTransparency = 1
    closeBtn.ZIndex = 51
    closeBtn.Activated:Connect(function() menu.Visible = false end)
    
    return menu
end

local function addSpeedSlider(menu, yPos, labelStr, varKey, maxVal)
    local label = Instance.new("TextLabel", menu)
    label.Size = UDim2.new(1, -30, 0, 20)
    label.Position = UDim2.new(0, 15, 0, yPos)
    label.BackgroundTransparency = 1
    label.Text = labelStr .. ": " .. Config[varKey]
    label.TextColor3 = Theme.TextWhite
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 51

    local track = Instance.new("TextButton", menu)
    track.Size = UDim2.new(1, -30, 0, 6)
    track.Position = UDim2.new(0, 15, 0, yPos + 22)
    track.BackgroundColor3 = Theme.PanelBg
    track.Text = ""
    track.ZIndex = 51
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame", track)
    fill.Size = UDim2.new(Config[varKey] / maxVal, 0, 1, 0)
    fill.BackgroundColor3 = Theme.PurpleNeon
    fill.ZIndex = 52
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local dragging = false
    local dragInput = nil
    
    local function update(input)
        local rel = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local val = math.floor(rel * maxVal)
        Config[varKey] = val
        fill.Size = UDim2.new(rel, 0, 1, 0)
        label.Text = labelStr .. ": " .. val
    end
    
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then return end
            dragging = true
            dragInput = input
            update(input)
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    dragInput = nil
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            update(input)
        end
    end)
end

local MenuBat = createSpeedMenu("BAT FUCKER SPEEDS")
MenuBat.Size = UDim2.new(0, 240, 0, 100)
addSpeedSlider(MenuBat, 40, "Tracking Speed", "BatSpeed", 100)

local MenuFly = createSpeedMenu("FLY SPEEDS")
addSpeedSlider(MenuFly, 40, "Fly Speed", "FlySpeed", 100)
addSpeedSlider(MenuFly, 100, "Fly Carry Speed", "FlyCarrySpeed", 50)

local MenuS4 = createSpeedMenu("S4BOOSTER SPEEDS")
addSpeedSlider(MenuS4, 40, "Walk Speed", "WalkSpeed", 100)
addSpeedSlider(MenuS4, 100, "Carry Speed", "CarrySpeed", 50)

-- ==========================================
-- ========== POPULATE HUB TABS =============
-- ==========================================
local function CreateHubButton(parent, text, stateKey, hasGear, callback)
    local BtnContainer = Instance.new("Frame", parent)
    BtnContainer.BackgroundTransparency = 1

    local Btn = Instance.new("TextButton", BtnContainer)
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundColor3 = Theme.Background
    Btn.BackgroundTransparency = 0.55
    Btn.Text = ""
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
    
    local Stroke = Instance.new("UIStroke", Btn)
    Stroke.Thickness = STROKE_THICKNESS
    local _, updateShine = applyShinyGradient(Stroke, Theme.InactiveStroke)

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
            MenuBat.Visible = false; MenuFly.Visible = false; MenuS4.Visible = false
            if stateKey == "BatFucker" then MenuBat.Visible = true
            elseif stateKey == "Fly" then MenuFly.Visible = true
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
                TweenService:Create(Btn, TweenFast, {BackgroundColor3 = Theme.PanelBg, BackgroundTransparency = 0.2}):Play()
                updateShine(Theme.PurpleNeon)
            else
                TweenService:Create(Btn, TweenFast, {BackgroundColor3 = Theme.Background, BackgroundTransparency = 0.55}):Play()
                updateShine(Theme.InactiveStroke)
            end
        end)
    else
        Btn.Activated:Connect(function()
            task.spawn(function()
                TweenService:Create(Btn, TweenFast, {BackgroundColor3 = Theme.PanelBg, BackgroundTransparency = 0.2}):Play()
                updateShine(Theme.PurpleNeon)
                task.wait(0.15)
                TweenService:Create(Btn, TweenFast, {BackgroundColor3 = Theme.Background, BackgroundTransparency = 0.55}):Play()
                updateShine(Theme.InactiveStroke)
            end)
            if callback then callback() end
        end)
    end
end

-- S4DUELS Tab
CreateHubButton(TabS4Duels, "duelfucker", "DuelFuckerMode", false)
CreateHubButton(TabS4Duels, "Auto Duel", "AutoDuel", false) 
CreateHubButton(TabS4Duels, "AIM FUCKER", "AimFucker", false) 
CreateHubButton(TabS4Duels, "Bat Fucker", "BatFucker", true)
CreateHubButton(TabS4Duels, "Fly", "Fly", true)
CreateHubButton(TabS4Duels, "S4BOOSTER", "S4Booster", true, function(state)
    if not state and Player.Character and Player.Character:FindFirstChild("Humanoid") then
        Player.Character.Humanoid.WalkSpeed = 16
    end
end)
CreateHubButton(TabS4Duels, "Instant Steal", "InstantSteal", false)
CreateHubButton(TabS4Duels, "Unwalk", "Unwalk", false)
CreateHubButton(TabS4Duels, "Anti Ragdoll", "AntiRagdoll", false)
CreateHubButton(TabS4Duels, "ESP", "ESP", false)

-- SERVER Tab
CreateHubButton(TabServer, "FPS Booster", nil, false, function()
    local Lighting = game:GetService("Lighting")
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Material = Enum.Material.SmoothPlastic
            v.Reflectance = 0
            v.CastShadow = false
        elseif v:IsA("Decal") or v:IsA("Texture") then
            v.Transparency = 1
        end
    end
end)
CreateHubButton(TabServer, "Taunt Chat", nil, false, function()
    if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        local channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
        if channel then channel:SendAsync("S4DUELS ON TOP") end
    else
        local rme = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
        if rme and rme:FindFirstChild("SayMessageRequest") then 
            rme.SayMessageRequest:FireServer("S4DUELS ON TOP", "All") 
        end
    end
end)
CreateHubButton(TabServer, "Rejoin Server", nil, false, function() TeleportService:Teleport(game.PlaceId, Player) end)
CreateHubButton(TabServer, "Server Hop", nil, false, function() TeleportService:Teleport(game.PlaceId) end)
CreateHubButton(TabServer, "Kick Self", nil, false, function() Player:Kick("S4DUELS Manual Disconnect") end)

-- ==========================================
-- ========== CORE V3 PHYSICS ENGINE ========
-- ==========================================
local function clearPhysics(char)
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if hrp then
        local att = hrp:FindFirstChild("S4_Attachment")
        local lv = hrp:FindFirstChild("S4_LinearVelocity")
        local ao = hrp:FindFirstChild("S4_AlignOrientation")
        if att then att:Destroy() end
        if lv then lv:Destroy() end
        if ao then ao:Destroy() end
    end
    if hum and not States.AimFucker then 
        hum.AutoRotate = true 
    end
end

local function getPhysics(hrp)
    local att = hrp:FindFirstChild("S4_Attachment")
    if not att then
        att = Instance.new("Attachment", hrp)
        att.Name = "S4_Attachment"
    end
    local lv = hrp:FindFirstChild("S4_LinearVelocity")
    if not lv then
        lv = Instance.new("LinearVelocity", hrp)
        lv.Name = "S4_LinearVelocity"
        lv.Attachment0 = att
        lv.MaxForce = 0 
        lv.RelativeTo = Enum.ActuatorRelativeTo.World
    end
    local ao = hrp:FindFirstChild("S4_AlignOrientation")
    if not ao then
        ao = Instance.new("AlignOrientation", hrp)
        ao.Name = "S4_AlignOrientation"
        ao.Attachment0 = att
        ao.Mode = Enum.OrientationAlignmentMode.OneAttachment
        ao.RigidityEnabled = true
    end
    return lv, ao
end

-- AUTO DUEL MEMORY
local lastCarryState = false
local currentAutoTarget = nil

-- HEARTBEAT DRIVER
RunService.Heartbeat:Connect(function()
    local char = Player.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end

    local needsLV = false
    local needsAO = false

    -- Fast Target Caching for AimFucker
    if States.AimFucker then
        local shortestDist = math.huge
        local targetPart = nil
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= Player and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                local part = p.Character:FindFirstChild("UpperTorso") or p.Character:FindFirstChild("HumanoidRootPart") or p.Character.PrimaryPart
                if part then
                    local dist = (part.Position - hrp.Position).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        targetPart = part
                    end
                end
            end
        end
        CurrentAimTarget = targetPart
    else
        CurrentAimTarget = nil
    end

    -- === GLOBAL PHYSICS RESET ===
    hum.PlatformStand = (States.BatFucker or States.Fly or States.AutoDuel)

    -- === ANTI RAGDOLL / ANTI FLING SYSTEM ===
    if States.AntiRagdoll then
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
        
        local state = hum:GetState()
        if state == Enum.HumanoidStateType.Ragdoll or state == Enum.HumanoidStateType.FallingDown or state == Enum.HumanoidStateType.Physics then
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end

        for _, obj in pairs(hrp:GetChildren()) do
            if obj:IsA("BodyVelocity") or obj:IsA("BodyThrust") or obj:IsA("BodyForce") or obj:IsA("LinearVelocity") or obj:IsA("VectorForce") or obj:IsA("AngularVelocity") then
                if not string.find(obj.Name, "S4_") then
                    obj:Destroy()
                end
            end
        end

        if not States.Fly and not States.BatFucker and not States.S4Booster and not States.AutoDuel then
            hrp.AssemblyAngularVelocity = Vector3.zero
            if hrp.AssemblyLinearVelocity.Magnitude > 100 then
                hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
            end
        end

        local shouldLockFOV = false
        local function checkFOVLock(parent)
            if not parent then return end
            for _, v in pairs(parent:GetChildren()) do
                local lowerName = string.lower(v.Name)
                if string.find(lowerName, "bee") or string.find(lowerName, "zoom") or string.find(lowerName, "yellow") then
                    shouldLockFOV = true
                end
                if v:IsA("ColorCorrectionEffect") and v.TintColor.R > 0.6 and v.TintColor.G > 0.6 and v.TintColor.B < 0.5 then
                    shouldLockFOV = true
                end
            end
        end
        
        checkFOVLock(char)
        checkFOVLock(Player:FindFirstChild("PlayerGui"))
        checkFOVLock(game:GetService("Lighting"))

        if shouldLockFOV then
            if Camera.FieldOfView < 70 or Camera.FieldOfView > 120 then
                Camera.FieldOfView = 70
            end
        end

        local badKeywords = {"bee", "invert", "yellow", "zoom", "confusion", "stun", "ragdoll", "dizzy", "sentry", "turret"}
        local function sweepBadEffects(parent)
            if not parent then return end
            for _, v in pairs(parent:GetChildren()) do
                local lowerName = string.lower(v.Name)
                for _, bad in pairs(badKeywords) do
                    if string.find(lowerName, bad) then
                        if v:IsA("Script") or v:IsA("LocalScript") or v:IsA("ScreenGui") or v:IsA("ParticleEmitter") or v:IsA("ColorCorrectionEffect") or v:IsA("BlurEffect") or v:IsA("Folder") or v:IsA("StringValue") or v:IsA("BoolValue") then
                            pcall(function() v:Destroy() end)
                        elseif string.find(bad, "sentry") or string.find(bad, "turret") then
                             pcall(function() v:Destroy() end)
                        end
                        break
                    end
                end
            end
        end
        
        sweepBadEffects(char)
        sweepBadEffects(Player:FindFirstChild("PlayerGui"))
        sweepBadEffects(game:GetService("Lighting"))
        sweepBadEffects(workspace)
    end

    -- === AIM FUCKER (UNIVERSAL AUTO-FACE & QUANTUM BAT) ===
    if States.AimFucker then
        if CurrentAimTarget then
            hum.AutoRotate = false
            needsAO = true
            local _, ao = getPhysics(hrp)
            if not States.BatFucker and not States.Fly and not States.AutoDuel then 
                ao.CFrame = CFrame.lookAt(hrp.Position, Vector3.new(CurrentAimTarget.Position.X, hrp.Position.Y, CurrentAimTarget.Position.Z))
            end
            
            local tool = char:FindFirstChildOfClass("Tool")
            if tool and tool:FindFirstChild("Handle") then
                local handle = tool.Handle
                for _, obj in pairs(workspace:GetDescendants()) do
                    local lowerName = string.lower(obj.Name)
                    if string.find(lowerName, "sentry") or string.find(lowerName, "turret") then
                        local targetHitbox = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                        if targetHitbox and firetouchinterest then
                            pcall(function()
                                firetouchinterest(handle, targetHitbox, 0)
                                firetouchinterest(handle, targetHitbox, 1)
                            end)
                        end
                    end
                end
            end

        else
            if not States.BatFucker and not States.AutoDuel then hum.AutoRotate = true end
        end
    else
        if not States.BatFucker and not States.AutoDuel then hum.AutoRotate = true end
    end

    -- === PHYSICS LOGIC ===
    if States.AutoDuel then
        hum.AutoRotate = false 
        needsLV = true
        needsAO = true
        
        local isCarrying = Player:GetAttribute("Stealing")
        
        if lastCarryState ~= isCarrying or not currentAutoTarget then
            local distL = (hrp.Position - BaseL_Center).Magnitude
            local distR = (hrp.Position - BaseR_Center).Magnitude
            
            -- If carry state changed, or initializing, Target is ALWAYS the furthest base
            currentAutoTarget = (distL > distR) and BaseL_Center or BaseR_Center
            lastCarryState = isCarrying
        end
        
        local lv, ao = getPhysics(hrp)
        lv.MaxForce = 9e9
        ao.CFrame = CFrame.lookAt(hrp.Position, currentAutoTarget)
        
        local dir = (currentAutoTarget - hrp.Position)
        if dir.Magnitude > 3 then
            dir = dir.Unit
            local speed = isCarrying and Config.FlyCarrySpeed or Config.FlySpeed
            lv.VectorVelocity = dir * speed
        else
            lv.VectorVelocity = Vector3.zero
        end

    elseif States.BatFucker then
        hum.AutoRotate = false 
        needsLV = true
        needsAO = true
        
        local bfTarget = CurrentAimTarget 
        if not bfTarget then 
            local shortestDist = math.huge
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= Player and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                    local part = p.Character:FindFirstChild("Head") or p.Character:FindFirstChild("UpperTorso") or p.Character:FindFirstChild("Torso") or p.Character:FindFirstChild("HumanoidRootPart")
                    if part then
                        local dist = (part.Position - hrp.Position).Magnitude
                        if dist < shortestDist then
                            shortestDist = dist
                            bfTarget = part
                        end
                    end
                end
            end
        end

        if bfTarget then
            local lv, ao = getPhysics(hrp)
            lv.MaxForce = 9e9
            local targetPos = bfTarget.Position
            local myPos = hrp.Position
            local distanceToTarget = (targetPos - myPos).Magnitude

            if distanceToTarget > 0.1 then
                ao.CFrame = CFrame.lookAt(myPos, targetPos)
            end

            local dirFromTarget = (myPos - targetPos)
            if dirFromTarget.Magnitude > 0.1 then 
                dirFromTarget = dirFromTarget.Unit 
            else 
                dirFromTarget = Vector3.new(0, 0, 1) 
            end
            
            local optimalStrikePos = targetPos + (dirFromTarget * 2.5)
            local distToOptimal = (optimalStrikePos - myPos).Magnitude

            if distanceToTarget > 8 then
                local timeToReach = math.clamp(distanceToTarget / Config.BatSpeed, 0, 0.3)
                local predictedPos = optimalStrikePos + (bfTarget.AssemblyLinearVelocity * timeToReach)
                local chaseDir = (predictedPos - myPos)
                if chaseDir.Magnitude > 0 then chaseDir = chaseDir.Unit else chaseDir = Vector3.zero end
                
                lv.VectorVelocity = chaseDir * Config.BatSpeed
            else
                if distToOptimal > 0.5 then
                    local stickDir = (optimalStrikePos - myPos).Unit
                    local lungeSpeed = math.min(25, distToOptimal * 8) 
                    lv.VectorVelocity = bfTarget.AssemblyLinearVelocity + (stickDir * lungeSpeed)
                else
                    lv.VectorVelocity = bfTarget.AssemblyLinearVelocity
                end
            end
        end

    elseif States.Fly then
        needsLV = true
        needsAO = true
        
        local lv, ao = getPhysics(hrp)
        lv.MaxForce = 9e9
        
        ao.CFrame = Camera.CFrame

        local moveDir = hum.MoveDirection
        if moveDir.Magnitude > 0 then
            local speed = Player:GetAttribute("Stealing") and Config.FlyCarrySpeed or Config.FlySpeed
            local flatLook = Vector3.new(Camera.CFrame.LookVector.X, 0, Camera.CFrame.LookVector.Z)
            if flatLook.Magnitude > 0 then flatLook = flatLook.Unit else flatLook = Vector3.new(0,0,1) end
            
            local forwardMag = moveDir:Dot(flatLook)
            local rightMag = moveDir:Dot(Camera.CFrame.RightVector)
            
            local flyDir = (Camera.CFrame.LookVector * forwardMag + Camera.CFrame.RightVector * rightMag)
            if flyDir.Magnitude > 0 then flyDir = flyDir.Unit end
            lv.VectorVelocity = flyDir * speed
        else
            lv.VectorVelocity = Vector3.zero
        end

    elseif States.S4Booster then
        needsLV = true
        local lv, _ = getPhysics(hrp)
        lv.MaxForce = 9e9
        
        if hum.MoveDirection.Magnitude > 0 then
            local speed = Player:GetAttribute("Stealing") and Config.CarrySpeed or Config.WalkSpeed
            local velocityDir = hum.MoveDirection * speed
            hrp.AssemblyLinearVelocity = Vector3.new(velocityDir.X, hrp.AssemblyLinearVelocity.Y, velocityDir.Z)
            lv.VectorVelocity = Vector3.new(velocityDir.X, hrp.AssemblyLinearVelocity.Y, velocityDir.Z)
        else
            lv.MaxForce = 0
        end
    end

    if not needsLV and hrp:FindFirstChild("S4_LinearVelocity") then
        hrp.S4_LinearVelocity.MaxForce = 0
    end
    if not needsAO and hrp:FindFirstChild("S4_AlignOrientation") then
        hrp.S4_AlignOrientation:Destroy()
    end
    if not needsLV and not needsAO then
        clearPhysics(char)
    end
end)

-- ==========================================
-- = INSTANT STEAL (HEARTBEAT OPTIMIZED) ====
-- ==========================================
local promptCache = {}

local function updatePromptCache()
    promptCache = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then table.insert(promptCache, obj) end
    end
end
updatePromptCache()
workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("ProximityPrompt") then table.insert(promptCache, obj) end
end)

RunService.Heartbeat:Connect(function()
    if not States.InstantSteal and not States.AutoDuel then return end
    if not Player.Character then return end
    
    if Player:GetAttribute("Stealing") then return end

    local hrp = Player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local closestPrompt = nil
    local closestDist = math.huge

    for i = #promptCache, 1, -1 do
        local prompt = promptCache[i]
        if not prompt or not prompt.Parent then
            table.remove(promptCache, i)
        elseif prompt.Enabled then
            local act = tostring(prompt.ActionText)
            if act == "Steal" or act == "Rob" or act == "Collect" then
                local part = prompt.Parent
                local pos = part:IsA("BasePart") and part.Position or (part:IsA("Attachment") and part.WorldPosition or nil)
                if pos then
                    local dist = (pos - hrp.Position).Magnitude
                    if dist <= prompt.MaxActivationDistance then
                        if dist < closestDist then
                            closestDist = dist
                            closestPrompt = prompt
                        end
                    end
                end
            end
        end
    end

    if closestPrompt and not closestPrompt:GetAttribute("S4_Stealing") then
        closestPrompt:SetAttribute("S4_Stealing", true)
        task.spawn(function()
            pcall(function()
                closestPrompt.RequiresLineOfSight = false
                closestPrompt.HoldDuration = 0
                if type(fireproximityprompt) == "function" then
                    fireproximityprompt(closestPrompt, 1)
                    fireproximityprompt(closestPrompt, 0)
                else
                    closestPrompt:InputHoldBegin()
                    task.wait()
                    closestPrompt:InputHoldEnd()
                end
            end)
            task.wait(0.1) 
            if closestPrompt then closestPrompt:SetAttribute("S4_Stealing", nil) end
        end)
    end
end)

-- === UNWALK ===
task.spawn(function()
    while task.wait(0.5) do
        if States.Unwalk then
            local char = Player.Character
            if char then
                local anim = char:FindFirstChild("Animate")
                if anim then anim.Disabled = true end
                local hum = char:FindFirstChild("Humanoid")
                if hum then
                    for _, track in pairs(hum:GetPlayingAnimationTracks()) do track:Stop() end
                end
            end
        end
    end
end)

-- === ESP RENDER (ANTI-DESYNC) ===
task.spawn(function()
    while task.wait(0.5) do
        if States.ESP then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= Player and p.Character then
                    if not p.Character:FindFirstChild("S4_ESP_HL") then
                        local hl = Instance.new("Highlight")
                        hl.Name = "S4_ESP_HL"
                        hl.FillColor = Theme.Danger
                        hl.FillTransparency = 0.5
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.Adornee = p.Character
                        hl.Parent = p.Character
                    end
                    
                    if not p.Character:FindFirstChild("S4_ESP_TAG") then
                        local head = p.Character:FindFirstChild("Head") or p.Character:FindFirstChild("HumanoidRootPart") or p.Character.PrimaryPart
                        if head then
                            local bb = Instance.new("BillboardGui")
                            bb.Name = "S4_ESP_TAG"
                            bb.Size = UDim2.new(0, 200, 0, 40)
                            bb.AlwaysOnTop = true
                            bb.StudsOffset = Vector3.new(0, 2.5, 0)
                            bb.Adornee = head
                            bb.Parent = p.Character
                            
                            local txt = Instance.new("TextLabel", bb)
                            txt.Size = UDim2.new(1, 0, 1, 0)
                            txt.BackgroundTransparency = 1
                            txt.Text = p.Name
                            txt.TextColor3 = Theme.TextWhite
                            txt.Font = Enum.Font.GothamBlack
                            txt.TextSize = 13
                            
                            local stroke = Instance.new("TextStroke", txt)
                            stroke.Color = Color3.new(0, 0, 0)
                            stroke.Thickness = 1
                            stroke.Transparency = 0
                        end
                    else
                        local tag = p.Character:FindFirstChild("S4_ESP_TAG")
                        local head = p.Character:FindFirstChild("Head") or p.Character:FindFirstChild("HumanoidRootPart") or p.Character.PrimaryPart
                        if tag and head and tag.Adornee ~= head then
                            tag.Adornee = head
                        end
                    end
                end
            end
        else
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character then
                    local hl = p.Character:FindFirstChild("S4_ESP_HL")
                    if hl then hl:Destroy() end
                    local tag = p.Character:FindFirstChild("S4_ESP_TAG")
                    if tag then tag:Destroy() end
                end
            end
        end
    end
end)

-- === INF JUMP ===
UserInputService.JumpRequest:Connect(function()
    if States.InfJump and Player.Character then
        local hrp = Player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 50, hrp.AssemblyLinearVelocity.Z)
        end
    end
end)

-- FPS & PING Updates
local lastFpsUpdate = 0
local frameCount = 0

RunService.RenderStepped:Connect(function(deltaTime)
    frameCount = frameCount + 1
    if tick() - lastFpsUpdate >= 0.5 then
        local fps = math.floor(frameCount / (tick() - lastFpsUpdate))
        local ping = 0
        pcall(function() ping = math.floor(Player:GetNetworkPing() * 1000) end)
        StatsLabel.Text = string.format("FPS: %d | PING: %dms", fps, ping)
        frameCount = 0
        lastFpsUpdate = tick()
    end
end)

-- Cleanup on Death
Player.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid").Died:Connect(function()
        States.BatFucker = false
        States.AimFucker = false
        States.Fly = false
        States.AutoDuel = false
        
        if UIRegistry["BatFucker"] then
            for _, func in pairs(UIRegistry["BatFucker"]) do func(false) end
        end
        if UIRegistry["AimFucker"] then
            for _, func in pairs(UIRegistry["AimFucker"]) do func(false) end
        end
        if UIRegistry["Fly"] then
            for _, func in pairs(UIRegistry["Fly"]) do func(false) end
        end
        if UIRegistry["AutoDuel"] then
            for _, func in pairs(UIRegistry["AutoDuel"]) do func(false) end
        end
    end)
end)
