local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local playerGui = Player:WaitForChild("PlayerGui")

-- === PREMIUM COLORS ===
local SHINY_PURPLE = Color3.fromRGB(210, 80, 255)
local NEON_BLUE = Color3.fromRGB(0, 220, 255)
local BG_COLOR = Color3.fromRGB(10, 10, 15)

local guiLocked = false

-- === UTILITY FUNCTIONS ===
local function rejoinServer()
    TeleportService:Teleport(game.PlaceId, Player)
end

local function serverHop()
    local servers = {}
    local api = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    local success, result = pcall(function() return HttpService:JSONDecode(game:HttpGet(api)) end)
    
    if success and result.data then
        for _, server in pairs(result.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                table.insert(servers, server.id)
            end
        end
    end
    
    if #servers > 0 then
        TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], Player)
    else
        rejoinServer()
    end
end

-- === UI BUILDER ===
local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "S4_Shiny_Elite"
screenGui.ResetOnSpawn = false

-- Enhanced Shiny Effect with smooth rotation
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
            rotation = (rotation + (deltaTime * 60)) % 360
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
    s.Thickness = 1.2
    s.Color = Color3.new(1,1,1)
    applyShinyEffect(s, accent or SHINY_PURPLE, Color3.new(1,1,1))
    return f, s
end

-- 1. LOCK BUTTON
local lockFrame, lockStroke = createFrame("Lock", UDim2.new(0, 95, 0, 30), UDim2.new(0.5, -240, 0, 50), NEON_BLUE)
local lockBtn = Instance.new("TextButton", lockFrame)
lockBtn.Size = UDim2.new(1, 0, 1, 0); lockBtn.BackgroundTransparency = 1; lockBtn.Text = "LOCK GUI"; lockBtn.TextColor3 = Color3.new(1,1,1); lockBtn.Font = "GothamBold"; lockBtn.TextSize = 10

-- 2. MAIN HEADER
local mainFrame = createFrame("Main", UDim2.new(0, 180, 0, 85), UDim2.new(0.5, -90, 0, 50), SHINY_PURPLE)

-- Styled S4DUELS Title Background
local titleBg = Instance.new("Frame", mainFrame)
titleBg.Size = UDim2.new(0.9, 0, 0, 35); titleBg.Position = UDim2.new(0.05, 0, 0, 5); titleBg.BackgroundColor3 = BG_COLOR; titleBg.BackgroundTransparency = 0.5
Instance.new("UICorner", titleBg).CornerRadius = UDim.new(0, 4)
local titleStroke = Instance.new("UIStroke", titleBg); titleStroke.Thickness = 1.2; applyShinyEffect(titleStroke, SHINY_PURPLE, Color3.new(1,1,1))

local title = Instance.new("TextLabel", titleBg)
title.Size = UDim2.new(1, 0, 1, 0); title.Text = "S4DUELS"; title.TextColor3 = Color3.new(1,1,1); title.Font = "ArialBold"; title.TextSize = 22; title.BackgroundTransparency = 1

local stats = Instance.new("TextLabel", mainFrame)
stats.Size = UDim2.new(1, 0, 0, 15); stats.Position = UDim2.new(0,0,0,42); stats.TextColor3 = Color3.fromRGB(200,200,200); stats.TextSize = 8.5; stats.BackgroundTransparency = 1

-- S4HUB Toggle Button
local toggleHub = Instance.new("TextButton", mainFrame)
toggleHub.Size = UDim2.new(0, 80, 0, 26); toggleHub.Position = UDim2.new(0.5, -40, 1, 10); toggleHub.Text = "S4HUB"; toggleHub.Font = "GothamBold"; toggleHub.BackgroundColor3 = BG_COLOR; toggleHub.BackgroundTransparency = 0.6; toggleHub.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", toggleHub).CornerRadius = UDim.new(0, 4)
local thStroke = Instance.new("UIStroke", toggleHub); thStroke.Thickness = 1.2; applyShinyEffect(thStroke, SHINY_PURPLE, Color3.new(1,1,1))

