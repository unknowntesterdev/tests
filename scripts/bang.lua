-- Orion UI kütüphanesi
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()

local Window = OrionLib:MakeWindow({Name = "test ui", HidePremium = false, SaveConfig = true, ConfigFolder = "HazardTest"})

local Tab = Window:MakeTab({
	Name = "Game",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local Section = Tab:AddSection({
	Name = "Game Menu"
})

local Players = game:GetService("Players")
local plr = Players.LocalPlayer

-- UI için değişkenler
local TargetedPlayerName = nil
local TargetedPlayer = nil
local DragToggle = false

-- DragVelocity Asset
local Velocity_Asset = Instance.new("BodyVelocity")
Velocity_Asset.MaxForce = Vector3.new(1e5, 1e5, 1e5)
Velocity_Asset.Velocity = Vector3.new(0, 0, 0)

-- Fonksiyon: Toggle buton rengi değişimi
local function ChangeToggleColor(button)
	if button.Ticket_Asset.ImageColor3 == Color3.fromRGB(255,0,0) then
		button.Ticket_Asset.ImageColor3 = Color3.fromRGB(0,255,0)
	else
		button.Ticket_Asset.ImageColor3 = Color3.fromRGB(255,0,0)
	end
end

-- Fonksiyon: Oyuncunun HumanoidRootPart'ını al
local function GetRoot(player)
	if player and player.Character then
		return player.Character:FindFirstChild("HumanoidRootPart")
	end
	return nil
end

-- Animasyon fonksiyonları (burayı kendine göre düzenle)
local function PlayAnim(animId, speed, loop)
	print("Anim oynatılıyor:", animId)
	-- Örnek: animasyon yükle ve oynat
end

local function StopAnim()
	print("Anim durduruldu")
	-- Örnek: animasyon durdur
end

-- Textbox: hedef oyuncu ismini yaz
Section:AddTextbox({
	Name = "Target Player Name",
	Default = "",
	TextDisappear = true,
	Callback = function(text)
		TargetedPlayerName = text
		TargetedPlayer = Players:FindFirstChild(text)
		if TargetedPlayer then
			print("Target set to:", text)
		else
			warn("Player not found:", text)
		end
	end
})

-- DragTarget_Button oluştur
local DragTarget_Button = Instance.new("TextButton")
DragTarget_Button.Size = UDim2.new(0, 150, 0, 50)
DragTarget_Button.Position = UDim2.new(0, 10, 0, 100)
DragTarget_Button.Text = "Drag Target"
DragTarget_Button.BackgroundColor3 = Color3.fromRGB(255, 0, 0)

-- Ticket_Asset: buton içinde renk göstergesi için ImageLabel (örnek)
local Ticket_Asset = Instance.new("ImageLabel", DragTarget_Button)
Ticket_Asset.Name = "Ticket_Asset"
Ticket_Asset.Size = UDim2.new(0, 30, 0, 30)
Ticket_Asset.Position = UDim2.new(1, -35, 0.5, -15)
Ticket_Asset.BackgroundTransparency = 1
Ticket_Asset.ImageColor3 = Color3.fromRGB(255, 0, 0)
Ticket_Asset.Image = "rbxassetid://3926305904" -- örnek tick icon

-- Butonu UI'ya ekle
local TabContainer = Window.Container
DragTarget_Button.Parent = TabContainer

-- Butona tıklama eventi
DragTarget_Button.MouseButton1Click:Connect(function()
	if TargetedPlayer == nil then
		warn("Lütfen geçerli hedef oyuncu ismi girin.")
		return
	end

	ChangeToggleColor(DragTarget_Button)
	DragToggle = (DragTarget_Button.Ticket_Asset.ImageColor3 == Color3.fromRGB(0,255,0))

	if DragToggle then
		PlayAnim(10714360343, 0.5, 0)
		spawn(function()
			while DragToggle do
				pcall(function()
					local root = GetRoot(plr)
					local targetRoot = GetRoot(TargetedPlayer)
					if root and targetRoot then
						if not root:FindFirstChild("BreakVelocity") then
							local tempV = Velocity_Asset:Clone()
							tempV.Name = "BreakVelocity"
							tempV.Parent = root
						end
						root.CFrame = targetRoot.CFrame * CFrame.new(0, -2.5, 1) * CFrame.Angles(math.rad(-2), math.rad(-3), 0)
						root.Velocity = Vector3.new(0, 0, 0)
					end
				end)
				task.wait()
			end
		end)
	else
		StopAnim()
		local root = GetRoot(plr)
		if root and root:FindFirstChild("BreakVelocity") then
			root.BreakVelocity:Destroy()
		end
	end
end)

-- Orion UI başlat
OrionLib:Init()
