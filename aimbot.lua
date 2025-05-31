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

local Window = OrionLib:MakeWindow({Name = "Title of the library", HidePremium = false, SaveConfig = true, ConfigFolder = "OrionTest"})

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
	Name = "Tab 1",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

--[[
Name = <string> - The name of the tab.
Icon = <string> - The icon of the tab.
PremiumOnly = <bool> - Makes the tab accessible to Sirus Premium users only.
]]

--[[
Name = <string> - The name of the tab.
Icon = <string> - The icon of the tab.
PremiumOnly = <bool> - Makes the tab accessible to Sirus Premium users only.
]]

local Section = Tab:AddSection({
	Name = "Section"
})

--[[
Name = <string> - The name of the section.
]]

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