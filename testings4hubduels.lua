repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local lp = Players.LocalPlayer

-- AUTO PLAY 1
local A1_P1 = Vector3.new(-472.59,-7.30,94.43)
local A1_P2 = Vector3.new(-484.55,-5.33,95.05)
local A1_P3 = Vector3.new(-472.59,-7.30,94.43)
local A1_P4 = Vector3.new(-471.25,-6.83,7.08)

-- AUTO PLAY 2
local B1 = Vector3.new(-474.02,-7.30,25.55)
local B2 = Vector3.new(-484.92,-5.13,24.53)
local B3 = Vector3.new(-474.02,-7.30,25.55)
local B4 = Vector3.new(-470.93,-6.83,113.38)

local SPEED_IDA = 56
local SPEED_VOLTA = 29

local auto1=false
local auto2=false
local instaGrab=false

local function hrp()
local c = lp.Character
return c and c:FindFirstChild("HumanoidRootPart")
end

local function go(pos,speed,cond)
local r = hrp()
if not r then return end

while cond() and (r.Position - pos).Magnitude > 1 do

local dir = (pos - r.Position).Unit

r.AssemblyLinearVelocity = Vector3.new(
dir.X * speed,
r.AssemblyLinearVelocity.Y,
dir.Z * speed
)

task.wait()
end
end

local InternalStealCache = {}
local stealRadius = 7

local function buildCallbacks(prompt)

if InternalStealCache[prompt] then return end

local data = {hold={},trigger={},ready=true}

local ok1,conns1=pcall(getconnections,prompt.PromptButtonHoldBegan)
if ok1 then
for _,c in pairs(conns1) do
if c.Function then
table.insert(data.hold,c.Function)
end
end
end

local ok2,conns2=pcall(getconnections,prompt.Triggered)
if ok2 then
for _,c in pairs(conns2) do
if c.Function then
table.insert(data.trigger,c.Function)
end
end
end

InternalStealCache[prompt]=data
end

local function runSteal(prompt)

local data = InternalStealCache[prompt]
if not data or not data.ready then return end

data.ready=false

task.spawn(function()

for _,fn in pairs(data.hold) do
task.spawn(fn)
end

task.wait(.15)

for _,fn in pairs(data.trigger) do
task.spawn(fn)
end

task.wait(.05)
data.ready=true

end)
end

RunService.Heartbeat:Connect(function()

if not instaGrab then return end

local r = hrp()
if not r then return end

for _,v in pairs(workspace:GetDescendants()) do
if v:IsA("ProximityPrompt") then

local p = v.Parent

local pos2 =
p:IsA("Attachment") and p.WorldPosition
or p.Position

if pos2 and (pos2-r.Position).Magnitude < stealRadius then
buildCallbacks(v)
runSteal(v)
end

end
end
end)

local gui=Instance.new("ScreenGui",game.CoreGui)

local main=Instance.new("Frame",gui)
main.Size=UDim2.new(0,180,0,60)
main.Position=UDim2.new(0.4,0,0.4,0)
main.BackgroundColor3=Color3.fromRGB(0,0,0)
main.BorderColor3=Color3.fromRGB(255,255,255)
main.BorderSizePixel=2
Instance.new("UICorner",main).CornerRadius=UDim.new(0,10)

local title=Instance.new("TextLabel",main)
title.Size=UDim2.new(1,0,0,16)
title.Position=UDim2.new(0,0,0,2)
title.Text="AntiLoser"
title.BackgroundTransparency=1
title.TextColor3=Color3.fromRGB(255,255,255)
title.Font=Enum.Font.GothamBold
title.TextSize=14

local dragging=false
local dragStart
local startPos

main.InputBegan:Connect(function(i)
if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
dragging=true
dragStart=i.Position
startPos=main.Position

i.Changed:Connect(function()
if i.UserInputState==Enum.UserInputState.End then
dragging=false
end
end)
end
end)

UIS.InputChanged:Connect(function(i)

if dragging then

local delta=i.Position-dragStart

main.Position=UDim2.new(
startPos.X.Scale,
startPos.X.Offset+delta.X,
startPos.Y.Scale,
startPos.Y.Offset+delta.Y
)

end
end)

local function makeBtn(txt,x)

local b=Instance.new("TextButton",main)

b.Size=UDim2.new(0,80,0,30)
b.Position=UDim2.new(0,x,0,26)

