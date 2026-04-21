local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local playerGui = Player:WaitForChild("PlayerGui")

-- === CONFIGURATION ===
local normalSpeed = 60
local carrySpeed = 29
local boosterEnabled = false

-- === IMPROVED AUTO-DETECTION ===
-- This looks for the "Brainrot" based on how the game formats names ($ or rarity brackets)
local function isHoldingBrainrot()
    local char = Player.Character
    if not char then return false end

    -- Check for Tools or Models welded to you
    for _, item in pairs(char:GetDescendants()) do
        -- 1. Check for the floating text UI that most Brainrot games use
        if item:IsA("BillboardGui") or item:IsA("SurfaceGui") then
            return true
        end
        
        -- 2. Check for name patterns like "[Legendary]" or "$500"
        local name = item.Name:lower()
        if name:find("%[") or name:find("%$") or name:find("per sec") then
            return true
        end
    end
    return false
end

-- === SPEED OVERRIDE LOOP ===
RunService.Heartbeat:Connect(function()
    if not boosterEnabled then return end
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if hrp and hum and hum.MoveDirection.Magnitude > 0.1 then
        -- AUTO SWITCH LOGIC
        local currentMax = isHoldingBrainrot() and carrySpeed or normalSpeed
        
        local velocity = hum.MoveDirection * currentMax
        hrp.AssemblyLinearVelocity = Vector3.new(velocity.X, hrp.AssemblyLinearVelocity.Y, velocity.Z)
    end
end)

-- === UI REFINEMENT (S4booster Button & Settings) ===
local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.ResetOnSpawn = false

-- Main Container (Same style as your header)
local function createPremiumFrame(name, size, pos)
    local f = Instance.new("Frame", screenGui)
    f.Name = name; f.Size = size; f.Position = pos
    f.BackgroundColor3 = Color3.fromRGB(10, 8, 15); f.BackgroundTransparency = 0.35
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 4)
    local s = Instance.new("UIStroke", f)
    s.Thickness = 1.2; s.Color = Color3.fromRGB(190, 0, 255)
    return f
end

local boosterBtn = createPremiumFrame("S4boosterBtn", UDim2.new(0, 180, 0, 40), UDim2.new(0.5, -90, 0.4, 0))
local mainBtn = Instance.new("TextButton", boosterBtn)
mainBtn.Size = UDim2.new(1, 0, 1, 0); mainBtn.BackgroundTransparency = 1
mainBtn.Text = "S4booster"; mainBtn.TextColor3 = Color3.new(1,1,1); mainBtn.Font = Enum.Font.GothamBold

-- Small Settings Icon
local gear = Instance.new("TextButton", boosterBtn)
gear.Size = UDim2.new(0, 20, 0, 20); gear.Position = UDim2.new(1, -25, 0.5, -10)
gear.Text = "⚙"; gear.TextColor3 = Color3.fromRGB(0, 200, 255); gear.BackgroundTransparency = 1

-- Seperate Settings GUI
local settingsGui = createPremiumFrame("BoosterSettings", UDim2.new(0, 220, 0, 160), UDim2.new(0.5, 100, 0.5, -80))
settingsGui.Visible = false

local function makeInput(label, default, y)
    local l = Instance.new("TextLabel", settingsGui)
    l.Text = label; l.Position = UDim2.new(0, 10, 0, y); l.Size = UDim2.new(0, 100, 0, 20)
    l.TextColor3 = Color3.new(0.8, 0.8, 0.8); l.BackgroundTransparency = 1; l.TextXAlignment = Enum.TextXAlignment.Left
    
    local i = Instance.new("TextBox", settingsGui)
    i.Size = UDim2.new(0, 80, 0, 20); i.Position = UDim2.new(0, 120, 0, y)
    i.Text = tostring(default); i.BackgroundColor3 = Color3.fromRGB(25, 25, 30); i.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", i)
    return i
end

local normInp = makeInput("Normal (1-60):", 60, 20)
local carryInp = makeInput("Carry (1-29):", 29, 55)

local saveBtn = Instance.new("TextButton", settingsGui)
saveBtn.Size = UDim2.new(0.8, 0, 0, 30); saveBtn.Position = UDim2.new(0.1, 0, 1, -45)
saveBtn.Text = "SAVE & APPLY"; saveBtn.BackgroundColor3 = Color3.fromRGB(30, 40, 30); saveBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", saveBtn)

-- Logic for UI Interaction
mainBtn.MouseButton1Click:Connect(function()
    boosterEnabled = not boosterEnabled
    boosterBtn.UIStroke.Color = boosterEnabled and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(190, 0, 255)
end)

gear.MouseButton1Click:Connect(function() settingsGui.Visible = not settingsGui.Visible end)

saveBtn.MouseButton1Click:Connect(function()
    normalSpeed = math.clamp(tonumber(normInp.Text) or 60, 1, 60)
    carrySpeed = math.clamp(tonumber(carryInp.Text) or 29, 1, 29)
    saveBtn.Text = "SAVED!"; task.wait(0.5); saveBtn.Text = "SAVE & APPLY"
end)
