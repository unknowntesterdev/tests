local SimpleSexGUI = Instance.new("ScreenGui", game:GetService("CoreGui"))
SimpleSexGUI.Name = "SimpleSexGUI"
SimpleSexGUI.ResetOnSpawn = false

local frame = Instance.new("Frame", SimpleSexGUI)
frame.Size = UDim2.new(0, 300, 0, 220)
frame.Position = UDim2.new(0.3, 0, 0.3, 0)
frame.BackgroundTransparency = 0.2
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.Text = "💠 FX GUI"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18

local textbox = Instance.new("TextBox", frame)
textbox.PlaceholderText = "Hedef isim"
textbox.Size = UDim2.new(0.9, 0, 0, 30)
textbox.Position = UDim2.new(0.05, 0, 0.2, 0)
textbox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
textbox.TextColor3 = Color3.new(1, 1, 1)
textbox.BorderSizePixel = 0
textbox.Font = Enum.Font.SourceSans
textbox.TextSize = 16

local btn = Instance.new("TextButton", frame)
btn.Text = "LET'S FX!"
btn.Size = UDim2.new(0.9, 0, 0, 35)
btn.Position = UDim2.new(0.05, 0, 0.4, 0)
btn.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
btn.TextColor3 = Color3.new(1, 1, 1)
btn.Font = Enum.Font.SourceSansBold
btn.TextSize = 20

local image = Instance.new("ImageLabel", frame)
image.Image = "rbxassetid://4283774086"
image.Position = UDim2.new(0.5, -50, 0.65, 0)
image.Size = UDim2.new(0, 100, 0, 100)
image.BackgroundTransparency = 1

-- Yardımcı fonksiyonlar
local function trim(s)
    return s:match("^%s*(.-)%s*$")
end

local function findPlayerByName(name)
    name = name:lower()
    for _, plr in pairs(game.Players:GetPlayers()) do
        if plr.Name:lower() == name then
            return plr
        end
    end
    return nil
end

btn.MouseButton1Click:Connect(function()
    local targetName = trim(textbox.Text)
    local plr = game:GetService("Players").LocalPlayer
    local char = plr.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    local animator = hum:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator", hum)
    end

    local target = findPlayerByName(targetName)
    if not target or not target.Character then
        warn("Hedef oyuncu bulunamadı: " .. tostring(targetName))
        return
    end

    -- Kıyafetleri çıkar
    pcall(function() char:FindFirstChildOfClass("Shirt"):Destroy() end)
    pcall(function() char:FindFirstChildOfClass("Pants"):Destroy() end)

    -- Animasyon
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://148840371"

    local track = animator:LoadAnimation(anim)

    for i = 1, 3 do
        track:Play()
        track:AdjustSpeed(10)
        task.wait(0.4)
        track:Stop()
        task.wait(0.2)
    end
end)