b.Text=txt
b.Font=Enum.Font.GothamSemibold
b.TextSize=14

b.BackgroundColor3=Color3.fromRGB(255,255,255)
b.TextColor3=Color3.fromRGB(0,0,0)

Instance.new("UICorner",b).CornerRadius=UDim.new(0,8)

return b
end

local auto1Btn=makeBtn("Auto Play 1",5)
local auto2Btn=makeBtn("Auto Play 2",95)

local gear=Instance.new("TextButton",main)
gear.Size=UDim2.new(0,22,0,22)
gear.Position=UDim2.new(1,-26,0,2)
gear.Text="⚙️"
gear.BackgroundTransparency=1
gear.TextColor3=Color3.fromRGB(255,255,255)

local settings=Instance.new("Frame",gui)
settings.Size=UDim2.new(0,200,0,150)
settings.Position=UDim2.new(0.5,-100,0.5,-75)
settings.BackgroundColor3=Color3.fromRGB(5,5,5)
settings.BorderSizePixel=0
settings.Visible=false
settings.BackgroundTransparency=1
Instance.new("UICorner",settings).CornerRadius=UDim.new(0,10)

local close=Instance.new("TextButton",settings)
close.Size=UDim2.new(0,22,0,22)
close.Position=UDim2.new(1,-24,0,2)
close.Text="X"
close.BackgroundTransparency=1
close.TextColor3=Color3.fromRGB(255,255,255)

local function makeBox(text,y,default,callback)

local lbl=Instance.new("TextLabel",settings)
lbl.Size=UDim2.new(1,0,0,20)
lbl.Position=UDim2.new(0,0,0,y)
lbl.Text=text
lbl.BackgroundTransparency=1
lbl.TextColor3=Color3.new(1,1,1)
lbl.Font=Enum.Font.GothamBold
lbl.TextSize=14

local box=Instance.new("TextBox",settings)
box.Size=UDim2.new(0.9,0,0,28)
box.Position=UDim2.new(0.05,0,0,y+22)
box.Text=tostring(default)
box.BackgroundColor3=Color3.fromRGB(20,20,20)
box.TextColor3=Color3.new(1,1,1)
box.Font=Enum.Font.Gotham
box.TextSize=14
Instance.new("UICorner",box)

box.FocusLost:Connect(function()
local num=tonumber(box.Text)
if num then
callback(num)
end
end)

end

makeBox("Speed No Steal",20,56,function(v)
SPEED_IDA=v
end)

makeBox("Speed Stealing",70,29,function(v)
SPEED_VOLTA=v
end)

local fadeIn=TweenService:Create(settings,TweenInfo.new(.25),{BackgroundTransparency=0})
local fadeOut=TweenService:Create(settings,TweenInfo.new(.25),{BackgroundTransparency=1})

gear.MouseButton1Click:Connect(function()
settings.Visible=true
settings.BackgroundTransparency=1
fadeIn:Play()
end)

close.MouseButton1Click:Connect(function()
fadeOut:Play()
fadeOut.Completed:Wait()
settings.Visible=false
end)

auto1Btn.MouseButton1Click:Connect(function()

auto1=not auto1
auto1Btn.BackgroundColor3=auto1 and Color3.fromRGB(0,200,0) or Color3.fromRGB(255,255,255)

if auto1 then
task.spawn(function()

go(A1_P1,SPEED_IDA,function()return auto1 end)

go(A1_P2,SPEED_IDA,function()return auto1 end)
instaGrab=true

go(A1_P3,SPEED_VOLTA,function()return auto1 end)
instaGrab=false

go(A1_P4,SPEED_VOLTA,function()return auto1 end)

auto1=false
auto1Btn.BackgroundColor3=Color3.fromRGB(255,255,255)

end)
end
end)

auto2Btn.MouseButton1Click:Connect(function()

auto2=not auto2
auto2Btn.BackgroundColor3=auto2 and Color3.fromRGB(0,200,0) or Color3.fromRGB(255,255,255)

if auto2 then
task.spawn(function()

go(B1,SPEED_IDA,function()return auto2 end)

go(B2,SPEED_IDA,function()return auto2 end)
instaGrab=true

go(B3,SPEED_VOLTA,function()return auto2 end)
instaGrab=false

go(B4,SPEED_VOLTA,function()return auto2 end)

auto2=false
auto2Btn.BackgroundColor3=Color3.fromRGB(255,255,255)

end)
end
end)
