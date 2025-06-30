local Services = setmetatable({}, {__index = function(Self, Index)
local NewService = game.GetService(game, Index)
if NewService then
Self[Index] = NewService
end
return NewService
end})

-- [ Modules ] --
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()
local Drawing = loadstring(game:HttpGet("https://raw.githubusercontent.com/iHavoc101/Genesis-Studios/main/Modules/DrawingAPI.lua", true))()

local ToolTip = require(Services.ReplicatedStorage.Modules_client.TooltipModule)

-- [ LocalPlayer ] --
local LocalPlayer = Services.Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [ Raycast Parameters ] --
local RaycastParameters = RaycastParams.new()
RaycastParameters.IgnoreWater = true
RaycastParameters.FilterType = Enum.RaycastFilterType.Blacklist
RaycastParameters.FilterDescendantsInstances = {LocalPlayer.Character}

-- // Variables \\ --
-- [ Info ] --
local Info = {
   SilentAIMEnabled = true;
   TriggeredEnabled = false;
   ArmsCheckEnabled = true;
   TeamWhitelist = "";
   FieldOfView = 500;
}

local LastArrest = time()

-- [ Interface ] --
-- Önce, FOV dairenin rengini ayarlayalım
--local FOVCircle = Drawing.new("Circle", {
   --Thickness = 2.5,
 --  Color = Color3.fromRGB(0, 0, 0),  -- Renk burada belirtiliyor
 --  NumSides = 25,
  -- Radius = _G.FOV
--})

-- Daireyi beyaz değil de görünmez yapmak için alpha kanalını kullanabiliriz
-- Alpha kanalı, rengin şeffaflığını belirtir; 0 tamamen şeffaf, 1 tamamen opak demektir.
-- Bu yüzden, Color değerini beyaz yapmak yerine alpha kanalını sıfıra ayarlayacağız.
 -- Alpha kanalı sıfır, yani tamamen şeffaf

local Target = Drawing.new("Triangle", {
   Thickness = 5,
   Color = Color3.fromRGB(0, 200, 255)
})

-- [ Weapons ] --
local Weapons = {
   "Remington 870";
   "AK-47";
   "M9";
   "M4A1";
   "Hammer";
   "Crude Knife";
}

-- [ Metatable ] --
local RawMetatable = getrawmetatable(game)
local __NameCall = RawMetatable.__namecall
local __Index = RawMetatable.__index

-- // Functions \\ --
local function ValidCharacter(Character)
   return Character and (Character.FindFirstChildWhichIsA(Character, "Humanoid") and Character.FindFirstChildWhichIsA(Character, "Humanoid").Health ~= 0) or false
end

local function NotObstructing(Destination, Ancestor)
   -- [ Camera ] --
   local ObstructingParts = Camera.GetPartsObscuringTarget(Camera, {Destination}, {Ancestor, LocalPlayer.Character})

   for i,v in ipairs(ObstructingParts) do
       pcall(function()
           if v.Transparency >= 1 then
               table.remove(ObstructingParts, i)
           end
       end)
   end

   if #ObstructingParts <= 0 then
       return true
   end

   -- [ Raycast ] --
   RaycastParameters.FilterDescendantsInstances = {LocalPlayer.Character}

   local Origin = Camera.CFrame.Position
   local Direction = (Destination - Origin).Unit * 500
   local RayResult = workspace.Raycast(workspace, Origin, Direction, RaycastParameters) or {
       Instance = nil;
       Position = Origin + Direction;
       Material = Enum.Material.Air;
   }

   if RayResult.Instance and (RayResult.Instance.IsDescendantOf(RayResult.Instance, Ancestor) or RayResult.Instance == Ancestor) then
       return true
   end

   -- [ Obstructed ] --
   return false
end

local function IsArmed(Player)
   for i,v in ipairs(Weapons) do
       local Tool = Player.Backpack.FindFirstChild(Player.Backpack, v) or Player.Character.FindFirstChild(Player.Character, v)
       if Tool then
           return true
       end
   end
   return false
end

