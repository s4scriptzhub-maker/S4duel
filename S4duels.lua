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
local ESP_COLOR = Color3.fromRGB(255, 0, 0) -- Red for ESP

local guiLocked = false
local infJumpActive = false
local batActive = false
local espActive = false

-- === UTILITY FUNCTIONS ===
local function saveConfig()
    if writefile then writefile(ConfigFile, HttpService:JSONEncode(SavedSettings)) end
end

local function saveBatSpeed()
    if writefile then writefile(SpeedConfigFile, HttpService:JSONEncode(BatSettings)) end
end

local function loadConfigs()
    if isfile and isfile(ConfigFile) then
        local success, data = pcall(function() return HttpService:JSONDecode(readfile(ConfigFile)) end)
        if success then SavedSettings = data end
    end
    if isfile and isfile(SpeedConfigFile) then
        local success, data = pcall(function() return HttpService:JSONDecode(readfile(SpeedConfigFile)) end)
        if success then BatSettings = data end
    end
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

-- 1. LOCK BUTTON
local lockFrame, lockStroke = createFrame("Lock", UDim2.new(0, 95, 0, 30), UDim2.new(0.5, -240, 0, 50), NEON_BLUE)
local lockBtn = Instance.new("TextButton", lockFrame)
lockBtn.Size = UDim2.new(1, 0, 1, 0); lockBtn.BackgroundTransparency = 1; lockBtn.Text = "LOCK GUI"; lockBtn.TextColor3 = Color3.new(1,1,1); lockBtn.Font = "GothamBold"; lockBtn.TextSize = 10

-- 2. MAIN HEADER
local mainFrame = createFrame("Main", UDim2.new(0, 180, 0, 85), UDim2.new(0.5, -90, 0, 50), SHINY_PURPLE)
local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 35); title.Position = UDim2.new(0, 0, 0, 5); title.Text = "S4DUELS"; title.TextColor3 = Color3.new(1,1,1); title.Font = "ArialBold"; title.TextSize = 22; title.BackgroundTransparency = 1
local tStroke = Instance.new("UIStroke", title); tStroke.Thickness = 1.5; applyShinyEffect(tStroke, SHINY_PURPLE, Color3.new(1,1,1))

local stats = Instance.new("TextLabel", mainFrame)
stats.Size = UDim2.new(1, 0, 0, 15); stats.Position = UDim2.new(0,0,0,42); stats.TextColor3 = Color3.fromRGB(200,200,200); stats.TextSize = 8.5; stats.BackgroundTransparency = 1

local toggleHub = Instance.new("TextButton", mainFrame)
toggleHub.Size = UDim2.new(0, 80, 0, 26); toggleHub.Position = UDim2.new(0.5, -40, 1, 10); toggleHub.Text = "S4HUB"; toggleHub.Font = "GothamBold"; toggleHub.BackgroundColor3 = BG_COLOR; toggleHub.BackgroundTransparency = 0.6; toggleHub.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", toggleHub).CornerRadius = UDim.new(0, 4)
local thStroke = Instance.new("UIStroke", toggleHub); thStroke.Thickness = 1.2; applyShinyEffect(thStroke, SHINY_PURPLE, Color3.new(1,1,1))

-- 3. HUB MENU
local hubFrame = createFrame("Hub", UDim2.new(0, 400, 0, 380), UDim2.new(0.5, -200, 0.5, -150), SHINY_PURPLE)
hubFrame.Visible = false

local hubTitle = Instance.new("TextLabel", hubFrame)
hubTitle.Size = UDim2.new(1, 0, 0, 50); hubTitle.Position = UDim2.new(0, 0, 0, 10); hubTitle.Text = "S4HUB"; hubTitle.TextColor3 = Color3.new(1,1,1); hubTitle.Font = "ArialBold"; hubTitle.TextSize = 26; hubTitle.BackgroundTransparency = 1
local htStroke = Instance.new("UIStroke", hubTitle); htStroke.Thickness = 1.8; applyShinyEffect(htStroke, SHINY_PURPLE, Color3.new(1,1,1))

