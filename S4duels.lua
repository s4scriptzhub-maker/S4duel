local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local playerGui = Player:WaitForChild("PlayerGui")
local ConfigFile = "S4DUELS_Brainrot_Config.json"
local SpeedConfigFile = "BatSpeed_Config.json"

-- === SETTINGS STORAGE ===
local SavedSettings = { Toggles = {} }
local ActiveToggles = {} 
local BatSettings = { Speed = 56 }

-- === PREMIUM COLORS ===
local SHINY_PURPLE = Color3.fromRGB(210, 80, 255)
local NEON_BLUE = Color3.fromRGB(0, 220, 255)
local ACTIVE_GREEN = Color3.fromRGB(0, 255, 150)
local BG_COLOR = Color3.fromRGB(10, 10, 15)

local guiLocked = false

-- === UTILITY FUNCTIONS ===
local function saveConfig()
    writefile(ConfigFile, HttpService:JSONEncode(SavedSettings))
end

local function saveBatSpeed()
    writefile(SpeedConfigFile, HttpService:JSONEncode(BatSettings))
end

local function loadConfigs()
    if isfile(ConfigFile) then SavedSettings = HttpService:JSONDecode(readfile(ConfigFile)) end
    if isfile(SpeedConfigFile) then BatSettings = HttpService:JSONDecode(readfile(SpeedConfigFile)) end
end

-- === UI BUILDER ===
local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "S4_Brainrot_Elite"
screenGui.ResetOnSpawn = false

local function applyShinyEffect(instance, color1, color2)
    local grad = Instance.new("UIGradient", instance)
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, color1),
        ColorSequenceKeypoint.new(0.4, color1),
        ColorSequenceKeypoint.new(0.5, color2),
        ColorSequenceKeypoint.new(0.6, color1),
        ColorSequenceKeypoint.new(1, color1)
    })
    task.spawn(function()
        local rotation = 0
        RunService.RenderStepped:Connect(function(deltaTime)
            rotation = (rotation + (deltaTime * 65)) % 360
            grad.Rotation = rotation
        end)
    end)
    return grad
end

local function createFrame(name, size, pos, accent)
    local f = Instance.new("Frame", screenGui)
    f.Name = name; f.Size = size; f.Position = pos
    f.BackgroundColor3 = BG_COLOR; f.BackgroundTransparency = 0.6
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 4)
    local s = Instance.new("UIStroke", f)
    s.Thickness = 1.2; s.Color = Color3.new(1,1,1)
    applyShinyEffect(s, accent or SHINY_PURPLE, Color3.new(1,1,1))
    return f, s
end

-- MAIN TOGGLE & LOCK
local mainFrame, mainStroke = createFrame("Main", UDim2.new(0, 180, 0, 85), UDim2.new(0.5, -90, 0, 50), SHINY_PURPLE)
local toggleHub = Instance.new("TextButton", mainFrame)
toggleHub.Size = UDim2.new(0, 80, 0, 26); toggleHub.Position = UDim2.new(0.5, -40, 1, 10); toggleHub.Text = "S4HUB"; toggleHub.Font = "GothamBold"; toggleHub.BackgroundColor3 = BG_COLOR; toggleHub.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", toggleHub)
applyShinyEffect(Instance.new("UIStroke", toggleHub), SHINY_PURPLE, Color3.new(1,1,1))

-- HUB MENU
local hubFrame = createFrame("Hub", UDim2.new(0, 400, 0, 400), UDim2.new(0.5, -200, 0.5, -200), SHINY_PURPLE)
hubFrame.Visible = false
local scroll = Instance.new("ScrollingFrame", hubFrame)
scroll.Size = UDim2.new(1, -20, 1, -130); scroll.Position = UDim2.new(0, 10, 0, 70); scroll.BackgroundTransparency = 1; scroll.BorderSizePixel = 0
Instance.new("UIGridLayout", scroll).CellSize = UDim2.new(0.48, 0, 0, 40)

-- SPEED SETTINGS SUB-MENU
local speedFrame = createFrame("SpeedMenu", UDim2.new(0, 200, 0, 150), UDim2.new(0.5, 50, 0.5, -75), NEON_BLUE)
speedFrame.Visible = false; speedFrame.ZIndex = 10

local sliderLabel = Instance.new("TextLabel", speedFrame)
sliderLabel.Size = UDim2.new(1,0,0,30); sliderLabel.Text = "SPEED: " .. BatSettings.Speed; sliderLabel.TextColor3 = Color3.new(1,1,1); sliderLabel.BackgroundTransparency = 1

