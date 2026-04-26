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
