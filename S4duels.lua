-- [[ STANDALONE FLY ENGINE + SETTINGS ]] --
-- [[ EXTRACTED FROM V5.0 ARCHITECTURE ]] --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

while not Player do
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    Player = Players.LocalPlayer
end

local Config = {
    FlySpeed = 54,
    FlyCarrySpeed = 25
}

local FlyEnabled = false

-- Aesthetics
local Theme = {
    Background = Color3.fromRGB(25, 10, 40),      
    PanelBg = Color3.fromRGB(45, 20, 65),         
    PurpleNeon = Color3.fromRGB(210, 50, 255),    
    InactiveStroke = Color3.fromRGB(70, 40, 90),
    TextWhite = Color3.fromRGB(245, 245, 250),
    Success = Color3.fromRGB(40, 255, 120),
    Danger = Color3.fromRGB(255, 50, 70)
}

-- ==========================================
-- ========== GUI CLEANUP & SETUP ===========
-- ==========================================
local GUI_NAME = "Standalone_Fly_HUD_Pro"
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

-- Helper: Shiny Gradient
local function applyShinyGradient(parent, color1)
    local gradient = Instance.new("UIGradient", parent)
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, color1),
        ColorSequenceKeypoint.new(0.4, color1),
        ColorSequenceKeypoint.new(0.5, Color3.new(1, 1, 1)), 
        ColorSequenceKeypoint.new(0.6, color1),
        ColorSequenceKeypoint.new(1, color1)
    })
    task.spawn(function()
        local rot = 0
        RunService.RenderStepped:Connect(function(dt)
            rot = (rot + (dt * 150)) % 360 
            gradient.Rotation = rot
        end)
    end)
    return gradient
end

-- Helper: Draggable
local function MakeDraggable(frame, handle)
    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true 
            dragInput = input
            dragStart = input.Position 
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false dragInput = nil end
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
-- ========== FLOATING FLY BUTTON ===========
-- ==========================================
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 140, 0, 42)
Frame.Position = UDim2.new(0.5, -70, 0.8, 0)
Frame.BackgroundColor3 = Theme.Background
Frame.BackgroundTransparency = 0.2
Frame.BorderSizePixel = 0
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 4)

local Stroke = Instance.new("UIStroke", Frame)
Stroke.Thickness = 1.2
Stroke.Color = Theme.InactiveStroke
local shinyGrad = applyShinyGradient(Stroke, Theme.InactiveStroke)

local FlyBtn = Instance.new("TextButton", Frame)
FlyBtn.Size = UDim2.new(1, -30, 1, 0) 
FlyBtn.BackgroundTransparency = 1
FlyBtn.Text = "Toggle Fly"
FlyBtn.TextColor3 = Theme.TextWhite
FlyBtn.Font = Enum.Font.GothamBold
FlyBtn.TextSize = 13

local GearBtn = Instance.new("TextButton", Frame)
GearBtn.Size = UDim2.new(0, 30, 1, 0)
GearBtn.Position = UDim2.new(1, -30, 0, 0)
GearBtn.BackgroundTransparency = 1
GearBtn.Text = "⚙️"
GearBtn.TextSize = 14

MakeDraggable(Frame, Frame)

-- ==========================================
-- ========== SPEED SETTINGS MENU ===========
-- ==========================================
local MenuFly = Instance.new("Frame", ScreenGui)
MenuFly.Size = UDim2.new(0, 240, 0, 140)
MenuFly.Position = UDim2.new(0.5, -120, 0.5, -70)
MenuFly.BackgroundColor3 = Theme.Background
MenuFly.BackgroundTransparency = 0.1
MenuFly.Visible = false
Instance.new("UICorner", MenuFly).CornerRadius = UDim.new(0, 4)

local mStroke = Instance.new("UIStroke", MenuFly)
mStroke.Thickness = 1.2
applyShinyGradient(mStroke, Theme.PurpleNeon)