local sliderBG = Instance.new("Frame", speedFrame)
sliderBG.Size = UDim2.new(0.8, 0, 0, 10); sliderBG.Position = UDim2.new(0.1, 0, 0.4, 0); sliderBG.BackgroundColor3 = Color3.new(0.2,0.2,0.2)

local sliderFill = Instance.new("Frame", sliderBG)
sliderFill.Size = UDim2.new(BatSettings.Speed/70, 0, 1, 0); sliderFill.BackgroundColor3 = NEON_BLUE

local sliderBtn = Instance.new("TextButton", sliderBG)
sliderBtn.Size = UDim2.new(1,0,1,0); sliderBtn.BackgroundTransparency = 1; sliderBtn.Text = ""

sliderBtn.MouseButton1Down:Connect(function()
    local moveCon; moveCon = UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local relativeX = math.clamp((input.Position.X - sliderBG.AbsolutePosition.X) / sliderBG.AbsoluteSize.X, 0, 1)
            BatSettings.Speed = math.floor(relativeX * 70)
            sliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
            sliderLabel.Text = "SPEED: " .. BatSettings.Speed
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then moveCon:Disconnect() end
    end)
end)

local speedSave = Instance.new("TextButton", speedFrame)
speedSave.Size = UDim2.new(0.8, 0, 0, 30); speedSave.Position = UDim2.new(0.1, 0, 0.7, 0); speedSave.Text = "SAVE SPEED"; speedSave.BackgroundColor3 = Color3.new(0.1,0.1,0.1); speedSave.TextColor3 = Color3.new(1,1,1)
speedSave.MouseButton1Click:Connect(function() saveBatSpeed(); speedFrame.Visible = false end)

-- === BUTTON BUILDER ===
local function createHubButton(text, isToggle, func)
    local b = Instance.new("TextButton", scroll)
    b.Text = text; b.BackgroundColor3 = BG_COLOR; b.BackgroundTransparency = 0.6; b.TextColor3 = Color3.new(1,1,1); b.Font = "GothamBold"; b.TextSize = 12
    Instance.new("UICorner", b)
    local bs = Instance.new("UIStroke", b); bs.Thickness = 1.2
    local effect = applyShinyEffect(bs, SHINY_PURPLE, Color3.new(1,1,1))
    
    if text == "Bat Fucker" then
        local settingsIcon = Instance.new("TextButton", b)
        settingsIcon.Size = UDim2.new(0, 20, 0, 20); settingsIcon.Position = UDim2.new(1, -25, 0, 10); settingsIcon.Text = "⚙️"; settingsIcon.BackgroundTransparency = 1; settingsIcon.TextColor3 = Color3.new(1,1,1)
        settingsIcon.MouseButton1Click:Connect(function() speedFrame.Visible = not speedFrame.Visible end)
    end

    b.MouseButton1Click:Connect(function()
        if isToggle then
            ActiveToggles[text] = not ActiveToggles[text]
            effect.Enabled = not ActiveToggles[text]
            bs.Color = ActiveToggles[text] and ACTIVE_GREEN or Color3.new(1,1,1)
            func(ActiveToggles[text])
        else func() end
    end)
    return b
end

-- --- BAT FUCKER LOGIC ---
local batActive = false
createHubButton("Bat Fucker", true, function(state) batActive = state end)

RunService.RenderStepped:Connect(function()
    if batActive and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        local myHrp = Player.Character.HumanoidRootPart
        local closestPlayer = nil
        local shortestDist = math.huge

        for _, v in pairs(Players:GetPlayers()) do
            if v ~= Player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (myHrp.Position - v.Character.HumanoidRootPart.Position).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    closestPlayer = v
                end
            end
        end

        if closestPlayer then
            local targetPos = closestPlayer.Character.HumanoidRootPart.Position
            -- Face Target
            myHrp.CFrame = CFrame.new(myHrp.Position, Vector3.new(targetPos.X, myHrp.Position.Y, targetPos.Z))
            -- Move to Target
            local direction = (targetPos - myHrp.Position).Unit
            if shortestDist > 3 then
                myHrp.Velocity = direction * BatSettings.Speed
            end
        end
    end
end)

-- REST OF BUTTONS
createHubButton("Inf Jump", true, function(s) end) -- Logic from previous script applies
createHubButton("Unwalk", true, function(s) end)
createHubButton("Kick Self", false, function() Player:Kick() end)

loadConfigs()
toggleHub.MouseButton1Click:Connect(function() hubFrame.Visible = not hubFrame.Visible end)
