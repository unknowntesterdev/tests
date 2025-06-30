local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "test ui", HidePremium = false, SaveConfig = true, ConfigFolder = "HazardTest"})
local Tab = Window:MakeTab({Name = "Game", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local Section = Tab:AddSection({Name = "Game Menu"})

local Players = game:GetService("Players")
local plr = Players.LocalPlayer

local Velocity_Asset = Instance.new("BodyVelocity")
Velocity_Asset.MaxForce = Vector3.new(1e5, 1e5, 1e5)
Velocity_Asset.Velocity = Vector3.new(0, 0, 0)

local TargetedPlayerName = ""

local DragActive = false
local SitHeadActive = false
local BackpackActive = false
local DoggyActive = false
local SexActive = false

local SexAnimId = 148840371

local function GetCharacter(Player)
	return Player and Player.Character
end

local function GetRoot(Player)
	local char = GetCharacter(Player)
	if char then
		return char:FindFirstChild("HumanoidRootPart")
	end
	return nil
end

local function PlayAnim(id, time, speed)
	pcall(function()
		plr.Character.Animate.Disabled = false
		local hum = plr.Character.Humanoid
		local animtrack = hum:GetPlayingAnimationTracks()
		for _, track in pairs(animtrack) do
			track:Stop()
		end
		plr.Character.Animate.Disabled = true
		local Anim = Instance.new("Animation")
		Anim.AnimationId = "rbxassetid://"..id
		local loadanim = hum:LoadAnimation(Anim)
		loadanim:Play()
		loadanim.TimePosition = time
		loadanim:AdjustSpeed(speed)
		loadanim.Stopped:Connect(function()
			plr.Character.Animate.Disabled = false
			for _, track in pairs(animtrack) do
				track:Stop()
			end
		end)
	end)
end

local function StopAnim()
	plr.Character.Animate.Disabled = false
	local animtrack = plr.Character.Humanoid:GetPlayingAnimationTracks()
	for _, track in pairs(animtrack) do
		track:Stop()
	end
end

local function ChangeToggleColor(Button)
	local led = Button.Ticket_Asset
	if led.ImageColor3 == Color3.fromRGB(255, 0, 0) then
		led.ImageColor3 = Color3.fromRGB(0, 255, 0)
	else
		led.ImageColor3 = Color3.fromRGB(255, 0, 0)
	end
end

local function GetPlayer(UserDisplay)
	if UserDisplay ~= "" then
		UserDisplay = UserDisplay:lower()
		for _, v in pairs(Players:GetPlayers()) do
			if v.Name:lower():match(UserDisplay) or v.DisplayName:lower():match(UserDisplay) then
				return v
			end
		end
	end
	return nil
end

-- Target Player Textbox
Section:AddTextbox({
	Name = "Target Player Name",
	Default = "",
	TextDisappear = true,
	Callback = function(text)
		TargetedPlayerName = text
	end
})

-- Drag Toggle Button
Section:AddButton({
	Name = "Toggle Drag",
	Callback = function()
		local target = GetPlayer(TargetedPlayerName)
		if not target then
			warn("Lütfen geçerli hedef oyuncu ismi girin.")
			return
		end

		DragActive = not DragActive

		if DragActive then
			print("Drag başladı")
			PlayAnim(10714360343, 0.5, 0)

			spawn(function()
				repeat
					pcall(function()
						local root = GetRoot(plr)
						local targetRightHand = target.Character and target.Character:FindFirstChild("RightHand")
						if root and targetRightHand then
							if not root:FindFirstChild("BreakVelocity") then
								local tempV = Velocity_Asset:Clone()
								tempV.Name = "BreakVelocity"
								tempV.Parent = root
							end
							root.CFrame = targetRightHand.CFrame * CFrame.new(0, -2.5, 1) * CFrame.Angles(math.rad(-2), math.rad(-3), 0)
							root.Velocity = Vector3.new(0, 0, 0)
						end
					end)
					task.wait()
				until DragActive == false
			end)

		else
			print("Drag durduruldu")
			StopAnim()
			local root = GetRoot(plr)
			if root and root:FindFirstChild("BreakVelocity") then
				root.BreakVelocity:Destroy()
			end
		end
	end
})

-- Sit Head Toggle Button
Section:AddButton({
	Name = "Toggle Sit Head",
	Callback = function()
		local target = GetPlayer(TargetedPlayerName)
		if not target then
			warn("Lütfen geçerli hedef oyuncu ismi girin.")
			return
		end

		SitHeadActive = not SitHeadActive

		if SitHeadActive then
			print("Sit Head başladı")
			spawn(function()
				repeat
					pcall(function()
						local root = GetRoot(plr)
						if root and not root:FindFirstChild("BreakVelocity") then
							local tempV = Velocity_Asset:Clone()
							tempV.Name = "BreakVelocity"
							tempV.Parent = root
						end

						local targetHead = target.Character and target.Character:FindFirstChild("Head")
						if targetHead and plr.Character and plr.Character:FindFirstChildOfClass("Humanoid") then
							plr.Character.Humanoid.Sit = true
							root.CFrame = targetHead.CFrame * CFrame.new(0, 2, 0)
							root.Velocity = Vector3.new(0, 0, 0)
						end
					end)
					task.wait()
				until SitHeadActive == false
			end)
		else
			print("Sit Head durduruldu")
			local root = GetRoot(plr)
			if root and root:FindFirstChild("BreakVelocity") then
				root.BreakVelocity:Destroy()
			end
			if plr.Character and plr.Character:FindFirstChildOfClass("Humanoid") then
				plr.Character.Humanoid.Sit = false
			end
		end
	end
})

-- Backpack Target Toggle Button
Section:AddButton({
	Name = "Toggle Backpack Target",
	Callback = function()
		local target = GetPlayer(TargetedPlayerName)
		if not target then
			warn("Lütfen geçerli hedef oyuncu ismi girin.")
			return
		end

		BackpackActive = not BackpackActive

		if BackpackActive then
			print("Backpack Target başladı")
			spawn(function()
				repeat
					pcall(function()
						local root = GetRoot(plr)
						if root and not root:FindFirstChild("BreakVelocity") then
							local tempV = Velocity_Asset:Clone()
							tempV.Name = "BreakVelocity"
							tempV.Parent = root
						end

						local targetRoot = GetRoot(target)
						if targetRoot and plr.Character and plr.Character:FindFirstChildOfClass("Humanoid") then
							plr.Character.Humanoid.Sit = true
							root.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 1.2) * CFrame.Angles(0, math.rad(-3), 0)
							root.Velocity = Vector3.new(0, 0, 0)
						end
					end)
					task.wait()
				until not BackpackActive
			end)
		else
			print("Backpack Target durduruldu")
			local root = GetRoot(plr)
			if root and root:FindFirstChild("BreakVelocity") then
				root.BreakVelocity:Destroy()
			end
			if plr.Character and plr.Character:FindFirstChildOfClass("Humanoid") then
				plr.Character.Humanoid.Sit = false
			end
		end
	end
})

-- Doggy Target Toggle Button
Section:AddButton({
	Name = "Toggle Doggy Target",
	Callback = function()
		local target = GetPlayer(TargetedPlayerName)
		if not target then
			warn("Lütfen geçerli hedef oyuncu ismi girin.")
			return
		end

		DoggyActive = not DoggyActive

		if DoggyActive then
			print("Doggy Target başladı")
			PlayAnim(13694096724, 3.4, 0)
			spawn(function()
				repeat
					pcall(function()
						local root = GetRoot(plr)
						if root and not root:FindFirstChild("BreakVelocity") then
							local tempV = Velocity_Asset:Clone()
							tempV.Name = "BreakVelocity"
							tempV.Parent = root
						end

						local targetLowerTorso = target.Character and target.Character:FindFirstChild("LowerTorso")
						if targetLowerTorso and root then
							root.CFrame = targetLowerTorso.CFrame * CFrame.new(0, 0.23, 0)
							root.Velocity = Vector3.new(0, 0, 0)
						end
					end)
					task.wait()
				until not DoggyActive
			end)
		else
			print("Doggy Target durduruldu")
			StopAnim()
			local root = GetRoot(plr)
			if root and root:FindFirstChild("BreakVelocity") then
				root.BreakVelocity:Destroy()
			end
		end
	end
})

-- Fucking Toggle Button
Section:AddButton({
	Name = "Toggle Fucking",
	Callback = function()
		local target = GetPlayer(TargetedPlayerName)
		if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then
			warn("Lütfen geçerli hedef oyuncu ismi girin ve hedef hazır olsun.")
			return
		end

		SexActive = not SexActive

		if SexActive then
			print("Fucking başladı")
			local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
			if hum then
				pcall(function()
					if plr.Character:FindFirstChild("Pants") then plr.Character.Pants:Destroy() end
					if plr.Character:FindFirstChild("Shirt") then plr.Character.Shirt:Destroy() end
				end)

				local anim = Instance.new("Animation")
				anim.AnimationId = "rbxassetid://"..SexAnimId
				local animTrack = hum:LoadAnimation(anim)
				animTrack:Play()
				animTrack:AdjustSpeed(10)

				spawn(function()
					while SexActive and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and target.Character and target.Character:FindFirstChild("HumanoidRootPart") do
						task.wait()
						plr.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
					end
					animTrack:Stop()
				end)
			end
		else
			print("Fucking durduruldu")
			local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
			if hum then
				for _, track in pairs(hum:GetPlayingAnimationTracks()) do
					track:Stop()
				end
			end
		end
	end
})

OrionLib:Init()
