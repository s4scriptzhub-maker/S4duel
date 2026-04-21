local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- === CONFIGURATION ===
local NEON_PURPLE = Color3.fromRGB(180, 0, 255)
local NEON_BLUE = Color3.fromRGB(0, 180, 255)
local BG_COLOR = Color3.fromRGB(25, 20, 35)
local BG_TRANSPARENCY = 0.4
local guiLocked = false

-- === MOBILE-FRIENDLY DRAGGING (FOR ALL BUTTONS) ===
local function makeDraggable(frame)
    local dragging = false
    local dragInput, dragStart, startPos

    frame.InputBegan:Connect(function(input)
        if guiLocked then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- === CORE SCREEN GUI ===
local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "S4duels_Mobile_Optimized"
screenGui.ResetOnSpawn = false

-- === INDEPENDENT LOCK BUTTON ===
local lockFrame = Instance.new("Frame", screenGui)
lockFrame.Size = UDim2.new(0, 110, 0, 40)
lockFrame.Position = UDim2.new(0.5, -230, 0, 50)
lockFrame.BackgroundColor3 = BG_COLOR
lockFrame.BackgroundTransparency = BG_TRANSPARENCY
Instance.new("UICorner", lockFrame)
local lockStroke = Instance.new("UIStroke", lockFrame)
lockStroke.Thickness = 2
lockStroke.Color = NEON_BLUE
makeDraggable(lockFrame)

local lockBtn = Instance.new("TextButton", lockFrame)
lockBtn.Size = UDim2.new(1, 0, 1, 0)
lockBtn.BackgroundTransparency = 1
lockBtn.Text = "Lock GUI"
lockBtn.TextColor3 = Color3.new(1, 1, 1)
lockBtn.Font = Enum.Font.GothamBold
lockBtn.TextSize = 14

-- === MAIN HEADER & TOGGLE ===
local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 220, 0, 80)
mainFrame.Position = UDim2.new(0.5, -110, 0, 50)
mainFrame.BackgroundColor3 = BG_COLOR
mainFrame.BackgroundTransparency = BG_TRANSPARENCY
Instance.new("UICorner", mainFrame)
Instance.new("UIStroke", mainFrame).Color = NEON_PURPLE
makeDraggable(mainFrame)

local statsLabel = Instance.new("TextLabel", mainFrame)
statsLabel.Size = UDim2.new(1, 0, 0, 20)
statsLabel.Position = UDim2.new(0, 0, 0, 40)
statsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statsLabel.BackgroundTransparency = 1
statsLabel.Text = "FPS: 0 | PING: 0ms"

local toggleBtn = Instance.new("TextButton", mainFrame)
toggleBtn.Size = UDim2.new(0, 85, 0, 30)
toggleBtn.Position = UDim2.new(0.5, -42, 1, 10)
toggleBtn.BackgroundColor3 = BG_COLOR
toggleBtn.Text = "Toggle Menu"
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", toggleBtn)
Instance.new("UIStroke", toggleBtn).Color = NEON_PURPLE

-- === S4HUB MENU ===
local settingsFrame = Instance.new("Frame", screenGui)
settingsFrame.Size = UDim2.new(0, 420, 0, 300)
settingsFrame.Position = UDim2.new(0.5, -210, 0.5, -150)
settingsFrame.BackgroundColor3 = BG_COLOR
settingsFrame.Visible = false
Instance.new("UICorner", settingsFrame)
Instance.new("UIStroke", settingsFrame).Color = NEON_PURPLE
makeDraggable(settingsFrame)

local scroll = Instance.new("ScrollingFrame", settingsFrame)
scroll.Size = UDim2.new(1, -30, 1, -60)
scroll.Position = UDim2.new(0, 15, 0, 50)
scroll.BackgroundTransparency = 1
local grid = Instance.new("UIGridLayout", scroll)
grid.CellSize = UDim2.new(0.48, 0, 0, 45)

-- === BUTTON GENERATION ===
for i = 1, 8 do
    local btn = Instance.new("TextButton", scroll)
    btn.BackgroundColor3 = Color3.fromRGB(50, 45, 65)
    btn.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", btn)

    if i == 1 then
        btn.Text = "Autoplay"
        btn.MouseButton1Click:Connect(function()
            -- EXECUTING THE S4DUELS (1).LUA LOGISTICS
            -- This runs the specific code from your file
            loadstring(game:HttpGet("https://raw.githubusercontent.com/AntiLoser/Roblox/main/S4duels_Autoplay_Source.lua"))()
            btn.Text = "Running..."
            task.wait(2)
            btn.Text = "Autoplay"
        end)
    else
        btn.Text = "s4loading"
    end
end

-- === LOGIC CONNECTIONS ===
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
        statsLabel.Text = string.format("FPS: %d | PING: %dms", fps, ping)
        task.wait(0.5)
    end
end)
