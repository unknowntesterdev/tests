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

-- Kullanıcı ismine göre oyuncu bulma
local function FindPlayerByName(UserDisplay)
    if UserDisplay ~= "" then
        UserDisplay = UserDisplay:lower()
        for _, v in pairs(Players:GetPlayers()) do
            if v.Name:lower():match(UserDisplay) or v.DisplayName:lower():match(UserDisplay) then
                return v
            end
        end
        return nil
    else
        return nil
    end
end

-- Oyuncunun karakterini güvenli alma
local function GetCharacter(Player)
    if Player and Player.Character then
        return Player.Character
    end
    return nil
end

-- HumanoidRootPart alma
local function GetRoot(Player)
    local character = GetCharacter(Player)
    if character then
        return character:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

-- Animasyon oynatma
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

-- Animasyon durdurma
local function StopAnim()
    plr.Character.Animate.Disabled = false
    local animtrack = plr.Character.Humanoid:GetPlayingAnimationTracks()
    for _, track in pairs(animtrack) do
        track:Stop()
    end
end

local Velocity_Asset = Instance.new("BodyVelocity")
Velocity_Asset.MaxForce = Vector3.new(1e5, 1e5, 1e5)
Velocity_Asset.Velocity = Vector3.new(0, 0, 0)

-- UI değişkenleri
local TargetedPlayerName = ""
local TargetedPlayer = nil
local DragEnabled = false

-- Textbox: Hedef oyuncu ismi gir
Section:AddTextbox({
	Name = "Target Player Name",
	Default = "",
	TextDisappear = true,
	Callback = function(text)
		TargetedPlayerName = text
		TargetedPlayer = FindPlayerByName(text)
		if TargetedPlayer then
			print("Target player set to:", text)
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
		DragEnabled = value
		if DragEnabled then
			if not TargetedPlayer then
				warn("Please enter a valid target player name before enabling drag!")
				Section:Toggle("Drag Target", false)
				return
			end
			PlayAnim(10714360343, 0.5, 0)
			spawn(function()
				while DragEnabled do
					pcall(function()
						local root = GetRoot(plr)
						local targetRoot = GetRoot(TargetedPlayer)
						if root and targetRoot then
							if not root:FindFirstChild("BreakVelocity") then
								local vel = Velocity_Asset:Clone()
								vel.Name = "BreakVelocity"
								vel.Parent = root
							end
							root.CFrame = targetRoot.CFrame * CFrame.new(0, -2.5, 1) * CFrame.Angles(math.rad(-2), math.rad(-3), 0)
							root.Velocity = Vector3.new(0, 0, 0)
						end
					end)
					task.wait()
				end
			end)
			print("Drag started")
		else
			StopAnim()
			local root = GetRoot(plr)
			if root and root:FindFirstChild("BreakVelocity") then
				root.BreakVelocity:Destroy()
			end
			print("Drag stopped")
		end
	end
})

OrionLib:Init()
