-- Orion UI kütüphanesi yükle
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
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")

local targetName = nil
local TargetPlayer = nil

-- İsimle oyuncu bulma fonksiyonu
local function GetPlayerByName(name)
	for _, player in pairs(Players:GetPlayers()) do
		if player.Name:lower() == name:lower() then
			return player
		end
	end
	return nil
end

-- Tool ile dokununca hedef belirleme
local function SetupTool(tool)
	if not tool then return end
	local handle = tool:FindFirstChild("Handle")
	if not handle then return end
	
	handle.Touched:Connect(function(hit)
		local character = hit.Parent
		local player = Players:GetPlayerFromCharacter(character)
		if player and player ~= LocalPlayer then
			TargetPlayer = player
			print("Target set by touch:", player.Name)
		end
	end)
end

-- Karakter yüklendiğinde veya tool eklendiğinde toolu ayarla
LocalPlayer.CharacterAdded:Connect(function(char)
	char.ChildAdded:Connect(function(child)
		if child:IsA("Tool") then
			SetupTool(child)
		end
	end)
end)

if LocalPlayer.Character then
	for _, tool in pairs(LocalPlayer.Character:GetChildren()) do
		if tool:IsA("Tool") then
			SetupTool(tool)
		end
	end
end

-- Drag fonksiyonu (Tween ile yumuşak hareket)
local function DragTarget(target)
	if not target or not target.Character then return end
	local localChar = LocalPlayer.Character
	if not localChar then return end

	local hrp = localChar:FindFirstChild("HumanoidRootPart")
	local targetHrp = target.Character:FindFirstChild("HumanoidRootPart")
	if not hrp or not targetHrp then return end

	local targetCFrame = targetHrp.CFrame * CFrame.new(0, 0, 3)

	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
	tween:Play()
end

-- SitHead fonksiyonu (pozisyon + kafa dönüşü)
local function SitHeadTarget(target)
	if not target or not target.Character then return end
	local localChar = LocalPlayer.Character
	if not localChar then return end

	local hrp = localChar:FindFirstChild("HumanoidRootPart")
	local head = localChar:FindFirstChild("Head")
	local targetHead = target.Character:FindFirstChild("Head")
	if not hrp or not head or not targetHead then return end

	hrp.CFrame = targetHead.CFrame * CFrame.new(0, 0, 0)
	localChar:SetPrimaryPartCFrame(CFrame.new(hrp.Position, targetHead.Position))
end

-- Fling fonksiyonu (ani kuvvet)
local function FlingTarget(target)
	if not target or not target.Character then return end
	local localChar = LocalPlayer.Character
	if not localChar then return end

	local hrp = localChar:FindFirstChild("HumanoidRootPart")
	local targetHrp = target.Character:FindFirstChild("HumanoidRootPart")
	if not hrp or not targetHrp then return end

	local direction = (targetHrp.Position - hrp.Position).Unit
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Velocity = direction * 100
	bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
	bodyVelocity.Parent = hrp
	game.Debris:AddItem(bodyVelocity, 0.2)
end

-- UI TextBox: hedef oyuncu ismi gir
Section:AddTextbox({
	Name = "Target Player Name",
	Default = "",
	TextDisappear = true,
	Callback = function(text)
		targetName = text
	end
})

-- UI Butonlar: drag, sithead, fling
Section:AddButton({
	Name = "Drag Target",
	Callback = function()
		if targetName and targetName ~= "" then
			TargetPlayer = GetPlayerByName(targetName)
			if not TargetPlayer then
				warn("Player not found: "..targetName)
				return
			end
		end
		DragTarget(TargetPlayer)
	end
})

Section:AddButton({
	Name = "Sit Head Target",
	Callback = function()
		if targetName and targetName ~= "" then
			TargetPlayer = GetPlayerByName(targetName)
			if not TargetPlayer then
				warn("Player not found: "..targetName)
				return
			end
		end
		SitHeadTarget(TargetPlayer)
	end
})

Section:AddButton({
	Name = "Fling Target",
	Callback = function()
		if targetName and targetName ~= "" then
			TargetPlayer = GetPlayerByName(targetName)
			if not TargetPlayer then
				warn("Player not found: "..targetName)
				return
			end
		end
		FlingTarget(TargetPlayer)
	end
})

-- Orion UI başlat
OrionLib:Init()
