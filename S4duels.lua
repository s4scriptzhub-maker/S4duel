-- [[ S4DUELS: ULTIMATE S4INTSMODE EDITION ]] --
-- [[ TOTAL SOURCE CODE - BUG FIXED - FULL DRAG CAPABILITY ]] --

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local playerGui = Player:WaitForChild("PlayerGui")
local ConfigFile = "S4_ELITE_MAIN.json"
local SpeedFile = "S4_ELITE_SPEED.json"

-- === GLOBAL STATE ===
local SavedSettings = { Toggles = {} }
local BatSettings = { Speed = 56 }
local ActiveToggles = {}

local guiLocked = false
local batActive = false
local espActive = false
local infJumpActive = false
local unwalkActive = false
local saintsModeActive = false

-- === PREMIUM THEME COLORS ===
local SHINY_PURPLE = Color3.fromRGB(210, 80, 255)
local NEON_BLUE = Color3.fromRGB(0, 220, 255)
local ACTIVE_GREEN = Color3.fromRGB(0, 255, 150)
local BG_COLOR = Color3.fromRGB(10, 10, 15)
local ESP_COLOR = Color3.fromRGB(255, 0, 0)

-- === CORE DATA PERSISTENCE ===
local function saveAllData()
    if writefile then
        pcall(function()
            writefile(ConfigFile, HttpService:JSONEncode(SavedSettings))
            writefile(SpeedFile, HttpService:JSONEncode(BatSettings))
        end)
    end
end

local function loadData()
    if isfile and isfile(ConfigFile) then
        pcall(function() SavedSettings = HttpService:JSONDecode(readfile(ConfigFile)) end)
    end
    if isfile and isfile(SpeedFile) then
        pcall(function() BatSettings = HttpService:JSONDecode(readfile(SpeedFile)) end)
    end
end

-- === ADVANCED UI FACTORY ===
local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "S4_S4INTS_V3_ULTIMATE"
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

-- FIXED: SECURE DRAG ENGINE
local function makeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    
    frame.InputBegan:Connect(function(input)
        if not guiLocked and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local function createBaseFrame(name, size, pos, accent, parent)
    local f = Instance.new("Frame", parent or screenGui)
    f.Name = name; f.Size = size; f.Position = pos
    f.BackgroundColor3 = BG_COLOR; f.BackgroundTransparency = 0.4
    f.BorderSizePixel = 0
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
    local s = Instance.new("UIStroke", f)
    s.Thickness = 1.5; s.Color = Color3.new(1,1,1)
    applyShinyEffect(s, accent or SHINY_PURPLE, Color3.new(1,1,1))
    return f, s
end

-- [1] LOCK BUTTON (STAYS ON BOTH MODES)
local lockFrame, lockStroke = createBaseFrame("PersistentLock", UDim2.new(0, 95, 0, 30), UDim2.new(0.5, -240, 0, 60), NEON_BLUE)
local lockBtn = Instance.new("TextButton", lockFrame)
lockBtn.Size = UDim2.new(1, 0, 1, 0); lockBtn.BackgroundTransparency = 1; lockBtn.Text = "LOCK GUI"; lockBtn.TextColor3 = Color3.new(1,1,1); lockBtn.Font = "GothamBold"; lockBtn.TextSize = 10
makeDraggable(lockFrame)

-- [2] TOP LEFT RETURN HUB (S4HUB Label)
local returnFrame, returnStroke = createBaseFrame("ReturnLabel", UDim2.new(0, 100, 0, 35), UDim2.new(0, 15, 0, 15), NEON_BLUE)
local returnBtn = Instance.new("TextButton", returnFrame)
returnBtn.Size = UDim2.new(1, 0, 1, 0); returnBtn.BackgroundTransparency = 1; returnBtn.Text = "S4HUB"; returnBtn.TextColor3 = Color3.new(1,1,1); returnBtn.Font = "GothamBold"; returnBtn.TextSize = 14
makeDraggable(returnFrame)

-- [3] MAIN HEADER
local mainHeader =