local closeBtn = Instance.new("TextButton", hubFrame)
closeBtn.Size = UDim2.new(0, 30, 0, 30); closeBtn.Position = UDim2.new(1, -35, 0, 10); closeBtn.Text = "X"; closeBtn.TextColor3 = Color3.new(1,1,1); closeBtn.Font = "GothamBold"; closeBtn.TextSize = 14; closeBtn.BackgroundColor3 = Color3.fromRGB(40, 10, 10); closeBtn.BackgroundTransparency = 0.5
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
closeBtn.MouseButton1Click:Connect(function() hubFrame.Visible = false end)

local scroll = Instance.new("ScrollingFrame", hubFrame)
scroll.Size = UDim2.new(1, -20, 1, -130); scroll.Position = UDim2.new(0, 10, 0, 70); scroll.BackgroundTransparency = 1; scroll.BorderSizePixel = 0
Instance.new("UIGridLayout", scroll).CellSize = UDim2.new(0.48, 0, 0, 40)

local saveBtn = Instance.new("TextButton", hubFrame)
saveBtn.Size = UDim2.new(0.9, 0, 0, 35); saveBtn.Position = UDim2.new(0.05, 0, 1, -45); saveBtn.Text = "SAVE SETTINGS"; saveBtn.BackgroundColor3 = BG_COLOR; saveBtn.TextColor3 = Color3.new(1,1,1); saveBtn.Font = "GothamBold"
Instance.new("UICorner", saveBtn)
local sbs = Instance.new("UIStroke", saveBtn); sbs.Thickness = 1.5; applyShinyEffect(sbs, NEON_BLUE, Color3.new(1,1,1))
saveBtn.MouseButton1Click:Connect(saveConfig)

-- === SPEED SETTINGS SUB-MENU (BAT FUCKER) ===
local speedFrame = createFrame("SpeedMenu", UDim2.new(0, 200, 0, 120), UDim2.new(0.5, 50, 0.5, -60), NEON_BLUE)
speedFrame.Visible = false
speedFrame.ZIndex = 10

local sliderLabel = Instance.new("TextLabel", speedFrame)
sliderLabel.Size = UDim2.new(1,0,0,30); sliderLabel.Position = UDim2.new(0,0,0,10); sliderLabel.Text = "SPEED: " .. BatSettings.Speed; sliderLabel.TextColor3 = Color3.new(1,1,1); sliderLabel.BackgroundTransparency = 1; sliderLabel.Font = "GothamBold"; sliderLabel.ZIndex = 11

local sliderBG = Instance.new("Frame", speedFrame)
sliderBG.Size = UDim2.new(0.8, 0, 0, 10); sliderBG.Position = UDim2.new(0.1, 0, 0.45, 0); sliderBG.BackgroundColor3 = Color3.new(0.2,0.2,0.2); sliderBG.ZIndex = 11

local sliderFill = Instance.new("Frame", sliderBG)
sliderFill.Size = UDim2.new(BatSettings.Speed/70, 0, 1, 0); sliderFill.BackgroundColor3 = NEON_BLUE; sliderFill.ZIndex = 12

local sliderBtn = Instance.new("TextButton", sliderBG)
sliderBtn.Size = UDim2.new(1,0,1,0); sliderBtn.BackgroundTransparency = 1; sliderBtn.Text = ""; sliderBtn.ZIndex = 13

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
speedSave.Size = UDim2.new(0.8, 0, 0, 25); speedSave.Position = UDim2.new(0.1, 0, 0.7, 0); speedSave.Text = "SAVE SPEED"; speedSave.BackgroundColor3 = BG_COLOR; speedSave.TextColor3 = Color3.new(1,1,1); speedSave.Font = "GothamBold"; speedSave.ZIndex = 11
Instance.new("UICorner", speedSave).CornerRadius = UDim.new(0, 4)
local ssStroke = Instance.new("UIStroke", speedSave); ssStroke.Thickness = 1.2; ssStroke.Color = NEON_BLUE
speedSave.MouseButton1Click:Connect(function() saveBatSpeed(); speedFrame.Visible = false end)