-- 3. HUB MENU (S4HUB)
local hubFrame = createFrame("Hub", UDim2.new(0, 400, 0, 300), UDim2.new(0.5, -200, 0.5, -150), SHINY_PURPLE)
hubFrame.Visible = false

-- Styled S4HUB Title Background
local hTitleBg = Instance.new("Frame", hubFrame)
hTitleBg.Size = UDim2.new(0.95, 0, 0, 50); hTitleBg.Position = UDim2.new(0.025, 0, 0, 10); hTitleBg.BackgroundColor3 = BG_COLOR; hTitleBg.BackgroundTransparency = 0.5
Instance.new("UICorner", hTitleBg).CornerRadius = UDim.new(0, 4)
local hTitleStroke = Instance.new("UIStroke", hTitleBg); hTitleStroke.Thickness = 1.5; applyShinyEffect(hTitleStroke, SHINY_PURPLE, Color3.new(1,1,1))

local hubTitle = Instance.new("TextLabel", hTitleBg)
hubTitle.Size = UDim2.new(1, 0, 1, 0); hubTitle.Text = "S4HUB"; hubTitle.TextColor3 = Color3.new(1,1,1); hubTitle.Font = "ArialBold"; hubTitle.TextSize = 28; hubTitle.BackgroundTransparency = 1

local closeHub = Instance.new("TextButton", hubFrame)
closeHub.Size = UDim2.new(0, 24, 0, 24); closeHub.Position = UDim2.new(1, -30, 0, 15); closeHub.Text = "×"; closeHub.BackgroundColor3 = Color3.fromRGB(45,15,20); closeHub.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", closeHub).CornerRadius = UDim.new(1,0)

local scroll = Instance.new("ScrollingFrame", hubFrame)
scroll.Size = UDim2.new(1, -20, 1, -90); scroll.Position = UDim2.new(0, 10, 0, 75); scroll.BackgroundTransparency = 1; scroll.BorderSizePixel = 0
Instance.new("UIGridLayout", scroll).CellSize = UDim2.new(0.48, 0, 0, 40)

-- === UPDATED HUB BUTTONS (MATCHING STYLE) ===
local function createHubButton(text, func)
    local b = Instance.new("TextButton", scroll)
    b.Text = text; b.BackgroundColor3 = BG_COLOR; b.BackgroundTransparency = 0.5; b.TextColor3 = Color3.new(1,1,1); b.Font = "GothamBold"; b.TextSize = 12
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    local bs = Instance.new("UIStroke", b); bs.Thickness = 1.2; applyShinyEffect(bs, SHINY_PURPLE, Color3.new(1,1,1))
    b.MouseButton1Click:Connect(func)
    return b
end

createHubButton("Rejoin Server", rejoinServer)
createHubButton("Server Hop", serverHop)
createHubButton("Kick Self", function() Player:Kick("Disconnected via S4HUB") end)

createHubButton("Taunt", function()
    local TextChatService = game:GetService("TextChatService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        local channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
        if channel then channel:SendAsync("S4DUELS") end
    else
        local sayMessageEvent = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
        if sayMessageEvent and sayMessageEvent:FindFirstChild("SayMessageRequest") then
            sayMessageEvent.SayMessageRequest:FireServer("S4DUELS", "All")
        end
    end
end)

for i = 1, 2 do createHubButton("s4loading", function() end) end

-- === INTERACTIONS ===
lockBtn.MouseButton1Click:Connect(function()
    guiLocked = not guiLocked
    lockBtn.Text = guiLocked and "LOCKED" or "LOCK GUI"
    lockStroke.Color = guiLocked and Color3.fromRGB(255, 50, 50) or NEON_BLUE
end)

toggleHub.MouseButton1Click:Connect(function() hubFrame.Visible = not hubFrame.Visible end)
closeHub.MouseButton1Click:Connect(function() hubFrame.Visible = false end)

-- Drag Logic
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
