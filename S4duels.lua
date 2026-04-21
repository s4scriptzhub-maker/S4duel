local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- === CONFIGURATION & AUTOPLAY DATA (From S4duels (1).lua) ===
local NEON_PURPLE = Color3.fromRGB(180, 0, 255)
local NEON_BLUE = Color3.fromRGB(0, 180, 255)
local BG_COLOR = Color3.fromRGB(25, 20, 35)
local BG_TRANSPARENCY = 0.4

local guiLocked = false
local autoPlayActive = false

-- Path coordinates from your script 
local A1_P1 = Vector3.new(-472.59, -7.30, 94.43)
local A1_P2 = Vector3.new(-484.55, -5.33, 95.05)
local A1_P3 = Vector3.new(-472.59, -7.30, 94.43)
local A1_P4 = Vector3.new(-471.25, -6.83, 7.08)

local SPEED_IDA = 56
local SPEED_VOLTA = 29

-- === UTILITIES ===
local function hrp()
    local c = player.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

-- Movement logic [cite: 2]
local function go(pos, speed, cond)
    local r = hrp()
    if not r then return end
    while cond() and (r.Position - pos).Magnitude > 1 do
        local dir = (pos - r.Position).Unit
        r.AssemblyLinearVelocity = Vector3.new(dir.X * speed, r.AssemblyLinearVelocity.Y, dir.Z * speed)
        task.wait()
    end
end

-- Fixed Dragging System (Works for Lock GUI and Main Frames)
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

-- === UI ELEMENTS ===
local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "S4duels_Autoplay_Fixed"
screenGui.ResetOnSpawn = false

local function createStyledFrame(name, size, pos, strokeColor)
    local frame = Instance.new("Frame", screenGui)
    frame.Name = name; frame.Size = size; frame.Position = pos
    frame.BackgroundColor3 = BG_COLOR; frame.BackgroundTransparency = BG_TRANSPARENCY
    frame.BorderSizePixel = 0; frame.Active = true
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    local s = Instance.new("UIStroke", frame); s.Thickness = 2; s.Color = strokeColor or NEON_PURPLE
    return frame, s
end

-- 1. DRAGGABLE LOCK BUTTON (Now moves properly)
local lockFrame, lockStroke = createStyledFrame("LockContainer", UDim2.new(0, 110, 0, 40), UDim2.new(0.5, -230, 0, 50), NEON_BLUE)
makeDraggable(lockFrame)

local lockBtn = Instance.new("TextButton", lockFrame)
lockBtn.Size = UDim2.new(1, 0, 1, 0); lockBtn.BackgroundTransparency = 1
lockBtn.Text = "Lock GUI"; lockBtn.TextColor3 = Color3.new(1, 1, 1)
lockBtn.Font = Enum.Font.GothamBold; lockBtn.TextSize = 14

-- 2. MAIN HEADER
local mainFrame = createStyledFrame("MainHeader", UDim2.new(0, 220, 0, 80), UDim2.new(0.5, -110, 0, 50))
makeDraggable(mainFrame)

local statsLabel = Instance.new("TextLabel", mainFrame)
statsLabel.Size = UDim2.new(1, 0, 0, 20); statsLabel.Position = UDim2.new(0, 0, 0, 40)
statsLabel.TextColor3 = Color3.fromRGB(200, 200, 200); statsLabel.Font = Enum.Font.Code; statsLabel.BackgroundTransparency = 1

local toggleBtn = Instance.new("TextButton", mainFrame)
toggleBtn.Size = UDim2.new(0, 80, 0, 30); toggleBtn.Position = UDim2.new(0.5, -40, 1, 10)
toggleBtn.BackgroundColor3 = BG_COLOR; toggleBtn.Text = "Toggle Menu"; toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Font = Enum.Font.GothamBold; Instance.new("UICorner", toggleBtn)
local tStroke = Instance.new("UIStroke", toggleBtn); tStroke.Color = NEON_PURPLE; tStroke.Thickness = 2

-- 3. SETTINGS MENU
local settingsFrame = createStyledFrame("S4HUB", UDim2.new(0, 420, 0, 300), UDim2.new(0.5, -210, 0.5, -150))
settingsFrame.Visible = false
makeDraggable(settingsFrame)

local scroll = Instance.new("ScrollingFrame", settingsFrame)
scroll.Size = UDim2.new(1, -30, 1, -70); scroll.Position = UDim2.new(0, 15, 0, 60); scroll.BackgroundTransparency = 1
local grid = Instance.new("UIGridLayout", scroll)
grid.CellSize = UDim2.new(0.48, 0, 0, 45); grid.CellPadding = UDim2.new(0.04, 0, 0, 10)

-- === ADDING AUTOPLAY LOGISTICS TO SETTINGS ===
for i = 1, 8 do
    local btn = Instance.new("TextButton", scroll)
    btn.BackgroundColor3 = Color3.fromRGB(50, 45, 65); btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamSemibold; Instance.new("UICorner", btn)

    if i == 1 then
        btn.Text = "Autoplay" -- Replaced s4loading 
        btn.MouseButton1Click:Connect(function()
            autoPlayActive = not autoPlayActive
            btn.BackgroundColor3 = autoPlayActive and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(50, 45, 65)
            
            if autoPlayActive then
                task.spawn(function()
                    -- Path logistics from S4duels (1).lua 
                    go(A1_P1, SPEED_IDA, function() return autoPlayActive end)
                    go(A1_P2, SPEED_IDA, function() return autoPlayActive end)
                    go(A1_P3, SPEED_VOLTA, function() return autoPlayActive end)
                    go(A1_P4, SPEED_VOLTA, function() return autoPlayActive end)
                    
                    autoPlayActive = false
                    btn.BackgroundColor3 = Color3.fromRGB(50, 45, 65)
                end)
            end
        end)
    else
        btn.Text = "s4loading"
    end
end

-- === FINAL CONNECTIONS ===
toggleBtn.MouseButton1Click:Connect(function() settingsFrame.Visible = not settingsFrame.Visible end)
lockBtn.MouseButton1Click:Connect(function()
    guiLocked = not guiLocked
    lockBtn.Text = guiLocked and "Locked" or "Lock GUI"
    lockStroke.Color = guiLocked and Color3.fromRGB(255, 80, 80) or NEON_BLUE
end)

task.spawn(function()
    while true do
        local fps = math.floor(1 / RunService.RenderStepped:Wait())
        local ping = math.floor(player:GetNetworkPing() * 1000)
        statsLabel.Text = string.format("FPS: %d  |  PING: %dms", fps, ping)
        task.wait(0.5)
    end
end)
