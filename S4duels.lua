local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local playerGui = Player:WaitForChild("PlayerGui")

-- === CONFIGURATION ===
local normalSpeed = 60
local carrySpeed = 29
local boosterEnabled = false

-- === LOGISTICS: ATTACHMENT DETECTION ===
local function isHoldingBrainrot()
    local char = Player.Character
    if not char then return false end

    -- 1. Check for any Model/Part attached to your upper body (where visual objects go)
    local checkAreas = {char:FindFirstChild("Head"), char:FindFirstChild("UpperTorso"), char:FindFirstChild("LowerTorso")}
    
    for _, area in pairs(checkAreas) do
        if area then
            for _, child in pairs(area:GetChildren()) do
                -- If there's a Model or Part welded there that isn't a standard accessory/hat
                if (child:IsA("Model") or child:IsA("BasePart")) and not child:IsA("Accessory") then
                    return true
                end
            end
        end
    end

    -- 2. Fallback: Check character for the "Stolen" marker or Brainrot UI
    for _, v in pairs(char:GetDescendants()) do
        if v.Name == "Stolen" or v:IsA("BillboardGui") or v.Name:find("%$") then
            return true
        end
    end

    return false
end

-- === SPEED OVERRIDE ENGINE ===
RunService.Heartbeat:Connect(function()
    if not boosterEnabled then return end
    
    local char = Player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if hrp and hum and hum.MoveDirection.Magnitude > 0.1 then
        -- Switches to Carry Speed if ANY visual brainrot is detected on the player
        local targetSpeed = isHoldingBrainrot() and carrySpeed or normalSpeed
        
        local moveVel = hum.MoveDirection * targetSpeed
        hrp.AssemblyLinearVelocity = Vector3.new(moveVel.X, hrp.AssemblyLinearVelocity.Y, moveVel.Z)
    end
end)

-- === PREMIUM UI (S4booster + Settings) ===
local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.ResetOnSpawn = false

local function createNeonFrame(name, size, pos, color)
    local f = Instance.new("Frame", screenGui)
    f.Name = name; f.Size = size; f.Position = pos
    f.BackgroundColor3 = Color3.fromRGB(10, 8, 15); f.BackgroundTransparency = 0.3
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 4)
    local s = Instance.new("UIStroke", f)
    s.Thickness = 1.2; s.Color = color or Color3.fromRGB(190, 0, 255)
    return f
end

-- Main Button
local boosterCont = createNeonFrame("BoosterMain", UDim2.new(0, 180, 0, 40), UDim2.new(0.5, -90, 0.1, 0))
local mainBtn = Instance.new("TextButton", boosterCont)
mainBtn.Size = UDim2.new(1, 0, 1, 0); mainBtn.BackgroundTransparency = 1; mainBtn.Text = "S4booster"; mainBtn.TextColor3 = Color3.new(1,1,1); mainBtn.Font = Enum.Font.GothamBold

-- Gear Icon
local gear = Instance.new("TextButton", boosterCont)
gear.Size = UDim2.new(0, 20, 0, 20); gear.Position = UDim2.new(1, -25, 0.5, -10); gear.Text = "⚙"; gear.TextColor3 = Color3.fromRGB(0, 200, 255); gear.BackgroundTransparency = 1

-- Settings Sub-Menu
local setGui = createNeonFrame("BoosterSettings", UDim2.new(0, 220, 0, 160), UDim2.new(0.5, 100, 0.5, -80))
setGui.Visible = false

local function addInput(txt, val, y)
    local l = Instance.new("TextLabel", setGui)
    l.Text = txt; l.Position = UDim2.new(0, 10, 0, y); l.Size = UDim2.new(0, 100, 0, 20); l.TextColor3 = Color3.new(0.8, 0.8, 0.8); l.BackgroundTransparency = 1; l.TextXAlignment = "Left"
    local i = Instance.new("TextBox", setGui)
    i.Size = UDim2.new(0, 80, 0, 22); i.Position = UDim2.new(0, 125, 0, y); i.Text = tostring(val); i.BackgroundColor3 = Color3.fromRGB(25, 25, 35); i.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", i)
    return i
end

local nInp = addInput("Normal (1-60):", normalSpeed, 25)
local cInp = addInput("Carry (1-29):", carrySpeed, 65)
local save = Instance.new("TextButton", setGui)
save.Size = UDim2.new(0.8, 0, 0, 30); save.Position = UDim2.new(0.1, 0, 1, -45); save.Text = "SAVE SETTINGS"; save.BackgroundColor3 = Color3.fromRGB(30, 45, 30); save.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", save)

-- === BUTTON CONNECTIONS ===
mainBtn.MouseButton1Click:Connect(function()
    boosterEnabled = not boosterEnabled
    boosterCont.UIStroke.Color = boosterEnabled and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(190, 0, 255)
end)

gear.MouseButton1Click:Connect(function() setGui.Visible = not setGui.Visible end)

save.MouseButton1Click:Connect(function()
    normalSpeed = math.clamp(tonumber(nInp.Text) or 60, 1, 60)
    carrySpeed = math.clamp(tonumber(cInp.Text) or 29, 1, 29)
    save.Text = "SAVED!"; task.wait(0.5); save.Text = "SAVE SETTINGS"
end)
