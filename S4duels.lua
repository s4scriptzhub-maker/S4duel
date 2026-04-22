local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local playerGui = Player:WaitForChild("PlayerGui")
local ConfigFile = "S4DUELS_Brainrot_Config.json"

-- === SETTINGS STORAGE ===
local SavedSettings = { Toggles = {} }
local ActiveToggles = {} 

-- === PREMIUM COLORS ===
local SHINY_PURPLE = Color3.fromRGB(210, 80, 255)
local NEON_BLUE = Color3.fromRGB(0, 220, 255)
local ACTIVE_GREEN = Color3.fromRGB(0, 255, 150)
local BG_COLOR = Color3.fromRGB(10, 10, 15)

local guiLocked = false

-- === UTILITY FUNCTIONS ===
local function saveConfig()
    if writefile then writefile(ConfigFile, HttpService:JSONEncode(SavedSettings)) end
end

local function loadConfig()
    if isfile and isfile(ConfigFile) then
        local success, data = pcall(function() return HttpService:JSONDecode(readfile(ConfigFile)) end)
        if success then SavedSettings = data end
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

-- 3. HUB MENU (SETTINGS)
local hubFrame = createFrame("Hub", UDim2.new(0, 400, 0, 350), UDim2.new(0.5, -200, 0.5, -150), SHINY_PURPLE)
hubFrame.Visible = false

-- RESTORED: S4HUB TITLE
local hubTitle = Instance.new("TextLabel", hubFrame)
hubTitle.Size = UDim2.new(1, 0, 0, 50); hubTitle.Position = UDim2.new(0, 0, 0, 10); hubTitle.Text = "S4HUB"; hubTitle.TextColor3 = Color3.new(1,1,1); hubTitle.Font = "ArialBold"; hubTitle.TextSize = 26; hubTitle.BackgroundTransparency = 1
local htStroke = Instance.new("UIStroke", hubTitle); htStroke.Thickness = 1.8; applyShinyEffect(htStroke, SHINY_PURPLE, Color3.new(1,1,1))

-- RESTORED: CLOSE BUTTON
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

-- === BUTTON BUILDER ===
local function createHubButton(text, isToggle, func)
    local b = Instance.new("TextButton", scroll)
    b.Text = text; b.BackgroundColor3 = BG_COLOR; b.BackgroundTransparency = 0.6; b.TextColor3 = Color3.new(1,1,1); b.Font = "GothamBold"; b.TextSize = 12
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    local bs = Instance.new("UIStroke", b); bs.Thickness = 1.2
    local currentEffect = applyShinyEffect(bs, SHINY_PURPLE, Color3.new(1,1,1))
    
    ActiveToggles[text] = false
    b.MouseButton1Click:Connect(function()
        if isToggle then
            ActiveToggles[text] = not ActiveToggles[text]
            currentEffect.Enabled = not ActiveToggles[text]
            bs.Color = ActiveToggles[text] and ACTIVE_GREEN or Color3.new(1,1,1)
            func(ActiveToggles[text])
        else
            func()
        end
    end)
    return b
end

-- --- FEATURES ---

createHubButton("Rejoin Server", false, function() TeleportService:Teleport(game.PlaceId, Player) end)
createHubButton("Server Hop", false, function() 
    local success, result = pcall(function() return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")) end)
    if success and result.data then
        for _, s in pairs(result.data) do if s.playing < s.maxPlayers and s.id ~= game.JobId then TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, Player) return end end
    end
end)

local infJumpActive = false
createHubButton("Inf Jump", true, function(state) infJumpActive = state end)

RunService.RenderStepped:Connect(function()
    if infJumpActive and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = Player.Character.HumanoidRootPart
            hrp.Velocity = Vector3.new(hrp.Velocity.X, 45, hrp.Velocity.Z)
        end
    end
end)

createHubButton("Taunt", true, function(state)
    if state then
        local tcs = game:GetService("TextChatService")
        if tcs.ChatVersion == Enum.ChatVersion.TextChatService then
            local c = tcs.TextChannels:FindFirstChild("RBXGeneral")
            if c then c:SendAsync("S4DUELSFUCKER") end
        else
            local e = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
            if e and e:FindFirstChild("SayMessageRequest") then e.SayMessageRequest:FireServer("S4DUELS", "All") end
        end
    end
end)

createHubButton("Unwalk", true, function(state)
    local char = Player.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    local anim = char:FindFirstChild("Animate")

    if state then
        if anim then anim.Disabled = true end
        for _, t in pairs(hum:GetPlayingAnimationTracks()) do t:Stop() end
    else
        if anim then 
            anim.Disabled = false 
            local c = anim:Clone()
            anim:Destroy()
            c.Parent = char
        end
    end
end)

createHubButton("Kick Self", false, function() Player:Kick("S4DUELS: Brainrot Disconnect") end)

-- === CORE LOGIC ===
loadConfig()
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
drag(mainFrame); drag(hubFrame); drag(lockFrame)

task.spawn(function()
    while true do
        stats.Text = string.format("FPS: %d | PING: %dms", math.floor(1/RunService.RenderStepped:Wait()), math.floor(Player:GetNetworkPing()*1000))
        task.wait(0.5)
    end
end)