-- === BUTTON BUILDER ===
local function createHubButton(text, isToggle, func)
    local b = Instance.new("TextButton", scroll)
    b.Text = text; b.BackgroundColor3 = BG_COLOR; b.BackgroundTransparency = 0.6; b.TextColor3 = Color3.new(1,1,1); b.Font = "GothamBold"; b.TextSize = 12
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    local bs = Instance.new("UIStroke", b); bs.Thickness = 1.2
    local currentEffect = applyShinyEffect(bs, SHINY_PURPLE, Color3.new(1,1,1))
    
    if text == "Bat Fucker" then
        local settingsIcon = Instance.new("TextButton", b)
        settingsIcon.Size = UDim2.new(0, 20, 0, 20); settingsIcon.Position = UDim2.new(1, -25, 0.5, -10); settingsIcon.Text = "⚙️"; settingsIcon.BackgroundTransparency = 1; settingsIcon.TextColor3 = Color3.new(1,1,1)
        settingsIcon.MouseButton1Click:Connect(function() speedFrame.Visible = not speedFrame.Visible end)
    end

    ActiveToggles[text] = false
    b.MouseButton1Click:Connect(function()
        if isToggle then
            ActiveToggles[text] = not ActiveToggles[text]
            currentEffect.Enabled = not ActiveToggles[text]
            bs.Color = ActiveToggles[text] and ACTIVE_GREEN or Color3.new(1,1,1)
            func(ActiveToggles[text])
        else
            task.spawn(function()
                local oldColor = bs.Color
                bs.Color = Color3.new(1,1,1)
                task.wait(0.2)
                bs.Color = oldColor
            end)
            func()
        end
    end)
    return b
end

-- === ADDING ALL FEATURES TO THE MENU ===

createHubButton("Bat Fucker", true, function(state) batActive = state end)

createHubButton("ESP", true, function(state) espActive = state end)

createHubButton("Inf Jump", true, function(state) infJumpActive = state end)

createHubButton("Unwalk", true, function(state)
    local char = Player.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    local anim = char:FindFirstChild("Animate")

    if state then
        if anim then anim.Disabled = true end
        if hum then 
            for _, t in pairs(hum:GetPlayingAnimationTracks()) do t:Stop() end 
        end
    else
        if anim then 
            anim.Disabled = false 
            local c = anim:Clone()
            anim:Destroy()
            c.Parent = char
        end
    end
end)

createHubButton("Taunt", true, function(state)
    if state then
        local tcs = game:GetService("TextChatService")
        if tcs.ChatVersion == Enum.ChatVersion.TextChatService then
            local c = tcs.TextChannels:FindFirstChild("RBXGeneral")
            if c then c:SendAsync("S4DUELS") end
        else
            local e = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
            if e and e:FindFirstChild("SayMessageRequest") then e.SayMessageRequest:FireServer("S4DUELS", "All") end
        end
    end
end)

createHubButton("Rejoin Server", false, function() TeleportService:Teleport(game.PlaceId, Player) end)

createHubButton("Server Hop", false, function() 
    local success, result = pcall(function() return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")) end)
    if success and result.data then
        for _, s in pairs(result.data) do if s.playing < s.maxPlayers and s.id ~= game.JobId then TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, Player) return end end
    end
end)

createHubButton("Kick Self", false, function() Player:Kick("S4DUELS: Brainrot Disconnect") end)

-- === ESP LOGIC ===
local function applyESP(v)
    if v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
        local char = v.Character
        -- Body Highlight
        if not char:FindFirstChild("S4_Highlight") then
            local hl = Instance.new("Highlight")
            hl.Name = "S4_Highlight"
            hl.FillColor = ESP_COLOR
            hl.OutlineColor = ESP_COLOR
            hl.FillTransparency = 0.5
            hl.Parent = char
        end
        -- Name Tag
        if not char:FindFirstChild("S4_NameTag") then
            local bg = Instance.new("BillboardGui")
            bg.Name = "S4_NameTag"
            bg.Size = UDim2.new(0, 200, 0, 40)
            bg.StudsOffset = Vector3.new(0, 3, 0)
            bg.AlwaysOnTop = true
            local txt = Instance.new("TextLabel")
            txt.Size = UDim2.new(1, 0, 1, 0)
            txt.BackgroundTransparency = 1
            txt.Text = v.Name
            txt.TextColor3 = ESP_COLOR
            txt.TextStrokeTransparency = 0
            txt.Font = Enum.Font.GothamBold
            txt.TextSize = 14
            txt.Parent = bg
            bg.Parent = char
        end
    end
