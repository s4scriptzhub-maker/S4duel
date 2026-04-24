-- [[ STANDALONE FLY ENGINE ]] --
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

-- ==========================================
-- ========== BASIC FLOATING UI =============
-- ==========================================
local GUI_NAME = "Standalone_Fly_HUD"

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

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 140, 0, 42)
Frame.Position = UDim2.new(0.5, -70, 0.8, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25, 10, 40)
Frame.BackgroundTransparency = 0.2
Frame.BorderSizePixel = 0
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 4)

local Stroke = Instance.new("UIStroke", Frame)
Stroke.Thickness = 1.2
Stroke.Color = Color3.fromRGB(70, 40, 90)

local FlyBtn = Instance.new("TextButton", Frame)
FlyBtn.Size = UDim2.new(1, 0, 1, 0)
FlyBtn.BackgroundTransparency = 1
FlyBtn.Text = "Toggle Fly"
FlyBtn.TextColor3 = Color3.fromRGB(245, 245, 250)
FlyBtn.Font = Enum.Font.GothamBold
FlyBtn.TextSize = 14

-- Dragging Logic
local dragging, dragInput, dragStart, startPos
FlyBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

FlyBtn.Activated:Connect(function()
    FlyEnabled = not FlyEnabled
    if FlyEnabled then
        FlyBtn.TextColor3 = Color3.fromRGB(40, 255, 120)
        Stroke.Color = Color3.fromRGB(210, 50, 255)
    else
        FlyBtn.TextColor3 = Color3.fromRGB(245, 245, 250)
        Stroke.Color = Color3.fromRGB(70, 40, 90)
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
    if not att then
        att = Instance.new("Attachment", hrp)
        att.Name = "Fly_Attachment"
    end
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
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end

    if FlyEnabled then
        hum.PlatformStand = true
        
        local lv, ao = getPhysics(hrp)
        lv.MaxForce = 9e9
        
        -- Locks orientation to camera
        ao.CFrame = Camera.CFrame

        local moveDir = hum.MoveDirection
        if moveDir.Magnitude > 0 then
            -- Smart carry detection for "Steal a Brainrot"
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
    else
        clearPhysics(char)
    end
end)

-- Clean up state if player dies
Player.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid").Died:Connect(function()
        FlyEnabled = false
        FlyBtn.TextColor3 = Color3.fromRGB(245, 245, 250)
        Stroke.Color = Color3.fromRGB(70, 40, 90)
    end)
end)