local function ClosestPlayerToCursor(Distance)
   local Closest = nil
   local Position = nil
   local ShortestDistance = Distance or math.huge

   local MousePosition = Services.UserInputService.GetMouseLocation(Services.UserInputService)

   for i, v in ipairs(Services.Players.GetPlayers(Services.Players)) do
       if v ~= LocalPlayer and (v.Team ~= LocalPlayer.Team and tostring(v.Team) ~= Info.TeamWhitelist) and ValidCharacter(v.Character) then
           if Info.ArmsCheckEnabled and (v.Team == Services.Teams.Inmates and IsArmed(v) == false) then
               continue
           end

           local ViewportPosition, OnScreen = Camera.WorldToViewportPoint(Camera, v.Character.PrimaryPart.Position)
           local Magnitude = (Vector2.new(ViewportPosition.X, ViewportPosition.Y) - MousePosition).Magnitude

           if OnScreen == false or NotObstructing(v.Character.PrimaryPart.Position, v.Character) == false then
               continue
           end

           if Magnitude < ShortestDistance  then
               Closest = v
               Position = ViewportPosition
               ShortestDistance = Magnitude
           end
       end
   end

   return Closest, Position
end

local function SwitchGuns()
   if LocalPlayer.Character.FindFirstChild(LocalPlayer.Character, "Remington 870") then
       local Tool = LocalPlayer.Backpack.FindFirstChild(LocalPlayer.Backpack, "M4A1") or LocalPlayer.Backpack.FindFirstChild(LocalPlayer.Backpack, "AK-47") or LocalPlayer.Backpack.FindFirstChild(LocalPlayer.Backpack, "M9")

       local Humanoid = LocalPlayer.Character.FindFirstChildWhichIsA(LocalPlayer.Character, "Humanoid")
       Humanoid.EquipTool(Humanoid, Tool)
   else
       local Tool = LocalPlayer.Backpack.FindFirstChild(LocalPlayer.Backpack, "Remington 870")

       local Humanoid = LocalPlayer.Character.FindFirstChildWhichIsA(LocalPlayer.Character, "Humanoid")
       Humanoid.EquipTool(Humanoid, Tool)
   end
end

local function Crash(Gun, BulletCount, ShotCount)
   local ShootEvent = Services.ReplicatedStorage.ShootEvent
   local StartTime = time()
   local BulletTable = {}

   for i = 1, BulletCount do
       BulletTable[i] = {
           Cframe = CFrame.new(),
           Distance = math.huge
       }
   end
   for i = 1, ShotCount do
       ShootEvent:FireServer(BulletTable, Gun)
       if time() - StartTime > 5 then
           break
       end
   end
end

-- // User Interface \\ --
-- [ Window ] --
local Window = OrionLib:MakeWindow({Name = "Privia X", HidePremium = false, SaveConfig = true, ConfigFolder = "X"})

