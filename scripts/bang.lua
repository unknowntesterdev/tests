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

local Velocity_Asset = Instance.new("BodyVelocity")
Velocity_Asset.MaxForce = Vector3.new(1e5, 1e5, 1e5)
Velocity_Asset.Velocity = Vector3.new(0, 0, 0)

local TargetedPlayerName = nil
local TargetedPlayer = nil
local DragToggle = false

local function GetRoot(player)
	if player and player.Character then
		return player.Character:FindFirstChild("HumanoidRootPart")
	end
	return nil
end

local function PlayAnim(animId, speed, loop)
	print("Anim oynatılıyor:", animId)
	-- Animasyon kodu buraya
end

local function StopAnim()
	print("Animasyon durduruldu")
	-- Animasyon durdurma buraya
end

-- Textbox: hedef oyuncu ismi gir
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

-- Drag toggle butonu
Section:AddToggle({
	Name = "Drag Target",
	Default = false,
	Callback = function(value)
		DragToggle = value
		if DragToggle then
			if not TargetedPlayer then
				warn("Lütfen geçerli hedef oyuncu ismi girin.")
				Section:Toggle("Drag Target", false) -- Toggle'u kapat
				return
			end

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
	end
})

OrionLib:Init()
