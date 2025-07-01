local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "test ui", HidePremium = false, SaveConfig = true, ConfigFolder = "HazardTest"})
local Tab = Window:MakeTab({Name = "Game", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local Section = Tab:AddSection({Name = "Game Menu"})

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local plr = Players.LocalPlayer

local Velocity_Asset = Instance.new("BodyVelocity")
Velocity_Asset.MaxForce = Vector3.new(1e5, 1e5, 1e5)
Velocity_Asset.Velocity = Vector3.new(0, 0, 0)

local TargetedPlayerName = ""
local SexAnimId = 148840371
local bangTweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

-- Durum değişkenleri
local DragActive = false
local SitHeadActive = false
local BackpackActive = false
local DoggyActive = false
local BangActive = false

-- Yardımcı fonksiyonlar
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

local function ToggleNoclip(enabled)
	for _, player in pairs(Players:GetPlayers()) do
		local character = player.Character
		if character then
			for _, part in pairs(character:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = not enabled
				end
			end
		end
	end
end

-- UI
Section:AddTextbox({
	Name = "Player Name",
	Default = "",
	TextDisappear = true,
	Callback = function(text)
		TargetedPlayerName = text
	end
})


Section:AddToggle({
	Name = "Sit Head",
	Default = false,
	Callback = function(Value)
		SitHeadActive = Value
		local target = GetPlayer(TargetedPlayerName)
		if not target then warn("Lütfen geçerli hedef oyuncu ismi girin.") return end

		if Value then
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
				until not SitHeadActive
			end)
		else
			local root = GetRoot(plr)
			if root and root:FindFirstChild("BreakVelocity") then root.BreakVelocity:Destroy() end
			if plr.Character and plr.Character:FindFirstChildOfClass("Humanoid") then plr.Character.Humanoid.Sit = false end
		end
	end
})

Section:AddToggle({
	Name = "Backpack Target",
	Default = false,
	Callback = function(Value)
		BackpackActive = Value
		local target = GetPlayer(TargetedPlayerName)
		if not target then warn("Lütfen geçerli hedef oyuncu ismi girin.") return end

		if Value then
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
			local root = GetRoot(plr)
			if root and root:FindFirstChild("BreakVelocity") then root.BreakVelocity:Destroy() end
			if plr.Character and plr.Character:FindFirstChildOfClass("Humanoid") then plr.Character.Humanoid.Sit = false end
		end
	end
})


Section:AddToggle({
	Name = "Suck v1",
	Default = false,
	Callback = function(Value)
		running = Value
		local target = GetPlayer(TargetedPlayerName)
		if not target then
			warn("Lütfen geçerli hedef oyuncu ismi girin.")
			return
		end

		local localPlayer = game.Players.LocalPlayer
		local humanoidRootPart = GetRoot(localPlayer)
		local targetRootPart = GetRoot(target)

		if not (humanoidRootPart and targetRootPart) then return end

		if running then
			originalGravity = workspace.Gravity
			workspace.Gravity = 0

			spawn(function()
				while running and humanoidRootPart and targetRootPart and humanoidRootPart.Position.Y <= 44 do
					task.wait()
					humanoidRootPart.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 1.5, 0)
				end

				task.wait(1)

				-- Attach to target
				attachmentLoop = game:GetService("RunService").Stepped:Connect(function()
					humanoidRootPart.CFrame = targetRootPart.CFrame * CFrame.new(0, 2.3, -1.1) * CFrame.Angles(0, math.pi, 0)
					humanoidRootPart.Velocity = Vector3.new(0, 0, 0)
				end)

				task.wait(1)

				-- Animation
				local anim = Instance.new("Animation")
				anim.AnimationId = "rbxassetid://148840371"
				local hum = localPlayer.Character:FindFirstChild("Humanoid")
				if hum then
					animTrack = hum:LoadAnimation(anim)
					animTrack:Play()
					animTrack:AdjustSpeed(3)
				end
			end)
		else
			if originalGravity then workspace.Gravity = originalGravity end
			if attachmentLoop then attachmentLoop:Disconnect() end
			if animTrack then animTrack:Stop() end
		end
	end
})


Section:AddToggle({
	Name = "Face Sit",
	Default = false,
	Callback = function(Value)
		FaceSitActive = Value

		local target = GetPlayer(TargetedPlayerName)
		if not target then
			warn("Geçerli hedef bulunamadı.")
			return
		end

		local root = GetRoot(plr)
		local targetRoot = GetRoot(target)

		if not (root and targetRoot) then return end

		if Value then
			if plr.Character and plr.Character:FindFirstChildOfClass("Humanoid") then
				plr.Character.Humanoid.Sit = true
			end

			spawn(function()
				while FaceSitActive and root and targetRoot do
					pcall(function()
						if not root:FindFirstChild("BreakVelocity") then
							local v = Velocity_Asset:Clone()
							v.Name = "BreakVelocity"
							v.Parent = root
						end

						-- Yüzünün önüne pozisyon hesapla:
						local forward = targetRoot.CFrame.LookVector -- hedefin baktığı yön
						local pos = targetRoot.Position + Vector3.new(0, 1.9, 0) + forward * 1.1

						root.CFrame = CFrame.new(pos, targetRoot.Position + Vector3.new(0,1.9,0))
						root.Velocity = Vector3.new(0, 0, 0)
					end)
					task.wait()
				end
			end)
		else
			if root and root:FindFirstChild("BreakVelocity") then
				root.BreakVelocity:Destroy()
			end
			if plr.Character and plr.Character:FindFirstChildOfClass("Humanoid") then
				plr.Character.Humanoid.Sit = false
			end
		end
	end
})

Section:AddToggle({
    Name = "Face Bang",
    Default = false,
    Callback = function(Value)
        FaceSitActive = Value

        local target = GetPlayer(TargetedPlayerName)
        if not target then
            warn("Geçerli hedef bulunamadı.")
            return
        end

        local root = GetRoot(plr)
        local targetRoot = GetRoot(target)

        if not (root and targetRoot) then return end

        if Value then
            if plr.Character and plr.Character:FindFirstChildOfClass("Humanoid") then
                plr.Character.Humanoid.Sit = true
            end

            spawn(function()
                local oscillationSpeed = -1 -- Hareket hızı (daha hızlı için azalt)
                local oscillationDistance = 1 -- Hareket mesafesi
                local timeOffset = 0

                while FaceSitActive and root and targetRoot do
                    pcall(function()
                        if not root:FindFirstChild("BreakVelocity") then
                            local v = Velocity_Asset:Clone()
                            v.Name = "BreakVelocity"
                            v.Parent = root
                        end

                        -- Yüzünün önüne pozisyon hesapla:
                        local forward = targetRoot.CFrame.LookVector -- hedefin baktığı yön
                        timeOffset = timeOffset + oscillationSpeed
                        
                        -- Sinüs fonksiyonu ile ileri-geri hareket
                        local oscillation = math.sin(timeOffset) * oscillationDistance
                        
                        local pos = targetRoot.Position + Vector3.new(0, 1.9, 0) + forward * (1.1 + oscillation)
                        
                        root.CFrame = CFrame.new(pos, targetRoot.Position + Vector3.new(0,1.9,0))
                        root.Velocity = Vector3.new(0, 0, 0)
                    end)
                    task.wait()
                end
            end)
        else
            if root and root:FindFirstChild("BreakVelocity") then
                root.BreakVelocity:Destroy()
            end
            if plr.Character and plr.Character:FindFirstChildOfClass("Humanoid") then
                plr.Character.Humanoid.Sit = false
            end
        end
    end
})

Section:AddToggle({
    Name = "Face Bang (Standing Behind)",
    Default = false,
    Callback = function(Value)
        FaceSitActive = Value

        local target = GetPlayer(TargetedPlayerName)
        if not target then
            warn("Geçerli hedef bulunamadı.")
            return
        end

        local root = GetRoot(plr)
        local targetRoot = GetRoot(target)

        if not (root and targetRoot) then return end

        if Value then
            spawn(function()
                local oscillationSpeed = 0.15 -- ileri-geri hız
                local oscillationDistance = 0.5 -- mesafe
                local timeOffset = 0

                while FaceSitActive and root and targetRoot do
                    pcall(function()
                        if not root:FindFirstChild("BreakVelocity") then
                            local v = Velocity_Asset:Clone()
                            v.Name = "BreakVelocity"
                            v.Parent = root
                        end

                        local backward = -targetRoot.CFrame.LookVector -- hedefin arkası
                        timeOffset = timeOffset + oscillationSpeed
                        local oscillation = math.sin(timeOffset) * oscillationDistance

                        local basePos = targetRoot.Position + Vector3.new(0, 0, 0) + backward * (1.2 + oscillation)
                        root.CFrame = CFrame.new(basePos, targetRoot.Position + Vector3.new(0, 1.9, 0))
                        root.Velocity = Vector3.new(0, 0, 0)
                    end)
                    task.wait()
                end
            end)
        else
            if root and root:FindFirstChild("BreakVelocity") then
                root.BreakVelocity:Destroy()
            end
        end
    end
})