--[[
Name = <string> - The name of the UI.
HidePremium = <bool> - Whether or not the user details shows Premium status or not.
SaveConfig = <bool> - Toggles the config saving in the UI.
ConfigFolder = <string> - The name of the folder where the configs are saved.
IntroEnabled = <bool> - Whether or not to show the intro animation.
IntroText = <string> - Text to show in the intro animation.
IntroIcon = <string> - URL to the image you want to use in the intro animation.
Icon = <string> - URL to the image you want displayed on the window.
CloseCallback = <function> - Function to execute when the window is closed.
]]
-- [ Assists ] --
local Tab = Window:MakeTab({
	Name = "Silent Aim",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

--[[
Name = <string> - The name of the tab.
Icon = <string> - The icon of the tab.
PremiumOnly = <bool> - Makes the tab accessible to Sirus Premium users only.
]]

local Section = Tab:AddSection({
	Name = "X"
})

--[[
Name = <string> - The name of the section.
]]
Tab:AddToggle({
	Name = "Silent Aim",
	Default = false,
	Callback = function(State)
		Info.SilentAIMEnabled = State
	end    
})

OrionLib:MakeNotification({
	Name = "Privia X",
	Content = "fxcked by @hazarzzy",
	Image = "rbxassetid://4483345998",
	Time = 10
})

--[[
Title = <string> - The title of the notification.
Content = <string> - The content of the notification.
Image = <string> - The icon of the notification.
Time = <number> - The duration of the notfication.
]]

--[[
Name = <string> - The name of the toggle.
Default = <bool> - The default value of the toggle.
Callback = <function> - The function of the toggle.
]]


Tab:AddSlider({
	Name = "Field Of View",
	Min = 50,
	Max = 500,
	Default = 500,
	Color = Color3.fromRGB(255,255,255),
	Increment = 1,
	ValueName = "View",
	Callback = function(Value)
		Info.FieldOfView = 500
	end    
})

--[[
Name = <string> - The name of the slider.
Min = <number> - The minimal value of the slider.
Max = <number> - The maxium value of the slider.
Increment = <number> - How much the slider will change value when dragging.
Default = <number> - The default value of the slider.
ValueName = <string> - The text after the value number.
Callback = <function> - The function of the slider.
]]
local Tab = Window:MakeTab({
	Name = "Scripts",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

--[[
Name = <string> - The name of the tab.
Icon = <string> - The icon of the tab.
PremiumOnly = <bool> - Makes the tab accessible to Sirus Premium users only.
]]

local Section = Tab:AddSection({
	Name = "X"
})

Tab:AddButton({
	Name = "Sprint",
	Callback = function()
      		-- ScreenGui oluştur
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = game.Players.LocalPlayer.PlayerGui

-- Hızı Ayarla butonu
local speedButton = Instance.new("TextButton")
speedButton.Parent = screenGui
speedButton.Position = UDim2.new(0, 20, 0, 20) -- Sol üst köşeye taşı
speedButton.Size = UDim2.new(0, 100, 0, 30) -- Boyutu küçült
speedButton.Text = "Sprint"
speedButton.Draggable = true -- Hareket ettirilebilir yap
speedButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- Arka plan rengini siyah yap
speedButton.TextColor3 = Color3.fromRGB(255, 255, 255) -- Yazı rengini beyaz yap

-- Hızı Ayarla butonuna tıklandığında yapılacak işlem
speedButton.MouseButton1Click:Connect(function()
    local character = game.Players.LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 24
        end
    end
end)

-- Saklama Düğmesi
local hideButton = Instance.new("TextButton")
hideButton.Parent = screenGui
hideButton.Position = UDim2.new(0, 10, 0, 10) -- Sol üst köşeye taşı
hideButton.Size = UDim2.new(0, 30, 0, 30) -- Boyutu küçült
hideButton.Text = "X" -- Kapatma işareti
hideButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- Arka plan rengini siyah yap
hideButton.TextColor3 = Color3.fromRGB(255, 255, 255) -- Yazı rengini beyaz yap

-- Saklama Düğmesine tıklandığında yapılacak işlem
local hidden = false
hideButton.MouseButton1Click:Connect(function()
    if hidden then
        speedButton.Visible = true -- Düğmeyi görünür yap
        hideButton.Text = "X" -- Kapatma işaretini geri getir
    else
        speedButton.Visible = false -- Düğmeyi gizle
        hideButton.Text = "+" -- Açma işareti göster
    end
    hidden = not hidden
end)
  	end    
})

Tab:AddButton({
	Name = "Shiftlock",
	Callback = function()
      		loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/hazarprivia/privia/main/Shiftlock.txt"))()
  	end    
})

Tab:AddButton({
	Name = "Infınıty stamina",
	Callback = function()
      		loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/ImMejor35/Prison-Life/main/Infinite%20Stamina.lua"))()
  	end    
})

Tab:AddButton({
	Name = "Remove doors",
	Callback = function()
      		game.Workspace.Doors:Destroy()
game.Workspace.Prison_Fences:Destroy()
  	end    
})





Tab:AddButton({
	Name = "Loop kill all",
	Callback = function()
      		spawn(function()
while wait(0.1) do
for i, v in next, game:GetService("Players"):GetChildren() do
pcall(function()
if v~= game:GetService("Players").LocalPlayer and not v.Character:FindFirstChildOfClass("ForceField") and v.Character.Humanoid.Health > 0 then
while v.Character:WaitForChild("Humanoid").Health > 0 do
wait();
game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = v.Character.HumanoidRootPart.CFrame;
for x, c in next, game:GetService("Players"):GetChildren() do
if c ~= game:GetService("Players").LocalPlayer then game.ReplicatedStorage.meleeEvent:FireServer(c) end
end
end
end
end)
wait()
end
end
end)
  	end    
})


Tab:AddButton({
	Name = "Arrest criminals",
	Callback = function()
      		for i, v in pairs(game.Teams.Criminals:GetPlayers()) do
		if v.Name ~= game.Players.LocalPlayer.Name then
			local inp = 10
			repeat
				wait()
				inp = inp-1
				game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1)
                		game.Workspace.Remote.arrest:InvokeServer(v.Character.HumanoidRootPart)
			until inp == 0
		end
	end
  	end    
})


local Tab = Window:MakeTab({
	Name = "Teleports",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

--[[
Name = <string> - The name of the tab.
Icon = <string> - The icon of the tab.
PremiumOnly = <bool> - Makes the tab accessible to Sirus Premium users only.
]]

local Section = Tab:AddSection({
	Name = "X"
})


Tab:AddButton({
	Name = "Cells",
	Callback = function()
	
		-- buraya gelecek script
		
		local Players = game:GetService('Players')
		local localPlayer = Players.LocalPlayer
		local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChild('HumanoidRootPart')
		
		if humanoid then
			humanoid.CFrame = CFrame.new(915, 100, 2450)
			print("Teleported")
		else
			game:GetService('StarterGui'):SetCore('SendNotification',{
				Title = "Error",
				Text = "HumanoidRootPart not found!",
				Duration = 5,
			})
		end
	
	end    
})


Tab:AddButton({
	Name = "Grocery Shop",
	Callback = function()
	
		-- buraya gelecek script
		
		local Players = game:GetService('Players')
		local localPlayer = Players.LocalPlayer
		local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChild('HumanoidRootPart')
		
		if humanoid then
			humanoid.CFrame = CFrame.new(-415, 55, 1750)
			print("Teleported")
		else
			game:GetService('StarterGui'):SetCore('SendNotification',{
				Title = "Error",
				Text = "HumanoidRootPart not found!",
				Duration = 5,
			})
		end
	
	end    
})

Tab:AddButton({
	Name = "Car Spawn",
	Callback = function()
	
		-- buraya gelecek script
		
		local Players = game:GetService('Players')
		local localPlayer = Players.LocalPlayer
		local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChild('HumanoidRootPart')
		
		if humanoid then
			humanoid.CFrame = CFrame.new(-200, 55, 1880)
			print("Teleported")
		else
			game:GetService('StarterGui'):SetCore('SendNotification',{
				Title = "Error",
				Text = "HumanoidRootPart not found!",
				Duration = 5,
			})
		end
	
	end    
})

Tab:AddButton({
	Name = "Outside Prison",
	Callback = function()
	
		-- buraya gelecek script
		
		local Players = game:GetService('Players')
		local localPlayer = Players.LocalPlayer
		local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChild('HumanoidRootPart')
		
		if humanoid then
			humanoid.CFrame = CFrame.new(280, 72, 2222)
			print("Teleported")
		else
			game:GetService('StarterGui'):SetCore('SendNotification',{
				Title = "Error",
				Text = "HumanoidRootPart not found!",
				Duration = 5,
			})
		end
	
	end    
})

Tab:AddButton({
	Name = "Prison Yard",
	Callback = function()
	
		-- buraya gelecek script
		
		local Players = game:GetService('Players')
		local localPlayer = Players.LocalPlayer
		local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChild('HumanoidRootPart')
		
		if humanoid then
			humanoid.CFrame = CFrame.new(777, 95, 2460)
			print("Teleported")
		else
			game:GetService('StarterGui'):SetCore('SendNotification',{
				Title = "Error",
				Text = "HumanoidRootPart not found!",
				Duration = 5,
			})
		end
	
	end    
})


Tab:AddButton({
	Name = "Shops",
	Callback = function()
	
		-- buraya gelecek script
		
		local Players = game:GetService('Players')
		local localPlayer = Players.LocalPlayer
		local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChild('HumanoidRootPart')
		
		if humanoid then
			humanoid.CFrame = CFrame.new(-370, 55, 1775)
			print("Teleported")
		else
			game:GetService('StarterGui'):SetCore('SendNotification',{
				Title = "Error",
				Text = "HumanoidRootPart not found!",
				Duration = 5,
			})
		end
	
	end    
})


Tab:AddButton({
	Name = "Secret Area",
	Callback = function()
	
		-- buraya gelecek script
		
		local Players = game:GetService('Players')
		local localPlayer = Players.LocalPlayer
		local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChild('HumanoidRootPart')
		
		if humanoid then
			humanoid.CFrame = CFrame.new(-920, 95, 1990)
			print("Teleported")
		else
			game:GetService('StarterGui'):SetCore('SendNotification',{
				Title = "Error",
				Text = "HumanoidRootPart not found!",
				Duration = 5,
			})
		end
	
	end    
})


Tab:AddButton({
	Name = "Gas Station",
	Callback = function()
	
		-- buraya gelecek script
		
		local Players = game:GetService('Players')
		local localPlayer = Players.LocalPlayer
		local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChild('HumanoidRootPart')
		
		if humanoid then
			humanoid.CFrame = CFrame.new(-520, 55, 1660)
			print("Teleported")
		else
			game:GetService('StarterGui'):SetCore('SendNotification',{
				Title = "Error",
				Text = "HumanoidRootPart not found!",
				Duration = 5,
			})
		end
	
	end    
})


Tab:AddButton({
	Name = "Criminal Base",
	Callback = function()
	
		-- buraya gelecek script
		
		local Players = game:GetService('Players')
		local localPlayer = Players.LocalPlayer
		local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChild('HumanoidRootPart')
		
		if humanoid then
			humanoid.CFrame = CFrame.new(-910, 95, 2060)
			print("Teleported")
		else
			game:GetService('StarterGui'):SetCore('SendNotification',{
				Title = "Error",
				Text = "HumanoidRootPart not found!",
				Duration = 5,
			})
		end
	
	end    
})


Tab:AddButton({
	Name = "House Area",
	Callback = function()
	
		-- buraya gelecek script
		
		local Players = game:GetService('Players')
		local localPlayer = Players.LocalPlayer
		local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChild('HumanoidRootPart')
		
		if humanoid then
			humanoid.CFrame = CFrame.new(-230, 55, 2520)
			print("Teleported")
		else
			game:GetService('StarterGui'):SetCore('SendNotification',{
				Title = "Error",
				Text = "HumanoidRootPart not found!",
				Duration = 5,
			})
		end
	
	end    
})


Tab:AddButton({
	Name = "Prison Walkway",
	Callback = function()
	
		-- buraya gelecek script
		
		local Players = game:GetService('Players')
		local localPlayer = Players.LocalPlayer
		local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChild('HumanoidRootPart')
		
		if humanoid then
			humanoid.CFrame = CFrame.new(505, 125, 2330)
			print("Teleported")
		else
			game:GetService('StarterGui'):SetCore('SendNotification',{
				Title = "Error",
				Text = "HumanoidRootPart not found!",
				Duration = 5,
			})
		end
	
	end    
})


Tab:AddButton({
	Name = "Police Cars",
	Callback = function()
	
		-- buraya gelecek script
		
		local Players = game:GetService('Players')
		local localPlayer = Players.LocalPlayer
		local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChild('HumanoidRootPart')
		
		if humanoid then
			humanoid.CFrame = CFrame.new(615, 100, 2515)
			print("Teleported")
		else
			game:GetService('StarterGui'):SetCore('SendNotification',{
				Title = "Error",
				Text = "HumanoidRootPart not found!",
				Duration = 5,
			})
		end
	
	end    
})


Tab:AddButton({
	Name = "Entrance",
	Callback = function()
	
		-- buraya gelecek script
		
		local Players = game:GetService('Players')
		local localPlayer = Players.LocalPlayer
		local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChild('HumanoidRootPart')
		
		if humanoid then
			humanoid.CFrame = CFrame.new(710, 100, 2300)
			print("Teleported")
		else
			game:GetService('StarterGui'):SetCore('SendNotification',{
				Title = "Error",
				Text = "HumanoidRootPart not found!",
				Duration = 5,
			})
		end
	
	end    
})


Tab:AddButton({
	Name = "Police Area",
	Callback = function()
	
		-- buraya gelecek script
		
		local Players = game:GetService('Players')
		local localPlayer = Players.LocalPlayer
		local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChild('HumanoidRootPart')
		
		if humanoid then
			humanoid.CFrame = CFrame.new(855, 100, 2297)
			print("Teleported")
		else
			game:GetService('StarterGui'):SetCore('SendNotification',{
				Title = "Error",
				Text = "HumanoidRootPart not found!",
				Duration = 5,
			})
		end
	
	end    
})


Tab:AddButton({
	Name = "Cafeteria",
	Callback = function()
	
		-- buraya gelecek script
		
		local Players = game:GetService('Players')
		local localPlayer = Players.LocalPlayer
		local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChild('HumanoidRootPart')
		
		if humanoid then
			humanoid.CFrame = CFrame.new(930, 100, 2285)
			print("Teleported")
		else
			game:GetService('StarterGui'):SetCore('SendNotification',{
				Title = "Error",
				Text = "HumanoidRootPart not found!",
				Duration = 5,
			})
		end
	
	end    
})


--[[
Name = <string> - The name of the textbox.
Default = <string> - The default value of the textbox.
TextDisappear = <bool> - Makes the text disappear in the textbox after losing focus.
Callback = <function> - The function of the textbox.
]]


-- // Metatable \\ --
setreadonly(RawMetatable, false)

RawMetatable.__index = newcclosure(function(Self, Index)
   if Info.SilentAIMEnabled == true and checkcaller() == false then
       if typeof(Self) == "Instance" and (Self:IsA("PlayerMouse") or Self:IsA("Mouse")) then
           if Index == "Hit" then
               local Closest = ClosestPlayerToCursor(Info.FieldOfView)
               if Closest then
                   local Velocity = Closest.Character.PrimaryPart.AssemblyLinearVelocity
                   local Prediction = Velocity.Unit
                   if Velocity.Magnitude == 0 then
                       Prediction = Vector3.new(0, 0, 0)
                   end
                   return CFrame.new(Closest.Character.Head.Position + Prediction)
               end
           end
       end
   end

   return __Index(Self, Index)
end)


setreadonly(RawMetatable, true)

-- // Event Listeners \\ --
Services.RunService.RenderStepped:Connect(function()
   if Info.SilentAIMEnabled == true then
       -- FOV --
       FOVCircle.Visible = true
       FOVCircle.Radius = Info.FieldOfView
       FOVCircle.Position = Services.UserInputService:GetMouseLocation()

       -- Target --
       local Closest, Position = ClosestPlayerToCursor(Info.FieldOfView)
       if Closest then
           Target.PointA = Vector2.new(Position.X - 25, Position.Y + 25)
           Target.PointB = Vector2.new(Position.X + 25, Position.Y + 25)
           Target.PointC = Vector2.new(Position.X, Position.Y - 25)
           if Info.TriggeredEnabled and not Services.UserInputService:IsKeyDown(Enum.KeyCode.G) then
               mouse1click()
           end
       end
       Target.Visible = Closest ~= nil
   else
       FOVCircle.Visible = false
       Target.Visible = false
   end
end)

LocalPlayer.Chatted:Connect(function(Message)
   if string.find(Message:lower(), "-lag") then
       local GunScript = (LocalPlayer.Backpack:FindFirstChild("GunInterface", true) or LocalPlayer.Character:FindFirstChild("GunInterface", true))
       if GunScript then
           ToolTip.update("Lagging...")
           Crash(GunScript.Parent, 100, 10)
           ToolTip.update("Lagged!")
       else
          ToolTip.update("Error: No gun found!")
       end
   end
end)

local LastShotDetected = time()
for i,v in ipairs(getconnections(Services.ReplicatedStorage.ReplicateEvent.OnClientEvent)) do
   local OldFunction = v.Function
   v.Function = function(BulletStats, IsTaser)
       if #BulletStats > 25 or time() - LastShotDetected > 0.02 then
           ToolTip.update("Bullet Overload: Removing...")
           return
       end
       LastShotDetected = time()
       OldFunction(BulletStats, IsTaser)
   end
end

local LastSoundDetected = time()
for i,v in ipairs(getconnections(Services.ReplicatedStorage.SoundEvent.OnClientEvent)) do
   local OldFunction = v.Function
   v.Function = function(Sound)
       if time() - LastSoundDetected > 0.02 then
           ToolTip.update("Audio Overload: Removing...")
           return
       end
       LastSoundDetected = time()
       OldFunction(Sound)
   end
end


-- // KeyBinds \\ --
Services.UserInputService.InputBegan:Connect(function(Input, GameProcessed)
   if _G.ArrestAssist == false or GameProcessed or LocalPlayer.Character:FindFirstChild("Handcuffs") == nil then
       return
   end

   local Delta = time() - LastArrest
   if Delta <= 15 then
       ToolTip.update("Wait " .. tostring(math.floor(Delta)) .. " seconds before arresting again!")
   end

   if Input.UserInputType == Enum.UserInputType.MouseButton1 then
       local Closest = ClosestPlayerToCursor(_G.FOV)
       if Closest then
           local Result = workspace.Remote.arrest:InvokeServer(Closest.Character.HumanoidRootPart)
           ToolTip.update(Result == true and "Successfully arrested!" or Result)
           if Result == true then
               LastArrest = time()
           end
       end
   end
end)

Services.ContextActionService:BindAction("Switch Bind", function(actionName, InputState, inputObject)
if InputState == Enum.UserInputState.End then
return
   end
   pcall(SwitchGuns)
end, false, Enum.KeyCode.Q)

   

-- // Actions \\ --
LocalPlayer.PlayerGui.Home.fadeFrame.Visible = false

return {};

---- // Auto-close Menu UI after 2 seconds // --
