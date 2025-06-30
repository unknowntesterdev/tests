local TweenService = game:GetService("TweenService")

local SimpleSexGUI = Instance.new("ScreenGui")
SimpleSexGUI.Name = "SimpleSexGUI"
SimpleSexGUI.Parent = game:GetService("CoreGui")
SimpleSexGUI.ResetOnSpawn = false

-- Ana Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Parent = SimpleSexGUI
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BackgroundTransparency = 0.3
mainFrame.BorderSizePixel = 0
mainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
mainFrame.Size = UDim2.new(0, 320, 0, 260)
mainFrame.Active = true
mainFrame.Draggable = true

-- Cam efekti (çerçeve)
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 255, 255)
stroke.Thickness = 1
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
stroke.Parent = mainFrame

-- Başlık Barı
local titleBar = Instance.new("TextLabel")
titleBar.Name = "TitleBar"
titleBar.Parent = mainFrame
titleBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
titleBar.BorderSizePixel = 0
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.Text = "💠 FX GUI - No CFrame"
titleBar.TextColor3 = Color3.new(1, 1, 1)
titleBar.Font = Enum.Font.SourceSansBold
titleBar.TextSize = 18

-- Küçült Butonu
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Parent = titleBar
minimizeBtn.Size = UDim2.new(0, 30, 1, 0)
minimizeBtn.Position = UDim2.new(1, -30, 0, 0)
minimizeBtn.Text = "-"
minimizeBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
minimizeBtn.TextColor3 = Color3.new(1,1,1)
minimizeBtn.Font = Enum.Font.SourceSansBold
minimizeBtn.TextSize = 18

-- İçerik Frame
local contentFrame = Instance.new("Frame")
contentFrame.Name = "Content"
contentFrame.Parent = mainFrame
contentFrame.Position = UDim2.new(0, 0, 0, 30)
contentFrame.Size = UDim2.new(1, 0, 1, -30)
contentFrame.BackgroundTransparency = 1

-- Hedef Oyuncu Adı
local victimBox = Instance.new("TextBox")
victimBox.Parent = contentFrame
victimBox.PlaceholderText = "[NAME]"
victimBox.Text = ""
victimBox.Position = UDim2.new(0.05, 0, 0.05, 0)
victimBox.Size = UDim2.new(0.9, 0, 0, 30)
victimBox.Font = Enum.Font.SourceSans
victimBox.TextSize = 18
victimBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
victimBox.TextColor3 = Color3.new(1, 1, 1)
victimBox.BorderSizePixel = 0

-- Buton
local actionBtn = Instance.new("TextButton")
actionBtn.Parent = contentFrame
actionBtn.Position = UDim2.new(0.05, 0, 0.22, 0)
actionBtn.Size = UDim2.new(0.9, 0, 0, 35)
actionBtn.Text = "LET'S FX!"
actionBtn.Font = Enum.Font.SourceSansBold
actionBtn.TextSize = 20
actionBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 255)
actionBtn.TextColor3 = Color3.new(1, 1, 1)
actionBtn.BorderSizePixel = 0

-- Resim
local image = Instance.new("ImageLabel")
image.Parent = contentFrame
image.Image = "rbxassetid://4283774086"
image.Position = UDim2.new(0.5, -50, 0.55, -50)
image.Size = UDim2.new(0, 100, 0, 100)
image.BackgroundTransparency = 1

-- Footer
local footer = Instance.new("TextLabel")
footer.Parent = contentFrame
footer.Size = UDim2.new(1, 0, 0, 20)
footer.Position = UDim2.new(0, 0, 1, -20)
footer.BackgroundTransparency = 1
footer.Text = "made by fx gui 2025"
footer.Font = Enum.Font.SourceSans
footer.TextSize = 14
footer.TextColor3 = Color3.fromRGB(150, 150, 150)

-- Küçült/Geri Aç Fonksiyonu
local minimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    contentFrame.Visible = not minimized
    minimizeBtn.Text = minimized and "+" or "-"
end)

-- Ana İşlev (CFrame yok, animasyonla ileri-geri efekt)
actionBtn.MouseButton1Click:Connect(function()
    local targetName = victimBox.Text
    local player = game:GetService("Players").LocalPlayer
    local char = player.Character
    if not char or not char:FindFirstChildOfClass("Humanoid") then return end

    local hummy = char:FindFirstChildOfClass("Humanoid")
    if not hummy then return end

    local targetPlayer = game.Players:FindFirstChild(targetName)
    if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then return end

    -- Kıyafetleri çıkar
    pcall(function() char:FindFirstChildOfClass("Shirt"):Destroy() end)
    pcall(function() char:FindFirstChildOfClass("Pants"):Destroy() end)

    -- Animasyonu yükle
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://148840371"
    local loaded = hummy:LoadAnimation(anim)

    -- FX efekti: ileri-geri 3 kez
    for i = 1, 3 do
        loaded:Play()
        loaded:AdjustSpeed(10)
        task.wait(0.4)
        loaded:Stop()
        task.wait(0.2)
    end
end)
