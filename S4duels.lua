local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local playerGui = Player:WaitForChild("PlayerGui")

-- === CONFIGURATION & SAVED DATA ===
local NEON_PURPLE = Color3.fromRGB(190, 0, 255)
local NEON_BLUE = Color3.fromRGB(0, 200, 255)
local BG_COLOR = Color3.fromRGB(10, 8, 15)

local boosterEnabled = false
local guiLocked = false
local normalSpeed = 60
local carrySpeed = 29

-- === LOGIC: BRAINROT DETECTION ===
local function isHoldingBrainrot()
    local char = Player.Character
    if not char then return false end
    -- Checks for a Tool named "Brainrot" or a Part welded to the character
    for _, v in pairs(char:GetChildren()) do
        if (v:IsA("Tool") and v.Name:lower():find("brain")) or v.Name == "Brainrot" then
            return true
        end
    end
    return false
end

-- === LOGIC: SPEED OVERRIDE ===
RunService.Heartbeat:Connect(function()
    if not boosterEnabled then return end
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if hrp and hum and hum.MoveDirection.Magnitude > 0.1 then
        local targetSpeed = isHoldingBrainrot() and carrySpeed or normalSpeed
        local velocity = hum.MoveDirection * targetSpeed
        hrp.AssemblyLinearVelocity = Vector3.new(velocity.X, hrp.AssemblyLinearVelocity.Y, velocity.Z)
    end
end)

-- === UI BUILDER ===
local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.ResetOnSpawn = false

local function createFrame(name, size, pos, accent)
    local f = Instance.new("Frame", screenGui)
    f.Name = name; f.Size = size; f.Position = pos
    f.BackgroundColor3 = BG_COLOR; f.BackgroundTransparency = 0.35
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 4)
    local s = Instance.new("UIStroke", f)
    s.Thickness = 1.2; s.Color = accent or NEON_PURPLE
    return f, s
end

-- 1. MAIN HEADER
local mainFrame = createFrame("MainHeader", UDim2.new(0, 180, 0, 80), UDim2.new(0.5, -90, 0, 50))
local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 30); title.Text = "S4duels"; title.TextColor3 = Color3.new(1,1,1); title.Font = Enum.Font.GothamBold; title.BackgroundTransparency = 1

-- 2. BOOSTER SETTINGS GUI (Hidden by default)
local boosterSettings = createFrame("BoosterSettings", UDim2.new(0, 200, 0, 150), UDim2.new(0.5, 100, 0.5, -75))
boosterSettings.Visible = false

local function createSlider(parent, labelText, maxVal, defaultVal, yPos)
    local lab = Instance.new("TextLabel", parent)
    lab.Size = UDim2.new(1, 0, 0, 20); lab.Position = UDim2.new(0, 0, 0, yPos)
    lab.Text = labelText .. ": " .. defaultVal; lab.TextColor3 = Color3.new(1,1,1); lab.BackgroundTransparency = 1; lab.TextSize = 10
    
    local box = Instance.new("TextBox", parent)
    box.Size = UDim2.new(0.8, 0, 0, 20); box.Position = UDim2.new(0.1, 0, 0, yPos + 20)
    box.BackgroundColor3 = Color3.fromRGB(30, 30, 40); box.Text = tostring(defaultVal); box.TextColor3 = NEON_BLUE
    Instance.new("UICorner", box)
    return box, lab
end

local normalInput, normalLab = createSlider(boosterSettings, "Normal Speed (1-60)", 60, 60, 15)
local carryInput, carryLab = createSlider(boosterSettings, "Carry Speed (1-29)", 29, 29, 65)

local saveBtn = Instance.new("TextButton", boosterSettings)
saveBtn.Size = UDim2.new(0.6, 0, 0, 25); saveBtn.Position = UDim2.new(0.2, 0, 1, -35)
saveBtn.Text = "SAVE SETTINGS"; saveBtn.BackgroundColor3 = Color3.fromRGB(20, 50, 20); saveBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", saveBtn)

saveBtn.MouseButton1Click:Connect(function()
    normalSpeed = math.clamp(tonumber(normalInput.Text) or 60, 1, 60)
    carrySpeed = math.clamp(tonumber(carryInput.Text) or 29, 1, 29)
    normalLab.Text = "Normal Speed: " .. normalSpeed
    carryLab.Text = "Carry Speed: " .. carrySpeed
    saveBtn.Text = "SAVED!"; task.wait(1); saveBtn.Text = "SAVE SETTINGS"
end)

-- 3. BOOSTER BUTTON (REPLACES s4loading)
local boosterBtn = Instance.new("TextButton", mainFrame) -- This would go inside your scroll frame in the full GUI
boosterBtn.Size = UDim2.new(0.9, 0, 0, 35); boosterBtn.Position = UDim2.new(0.05, 0, 0.5, 5)
boosterBtn.Text = "S4booster"; boosterBtn.BackgroundColor3 = Color3.fromRGB(25, 20, 35); boosterBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", boosterBtn)
local bStroke = Instance.new("UIStroke", boosterBtn); bStroke.Thickness = 1; bStroke.Color = Color3.fromRGB(60,60,70)

-- Settings Icon (Bottom Right of Button)
local gearIcon = Instance.new("TextButton", boosterBtn)
gearIcon.Size = UDim2.new(0, 20, 0, 20); gearIcon.Position = UDim2.new(1, -22, 1, -22)
gearIcon.Text = "⚙"; gearIcon.BackgroundTransparency = 1; gearIcon.TextColor3 = NEON_BLUE; gearIcon.TextSize = 14

boosterBtn.MouseButton1Click:Connect(function()
    boosterEnabled = not boosterEnabled
    bStroke.Color = boosterEnabled and NEON_PURPLE or Color3.fromRGB(60,60,70)
    boosterBtn.BackgroundColor3 = boosterEnabled and Color3.fromRGB(40, 20, 60) or Color3.fromRGB(25, 20, 35)
end)

gearIcon.MouseButton1Click:Connect(function()
    boosterSettings.Visible = not boosterSettings.Visible
end)
