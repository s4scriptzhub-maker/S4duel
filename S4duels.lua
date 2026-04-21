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

local function applyShinyEffect(instance, color1, color2)
    local grad = Instance.new("UIGradient", instance)
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, color1),
        ColorSequenceKeypoint.new(0.5, color2),
        ColorSequenceKeypoint.new(1, color1)
    })
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
local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 35); title.Text = "S4DUELS"; title.TextColor3 = Color3.new(1,1,1); title.Font = "ArialBold"; title.TextSize = 24; title.BackgroundTransparency = 1
local tStroke = Instance.new("UIStroke", title); tStroke.Thickness = 1.5; applyShinyEffect(tStroke, SHINY_PURPLE, Color3.new(1,1,1))

local stats = Instance.new("TextLabel", mainFrame)
stats.Size = UDim2.new(1, 0, 0, 15); stats.Position = UDim2.new(0,0,0,42); stats.TextColor3 = Color3.fromRGB(200,200,200); stats.TextSize = 8.5; stats.BackgroundTransparency = 1

local toggleHub = Instance.new("TextButton", mainFrame)
toggleHub.Size = UDim2.new(0, 70, 0, 24); toggleHub.Position = UDim2.new(0.5, -35, 1, 10); toggleHub.Text = "S4HUB"; toggleHub.BackgroundColor3 = Color3.fromRGB(20,20,25); toggleHub.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", toggleHub)

-- 3. HUB MENU (S4HUB)
local hubFrame = createFrame("Hub", UDim2.new(0, 400, 0, 300), UDim2.new(0.5, -200, 0.5, -150), SHINY_PURPLE)
hubFrame.Visible = false

local hubTitle = Instance.new("TextLabel", hubFrame)
hubTitle.Size = UDim2.new(1, 0, 0, 55); hubTitle.Text = "S4HUB"; hubTitle.TextColor3 = Color3.new(1,1,1); hubTitle.Font = "ArialBold"; hubTitle.TextSize = 28; hubTitle.BackgroundTransparency = 1
local hTStroke = Instance.new("UIStroke", hubTitle); hTStroke.Thickness = 2; applyShinyEffect(hTStroke, SHINY_PURPLE, Color3.new(1,1,1))

local closeHub = Instance.new("TextButton", hubFrame)
closeHub.Size = UDim2.new(0, 24, 0, 24); closeHub.Position = UDim2.new(1, -30, 0, 15); closeHub.Text = "×"; closeHub.BackgroundColor3 = Color3.fromRGB(45,15,20); closeHub.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", closeHub).CornerRadius = UDim.new(1,0)

local scroll = Instance.new("ScrollingFrame", hubFrame)
scroll.Size = UDim2.new(1, -20, 1, -90); scroll.Position = UDim2.new(0, 10, 0, 75); scroll.BackgroundTransparency = 1; scroll.BorderSizePixel = 0
Instance.new("UIGridLayout", scroll).CellSize = UDim2.new(0.48, 0, 0, 40)

-- === ADDING FUNCTIONAL BUTTONS ===
local function createHubButton(text, func)
    local b = Instance.new("TextButton", scroll)
    b.Text = text; b.BackgroundColor3 = Color3.fromRGB(20, 20, 30); b.TextColor3 = Color3.new(1,1,1); b.Font = "GothamSemibold"; Instance.new("UICorner", b)
    local bs = Instance.new("UIStroke", b); bs.Color = Color3.fromRGB(80, 80, 90); bs.Thickness = 1
    b.MouseButton1Click:Connect(func)
    return b
end

createHubButton("Rejoin Server", rejoinServer)
createHubButton("Server Hop", serverHop)
createHubButton("Kick Self", function() Player:Kick("Disconnected via S4HUB") end)

for i = 1, 3 do createHubButton("s4loading", function() end) end

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
