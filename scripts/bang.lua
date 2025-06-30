local SimpleSexGUI = Instance.new("ScreenGui")
SimpleSexGUI.Name = "SimpleSexGUI"
SimpleSexGUI.Parent = game:GetService("CoreGui")
SimpleSexGUI.ResetOnSpawn = false

-- Ana UI frame
local mainFrame = Instance.new("Frame")
mainFrame.Parent = SimpleSexGUI
mainFrame.Name = "MainFrame"
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BackgroundTransparency = 0.3
mainFrame.BorderSizePixel = 0
mainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
mainFrame.Size = UDim2.new(0, 320, 0, 260)
mainFrame.Active = true
mainFrame.Draggable = true

-- Uyuşturulmuş Blur efekti
local blur = Instance.new("UIStroke")
blur.Color = Color3.fromRGB(255, 255, 255)
blur.Thickness = 1
blur.Parent = mainFrame

-- Üst başlık çubuğu
local titleBar = Instance.new("TextLabel")
titleBar.Name = "TitleBar"
titleBar.Parent = mainFrame
titleBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
titleBar.BorderSizePixel = 0
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.Text = "💠 Simple GUI - v2"
titleBar.TextColor3 = Color3.new(1, 1, 1)
titleBar.Font = Enum.Font.SourceSansBold
titleBar.TextSize = 18

-- Küçültme Butonu
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Parent = titleBar
minimizeBtn.Size = UDim2.new(0, 30, 1, 0)
minimizeBtn.Position = UDim2.new(1, -30, 0, 0)
minimizeBtn.Text = "-"
minimizeBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
minimizeBtn.TextColor3 = Color3.new(1,1,1)
minimizeBtn.Font = Enum.Font.SourceSansBold
minimizeBtn.TextSize = 18

-- İçerik konteyneri
local contentFrame = Instance.new("Frame")
contentFrame.Name = "Content"
contentFrame.Parent = mainFrame
contentFrame.Position = UDim2.new(0, 0, 0, 30)
contentFrame.Size = UDim2.new(1, 0, 1, -30)
contentFrame.BackgroundTransparency = 1

-- Hedef TextBox
local victimBox = Instance.new("TextBox")
victimBox.Parent = contentFrame
victimBox.PlaceholderText = "Hedef oyuncu adı"
victimBox.Text = ""
victimBox.Position = UDim2.new(0.05, 0, 0.05, 0)
victimBox.Size = UDim2.new(0.9, 0, 0, 30)
victimBox.Font = Enum.Font.SourceSans
victimBox.TextSize = 18
victimBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
victimBox.TextColor3 = Color3.new(1, 1, 1)
victimBox.BorderSizePixel = 0

-- İşlem Butonu
local actionBtn = Instance.new("TextButton")
actionBtn.Parent = contentFrame
actionBtn.Position = UDim2.new(0.05, 0, 0.22, 0)
actionBtn.Size = UDim2.new(0.9, 0, 0, 35)
actionBtn.Text = "LET'S GO!"
actionBtn.Font = Enum.Font.SourceSansBold
actionBtn.TextSize = 20
actionBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 255)
actionBtn.TextColor3 = Color3.new(1, 1, 1)
actionBtn.BorderSizePixel = 0

-- Görsel
local image = Instance.new("ImageLabel")
image.Parent = contentFrame
image.Image = "rbxassetid://4283774086"
image.Position = UDim2.new(0.5, -50, 0.5, -50)
image.Size = UDim2.new(0, 100, 0, 100)
image.BackgroundTransparency = 1

-- Alt bilgi
local footer = Instance.new("TextLabel")
footer.Parent = contentFrame
footer.Size = UDim2.new(1, 0, 0, 20)
footer.Position = UDim2.new(0, 0, 1, -20)
footer.BackgroundTransparency = 1
footer.Text = "Made by YOU | Fun only"
footer.Font = Enum.Font.SourceSans
footer.TextSize = 14
footer.TextColor3 = Color3.fromRGB(150, 150, 150)

-- Minimize scripti
local minimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    contentFrame.Visible = not minimized
    minimizeBtn.Text = minimized and "+" or "-"
end)

-- Ana işlev (bozulmadan korundu)
actionBtn.MouseButton1Click:Connect(function()
    local player = victimBox.Text
    local anim = Instance.new('Animation')
    anim.AnimationId = 'rbxassetid://148840371'
    local hummy = game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid")

    if hummy then
        pcall(function()
            hummy.Parent:FindFirstChildOfClass("Pants"):Destroy()
        end)
        pcall(function()
            hummy.Parent:FindFirstChildOfClass("Shirt"):Destroy()
        end)

        local playAnim = hummy:LoadAnimation(anim)
        playAnim:Play()
        playAnim:AdjustSpeed(10)

        while hummy.Parent and hummy.Parent.Parent do
            task.wait()
            local target = game.Players:FindFirstChild(player)
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                hummy.Parent:FindFirstChild("HumanoidRootPart").CFrame = target.Character.HumanoidRootPart.CFrame
            end
        end
    end
end)
