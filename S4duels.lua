local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- === CONFIGURATION ===
local NEON_PURPLE = Color3.fromRGB(180, 0, 255)
local NEON_BLUE = Color3.fromRGB(0, 180, 255)
local BG_COLOR = Color3.fromRGB(25, 20, 35)
local BG_TRANSPARENCY = 0.4 -- Transparent background for all frames
local guiLocked = false

-- === UNIVERSAL DRAGGABLE SYSTEM ===
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

-- === UI CREATION ===
local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "S4duels_Neon_Final"
screenGui.ResetOnSpawn = false

local function createStyledFrame(name, size, pos, strokeColor)
    local frame = Instance.new("Frame", screenGui)
    frame.Name = name; frame.Size = size; frame.Position = pos
    frame.BackgroundColor3 = BG_COLOR
    frame.BackgroundTransparency = BG_TRANSPARENCY -- Set to transparent
    frame.BorderSizePixel = 0; frame.Active = true
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    
    -- Bold Neon Stroke
    local s = Instance.new("UIStroke", frame)
    s.Thickness = 3.5 -- Slightly bold
    s.Color = strokeColor or NEON_PURPLE
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    
    return frame, s
end

-- 1. LOCK GUI BUTTON (Independent & Draggable)
local lockFrame, lockStroke = createStyledFrame("LockContainer", UDim2.new(0, 110, 0, 40), UDim2.new(0.5, -230, 0, 50), NEON_BLUE)
makeDraggable(lockFrame)

local lockBtn = Instance.new("TextButton", lockFrame)
lockBtn.Size = UDim2.new(1, 0, 1, 0); lockBtn.BackgroundTransparency = 1
lockBtn.Text = "Lock GUI"; lockBtn.TextColor3 = Color3.new(1, 1, 1)
lockBtn.Font = Enum.Font.GothamBold; lockBtn.TextSize = 14

-- 2. MAIN HEADER (S4duels)
local mainFrame = createStyledFrame("S4duels", UDim2.new(0, 220, 0, 80), UDim2.new(0.5, -110, 0, 50))
makeDraggable(mainFrame)

local titleLabel = Instance.new("TextLabel", mainFrame)
titleLabel.Size = UDim2.new(1, 0, 0, 35); titleLabel.Position = UDim2.new(0, 0, 0, 5)
titleLabel.Text = "S4duels"; titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.Font = Enum.Font.GothamBold; titleLabel.TextSize = 22; titleLabel.BackgroundTransparency = 1

local statsLabel = Instance.new("TextLabel", mainFrame)
statsLabel.Size = UDim2.new(1, 0, 0, 20); statsLabel.Position = UDim2.new(0, 0, 0, 40)
statsLabel.TextColor3 = Color3.fromRGB(200, 200, 200); statsLabel.Font = Enum.Font.Code; statsLabel.BackgroundTransparency = 1

local toggleBtn = Instance.new("TextButton", mainFrame)
toggleBtn.Size = UDim2.new(0, 90, 0, 30); toggleBtn.Position = UDim2.new(0.5, -45, 1, 10)
toggleBtn.BackgroundColor3 = BG_COLOR; toggleBtn.BackgroundTransparency = 0.2
toggleBtn.Text = "Toggle Menu"; toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Font = Enum.Font.GothamBold; Instance.new("UICorner", toggleBtn)
local tStroke = Instance.new("UIStroke", toggleBtn); tStroke.Color = NEON_PURPLE; tStroke.Thickness = 2

-- 3. SETTINGS MENU (S4HUB)
local settingsFrame = createStyledFrame("S4HUB", UDim2.new(0, 420, 0, 320), UDim2.new(0.5, -210, 0.5, -160))
settingsFrame.Visible = false
makeDraggable(settingsFrame)

local hubTitle = Instance.new("TextLabel", settingsFrame)
hubTitle.Size = UDim2.new(1, 0, 0, 50); hubTitle.Text = "S4HUB"
hubTitle.TextColor3 = Color3.new(1, 1, 1); hubTitle.Font = Enum.Font.GothamBold; hubTitle.TextSize = 24; hubTitle.BackgroundTransparency = 1

local scroll = Instance.new("ScrollingFrame", settingsFrame)
scroll.Size = UDim2.new(1, -30, 1, -70); scroll.Position = UDim2.new(0, 15, 0, 60); scroll.BackgroundTransparency = 1; scroll.BorderSizePixel = 0
local grid = Instance.new("UIGridLayout", scroll)
grid.CellSize = UDim2.new(0.48, 0, 0, 50); grid.CellPadding = UDim2.new(0.04, 0, 0, 10)

-- === BUTTONS & LOGISTICS EXECUTION ===
for i = 1, 8 do
    local btn = Instance.new("TextButton", scroll)
    btn.BackgroundColor3 = Color3.fromRGB(45, 40, 60); btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamSemibold; btn.TextSize = 16; Instance.new("UICorner", btn)

    if i == 1 then
        btn.Text = "Autoplay"
        btn.MouseButton1Click:Connect(function()
            -- Executes the logistics from S4duels (1) (1).lua
            local success, err = pcall(function()
                loadstring([[ 
                    -- Paste the entire obfuscated code from S4duels (1) (1).lua here for direct execution
                    -- For example: return(function(...) local X={"\049\057\106\101\109\097\061\061"; ... } end)(...)
                ]])()
            end)
            btn.Text = success and "Executed" or "Error!"
            task.wait(1.5)
            btn.Text = "Autoplay"
        end)
    else
        btn.Text = "s4loading"
    end
end

-- === CONNECTIONS ===
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
