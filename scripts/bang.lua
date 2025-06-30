local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "test ui", HidePremium = false, SaveConfig = true, ConfigFolder = "HazardTest"})
local Tab = Window:MakeTab({Name = "Game", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local Section = Tab:AddSection({Name = "Game Menu"})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local plr = Players.LocalPlayer

local Velocity_Asset = Instance.new("BodyVelocity")
Velocity_Asset.MaxForce = Vector3.new(1e5, 1e5, 1e5)
Velocity_Asset.Velocity = Vector3.new(0, 0, 0)

local TargetedPlayerName = ""

local DragActive = false
local SitHeadActive = false
local BackpackActive = false
local DoggyActive = false
local FlingActive = false
local BangActive = false
local BangConn

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

local function TeleportTO(posX,posY,posZ,player,method)
    pcall(function()
        if method == "safe" then
            task.spawn(function()
                for i = 1,30 do
                    task.wait()
                    GetRoot(plr).Velocity = Vector3.new(0,0,0)
                    if player == "pos" then
                        GetRoot(plr).CFrame = CFrame.new(posX,posY,posZ)
                    else
                        GetRoot(plr).CFrame = CFrame.new(GetRoot(player).Position)+Vector3.new(0,2,0)
                    end
                end
            end)
        else
            GetRoot(plr).Velocity = Vector3.new(0,0,0)
            if player == "pos" then
                GetRoot(plr).CFrame = CFrame.new(posX,posY,posZ)
            else
                GetRoot(plr).CFrame = CFrame.new(GetRoot(player).Position)+Vector3.new(0,2,0)
            end
        end
    end)
end

local function PredictionTP(player,method)
    local root = GetRoot(player)
    local pos = root.Position
    local vel = root.Velocity
    GetRoot(plr).CFrame = CFrame.new((pos.X)+(vel.X)*(GetPing()*3.5),(pos.Y)+(vel.Y)*(GetPing()*2),(pos.Z)+(vel.Z)*(GetPing()*3.5))
    if method == "safe" then
        task.wait()
        GetRoot(plr).CFrame = CFrame.new(pos)
        task.wait()
        GetRoot(plr).CFrame = CFrame.new((pos.X)+(vel.X)*(GetPing()*3.5),(pos.Y)+(vel.Y)*(GetPing()*2),(pos.Z)+(vel.Z)*(GetPing()*3.5))
    end
end

-- UI Elements --
Section:AddTextbox({
	Name = "Player Name",
	Default = "",
	TextDisappear = true,
	Callback = function(text)
		TargetedPlayerName = text
	end
})

-- Drag Toggle Button
Section:AddButton({
	Name = "Drag",
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
	Name = "Sit Head",
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
	Name = "Backpack Target",
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
	Name = "Doggy",
	Callback = function()
		local target = GetPlayer(TargetedPlayerName)
		if not target then
			warn("Lütfen geçerli hedef oyuncu ismi girin.")
			return
		end

		DoggyActive = not DoggyActive

		if DoggyActive then
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
			StopAnim()
			local root = GetRoot(plr)
			if root and root:FindFirstChild("BreakVelocity") then
				root.BreakVelocity:Destroy()
			end
		end
	end
})

-- Bang Feature (Target'in arkasında ileri geri salınma)
local speed = 20 -- salınım hızı
local distance = 3 -- hedefin arkasındaki mesafe
local oscillationRange = 1 -- ileri geri salınım mesafesi

local function StartBang(target)
	if BangConn then BangConn:Disconnect() end
	local t = 0
	local root = GetRoot(plr)
	if not root then return end

	BangConn = RunService.Heartbeat:Connect(function(deltaTime)
		if not BangActive or not target or not target.Character or not GetRoot(target) then
			StopBang()
			return
		end

		t = t + deltaTime * speed

		local targetRoot = GetRoot(target)
		if targetRoot then
			local lookVector = targetRoot.CFrame.LookVector
			local basePos = targetRoot.Position - (lookVector * distance)
			local offset = math.sin(t) * oscillationRange
			local rightVector = targetRoot.CFrame.RightVector
			local finalPos = basePos + rightVector * offset

			root.CFrame = CFrame.new(finalPos, targetRoot.Position)
			root.Velocity = Vector3.new(0, 0, 0)
		end
	end)
end

function StopBang()
	if BangConn then
		BangConn:Disconnect()
		BangConn = nil
	end
end

Section:AddButton({
	Name = "Bang",
	Callback = function()
		local target = GetPlayer(TargetedPlayerName)
		if not target then
			warn("Geçerli hedef yok!")
			return
		end

		BangActive = not BangActive
		if BangActive then
			print("Bang başladı")
			StartBang(target)
		else
			print("Bang durdu")
			StopBang()
		end
	end
})

OrionLib:Init()
