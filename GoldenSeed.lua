-- [[ Golden Seed - Event Hunter Edition ]] --
-- مخصص للعمل على Delta Executor ومرفوع على GitHub

local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- إعدادات الواجهة (GUI)
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local ToggleBtn = Instance.new("TextButton")
local Title = Instance.new("TextLabel")

ScreenGui.Name = "GoldenSeedEvent"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- تصميم الصندوق (أسود، مربع، حواف دائرية)
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15) -- أسود
MainFrame.Position = UDim2.new(0.5, -60, 0.4, 0)
MainFrame.Size = UDim2.new(0, 120, 0, 120)
MainFrame.Active = true
MainFrame.Draggable = true -- دعم السحب للجوال

UICorner.CornerRadius = UDim.new(0, 20)
UICorner.Parent = MainFrame

Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Font = Enum.Font.GothamBold
Title.Text = "Golden Seed"
Title.TextColor3 = Color3.fromRGB(255, 215, 0) -- ذهبي
Title.TextSize = 14

ToggleBtn.Parent = MainFrame
ToggleBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0) -- أحمر (OFF)
ToggleBtn.Position = UDim2.new(0.1, 0, 0.4, 0)
ToggleBtn.Size = UDim2.new(0.8, 0, 0.45, 0)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Text = "OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 18

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 15)
BtnCorner.Parent = ToggleBtn

-- [[ برمجة المنطق الذكي ]] --

_G.AutoFarm = false

-- المواصفات الدقيقة التي أعطيتها لي
local TargetSize = Vector3.new(7, 7, 7)
local TargetColor = Color3.new(0.639216, 0.635294, 0.647059)
local MainPath = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("SeedPackSpawnServerLocations")

-- دالة للتحقق هل هذه القطعة هي المطلوبة؟
local function isTheSeed(part)
    if part:IsA("BasePart") and 
       (part.Size - TargetSize).Magnitude < 0.1 and 
       part.CanCollide == false then
       return true
    end
    return false
end

-- وظيفة البحث والانتقال
local function startFarming()
    task.spawn(function()
        while _G.AutoFarm do
            local target = nil

            -- 1. ابحث أولاً في المسار الرئيسي (أولوية قصوى)
            if MainPath then
                for _, obj in pairs(MainPath:GetDescendants()) do
                    if isTheSeed(obj) then
                        target = obj
                        break
                    end
                end
            end

            -- 2. إذا لم يجدها، ابحث في الماب بالكامل (مراقبة المسار الواسع)
            if not target then
                for _, obj in pairs(workspace:GetDescendants()) do
                    if isTheSeed(obj) then
                        target = obj
                        break
                    end
                end
            end

            -- 3. إذا وجدها، انتقل فوراً وثبت اللاعب
            if target then
                while _G.AutoFarm and target.Parent ~= nil do
                    if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                        Player.Character.HumanoidRootPart.CFrame = target.CFrame
                    end
                    task.wait() -- تثبيت فائق السرعة
                end
            end
            
            task.wait(0.2) -- انتظار بسيط قبل البحث عن القطعة التالية
        end
    end)
end

-- تشغيل وإطفاء السكريبت
ToggleBtn.MouseButton1Click:Connect(function()
    _G.AutoFarm = not _G.AutoFarm
    if _G.AutoFarm then
        ToggleBtn.Text = "ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0) -- أخضر
        startFarming()
    else
        ToggleBtn.Text = "OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
    end
end)

-- كود إضافي للتأكد من أن الواجهة قابلة للسحب باللمس (Touch Support)
local UserInputService = game:GetService("UserInputService")
local dragging, dragInput, dragStart, startPos

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
