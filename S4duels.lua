local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- === CUSTOM LOGISTICS DATA ===
local NEON_PURPLE = Color3.fromRGB(180, 0, 255)
local NEON_BLUE = Color3.fromRGB(0, 180, 255)
local BG_COLOR = Color3.fromRGB(25, 20, 35)
local BG_TRANSPARENCY = 0.4 

local guiLocked = false
local autoPlayActive = false

-- Coordinates from AntiLoser script
local P1 = Vector3.new(-472.59, -7.30, 94.43)
local P2 = Vector3.new(-484.55, -5.33, 95.05)
local P3 = Vector3.new(-472.59, -7.30, 94.43)
local P4 = Vector3.new(-471.25, -6.83, 7.08)

local SPEED_IDA = 56
local SPEED_VOLTA = 29

-- === CORE FUNCTIONS ===
local function hrp()
    local c = player.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function moveTo(pos, speed, cond)
    local root = hrp()
    if not root then return end
    while cond() and (root.Position - pos).Magnitude > 2 do
        local dir = (pos - root.Position).Unit
        root.AssemblyLinearVelocity = Vector3.new(dir.X * speed, root.AssemblyLinearVelocity.Y, dir.Z * speed)
        task.wait()
    end
end

local function makeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if guiLocked then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- === UI CONSTRUCTION ===
local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "S4duels_Custom_Logic"
screenGui.ResetOnSpawn = false

local function createNeonFrame(name, size, pos, strokeColor)
    local frame = Instance.new("Frame", screenGui)
    frame.Name = name; frame.Size = size; frame.Position = pos
    frame.BackgroundColor3 = BG_COLOR
    frame.BackgroundTransparency = BG_TRANSPARENCY
    frame.BorderSizePixel = 0; frame.Active = true
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
    
    local s = Instance.new("UIStroke", frame)
    s.Thickness = 3.5 -- Bold neon look
    s.Color = strokeColor or NEON_PURPLE
    return frame, s
end

-- 1. LOCK GUI (Independent)
local lockFrame, lockStroke = createNeonFrame("LockContainer", UDim2.new(0, 110, 0, 40), UDim2.new(0.5, -250, 0, 50), NEON_BLUE)
makeDraggable(lockFrame)

local lockBtn = Instance.new("TextButton", lockFrame)
lockBtn.Size = UDim2.new(1, 0, 1, 0); lockBtn.BackgroundTransparency = 1
lockBtn.Text = "Lock GUI"; lockBtn.TextColor3 = Color3.new(1, 1, 1)
lockBtn.Font = Enum.Font.GothamBold; lockBtn.TextSize = 14

-- 2. MAIN HEADER (S4duels)
local mainFrame = createNeonFrame("S4duels_Header", UDim2.new(0, 220, 0, 90), UDim2.new(0.5, -110, 0, 50))
makeDraggable(mainFrame)

local s4Title = Instance.new("TextLabel", mainFrame)
s4Title.Size = UDim2.new(1, 0, 0, 40); s4Title.Text = "S4duels"
s4Title.TextColor3 = Color3.new(1, 1, 1); s4Title.Font = Enum.Font.GothamBold; s4Title.TextSize = 24; s4Title.BackgroundTransparency = 1

local statsLabel = Instance.new("TextLabel", mainFrame)
statsLabel.Size = UDim2.new(1, 0, 0, 20); statsLabel.Position = UDim2.new(0, 0, 0, 40)
statsLabel.TextColor3 = Color3.fromRGB(200, 200, 200); statsLabel.Font = Enum.Font.Code; statsLabel.BackgroundTransparency = 1

local toggleBtn = Instance.new("TextButton", mainFrame)
toggleBtn.Size = UDim2.new(0, 100, 0, 30); toggleBtn.Position = UDim2.new(0.5, -50, 1, 12)
toggleBtn.BackgroundColor3 = BG_COLOR; toggleBtn.Text = "S4HUB"; toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Font = Enum.Font.GothamBold; Instance.new("UICorner", toggleBtn)
Instance.new("UIStroke", toggleBtn).Color = NEON_PURPLE

-- 3. SETTINGS MENU (S4HUB)
local hubFrame = createNeonFrame("S4HUB_Menu", UDim2.new(0, 440, 0, 320), UDim2.new(0.5, -220, 0.5, -160))
hubFrame.Visible = false
makeDraggable(hubFrame)

local hubTitle = Instance.new("TextLabel", hubFrame)
hubTitle.Size = UDim2.new(1, 0, 0, 50); hubTitle.Text = "S4HUB SETTINGS"
hubTitle.TextColor3 = Color3.new(1, 1, 1); hubTitle.Font = Enum.Font.GothamBold; hubTitle.TextSize = 22; hubTitle.BackgroundTransparency = 1

local scroll = Instance.new("ScrollingFrame", hubFrame)
scroll.Size = UDim2.new(1, -30, 1, -70); scroll.Position = UDim2.new(0, 15, 0, 60); scroll.BackgroundTransparency = 1; scroll.BorderSizePixel = 0
local grid = Instance.new("UIGridLayout", scroll)
grid.CellSize = UDim2.new(0.48, 0, 0, 50); grid.CellPadding = UDim2.new(0.04, 0, 0, 12)

-- === BUTTONS & LOGIC ===
for i = 1, 8 do
    local btn = Instance.new("TextButton", scroll)
    btn.BackgroundColor3 = Color3.fromRGB(40, 35, 55); btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamSemibold; Instance.new("UICorner", btn)

    if i == 1 then
        btn.Text = "Autoplay"
        btn.MouseButton1Click:Connect(function()
            autoPlayActive = not autoPlayActive
            btn.BackgroundColor3 = autoPlayActive and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(40, 35, 55)
            if autoPlayActive then
                task.spawn(function()
                    moveTo(P1, SPEED_IDA, function() return autoPlayActive end)
                    moveTo(P2, SPEED_IDA, function() return autoPlayActive end)
                    moveTo(P3, SPEED_VOLTA, function() return autoPlayActive end)
                    moveTo(P4, SPEED_VOLTA, function() return autoPlayActive end)
                    autoPlayActive = false
                    btn.BackgroundColor3 = Color3.fromRGB(40, 35, 55)
                end)
            end
        end)
    else
        btn.Text = "s4loading"
    end
end

-- CONNECTIONS
toggleBtn.MouseButton1Click:Connect(function() hubFrame.Visible = not hubFrame.Visible end)
lockBtn.MouseButton1Click:Connect(function()
    guiLocked = not guiLocked
    lockBtn.Text = guiLocked and "Locked" or "Lock GUI"
    lockStroke.Color = guiLocked and Color3.fromRGB(255, 80, 80) or NEON_BLUE
end)

task.spawn(function()
    while true do
        local fps = math.floor(1 / RunService.RenderStepped:Wait())
        local ping = math.floor(player:GetNetworkPing() * 1000)
        statsLabel.Text = string.format("FPS: %d | PING: %dms", fps, ping)
        task.wait(0.5)
    end
end)
