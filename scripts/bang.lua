-- Orion UI yükle
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
local targetName = nil
local TargetPlayer = nil

-- Oyuncu ismine göre hedef bulma
local function GetPlayerByName(name)
	for _, player in pairs(Players:GetPlayers()) do
		if player.Name:lower() == name:lower() then
			return player
		end
	end
	return nil
end

-- Tool ile dokunma eventiyle hedef belirleme
local function SetupTool(tool)
	if not tool then return end
	local handle = tool:FindFirstChild("Handle")
	if not handle then return end
	
	handle.Touched:Connect(function(hit)
		local character = hit.Parent
		local player = Players:GetPlayerFromCharacter(character)
		if player and player ~= LocalPlayer then
			TargetPlayer = player
			print("Target set to (touch):", player.Name)
		end
	end)
end

-- Karakter yüklendiğinde tool varsa ayarla
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

-- Drag fonksiyonu
local function DragTarget()
	if not TargetPlayer then
		warn("No target selected!")
		return
	end

	local localChar = LocalPlayer.Character
	local targetChar = TargetPlayer.Character
	if not localChar or not targetChar then return end

	local hrp = localChar:FindFirstChild("HumanoidRootPart")
	local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
	if hrp and targetHrp then
		-- Hedefin 3 birim önüne hareket
		hrp.CFrame = targetHrp.CFrame * CFrame.new(0, 0, 3)
	end
end

-- SitHead fonksiyonu
local function SitHeadTarget()
	if not TargetPlayer then
		warn("No target selected!")
		return
	end

	local localChar = LocalPlayer.Character
	local targetChar = TargetPlayer.Character
	if not localChar or not targetChar then return end

	local hrp = localChar:FindFirstChild("HumanoidRootPart")
	local targetHead = targetChar:FindFirstChild("Head")
	if hrp and targetHead then
		hrp.CFrame = targetHead.CFrame * CFrame.new(0, 0, 0)
		-- Kafayı hedefe döndür
		localChar:SetPrimaryPartCFrame(CFrame.new(hrp.Position, targetHead.Position))
	end
end

-- Fling fonksiyonu
local function FlingTarget()
	if not TargetPlayer then
		warn("No target selected!")
		return
	end

	local localChar = LocalPlayer.Character
	local targetChar = TargetPlayer.Character
	if not localChar or not targetChar then return end

	local hrp = localChar:FindFirstChild("HumanoidRootPart")
	local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
	if hrp and targetHrp then
		local direction = (targetHrp.Position - hrp.Position).Unit
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.Velocity = direction * 100
		bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
		bodyVelocity.Parent = hrp
		game.Debris:AddItem(bodyVelocity, 0.2)
	end
end

-- UI TextBox: oyuncu ismi gir
Section:AddTextbox({
	Name = "Target Player Name",
	Default = "",
	TextDisappear = true,
	Callback = function(text)
		targetName = text
	end
})

-- UI Butonlar

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
		DragTarget()
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
		SitHeadTarget()
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
		FlingTarget()
	end
})

-- Orion UI başlat
OrionLib:Init()