local title = Instance.new("TextLabel", MenuFly)
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 15, 0, 5)
title.Text = "FLY SPEEDS"
title.TextColor3 = Theme.TextWhite
title.Font = Enum.Font.GothamBlack
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Left
title.BackgroundTransparency = 1

local closeBtn = Instance.new("TextButton", MenuFly)
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Theme.Danger
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.BackgroundTransparency = 1
closeBtn.Activated:Connect(function() MenuFly.Visible = false end)

MakeDraggable(MenuFly, MenuFly)

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

    local track = Instance.new("TextButton", menu)
    track.Size = UDim2.new(1, -30, 0, 6)
    track.Position = UDim2.new(0, 15, 0, yPos + 22)
    track.BackgroundColor3 = Theme.PanelBg
    track.Text = ""
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame", track)
    fill.Size = UDim2.new(Config[varKey] / maxVal, 0, 1, 0)
    fill.BackgroundColor3 = Theme.PurpleNeon
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

addSpeedSlider(MenuFly, 40, "Fly Speed", "FlySpeed", 100)
addSpeedSlider(MenuFly, 100, "Fly Carry Speed", "FlyCarrySpeed", 50)

-- ==========================================
-- ========== BUTTON LOGIC ==================
-- ==========================================
GearBtn.Activated:Connect(function()
    MenuFly.Visible = not MenuFly.Visible
end)

FlyBtn.Activated:Connect(function()
    FlyEnabled = not FlyEnabled
    if FlyEnabled then
        FlyBtn.TextColor3 = Theme.Success
        shinyGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme.PurpleNeon),
            ColorSequenceKeypoint.new(0.4, Theme.PurpleNeon),
            ColorSequenceKeypoint.new(0.5, Color3.new(1, 1, 1)), 
            ColorSequenceKeypoint.new(0.6, Theme.PurpleNeon),
            ColorSequenceKeypoint.new(1, Theme.PurpleNeon)
        })
        Frame.BackgroundColor3 = Theme.PanelBg
    else
        FlyBtn.TextColor3 = Theme.TextWhite
        shinyGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme.InactiveStroke),
            ColorSequenceKeypoint.new(0.4, Theme.InactiveStroke),
            ColorSequenceKeypoint.new(0.5, Color3.new(1, 1, 1)), 
            ColorSequenceKeypoint.new(0.6, Theme.InactiveStroke),
            ColorSequenceKeypoint.new(1, Theme.InactiveStroke)
        })
        Frame.BackgroundColor3 = Theme.Background
    end
end)

-- ==========================================
-- ========== FLY PHYSICS ENGINE ============
-- ==========================================
local function clearPhysics(char)
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if hrp then
        local att = hrp:FindFirstChild("Fly_Attachment")
        local lv = hrp:FindFirstChild("Fly_LinearVelocity")
        local ao = hrp:FindFirstChild("Fly_AlignOrientation")
        if att then att:Destroy() end
        if lv then lv:Destroy() end
        if ao then ao:Destroy() end
    end
    if hum then hum.PlatformStand = false end
end

local function getPhysics(hrp)
    local att = hrp:FindFirstChild("Fly_Attachment")
    if not att then att = Instance.new("Attachment", hrp) att.Name = "Fly_Attachment" end
    
    local lv = hrp:FindFirstChild("Fly_LinearVelocity")
    if not lv then
        lv = Instance.new("LinearVelocity", hrp)
        lv.Name = "Fly_LinearVelocity"
        lv.Attachment0 = att
        lv.MaxForce = 9e9
        lv.RelativeTo = Enum.ActuatorRelativeTo.World
    end
    
    local ao = hrp:FindFirstChild("Fly_AlignOrientation")
    if not ao then
        ao = Instance.new("AlignOrientation", hrp)
        ao.Name = "Fly_AlignOrientation"
        ao.Attachment0 = att
        ao.Mode = Enum.OrientationAlignmentMode.OneAttachment
        ao.RigidityEnabled = true
    end
    return lv, ao
end

RunService.Heartbeat:Connect(function()
    local char = Player.Character
    if not char
