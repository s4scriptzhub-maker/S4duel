local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- 1. Create the Main ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CustomDashboardUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- === THEME COLORS ===
local bgColor = Color3.fromRGB(45, 45, 65)
local elementColor = Color3.fromRGB(65, 65, 90)
local textColor = Color3.fromRGB(255, 255, 255)
local accentColor = Color3.fromRGB(138, 43, 226) -- Purple-ish accent

-- 2. Top Center Panel (The "Hub" banner)
local topFrame = Instance.new("Frame")
topFrame.Name = "TopMenu"
topFrame.Size = UDim2.new(0, 300, 0, 80)
topFrame.Position = UDim2.new(0.5, -150, 0, 20) -- Centered at the top
topFrame.BackgroundColor3 = bgColor
topFrame.BorderSizePixel = 0
topFrame.Parent = screenGui

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 12)
topCorner.Parent = topFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.Position = UDim2.new(0, 0, 0, 10)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Main Dashboard"
titleLabel.TextColor3 = accentColor
titleLabel.TextSize = 22
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = topFrame

local subtitleLabel = Instance.new("TextLabel")
subtitleLabel.Size = UDim2.new(1, 0, 0, 20)
subtitleLabel.Position = UDim2.new(0, 0, 0, 40)
subtitleLabel.BackgroundTransparency = 1
subtitleLabel.Text = "Status: Online | Ping: 50ms"
subtitleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
subtitleLabel.TextSize = 14
subtitleLabel.Font = Enum.Font.Gotham
subtitleLabel.Parent = topFrame

-- 3. Right Side Panel (For Modules/Toggles)
local sideFrame = Instance.new("Frame")
sideFrame.Name = "SideMenu"
sideFrame.Size = UDim2.new(0, 220, 0, 350)
sideFrame.Position = UDim2.new(1, -240, 0, 120) -- Anchored to the right
sideFrame.BackgroundColor3 = bgColor
sideFrame.BorderSizePixel = 0
sideFrame.Parent = screenGui

local sideCorner = Instance.new("UICorner")
sideCorner.CornerRadius = UDim.new(0, 12)
sideCorner.Parent = sideFrame

local sideTitle = Instance.new("TextLabel")
sideTitle.Size = UDim2.new(1, -20, 0, 30)
sideTitle.Position = UDim2.new(0, 10, 0, 5)
sideTitle.BackgroundTransparency = 1
sideTitle.Text = "Modules"
sideTitle.TextColor3 = textColor
sideTitle.TextXAlignment = Enum.TextXAlignment.Left
sideTitle.TextSize = 16
sideTitle.Font = Enum.Font.GothamBold
sideTitle.Parent = sideFrame

local separator = Instance.new("Frame")
separator.Size = UDim2.new(1, -20, 0, 2)
separator.Position = UDim2.new(0, 10, 0, 35)
separator.BackgroundColor3 = elementColor
separator.BorderSizePixel = 0
separator.Parent = sideFrame

-- 4. Reusable Function to Create Buttons/Toggles
local function createButton(parent, name, yOffset)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(1, -20, 0, 35)
    button.Position = UDim2.new(0, 10, 0, yOffset)
    button.BackgroundColor3 = elementColor
    button.Text = "  " .. name
    button.TextColor3 = textColor
    button.TextXAlignment = Enum.TextXAlignment.Left
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 14
    button.AutoButtonColor = true
    button.Parent = parent
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = button
    
    -- Visual Indicator (fake toggle switch)
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 20, 0, 20)
    indicator.Position = UDim2.new(1, -30, 0.5, -10)
    indicator.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    indicator.Parent = button
    
    local indCorner = Instance.new("UICorner")
    indCorner.CornerRadius = UDim.new(1, 0)
    indCorner.Parent = indicator

    return button, indicator
end

-- 5. Populate the Side Panel and Add Your "Logistics" Here
local btn1, ind1 = createButton(sideFrame, "Feature Toggle 1", 50)
local btn2, ind2 = createButton(sideFrame, "Feature Toggle 2", 95)
local btn3, ind3 = createButton(sideFrame, "Execute Action", 140)

-- Example Logic Attachment
local toggle1State = false
btn1.MouseButton1Click:Connect(function()
    toggle1State = not toggle1State
    if toggle1State then
        ind1.BackgroundColor3 = accentColor -- Turn "On" visually
        print("Feature 1 Activated")
        -- Add your enable code here
    else
        ind1.BackgroundColor3 = Color3.fromRGB(100, 100, 100) -- Turn "Off" visually
        print("Feature 1 Deactivated")
        -- Add your disable code here
    end
end)

btn3.MouseButton1Click:Connect(function()
    -- This is a click button rather than a toggle
    ind3.BackgroundColor3 = accentColor
    task.wait(0.1)
    ind3.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    
    print("Action Executed!")
    -- Add your execution code here
end)