end

local function removeESP(v)
    if v.Character then
        if v.Character:FindFirstChild("S4_Highlight") then v.Character.S4_Highlight:Destroy() end
        if v.Character:FindFirstChild("S4_NameTag") then v.Character.S4_NameTag:Destroy() end
    end
end

-- === RENDER LOOP FOR PHYSICS & ESP ===
local batMover = nil
local batGyro = nil

RunService.Stepped:Connect(function()
    -- Noclip for Bat Fucker to prevent tripping over walls/floors while tracking
    if batActive and Player.Character then
        for _, part in pairs(Player.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    -- Inf Jump Logic
    if infJumpActive and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = Player.Character.HumanoidRootPart
            hrp.Velocity = Vector3.new(hrp.Velocity.X, 45, hrp.Velocity.Z)
        end
    end

    -- ESP Logic
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= Player then
            if espActive then
                applyESP(v)
            else
                removeESP(v)
            end
        end
    end

    -- Bat Fucker Logic (Smooth 3D Tracking using BodyMovers)
    if batActive and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Player.Character:FindFirstChild("Humanoid") then
        local myHrp = Player.Character.HumanoidRootPart
        local closestPlayer = nil
        local shortestDist = math.huge

        for _, v in pairs(Players:GetPlayers()) do
            if v ~= Player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
                local dist = (myHrp.Position - v.Character.HumanoidRootPart.Position).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    closestPlayer = v
                end
            end
        end

        if closestPlayer then
            local targetPos = closestPlayer.Character.HumanoidRootPart.Position
            local direction = (targetPos - myHrp.Position).Unit

            -- Create Movers if they don't exist
            if not batMover then
                batMover = Instance.new("BodyVelocity")
                batMover.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                batMover.Parent = myHrp
            end
            if not batGyro then
                batGyro = Instance.new("BodyGyro")
                batGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                batGyro.P = 15000
                batGyro.Parent = myHrp
            end

            -- Apply 3D Float/Flight Movement
            if shortestDist > 2.5 then
                batMover.Velocity = direction * BatSettings.Speed
            else
                batMover.Velocity = Vector3.zero
            end

            -- Always face target
            batGyro.CFrame = CFrame.lookAt(myHrp.Position, targetPos)
            
            -- Prevent natural physics from interfering
            Player.Character.Humanoid.PlatformStand = true 
        else
            -- Cleanup if no target found
            if batMover then batMover:Destroy(); batMover = nil end
            if batGyro then batGyro:Destroy(); batGyro = nil end
            Player.Character.Humanoid.PlatformStand = false
        end
    else
        -- Cleanup if deactivated
        if batMover then batMover:Destroy(); batMover = nil end
        if batGyro then batGyro:Destroy(); batGyro = nil end
        if Player.Character and Player.Character:FindFirstChild("Humanoid") then
            Player.Character.Humanoid.PlatformStand = false
        end
    end
end)

-- === CORE LOGIC INITIALIZATION ===
loadConfigs()
toggleHub.MouseButton1Click:Connect(function() hubFrame.Visible = not hubFrame.Visible end)
lockBtn.MouseButton1Click:Connect(function()
    guiLocked = not guiLocked
    lockBtn.Text = guiLocked and "LOCKED" or "LOCK GUI"
    lockStroke.Color = guiLocked and Color3.fromRGB(255, 50, 50) or NEON_BLUE
end)

local function drag(f)
    local d, st, sp
    f.InputBegan:Connect(function(i) if not guiLocked and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then d = true; st = i.Position; sp = f.Position end end)
    UserInputService.InputChanged:Connect(function(i) if d then local del = i.Position - st; f.Position = UDim2.new(sp.X.Scale, sp.X.Offset + del.X, sp.Y.Scale, sp.Y.Offset + del.Y) end end)
    UserInputService.InputEnded:Connect(function() d = false end)
end
drag(mainFrame); drag(hubFrame); drag(lockFrame); drag(speedFrame)

task.spawn(function()
    while true do
        stats.Text = string.format("FPS: %d | PING: %dms", math.floor(1/RunService.RenderStepped:Wait()), math.floor(Player:GetNetworkPing()*1000))
        task.wait(0.5)
    end
end)
