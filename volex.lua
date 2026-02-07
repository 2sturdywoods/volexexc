LPH_NO_VIRTUALIZE(function()

local Starlight = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/starlight"))()
local NebulaIcons = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/nebula-icon-library-loader"))()

if not LRM_SecondsLeft then
    LRM_SecondsLeft = math.huge
end

local time_left = (LRM_SecondsLeft == math.huge)
    and "lifetime"
    or (tostring(math.floor((((LRM_SecondsLeft / 60) / 60) / 24))) .. " days")

local Window = Starlight:CreateWindow({
    Name = "Volex",
    Subtitle = time_left,
    Icon = 115775448676820,
    LoadingSettings = {
        Title = "Volex",
        Subtitle = "Loading...",
    },
    FileSettings = {
        ConfigFolder = "Volex"
    },
})

Window:CreateHomeTab({
    SupportedExecutors = {
        "Synapse X",
        "Script-Ware",
        "Krnl",
        "Fluxus"
    },

    UnsupportedExecutors = {
        "Delta"
    },

    DiscordInvite = "fTse9gww",

    -- nil = void
    -- 0 = game thumbnail
    -- "" = none
    Backdrop = 0,

    IconStyle = 1,

    Changelog = {
        {
            Title = "Initial Release",
            Date = "Feb 4, 2026",
            Description = "• Core features added\n• Teleports\n• Player mods",
        },
        {
            Title = "QoL Update",
            Date = "Later",
            Description = "Bug fixes & performance improvements",
        }
    }
})

local UIS = game:GetService("UserInputService")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local function DistanceCheck(plr, dist)
	if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then return false end
	if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return false end

	return (plr.Character.HumanoidRootPart.Position
		- LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <= dist
end

local function HasGunEquipped()
	local char = LocalPlayer.Character
	if not char then return false end

	for _, tool in ipairs(char:GetChildren()) do
		if tool:IsA("Tool") then
			if tool:FindFirstChild("GunScript_Local") or tool:FindFirstChild("Setting") then
				return true
			end
		end
	end

	return false
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local StarterGui = game:GetService("StarterGui")

local function GetGoodCleaner()
	local CounterInstance

	for _, v in ipairs(workspace["1# Map"]:GetChildren()) do
		if v:FindFirstChild("CounterM") then
			CounterInstance = v
			break
		end
	end

	if not CounterInstance then return nil end

	for _, list in ipairs({
		workspace.CounterBag:GetChildren(),
		CounterInstance:GetChildren()
	}) do
		for _, cleaner in ipairs(list) do
			local cashPrompt = cleaner:FindFirstChild("CashPrompt", true)
			local grabPrompt = cleaner:FindFirstChild("GrabPrompt", true)

			if cashPrompt
				and cashPrompt.Enabled
				and cashPrompt.ObjectText == "Count Bread"
				and grabPrompt
				and not grabPrompt.Enabled then
				return cleaner
			end
		end
	end

	return nil
end

local Config = {
	Guns = {}
}

local gunsFolder = workspace:WaitForChild("GUNS")

for _, gun in ipairs(gunsFolder:GetChildren()) do
	table.insert(Config.Guns, gun.Name)
end

local TeleportLocations = {
	["Deli Market 🥪"] = CFrame.new(-602.3944091796875, 253.73313903808594, -584.2000732421875),
	["Switches Plug 🔫"] = CFrame.new(-1444.5, 253.3, 2222.1),
	["Capital One Bank 🏦"] = CFrame.new(-235.0, 283.7, -1213.2),
	["Ice Box 🧊"] = CFrame.new(-198.8927001953125, 283.8486633300781, -1170.4500732421875),
	["Margreens"] = CFrame.new(-365.5, 254.5, -377.2),
	["Hospital 🏥"] = CFrame.new(-1594.6, 254.3, 23.9),
	["Bookbag Store 🎒"] = CFrame.new(-694.4, 253.8, -682.9),
	["Safe Spot 🛡️"] = CFrame.new(-386.5, 462.7, -718.5),
	["Popeyes 🏪"] = CFrame.new(-45.9, 283.7, -774.9),
	["Hotel 🏨"] = CFrame.new(-1012, 266, -933),
	["Drip Store 👓"] = CFrame.new(67462.6953125, 10489.0322265625, 546.6762084960938),
	["Gun Store 🔫"] = CFrame.new(92958.2, 122098.5, 17237.6),
	["Car Dealer 🚗"] = CFrame.new(-378.6668701171875, 253.2564697265625, -1245.4259033203125),
	["Laundromat 💷"] = CFrame.new(-979.4635620117188, 253.65318298339844, -689.3339233398438),
	["Studio🎙"] = CFrame.new(93408.453125, 14484.7158203125, 570.139404296875),
	["Basketball Court 🏀"] = CFrame.new(-1055.6407470703125, 253.51364135742188, -497.10528564453125),
	["Robbable Ice Box 🧊"] = CFrame.new(-209.68360900878906, 283.4959411621094, -1265.5286865234375),
	["Exotic Dealer 🍃"] = CFrame.new(-1521.943115234375, 272.5462646484375, -984.3020629882812),
	["Safe / Store Guns🔒"] = CFrame.new(-1562.8, 257.0, 2413.6),
	["Roof Top / Bank Tools 🛠"] = CFrame.new(-385, 340, -557),
	["Second Gun Shop 🔫"] = CFrame.new(66202, 123615.7109375, 5749.81689453125),
	["Construction Job 🔨"] = CFrame.new(-1729, 371, -1171)
}

local UserInputService = game:GetService("UserInputService")
 
local Camera = workspace.CurrentCamera

if UIS.TouchEnabled then
    pcall(function()
        Starlight:SetScale(1.15)
    end)

    pcall(function()
        Window:MakeDraggable(true)
    end)
end

getgenv().Teleport = function(CFrame, Name)
    if not LocalPlayer.Character then return end
    local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
    local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not hrp then return end

    humanoid:ChangeState(0)
    repeat task.wait() until not LocalPlayer:GetAttribute("LastACPos")
    hrp.CFrame = CFrame
    task.wait()
    humanoid:ChangeState(2)

    Starlight:Notification({
        Title = "Notification",
        Icon = NebulaIcons:GetIcon("sparkle", "Material"),
        Content = "Successfully teleported to " .. (Name or "location") .. "!",
    })

    return true
end

local function kill_gun(target, hpart, damage)
    if not hpart then
        hpart = "head"
    end

    if not damage then
        damage = math.huge
    end

    local data = {
        ["tool"] = Players.LocalPlayer.Character:FindFirstChildOfClass("Tool"),
        ["target"] = Players[target],
        ["hitpos"] = Players[target].Character[hpart].Position,
    }

    if not rawget(data, "tool") then
        return
    end

    if RequireSupport then
        require(rawget(data, "tool").Setting).Range = 10000
    end

    ReplicatedStorage.VisualizeMuzzle:FireServer(table.unpack({
        rawget(data, "tool").Handle,
        true,
        {
            false,
            7,
            Color3.new(1, 1.1098039150238, 0),
            15,
            true,
            0.02
        },
        rawget(data, "tool").GunScript_Local.MuzzleEffect
    }))

    ReplicatedStorage.VisualizeBullet:FireServer(table.unpack({
        rawget(data, "tool"),
        rawget(data, "tool").Handle,
        Vector3.new(-0.17746905982494, 0.088731124997139, 0.98011803627014),
        rawget(data, "tool").Handle.GunFirePoint,
        {
            true,
            {
                112139677907600,
                92977228204408,
                112139677907600,
                92977228204408
            },
            1,
            1,
            10,
            rawget(data, "tool").GunScript_Local.HitEffect,
            true
        },
        {
            true,
            {
                0,
                0,
                0,
                0,
                0,
                0
            },
            1,
            1,
            1,
            rawget(data, "tool").GunScript_Local.BloodEffect
        },
        {
            true,
            0.2,
            {
                3696144972
            },
            true,
            7,
            1
        },
        {
            false,
            8,
            true,
            {
                163064102
            },
            1,
            1.5,
            1,
            false,
            rawget(data, "tool").GunScript_Local.ExplosionEffect
        },
        {
            false,
            Vector3.new(0.10000000149012, 0, 0),
            Vector3.new(-0.10000000149012, 0, 0),
            rawget(data, "tool").GunScript_Local.TracerEffect,
            nil,
            rawget(data, "tool").GunScript_Local.ParticleEffect,
            300,
            526,
            0,
            Vector3.zero,
            Vector3.new(0.40000000596046, 0.40000000596046, 0.40000000596046),
            Color3.new(0.63921570777893, 0.63529413938522, 0.61176472902298),
            1,
            Enum.Material.Neon,
            Enum.PartType.Cylinder,
            false,
            6696543809,
            0,
            Vector3.new(0.0070000002160668, 0.0070000002160668, 0.0070000002160668)
        },
        {
            true,
            {
                269514869,
                269514887,
                269514807,
                269514817
            },
            0.5,
            1,
            1.5,
            100
        },
        {
            false,
            3,
            Color3.new(1, 0.64705884456635, 0.60000002384186),
            6,
            true
        }
    }))

    ReplicatedStorage.InflictTarget:FireServer(table.unpack({
        rawget(data, "tool"),
        LocalPlayer,
        rawget(data, "target").Character.Humanoid,
        rawget(data, "target").Character[hpart],
        damage,
        {
            0,
            0,
            false,
            false,
            rawget(data, "tool").GunScript_Server.IgniteScript,
            rawget(data, "tool").GunScript_Server.IcifyScript,
            100,
            100
        },
        {
            false,
            5,
            3
        },
        rawget(data, "target").Character[hpart],
        {
            false,
            {
                1930359546
            },
            1,
            1.5,
            1
        },
        rawget(data, "hitpos"),
        Vector3.new(0.074456036090851, -0.099775791168213, -0.99222022294998),
        true
    }))
end

getgenv().kill_gun = kill_gun

local GameSection = Window:CreateTabSection("Game")
local CombatSection = Window:CreateTabSection("Combat")
local ModSection = Window:CreateTabSection("Modifications")
local VisualsSection = Window:CreateTabSection("Visuals")
local ConfigSection = Window:CreateTabSection("Config")

local LocalPlayerTab = GameSection:CreateTab({
    Name = "Local Player",
    Icon = NebulaIcons:GetIcon("person", "Material"),
    Columns = 2,
}, "LOCAL_PLAYER")

local LocalPlayerMods = LocalPlayerTab:CreateGroupbox({
    Name = "Local Player Modifications",
    Column = 1,
}, "LOCAL_PLAYER_MODS")

LocalPlayerMods:CreateToggle({
    Name = "Infinite Sleep",
    CurrentValue = false,
    Style = 1,
    Callback = function(Value)
        if _G.InfSleepConn then _G.InfSleepConn:Disconnect() _G.InfSleepConn = nil end
        local pg = game.Players.LocalPlayer:FindFirstChild("PlayerGui")
        if not pg then return end
        local gui = pg:FindFirstChild("SleepGui")
        if not gui then return end
        local s = gui:FindFirstChild("sleepScript", true)
        if not s then return end

        if Value then
            _G.InfSleepConn = game:GetService("RunService").RenderStepped:Connect(function()
                s.Disabled = true
            end)
        else
            s.Disabled = false
        end
    end,
}, "INF_SLEEP")

LocalPlayerMods:CreateToggle({
    Name = "Infinite Hunger",
    CurrentValue = false,
    Style = 1,
    Callback = function(Value)
        if _G.InfHungerConn then _G.InfHungerConn:Disconnect() _G.InfHungerConn = nil end
        local pg = game.Players.LocalPlayer:FindFirstChild("PlayerGui")
        if not pg then return end
        local gui = pg:FindFirstChild("Hunger")
        if not gui then return end
        local s = gui:FindFirstChild("HungerBarScript", true)
        if not s then return end

        if Value then
            _G.InfHungerConn = game:GetService("RunService").RenderStepped:Connect(function()
                s.Disabled = true
            end)
        else
            s.Disabled = false
        end
    end,
}, "INF_HUNGER")

LocalPlayerMods:CreateToggle({
    Name = "Infinite Stamina",
    CurrentValue = false,
    Style = 1,
    Callback = function(Value)
        if _G.InfStamConn then _G.InfStamConn:Disconnect() _G.InfStamConn = nil end
        local pg = game.Players.LocalPlayer:FindFirstChild("PlayerGui")
        if not pg then return end
        local gui = pg:FindFirstChild("Run")
        if not gui then return end
        local s = gui:FindFirstChild("StaminaBarScript", true)
        if not s then return end

        if Value then
            _G.InfStamConn = game:GetService("RunService").RenderStepped:Connect(function()
                s.Disabled = true
            end)
        else
            s.Disabled = false
        end
    end,
}, "INF_STAMINA")

local InstantEnabled = false

LocalPlayerMods:CreateToggle({
	Name = "Instant Interact",
	CurrentValue = false,
	Style = 1,
	Callback = function(v)
		InstantEnabled = v

		for _, p in ipairs(workspace:GetDescendants()) do
			if p:IsA("ProximityPrompt") then
				if p:GetAttribute("OLD_HOLD") == nil then
					p:SetAttribute("OLD_HOLD", p.HoldDuration)
				end
				p.HoldDuration = v and 0 or p:GetAttribute("OLD_HOLD")
			end
		end
	end
}, "INSTANT_INTERACT")

local function HandlePrompt(p)
	if not p:IsA("ProximityPrompt") then return end
	if p:GetAttribute("OLD_HOLD") == nil then
		p:SetAttribute("OLD_HOLD", p.HoldDuration)
	end
	if InstantEnabled then
		p.HoldDuration = 0
	end
end

for _, p in ipairs(workspace:GetDescendants()) do
	HandlePrompt(p)
end

workspace.DescendantAdded:Connect(HandlePrompt)

local InstantReviveEnabled = false

LocalPlayerMods:CreateToggle({
	Name = "Instant Revive",
	CurrentValue = false,
	Style = 1,
	Callback = function(state)
		InstantReviveEnabled = state

		if not state and LocalPlayer.Character then
			local dc = LocalPlayer.Character:FindFirstChild("deathClient", true)
			if dc and dc:IsA("LocalScript") then
				dc.Disabled = false
			end
		end
	end
}, "INSTANT_REVIVE")

task.spawn(function()
	while task.wait(0.3) do
		if not InstantReviveEnabled then
			continue
		end

		local char = LocalPlayer.Character
		if not char then continue end

		local dc = char:FindFirstChild("deathClient", true)
		if dc and dc:IsA("LocalScript") then
			dc.Disabled = true
		end

		local gui = LocalPlayer.PlayerGui:FindFirstChild("deathScreen")
		if gui then
			gui:Destroy()
		end

		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum and hum.Health <= 0 then
			ReplicatedStorage:WaitForChild("LoadCharacter"):FireServer()
		end
	end
end)

LocalPlayerMods:CreateToggle({ Name = "Anti Lose Items", CurrentValue = false, Style = 1, Callback = function() end }, "ANTI_LOSE_ITEMS")

local NoCameraBob = false

LocalPlayerMods:CreateToggle({
	Name = "Disable Camera Bobbing",
	CurrentValue = false,
	Style = 1,
	Callback = function(state)
		NoCameraBob = state
	end
}, "NO_CAMERA_BOB")

RunService.RenderStepped:Connect(function()
	local char = LocalPlayer.Character
	if not char then return end

	local s = char:FindFirstChild("CameraBobbing")
	if s then
		s.Disabled = NoCameraBob
	end
end)

local NoBlood = false

LocalPlayerMods:CreateToggle({
	Name = "Disable Blood Effects",
	CurrentValue = false,
	Style = 1,
	Callback = function(state)
		NoBlood = state
	end
}, "NO_BLOOD")

RunService.RenderStepped:Connect(function()
	local pg = LocalPlayer:FindFirstChild("PlayerGui")
	if not pg then return end

	local gui = pg:FindFirstChild("BloodGui")
	if gui then
		gui.Enabled = not NoBlood
	end
end)

local BypassLockedCars = false

LocalPlayerMods:CreateToggle({
	Name = "Bypass Locked Cars",
	CurrentValue = false,
	Style = 1,
	Callback = function(v)
		BypassLockedCars = v
	end
}, "BYPASS_CARS")

ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt, player)
	if player ~= LocalPlayer then return end
	if not BypassLockedCars then return end

	local obj = prompt
	local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	if not hum then return end

	while obj and obj.Parent do
		if obj:IsA("VehicleSeat") then
			obj:Sit(hum)
			break
		end

		local seat = obj.Parent:FindFirstChildOfClass("VehicleSeat")
		if seat then
			seat:Sit(hum)
			break
		end

		obj = obj.Parent
	end
end)

local NoRentPay = false
local NoFallDamage = false
local NoKnockback = false
local RespawnSame = false

LocalPlayerMods:CreateToggle({
	Name = "No Rent Pay",
	CurrentValue = false,
	Style = 1,
	Callback = function(v)
		NoRentPay = v
	end
}, "NO_RENT")

LocalPlayerMods:CreateToggle({
	Name = "No Fall Damage",
	CurrentValue = false,
	Style = 1,
	Callback = function(v)
		NoFallDamage = v
	end
}, "NO_FALL")

LocalPlayerMods:CreateToggle({
	Name = "No Knockback",
	CurrentValue = false,
	Style = 1,
	Callback = function(v)
		NoKnockback = v
	end
}, "NO_KNOCKBACK")

LocalPlayerMods:CreateToggle({
	Name = "Respawn Where You Died",
	CurrentValue = false,
	Style = 1,
	Callback = function(v)
		RespawnSame = v
	end
}, "RESPAWN_SAME")

RunService.RenderStepped:Connect(function()
	local pg = LocalPlayer:FindFirstChild("PlayerGui")
	if pg then
		local gui = pg:FindFirstChild("RentGui")
		if gui and gui:FindFirstChild("LocalScript") then
			gui.LocalScript.Disabled = NoRentPay
		end
	end

	local char = LocalPlayer.Character
	if char then
		local s = char:FindFirstChild("FallDamageRagdoll")
		if s then
			s.Disabled = NoFallDamage
		end
	end
end)

local function ApplyNoKnockback(char)
	char.DescendantAdded:Connect(function(d)
		if not NoKnockback then return end
		if d:IsA("BodyVelocity") or d:IsA("LinearVelocity") or d:IsA("VectorForce") then
			task.defer(function()
				if d and d.Parent then
					d:Destroy()
				end
			end)
		end
	end)
end

if LocalPlayer.Character then
	ApplyNoKnockback(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(ApplyNoKnockback)

local DeathFrame

local function HookCharacter(char)
	local hum = char:WaitForChild("Humanoid")
	local hrp = char:WaitForChild("HumanoidRootPart")

	hum.Died:Connect(function()
		DeathFrame = hrp.CFrame
	end)

	if RespawnSame and typeof(DeathFrame) == "CFrame" then
		task.defer(function()
			hrp.CFrame = DeathFrame
		end)
	end
end

if LocalPlayer.Character then
	HookCharacter(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(HookCharacter)

local CharacterMods = LocalPlayerTab:CreateGroupbox({
    Name = "Character Modifications",
    Column = 2,
}, "CHARACTER_MODS")

local player = Players.LocalPlayer
local cam = workspace.CurrentCamera

local flying = false
local flySpeed = 140
local accel = 7

local proxySeat
local lv
local ao
local att
local vel = Vector3.zero

local function stopFly()
    if not flying then return end
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    local root = player.Character.HumanoidRootPart
    local ray = workspace:Raycast(root.Position, Vector3.new(0,-500,0))
    local groundPos = ray and ray.Position + Vector3.new(0,5,0) or root.Position
    Teleport(CFrame.new(groundPos))
    if lv then lv:Destroy() end
    if ao then ao:Destroy() end
    if att then att:Destroy() end
    if proxySeat then proxySeat:Destroy() end
    for _, c in pairs(root:GetChildren()) do
        if c:IsA("WeldConstraint") then c:Destroy() end
    end
    vel = Vector3.zero
    flying = false
end

local function startFly()
    if flying then return end
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    local root = player.Character.HumanoidRootPart
    Teleport(root.CFrame + Vector3.new(0,5,0))
    proxySeat = Instance.new("Seat")
    proxySeat.Size = Vector3.new(2,1,2)
    proxySeat.CFrame = root.CFrame
    proxySeat.Anchored = false
    proxySeat.CanCollide = false
    proxySeat.Transparency = 1
    proxySeat.Parent = workspace
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = root
    weld.Part1 = proxySeat
    weld.Parent = root
    att = Instance.new("Attachment")
    att.Parent = proxySeat
    lv = Instance.new("LinearVelocity")
    lv.Attachment0 = att
    lv.MaxForce = math.huge
    lv.RelativeTo = Enum.ActuatorRelativeTo.World
    lv.Parent = proxySeat
    ao = Instance.new("AlignOrientation")
    ao.Attachment0 = att
    ao.MaxTorque = math.huge
    ao.Responsiveness = 40
    ao.Parent = proxySeat
    vel = Vector3.zero
    flying = true
end

CharacterMods:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Style = 1,
    Callback = function(Value)
        if Value then
            startFly()
        else
            stopFly()
        end
    end,
}, "FLY_TOGGLE")

RunService.RenderStepped:Connect(function(dt)
    if not flying or not proxySeat then return end
    local dir = Vector3.zero
    if UIS:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.yAxis end
    if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.yAxis end
    if dir.Magnitude > 0 then
        dir = dir.Unit * flySpeed
    end
    vel = vel:Lerp(dir, math.clamp(accel * dt, 0, 1))
    lv.VectorVelocity = vel
    local look = cam.CFrame.LookVector
    look = Vector3.new(look.X, 0, look.Z)
    if look.Magnitude < 0.01 then look = Vector3.zAxis end
    look = look.Unit
    ao.CFrame = CFrame.lookAt(proxySeat.Position, proxySeat.Position + look, Vector3.yAxis)
end)

local CurrentSpectatePlayer

local function startSpectate(plr)
	if not plr.Character then return end
	local hum = plr.Character:FindFirstChildOfClass("Humanoid")
	if hum then
		CurrentSpectatePlayer = plr
		Camera.CameraSubject = hum
	end
end

local function stopSpectate()
	CurrentSpectatePlayer = nil
	if LocalPlayer.Character then
		local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			Camera.CameraSubject = hum
		end
	end
end

local DEFAULT_JUMP_HEIGHT = 7.2
local jumpValue = DEFAULT_JUMP_HEIGHT
local jumpEnabled = false

local function ApplyJumpPower()
	local char = LocalPlayer.Character
	if not char then return end

	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return end

	hum.UseJumpPower = false

	if jumpEnabled then
		hum.JumpHeight = jumpValue
	else
		hum.JumpHeight = DEFAULT_JUMP_HEIGHT
	end
end

CharacterMods:CreateToggle({
	Name = "Modify WalkSpeed",
	CurrentValue = false,
	Style = 1,
	Callback = function() end
}, "MOD_WS")

CharacterMods:CreateToggle({
	Name = "Modify JumpPower",
	CurrentValue = false,
	Style = 1,
	Callback = function(Value)
		jumpEnabled = Value
		ApplyJumpPower()
	end
}, "MOD_JP")

CharacterMods:CreateToggle({
	Name = "Click Teleport",
	CurrentValue = false,
	Style = 1,
	Callback = function() end
}, "CLICK_TP")

CharacterMods:CreateToggle({
	Name = "No Clip",
	CurrentValue = false,
	Style = 1,
	Callback = function() end
}, "NOCLIP")

local Divider = CharacterMods:CreateDivider()

CharacterMods:CreateSlider({
	Name = "FlySpeed Value",
	Range = {0, 250},
	Increment = 1,
	CurrentValue = 100,
	Callback = function(Value)
		flySpeed = Value
	end,
}, "FLY_SPEED")


CharacterMods:CreateSlider({
	Name = "WalkSpeed Value",
	Range = {0, 250},
	Increment = 1,
	Callback = function() end,
}, "WS_VALUE")

CharacterMods:CreateSlider({
	Name = "JumpPower Value",
	Range = {0, 250},
	Increment = 1,
	Callback = function(Value)
		jumpValue = Value
		ApplyJumpPower()
	end,
}, "JP_VALUE")

LocalPlayer.CharacterAdded:Connect(function()
	task.wait(0.3)
	ApplyJumpPower()
end)

local ClickTPLabel = CharacterMods:CreateLabel({
    Name = "Click Teleport Key",
}, "CLICKTP_LABEL")

ClickTPLabel:AddBind({
    HoldToInteract = false,
    CurrentValue = "LeftControl",
    Callback = function() end,
}, "CLICKTP_BIND")

local LastEnabledUI = nil
local SelectedUI = nil
local UIEnabled = false

local function GetGameUIs()
	local Names = {}
	local Seen = {}
	local Blacklist = {
		["Dead"]=true,["Settings1"]=true,["Controls"]=true,["FirstShopGUI"]=true,
		["Freecam"]=true,["ThaShop2"]=true,["WATCH GUI"]=true,["NYPD Cars"]=true,
		["CONSTRUCTION LEVEL"]=true,["RobPlayerUI"]=true,["Bronx LOCKER"]=true,
		["MobileBeam"]=true,["Settings"]=true,["Flash"]=true,["Enter"]=true,
		["CopSirens"]=true,["BailLists"]=true,["Animations"]=true,["BACKPACK UI"]=true,
		["BRONX FRONTEND"]=true,["BagGui"]=true,["BasketMobile"]=true,["Block Party"]=true,
		["BloodGui"]=true,["Bronx MessageList"]=true,["Bronx Radio"]=true,["Bronx SUBSCRIPTIONS"]=true,
		["COUNTDOWN UI"]=true,["CameraTexts"]=true,["CarMobileRev"]=true,["ClansGui"]=true,
		["ClothingStore_1"]=true,["CopRadioChat"]=true,["CraftGUI"]=true,["CraftSystem"]=true,
		["FOLLOWER REWARDS"]=true,["Garage GUI"]=true,["Garage GUI [OLD]"]=true,["Hitmarkers"]=true,
		["Inventory"]=true,["LocalGunUI"]=true,["Idle Animations"]=true,["LowHealthT"]=true,
		["MAIN UI"]=true,["MobileDriveBy"]=true,["MobileHonk"]=true,["MobileNYPD"]=true,
		["Optmizer"]=true,["Phone"]=true,["RentGui"]=true,["SHIFTLOCK MOBILE"]=true,
		["TANKTOP PICKER"]=true,["TEST LOCKPICK"]=true,["TextsForGas"]=true,["Unboxing"]=true,
		["VestG"]=true,["Hunger"]=true,["HealthGui"]=true,["Character Detect"]=true,
		["CrouchSystem"]=true,["MoneyGui"]=true,["NewMoneyGui"]=true,["SleepGui"]=true,["Run"]=true
	}

	for _, gui in ipairs(StarterGui:GetChildren()) do
		if gui:IsA("ScreenGui") and not Blacklist[gui.Name] and not Seen[gui.Name] then
			table.insert(Names, gui.Name)
			Seen[gui.Name] = true
		end
	end

	table.sort(Names)
	return Names
end

local InterfaceSection = LocalPlayerTab:CreateGroupbox({
	Name = "Toggle Interface Section",
	Column = 2,
}, "INTERFACE_SECTION")

local UILabel = InterfaceSection:CreateLabel({
	Name = "Selected UI",
}, "UI_LABEL")

UILabel:AddDropdown({
	Options = GetGameUIs(),
	CurrentOptions = {},
	Placeholder = "Select UI",
	Callback = function(Value)
		if UIEnabled and LastEnabledUI then
			local old = LocalPlayer.PlayerGui:FindFirstChild(LastEnabledUI)
			if old then old.Enabled = false end
			LastEnabledUI = nil
			UIEnabled = false
		end

		SelectedUI = Value[1]
	end,
}, "UI_DROPDOWN")

InterfaceSection:CreateToggle({
	Name = "UI Enabled",
	CurrentValue = false,
	Style = 1,
	Callback = function(state)
		UIEnabled = state
		if not SelectedUI then return end

		local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

		if state then
			if LastEnabledUI and LastEnabledUI ~= SelectedUI then
				local old = PlayerGui:FindFirstChild(LastEnabledUI)
				if old then old.Enabled = false end
			end

			local UI = PlayerGui:FindFirstChild(SelectedUI)
			if not UI then
				local Source = StarterGui:FindFirstChild(SelectedUI)
				if Source then
					UI = Source:Clone()
					UI.Parent = PlayerGui
				end
			end

			if UI then
				UI.Enabled = true
				LastEnabledUI = SelectedUI
			end
		else
			if LastEnabledUI then
				local old = PlayerGui:FindFirstChild(LastEnabledUI)
				if old then old.Enabled = false end
				LastEnabledUI = nil
			end
		end
	end,
}, "UI_ENABLED")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local PlayersTab = GameSection:CreateTab({
	Name = "Players",
	Icon = NebulaIcons:GetIcon("group", "Material"),
	Columns = 2,
}, "PLAYERS")

local SelectPlayerGroupbox = PlayersTab:CreateGroupbox({
	Name = "Select Player",
	Column = 1,
}, "SELECT_PLAYER")

local PlayerLabel = SelectPlayerGroupbox:CreateLabel({
	Name = "Players",
}, "PLAYER_LABEL")

local PlayerOptionsGroupbox = PlayersTab:CreateGroupbox({
	Name = "Player Options",
	Column = 2,
}, "PLAYER_OPTIONS")

local PlayerDropdown
local SelectedPlayerName = nil
local SpectateEnabled = false
local CurrentSpectatePlayer = nil

local function getPlayerNames()
	local t = {}
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer then
			table.insert(t, p.Name)
		end
	end
	table.sort(t)
	return t
end

local function startSpectate(plr)
	if not plr or not plr.Character then return end
	local hum = plr.Character:FindFirstChildOfClass("Humanoid")
	if hum then
		CurrentSpectatePlayer = plr
		Camera.CameraSubject = hum
	end
end

local function stopSpectate()
	CurrentSpectatePlayer = nil
	if LocalPlayer.Character then
		local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			Camera.CameraSubject = hum
		end
	end
end

local function rebuildDropdown()
	if PlayerDropdown then
		pcall(function()
			PlayerDropdown:Destroy()
		end)
	end

	PlayerDropdown = PlayerLabel:AddDropdown({
		Options = getPlayerNames(),
		CurrentOptions = SelectedPlayerName and { SelectedPlayerName } or {},
		Placeholder = "--",
		Callback = function(value)
			SelectedPlayerName = value and value[1] or nil
			if not SpectateEnabled then return end

			if not SelectedPlayerName then
				stopSpectate()
				return
			end

			local plr = Players:FindFirstChild(SelectedPlayerName)
			if plr then
				startSpectate(plr)
			else
				stopSpectate()
			end
		end,
	}, "PLAYER_DROPDOWN")
end

rebuildDropdown()

Players.PlayerAdded:Connect(function()
	rebuildDropdown()
end)

Players.PlayerRemoving:Connect(function(p)
	if p.Name == SelectedPlayerName then
		SelectedPlayerName = nil
		stopSpectate()
	end
	rebuildDropdown()
end)

PlayerOptionsGroupbox:CreateToggle({
	Name = "Spectate Player",
	CurrentValue = false,
	Style = 1,
	Callback = function(state)
		SpectateEnabled = state

		if not state then
			stopSpectate()
			return
		end

		if not SelectedPlayerName then
			stopSpectate()
			return
		end

		local plr = Players:FindFirstChild(SelectedPlayerName)
		if plr then
			startSpectate(plr)
		else
			stopSpectate()
		end
	end,
}, "SPECTATE")

LocalPlayer.CharacterAdded:Connect(function()
	task.wait(0.2)
	if SpectateEnabled and SelectedPlayerName then
		local plr = Players:FindFirstChild(SelectedPlayerName)
		if plr then
			startSpectate(plr)
		end
	end
end)

local BringPlayer = false

PlayerOptionsGroupbox:CreateToggle({
	Name = "Bring Player",
	CurrentValue = false,
	Style = 1,
	Callback = function(v)
		BringPlayer = v
	end
}, "BRING")

task.spawn(function()
	while task.wait() do
		if not BringPlayer then continue end
		if not SelectedPlayerName then continue end

		local target = Players:FindFirstChild(SelectedPlayerName)
		if not target or not target.Character then continue end

		local thrp = target.Character:FindFirstChild("HumanoidRootPart")
		local lhrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if not thrp or not lhrp then continue end

		thrp.CFrame = lhrp.CFrame * CFrame.new(2, 0, 0)
	end
end)

local BugKillCar = false

PlayerOptionsGroupbox:CreateToggle({
	Name = "Bug / Kill Player - Car",
	CurrentValue = false,
	Style = 1,
	Callback = function(v)
		BugKillCar = v
	end
}, "BUG_KILL_CAR")

local function GetVehicle()
	for _, v in ipairs(workspace.CivCars:GetChildren()) do
		if v:FindFirstChild("DriveSeat") and not v.DriveSeat.Occupant then
			return v
		end
	end
end

task.spawn(function()
	while task.wait() do
		if not BugKillCar then continue end
		if not SelectedPlayerName then continue end

		local target = Players:FindFirstChild(SelectedPlayerName)
		if not target or not target.Character then continue end

		local hrp = target.Character:FindFirstChild("HumanoidRootPart")
		if not hrp then continue end

		local car = GetVehicle()
		if not car then continue end

		if not car.PrimaryPart then
			car.PrimaryPart = car.Body:FindFirstChild("#Weight")
		end

		car:SetPrimaryPartCFrame(hrp.CFrame)
	end
end)

local AutoKillGun = false

PlayerOptionsGroupbox:CreateToggle({
	Name = "Auto Kill Player - Gun",
	CurrentValue = false,
	Style = 1,
	Callback = function(v)
		AutoKillGun = v
	end
}, "AUTO_KILL_GUN")

task.spawn(function()
	while task.wait(1) do
		if not AutoKillGun then continue end
		if not SelectedPlayerName then continue end

		local char = LocalPlayer.Character
		if not char then continue end

		local tool = char:FindFirstChildOfClass("Tool")
		if not tool or not tool:FindFirstChild("GunScript_Local") then continue end

		local target = Players:FindFirstChild(SelectedPlayerName)
		if not target or not target.Character then continue end

		local hum = target.Character:FindFirstChildOfClass("Humanoid")
		if not hum or hum.Health <= 0 then continue end
		if target.Character:FindFirstChildOfClass("ForceField") then continue end

		kill_gun(target.Name, "Head", math.huge)
	end
end)

local AutoRagdollGun = false

PlayerOptionsGroupbox:CreateToggle({
	Name = "Auto Ragdoll Player - Gun",
	CurrentValue = false,
	Style = 1,
	Callback = function(v)
		AutoRagdollGun = v
	end
}, "AUTO_RAGDOLL")

task.spawn(function()
	while task.wait(2) do
		if not AutoRagdollGun then continue end
		if not SelectedPlayerName then continue end

		local char = LocalPlayer.Character
		if not char then continue end

		local tool = char:FindFirstChildOfClass("Tool")
		if not tool or not tool:FindFirstChild("GunScript_Local") then continue end

		local target = Players:FindFirstChild(SelectedPlayerName)
		if not target or not target.Character then continue end

		local hum = target.Character:FindFirstChildOfClass("Humanoid")
		if not hum or hum.Health <= 0 then continue end
		if hum:GetState() == Enum.HumanoidStateType.Physics then continue end

		kill_gun(target.Name, "RightUpperLeg", 0.01)
	end
end)

PlayerOptionsGroupbox:CreateButton({
	Name = "Teleport To Player",
	Callback = function()
		if not SelectedPlayerName then return end

		local target = Players:FindFirstChild(SelectedPlayerName)
		if not target or not target.Character then return end

		getgenv().Teleport(target.Character.HumanoidRootPart.CFrame, SelectedPlayerName)
	end
}, "TP_PLAYER")

PlayerOptionsGroupbox:CreateButton({
	Name = "Down Player - Hold Gun",
	Callback = function()
		local char = LocalPlayer.Character
		if not char then return end

		local tool = char:FindFirstChildOfClass("Tool")
		if not tool then return end
		if not SelectedPlayerName then return end

		local target = Players:FindFirstChild(SelectedPlayerName)
		if not target or not target.Character then return end

		local hum = target.Character:FindFirstChildOfClass("Humanoid")
		if not hum or hum.Health <= 0 then return end

		pcall(kill_gun, SelectedPlayerName, "HumanoidRootPart", hum.Health - 5)
	end
}, "DOWN_PLAYER")

PlayerOptionsGroupbox:CreateButton({
	Name = "Kill Player - Hold Gun",
	Callback = function()
		local char = LocalPlayer.Character
		if not char or not char:FindFirstChildOfClass("Tool") then return end
		if not SelectedPlayerName then return end

		pcall(kill_gun, SelectedPlayerName, "HumanoidRootPart", math.huge)
	end
}, "KILL_PLAYER")

PlayerOptionsGroupbox:CreateButton({
	Name = "God Player - Hold Gun",
	Callback = function()
		local char = LocalPlayer.Character
		if not char or not char:FindFirstChildOfClass("Tool") then return end
		if not SelectedPlayerName then return end

		pcall(kill_gun, SelectedPlayerName, "HumanoidRootPart", math.sqrt(-1))
	end
}, "GOD_PLAYER")

PlayerOptionsGroupbox:CreateButton({
	Name = "Fling Player - Hold Gun",
	Callback = function()
		local char = LocalPlayer.Character
		if not char or not char:FindFirstChildOfClass("Tool") then return end
		if not SelectedPlayerName then return end

		for i = 1, 50 do
			pcall(kill_gun, SelectedPlayerName, "RightUpperLeg", 0.01)
			task.wait()
		end
	end
}, "FLING_PLAYER")

PlayerOptionsGroupbox:CreateButton({
	Name = "Explode All Cars x2 - Hold Gun",
	Callback = function()
		for _, car in ipairs(workspace.CivCars:GetChildren()) do
			if car.PrimaryPart then
				for i = 1, 2 do
					car:SetPrimaryPartCFrame(car.PrimaryPart.CFrame * CFrame.new(0, 5, 0))
					task.wait()
				end
			end
		end
	end
}, "EXPLODE_CARS")

PlayerOptionsGroupbox:CreateButton({
	Name = "Kill All Players - Hold Gun",
	Callback = function()
		local char = LocalPlayer.Character
		if not char or not char:FindFirstChildOfClass("Tool") then return end

		task.spawn(function()
			for _, plr in ipairs(Players:GetPlayers()) do
				if plr ~= LocalPlayer
					and plr.Character
					and plr.Character:FindFirstChild("HumanoidRootPart")
					and plr.Character:FindFirstChildOfClass("Humanoid")
					and plr.Character.Humanoid.Health > 0
					and not plr.Character:FindFirstChildOfClass("ForceField") then

					pcall(kill_gun, plr.Name, "HumanoidRootPart", math.huge)
					task.wait(0.1)
				end
			end
		end)
	end
}, "KILL_ALL")

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

local LocalPlayer = Players.LocalPlayer
local SelectedItem = nil

local TeleportsTab = GameSection:CreateTab({
	Name = "Teleports / Purchases",
	Icon = NebulaIcons:GetIcon("place", "Material"),
	Columns = 2,
}, "TELEPORTS")

local PurchaseGroupbox = TeleportsTab:CreateGroupbox({
	Name = "Purchase Selected Item",
	Column = 1,
}, "PURCHASE_ITEM")

local ItemLabel = PurchaseGroupbox:CreateLabel({
	Name = "Item",
}, "ITEM_LABEL")

local ItemDropdown = ItemLabel:AddDropdown({
	Options = (function()
		local seen = {}
		local t = {}
		for _, v in ipairs(Config.Guns) do
			if not seen[v] then
				seen[v] = true
				table.insert(t, v)
			end
		end
		table.sort(t, function(a, b)
			return tostring(a):lower() < tostring(b):lower()
		end)
		return t
	end)(),
	CurrentOptions = {},
	Placeholder = "--",
Callback = function(state)
    SelectedItem = state and state[1]
end
}, "ITEM_DROPDOWN")

PurchaseGroupbox:CreateButton({
	Name = "Purchase Selected Item",
	Callback = function()
		if not SelectedItem then
			Starlight:Notification({
				Title = "Purchase Failed",
				Icon = NebulaIcons:GetIcon("error", "Material"),
				Content = "No item selected.",
			}, "NO_ITEM")
			return
		end

		local char = LocalPlayer.Character
		if not char then return end
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not hrp then return end

		local guns = workspace:FindFirstChild("GUNS")
		if not guns then return end

		local item = guns:FindFirstChild(SelectedItem)
		if not item then
			Starlight:Notification({
				Title = "Purchase Failed",
				Icon = NebulaIcons:GetIcon("error", "Material"),
				Content = "Selected item not found.",
			}, "ITEM_NOT_FOUND")
			return
		end

		local prompt = item:FindFirstChildWhichIsA("ProximityPrompt", true)
		if not prompt then
			Starlight:Notification({
				Title = "Purchase Failed",
				Icon = NebulaIcons:GetIcon("error", "Material"),
				Content = "Purchase prompt not found.",
			}, "NO_PROMPT")
			return
		end

		local gamepass = item:FindFirstChild("GamepassID", true)
		if gamepass then
			local owns = false
			pcall(function()
				owns = MarketplaceService:UserOwnsGamePassAsync(LocalPlayer.UserId, gamepass.Value)
			end)
			if not owns then
				Starlight:Notification({
					Title = "Purchase Failed",
					Icon = NebulaIcons:GetIcon("lock", "Material"),
					Content = "You do not own this gamepass.",
				}, "NO_GAMEPASS")
				return
			end
		end

		local price = item:FindFirstChild("Price", true)
		local money = LocalPlayer:FindFirstChild("stored") and LocalPlayer.stored:FindFirstChild("Money")
		if price and money and money.Value < price.Value then
			Starlight:Notification({
				Title = "Purchase Failed",
				Icon = NebulaIcons:GetIcon("attach_money", "Material"),
				Content = "You are $" .. (price.Value - money.Value) .. " short.",
			}, "NOT_ENOUGH_MONEY")
			return
		end

local oldPos = hrp.CFrame
hrp.CFrame = prompt.Parent.CFrame
task.wait(0.3)
fireproximityprompt(prompt)
task.wait(0.4)
hrp.CFrame = oldPos

		Starlight:Notification({
			Title = "Success",
			Icon = NebulaIcons:GetIcon("check_circle", "Material"),
			Content = "Item purchased successfully.",
		}, "PURCHASE_SUCCESS")
	end,
}, "PURCHASE_BUTTON")

local TeleportGroupbox = TeleportsTab:CreateGroupbox({
	Name = "Teleport To Location",
	Column = 2,
}, "TELEPORT_LOCATION")

local LocationLabel = TeleportGroupbox:CreateLabel({
	Name = "Locations",
}, "LOCATION_LABEL")

local LocationNames = {}
for name in pairs(TeleportLocations) do
	table.insert(LocationNames, name)
end
table.sort(LocationNames)

LocationLabel:AddDropdown({
	Options = LocationNames,
	CurrentOptions = {},
	Placeholder = "--",
Callback = function(state)
    local name = state and state[1]
    if not name then return end
    getgenv().Teleport(TeleportLocations[name], name)
end
}, "LOCATION_DROPDOWN")

-- Create the Misc tab and save it in a variable
local MiscTab = GameSection:CreateTab({
    Name = "Misc",
    Icon = NebulaIcons:GetIcon("settings", "Material"),
    Columns = 2,
}, "MISC")

local FarmingSection = MiscTab:CreateGroupbox({
    Name = "Farming",
    Column = 1,
}, "FARMING_SECTION")

local AutoFarmSodaPop = false

FarmingSection:CreateToggle({
	Name = "Auto Farm Soda Pop",
	CurrentValue = false,
	Style = 2,
	Callback = function(v)
		AutoFarmSodaPop = v
	end
}, "AUTO_FARM_SODA_POP")

local function TeleportNoNotify(cf)
	local oldNotify = Starlight.Notification
	Starlight.Notification = function() end
	getgenv().Teleport(cf)
	Starlight.Notification = oldNotify
end

local BoughtOnce = false
local MachinesUsed = {}
local Watching = {}
local FiredThisCycle = {}
local FiredCollect = {}
local SoldThisCycle = false

local FinishedItems = { "GreenApplePop", "PurpleGrapePop", "BlueBlueBaryPop" }

local function BuyItems()
	for i = 1, 4 do
		ReplicatedStorage.ShopRemote6:InvokeServer("SugarBag")
		task.wait(0.2)
		ReplicatedStorage.ShopRemote6:InvokeServer("FijiWater")
		task.wait(0.2)
	end
	BoughtOnce = true
end

local function HasItems(char)
	return LocalPlayer.Backpack:FindFirstChild("SugarBag")
		or LocalPlayer.Backpack:FindFirstChild("FijiWater")
		or char:FindFirstChild("SugarBag")
		or char:FindFirstChild("FijiWater")
end

local function CountFinished()
	local c = 0
	for _, t in ipairs(LocalPlayer.Backpack:GetChildren()) do
		for _, n in ipairs(FinishedItems) do
			if t.Name == n then
				c += 1
			end
		end
	end
	return c
end

local function GetMachines()
	local t = {}
	for _, m in ipairs(workspace.SodaMachine:GetChildren()) do
		local cook = m:FindFirstChild("CookPart")
		local prompt = cook and cook:FindFirstChildOfClass("ProximityPrompt")
		if cook and prompt then
			table.insert(t, cook)
		end
	end
	return t
end

local function GetClosestMachines(originCF, machines, count)
	table.sort(machines, function(a, b)
		return (a.Position - originCF.Position).Magnitude < (b.Position - originCF.Position).Magnitude
	end)
	local r = {}
	for i = 1, math.min(count, #machines) do
		table.insert(r, machines[i])
	end
	return r
end

local function FarmMachine(cook)
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not char or not hum or hum.Health == 0 then return end
	local prompt = cook:FindFirstChildOfClass("ProximityPrompt")
	if not prompt or not prompt.Enabled then return end
	TeleportNoNotify(cook.CFrame)
	task.wait(0.3)
	fireproximityprompt(prompt)
	if LocalPlayer.Backpack:FindFirstChild("SugarBag") then
		hum:EquipTool(LocalPlayer.Backpack.SugarBag)
		task.wait(0.15)
		fireproximityprompt(prompt)
	end
	if LocalPlayer.Backpack:FindFirstChild("FijiWater") then
		hum:EquipTool(LocalPlayer.Backpack.FijiWater)
		task.wait(0.15)
		fireproximityprompt(prompt)
	end
end

local function WatchPrompt(cook)
	if Watching[cook] then return end
	Watching[cook] = true
	FiredThisCycle[cook] = false
	task.spawn(function()
		local prompt = cook:FindFirstChildOfClass("ProximityPrompt")
		if not prompt then return end
		while AutoFarmSodaPop do
			if not prompt.Enabled then
				FiredThisCycle[cook] = false
			elseif prompt.Enabled and not FiredThisCycle[cook] then
				FiredThisCycle[cook] = true
				TeleportNoNotify(cook.CFrame)
				task.wait(0.3)
				fireproximityprompt(prompt)
			end
			task.wait(0.5)
		end
	end)
end

local function CollectFinishedProducts()
	for _, cook in ipairs(MachinesUsed) do
		local prompt = cook:FindFirstChildOfClass("ProximityPrompt")
		if prompt and prompt.Enabled and not FiredCollect[cook] then
			FiredCollect[cook] = true
			TeleportNoNotify(cook.CFrame)
			task.wait(0.3)
			fireproximityprompt(prompt)
			task.wait(0.3)
		end
	end
end

local function SellFinishedProducts()
	if SoldThisCycle then return end
	if CountFinished() < 4 then return end
	local folder = workspace:FindFirstChild("SodaMachine")
	if not folder then return end
	local seller = folder:FindFirstChild("SodaSeller")
	if not seller then return end
	local prompt = seller:FindFirstChildOfClass("ProximityPrompt")
	if not prompt or not prompt.Enabled then return end
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health == 0 then return end
	TeleportNoNotify(seller.CFrame)
	task.wait(0.3)
	for _, t in ipairs(LocalPlayer.Backpack:GetChildren()) do
		for _, n in ipairs(FinishedItems) do
			if t.Name == n then
				hum:EquipTool(t)
				task.wait(0.05)
				fireproximityprompt(prompt)
				task.wait(0.05)
			end
		end
	end
	SoldThisCycle = true
end

task.spawn(function()
	while task.wait() do
		if not AutoFarmSodaPop then
			BoughtOnce = false
			MachinesUsed = {}
			Watching = {}
			FiredThisCycle = {}
			FiredCollect = {}
			SoldThisCycle = false
			continue
		end

		local char = LocalPlayer.Character
		if not char or not char:FindFirstChild("HumanoidRootPart") then continue end

		if not BoughtOnce then BuyItems() end
		if not HasItems(char) then continue end

		if #MachinesUsed == 0 then
			local m = GetMachines()
			if #m == 0 then continue end
			MachinesUsed = GetClosestMachines(char.HumanoidRootPart.CFrame, m, 4)
			for _, c in ipairs(MachinesUsed) do
				WatchPrompt(c)
				FiredCollect[c] = false
			end
		end

		for _, c in ipairs(MachinesUsed) do
			FarmMachine(c)
			task.wait(0.3)
		end

		CollectFinishedProducts()
		SellFinishedProducts()
	end
end)

local AutoFarmConstruction = false

FarmingSection:CreateToggle({
	Name = "Auto Farm Construction",
	CurrentValue = false,
	Style = 2,
	Callback = function(v)
		AutoFarmConstruction = v
	end
}, "AUTO_FARM_CONSTRUCTION")

local function TeleportNoNotify(cf)
	local oldNotify = Starlight.Notification
	Starlight.Notification = function() end
	getgenv().Teleport(cf)
	Starlight.Notification = oldNotify
end

local function GetPlaceToPlaceWood()
	for _, Value in ipairs(Workspace.ConstructionStuff:GetChildren()) do
		if Value.Name:find("Wall") and Value:IsA("Part") and Value:FindFirstChild("Prompt") then
			if Value.Prompt.Enabled then
				return Value
			end
		end
	end
end

task.spawn(function()
	while task.wait() do
		if not AutoFarmConstruction then continue end

		local char = LocalPlayer.Character
		if not char or not char:FindFirstChild("HumanoidRootPart") then continue end
		local hum = char:FindFirstChildOfClass("Humanoid")
		if not hum or hum.Health == 0 then continue end

		if not LocalPlayer:GetAttribute("WorkingJob") then
			TeleportNoNotify(CFrame.new(-1729, 371, -1171))
			task.wait(0.4)
			fireproximityprompt(Workspace.ConstructionStuff["Start Job"].Prompt)
			repeat task.wait() until LocalPlayer:GetAttribute("WorkingJob")
		end

		if not LocalPlayer.Backpack:FindFirstChild("PlyWood") and not char:FindFirstChild("PlyWood") then
			TeleportNoNotify(CFrame.new(-1728, 371, -1178))
			repeat
				task.wait()
				fireproximityprompt(Workspace.ConstructionStuff["Grab Wood"].Prompt)
			until LocalPlayer.Backpack:FindFirstChild("PlyWood") or char:FindFirstChild("PlyWood")
		end

		repeat task.wait() until LocalPlayer.Backpack:FindFirstChild("PlyWood") or char:FindFirstChild("PlyWood")

		hum:EquipTool(LocalPlayer.Backpack:FindFirstChild("PlyWood"))

		local PlaceToPlaceWood = GetPlaceToPlaceWood()
		if not PlaceToPlaceWood then continue end

		TeleportNoNotify(PlaceToPlaceWood.CFrame)

		repeat
			task.wait()
			fireproximityprompt(PlaceToPlaceWood.Prompt)
		until not char:FindFirstChild("PlyWood") or not PlaceToPlaceWood.Prompt.Enabled
	end
end)

local AutoFarmBankRobbery = false

FarmingSection:CreateToggle({
	Name = "Auto Farm Bank Robbery",
	CurrentValue = false,
	Style = 2,
	Callback = function(v)
		AutoFarmBankRobbery = v
	end
}, "AUTO_FARM_BANK_ROBBERY")

task.spawn(function()
	while task.wait() do
		if not AutoFarmBankRobbery then continue end

		local char = LocalPlayer.Character
		if not char or not char:FindFirstChild("HumanoidRootPart") then continue end
		local hum = char:FindFirstChildOfClass("Humanoid")
		if not hum or hum.Health == 0 then continue end

		local robPrompt = Workspace.vault.door.robPrompt:FindFirstChild("ProximityPrompt")
		local Robbable = robPrompt and robPrompt.Enabled

		if not Robbable then
			task.wait(0.4)
			continue
		end

		if not char:FindFirstChild("DuffelBag") then
			local bagPart = Workspace:FindFirstChild("dufflebagequip")
			if bagPart then
				getgenv().Teleport(bagPart.CFrame)
				task.wait(0.8)
				local bagPrompt = bagPart:FindFirstChildWhichIsA("ProximityPrompt", true)
				if bagPrompt then
					repeat task.wait() until bagPrompt.Parent and bagPrompt.Enabled
					fireproximityprompt(bagPrompt)
					task.wait(0.4)
				end
			end
		end

		if not LocalPlayer.Backpack:FindFirstChild("C4") and not char:FindFirstChild("C4") then
			local c4Model = Workspace.GUNS:FindFirstChild("C4")
			if c4Model and c4Model:FindFirstChild("Handle") then
				getgenv().Teleport(c4Model.Handle.CFrame)
				task.wait(0.6)
				local c4Prompt = c4Model.Handle:FindFirstChild("BuyPrompt")
				if c4Prompt and c4Prompt:IsA("ProximityPrompt") then
					repeat task.wait() until c4Prompt.Parent and c4Prompt.Enabled
					fireproximityprompt(c4Prompt)
					task.wait(0.4)
				end
			end
		end

		repeat task.wait() until LocalPlayer.Backpack:FindFirstChild("C4") or char:FindFirstChild("C4")
		char.Humanoid:EquipTool(LocalPlayer.Backpack:FindFirstChild("C4"))

		if robPrompt then
			getgenv().Teleport(Workspace.vault.door.robPrompt.CFrame)
			task.wait(0.6)
			repeat task.wait() until robPrompt.Parent and robPrompt.Enabled
			fireproximityprompt(robPrompt)
		end

		task.wait(2)

		local Number = char.DuffelBag.display.SurfaceGui.Frame.TextLabel.Text
		Number = Number:gsub("0/", "")

		for _ = 1, tonumber(Number) do
			local Cash = Workspace.BankItems.Cash:FindFirstChild("Cash")
			if not Cash then
				for _, v in ipairs(Workspace:GetChildren()) do
					if v.Name == "Cash" and v:IsA("Model") and v:FindFirstChild("Model") then
						Cash = v
					end
				end
			end

			if Cash and Cash:FindFirstChild("Model") and Cash.Model:FindFirstChild("Cash") then
				getgenv().Teleport(Cash.Model.Cash.CFrame)
				task.wait(0.4)
				local cashPrompt = Cash.Model:FindFirstChildWhichIsA("ProximityPrompt", true)
				if cashPrompt then
					repeat task.wait() until cashPrompt.Parent and cashPrompt.Enabled
					fireproximityprompt(cashPrompt)
					task.wait(0.25)
				end
			end
		end

		if Workspace:FindFirstChild("sellgold") then
			getgenv().Teleport(Workspace.sellgold.CFrame)
			task.wait(0.4)
			if Workspace.sellgold:FindFirstChild("ClickDetector") then
				fireclickdetector(Workspace.sellgold.ClickDetector)
			end
		end

		task.wait(0.5)
	end
end)

local AutoFarmHouseRobbery = false

FarmingSection:CreateToggle({
	Name = "Auto Farm House Robbery",
	CurrentValue = false,
	Style = 2,
	Callback = function(v)
		AutoFarmHouseRobbery = v
	end
}, "AUTO_FARM_HOUSE_ROBBERY")

local function TeleportNoNotify(cf)
	local oldNotify = Starlight.Notification
	Starlight.Notification = function() end
	getgenv().Teleport(cf)
	Starlight.Notification = oldNotify
end

task.spawn(function()
	while task.wait() do
		if not AutoFarmHouseRobbery then continue end

		local char = LocalPlayer.Character
		if not char or not char:FindFirstChild("HumanoidRootPart") then continue end
		local hum = char:FindFirstChildOfClass("Humanoid")
		if not hum or hum.Health == 0 then continue end

		local oldCF = char.HumanoidRootPart.CFrame

		local hardDoorPrompt = Workspace.HouseRobb.HardDoor.Door:FindFirstChildWhichIsA("ProximityPrompt", true)
		local hardDoorEnabled = hardDoorPrompt and hardDoorPrompt.Enabled
		if not hardDoorEnabled then continue end

		repeat
			if not AutoFarmHouseRobbery then break end
			task.wait()
			TeleportNoNotify(hardDoorPrompt.Parent.CFrame)
			task.wait(0.4)
			fireproximityprompt(hardDoorPrompt)
		until (not AutoFarmHouseRobbery) or
			(Workspace.HouseRobb.HardDoor:FindFirstChild("TakeMoney") and
			Workspace.HouseRobb.HardDoor.TakeMoney:FindFirstChild("MoneyGrab"):FindFirstChildWhichIsA("ProximityPrompt", true).Enabled)

		if not AutoFarmHouseRobbery then
			TeleportNoNotify(oldCF)
			continue
		end

		for _, Value in ipairs(Workspace.HouseRobb.HardDoor.TakeMoney:GetChildren()) do
			if not AutoFarmHouseRobbery then break end
			TeleportNoNotify(Value.CFrame)
			fireproximityprompt(Value:FindFirstChildWhichIsA("ProximityPrompt", true))
			task.wait(0.025)
		end

		TeleportNoNotify(oldCF)
	end
end)

local AutoFarmStudioRobbery = false

FarmingSection:CreateToggle({
	Name = "Auto Farm Studio Robbery",
	CurrentValue = false,
	Style = 2,
	Callback = function(v)
		AutoFarmStudioRobbery = v
	end
}, "AUTO_FARM_STUDIO_ROBBERY")

local function TeleportNoNotify(cf)
	local oldNotify = Starlight.Notification
	Starlight.Notification = function() end
	getgenv().Teleport(cf)
	Starlight.Notification = oldNotify
end

task.spawn(function()
	local notified = false

	while task.wait() do
		if not AutoFarmStudioRobbery then
			notified = false
			continue
		end

		local char = LocalPlayer.Character
		if not char then continue end

		local hrp = char:FindFirstChild("HumanoidRootPart")
		local hum = char:FindFirstChildOfClass("Humanoid")
		if not hrp or not hum or hum.Health <= 0 then continue end

		local oldCF = hrp.CFrame

		local p1 = workspace.StudioPay.Money.StudioPay1:FindFirstChild("Prompt", true)
		local p2 = workspace.StudioPay.Money.StudioPay2:FindFirstChild("Prompt", true)
		local p3 = workspace.StudioPay.Money.StudioPay3:FindFirstChild("Prompt", true)

		if p1 and p1.Enabled then
			TeleportNoNotify(p1.Parent.CFrame)
			task.wait(0.4)
			fireproximityprompt(p1)
		elseif p1 and not p1.Enabled and not notified then
			Starlight:Notification({
				Title = "Notification",
				Icon = NebulaIcons:GetIcon("sparkle", "Material"),
				Content = "Already robbed",
			})
			notified = true
		end

		if p2 and p2.Enabled then
			TeleportNoNotify(p2.Parent.CFrame)
			task.wait(0.4)
			fireproximityprompt(p2)
		elseif p2 and not p2.Enabled and not notified then
			Starlight:Notification({
				Title = "Notification",
				Icon = NebulaIcons:GetIcon("sparkle", "Material"),
				Content = "Already robbed",
			})
			notified = true
		end

		if p3 and p3.Enabled then
			TeleportNoNotify(p3.Parent.CFrame)
			task.wait(0.4)
			fireproximityprompt(p3)
		elseif p3 and not p3.Enabled and not notified then
			Starlight:Notification({
				Title = "Notification",
				Icon = NebulaIcons:GetIcon("sparkle", "Material"),
				Content = "Already robbed",
			})
			notified = true
		end

		task.wait(0.2)
		TeleportNoNotify(oldCF)
		task.wait(1)
	end
end)

local AutoFarmDumpsters = false

FarmingSection:CreateToggle({
	Name = "Auto Farm Dumpsters",
	CurrentValue = false,
	Style = 2,
	Callback = function(v)
		AutoFarmDumpsters = v
	end
}, "AUTO_FARM_DUMPSTERS")

local function TeleportNoNotify(cf)
	local oldNotify = Starlight.Notification
	Starlight.Notification = function() end
	getgenv().Teleport(cf)
	Starlight.Notification = oldNotify
end

local function GetAllDumpsterPrompts(parent)
	local prompts = {}
	for _, v in ipairs(parent:GetDescendants()) do
		if v.Name == "DumpsterPromt" then
			local prompt = v:FindFirstChildOfClass("ProximityPrompt") or v:FindFirstChild("ProximityPrompt", true)
			if prompt and prompt.Enabled then
				table.insert(prompts, prompt)
			end
		end
	end
	return prompts
end

task.spawn(function()
	local done = {}
	local startCF = nil

	while true do
		task.wait(0.1)

		if AutoFarmDumpsters then
			if not startCF then
				local char = LocalPlayer.Character
				if char and char:FindFirstChild("HumanoidRootPart") then
					startCF = char.HumanoidRootPart.CFrame
				end
			end

			local char = LocalPlayer.Character
			if not char or not char:FindFirstChild("HumanoidRootPart") then continue end
			local hum = char:FindFirstChildOfClass("Humanoid")
			if not hum or hum.Health == 0 then continue end

			local prompts = GetAllDumpsterPrompts(workspace)
			local allDone = true

			for _, prompt in ipairs(prompts) do
				if not AutoFarmDumpsters then break end

				if prompt and prompt.Enabled and not done[prompt] then
					allDone = false
					local part = prompt.Parent
					TeleportNoNotify(part.CFrame)
					task.wait(0.3)

					fireproximityprompt(prompt)
					task.wait(0.3)

					done[prompt] = true
				end
			end

			if allDone then
				if startCF then
					TeleportNoNotify(startCF)
				end
				startCF = nil
				task.wait(1)
			end
		else
			if startCF then
				TeleportNoNotify(startCF)
				startCF = nil
			end
			done = {}
			task.wait(0.5)
		end
	end
end)

local DupingSection = MiscTab:CreateGroupbox({
    Name = "Duping Section",
    Column = 2,
}, "DUPING_SECTION")

local Cooldown = false
local AutoDupeEnabled = false
local LastToolName = nil

local function Notify(text)
	Starlight:Notification({
		Title = "Duping",
		Icon = NebulaIcons:GetIcon("sparkle", "Material"),
		Content = text,
	}, "DUPE_NOTIFY")
end

local function GetToolByName(name)
	local Player = Players.LocalPlayer
	return (Player.Character and Player.Character:FindFirstChild(name))
		or Player.Backpack:FindFirstChild(name)
end

local function DupeCurrent(toolOverride)
	if Cooldown then return end
	Cooldown = true

	task.spawn(function()
		local Player = Players.LocalPlayer
		local Tool = toolOverride and GetToolByName(toolOverride)
			or (Player.Character and Player.Character:FindFirstChildOfClass("Tool"))

		if not Tool then
			Notify("Could not find a tool! You must hold one.")
			Cooldown = false
			return
		end

		local ToolName = Tool.Name
		LastToolName = ToolName

		Player.Character.Humanoid:UnequipTools()

		local ToolId
		local Connection = ReplicatedStorage.MarketItems.ChildAdded:Connect(function(item)
			if item.Name == ToolName and item:WaitForChild("owner").Value == Player.Name then
				ToolId = item:GetAttribute("SpecialId")
			end
		end)

		Notify("Duplicating " .. ToolName)

		ReplicatedStorage.ListWeaponRemote:FireServer(ToolName, 99999)
		task.wait(0.26)
		ReplicatedStorage.BackpackRemote:InvokeServer("Store", ToolName)
		task.wait(3)
		ReplicatedStorage.BuyItemRemote:FireServer(ToolName, "Remove", ToolId)
		ReplicatedStorage.BackpackRemote:InvokeServer("Grab", ToolName)

		Connection:Disconnect()
		Cooldown = false
	end)
end

DupingSection:CreateToggle({
	Name = "Auto Dupe",
	CurrentValue = false,
	Style = 2,
	Callback = function(state)
		AutoDupeEnabled = state

		if state then
			local held = Players.LocalPlayer.Character
				and Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")

			if held then
				LastToolName = held.Name
			end

			if not LastToolName then
				Notify("Hold a tool first.")
				AutoDupeEnabled = false
				return
			end

			task.spawn(function()
				while AutoDupeEnabled do
					repeat task.wait() until not Cooldown

					local Tool = GetToolByName(LastToolName)
					if Tool and Players.LocalPlayer.Character then
						Players.LocalPlayer.Character.Humanoid:EquipTool(Tool)
					end

					DupeCurrent(LastToolName)

					repeat task.wait() until not Cooldown
					task.wait(3)
				end
			end)
		end
	end
}, "AUTO_DUPE")

DupingSection:CreateButton({
	Name = "Duplicate Item",
	Callback = function()
		DupeCurrent()
	end
}, "DUPE_BUTTON")

DupingSection:CreateParagraph({
	Name = "",
	Content = "This might bug if you have more than one of the item you're duping. Keep retrying if it doesn't work the first time; it should work after a few tries!",
}, "DUPE_INFO")

local ManualFarmSection = MiscTab:CreateGroupbox({
    Name = "Manual Farm",
    Column = 1,
}, "MANUAL_FARM_SECTION")

local AutoCollectDroppedCash = false
local AutoCollectDroppedBags = false
local AutoCollectDroppedGuns = false

local lastGunUse = 0
local lastBagUse = 0
local lastCashUse = 0
local LootGamepassId = 1061358030
local hasShownNoGamepass = false
local fireClick = rawget(getfenv(), "fireclickdetector") or fireclickdetector

ManualFarmSection:CreateToggle({
	Name = "Auto Collect Dropped Cash",
	CurrentValue = false,
	Style = 2,
	Callback = function(v)
		AutoCollectDroppedCash = v
	end
}, "AUTO_COLLECT_CASH")

ManualFarmSection:CreateToggle({
	Name = "Auto Collect Dropped Bags",
	CurrentValue = false,
	Style = 2,
	Callback = function(v)
		AutoCollectDroppedBags = v
		if not v then
			hasShownNoGamepass = false
		end
	end
}, "AUTO_COLLECT_BAGS")

ManualFarmSection:CreateToggle({
	Name = "Auto Collect Dropped Guns",
	CurrentValue = false,
	Style = 2,
	Callback = function(v)
		AutoCollectDroppedGuns = v
	end
}, "AUTO_COLLECT_GUNS")

task.spawn(function()
	while task.wait(0.6) do
		if not AutoCollectDroppedGuns then continue end
		if tick() - lastGunUse < 0.6 then continue end

		local char = LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if not hrp then continue end

		local toolsFolder = workspace:FindFirstChild("DroppedTools")
		if not toolsFolder then continue end

		local nearestPart, nearestClick
		local shortest = math.huge

		for _, tool in ipairs(toolsFolder:GetChildren()) do
			local click = tool:FindFirstChildWhichIsA("ClickDetector", true)
			if not click then continue end

			local part = tool:IsA("BasePart") and tool or tool.PrimaryPart or tool:FindFirstChildWhichIsA("BasePart", true)
			if not part then continue end

			local dist = (part.Position - hrp.Position).Magnitude
			if dist < shortest then
				shortest = dist
				nearestPart = part
				nearestClick = click
			end
		end

		if nearestPart and nearestClick then
			pcall(function()
				getgenv().Teleport(nearestPart.CFrame + Vector3.new(0, 3, 0))
				task.wait(0.15)
				if fireClick then fireClick(nearestClick) end
			end)
			lastGunUse = tick()
		end
	end
end)

task.spawn(function()
	while task.wait(0.5) do
		if not AutoCollectDroppedBags then continue end
		if tick() - lastBagUse < 0.5 then continue end

		local ownsGamepass = false
		pcall(function()
			ownsGamepass = MarketplaceService:UserOwnsGamePassAsync(LocalPlayer.UserId, LootGamepassId)
		end)

		if not ownsGamepass then
			if not hasShownNoGamepass then
				Starlight:Notification({
					Title = "Notification",
					Icon = NebulaIcons:GetIcon("sparkle", "Material"),
					Content = "You don't own looting gamepass.",
				})
				hasShownNoGamepass = true
			end
			continue
		end

		local char = LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if not hrp then continue end

		local storageFolder = workspace:FindFirstChild("Storage")
		if not storageFolder then continue end

		local oldPos = hrp.CFrame
		for _, bag in ipairs(storageFolder:GetChildren()) do
			if bag:IsA("MeshPart") and bag.Name == "Baggy" then
				local prompt = bag:FindFirstChild("stealprompt")
				if prompt and prompt.Enabled then
					getgenv().Teleport(bag.CFrame + Vector3.new(0, 3, 0))
					task.wait(0.1)
					pcall(function()
						fireproximityprompt(prompt)
					end)
					task.wait(0.2)
				end
			end
		end

		getgenv().Teleport(oldPos)
		lastBagUse = tick()
	end
end)

task.spawn(function()
	while task.wait(0.4) do
		if not AutoCollectDroppedCash then continue end
		if tick() - lastCashUse < 0.4 then continue end

		local char = LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if not hrp then continue end

		local cashFolder = workspace:FindFirstChild("DroppedCash") or workspace:FindFirstChild("Cash")
		if not cashFolder then continue end

		for _, cash in ipairs(cashFolder:GetChildren()) do
			local prompt = cash:FindFirstChildWhichIsA("ProximityPrompt", true)
			local part = cash:IsA("BasePart") and cash or cash:FindFirstChildWhichIsA("BasePart", true)
			if prompt and part and prompt.Enabled then
				getgenv().Teleport(part.CFrame + Vector3.new(0, 3, 0))
				task.wait(0.1)
				pcall(function()
					fireproximityprompt(prompt)
				end)
				task.wait(0.15)
			end
		end

		lastCashUse = tick()
	end
end)

ManualFarmSection:CreateButton({
	Name = "Clean All Filthy Money",
	Callback = function()
		local player = Players.LocalPlayer

		if not player:FindFirstChild("stored")
			or not player.stored:FindFirstChild("FilthyStack")
			or player.stored.FilthyStack.Value == 0 then
			Starlight:Notification({
				Title = "Notification",
				Icon = NebulaIcons:GetIcon('sparkle', 'Material'),
				Content = "You have no filthy money to clean.",
			}, "INDEX")
			return
		end

		if not player.Character
			or not player.Character:FindFirstChild("HumanoidRootPart")
			or not player.Character:FindFirstChild("Humanoid")
			or player.Character.Humanoid.Health <= 0 then
			return
		end

		local Cleaner = GetGoodCleaner()
		if not Cleaner then
			Starlight:Notification({
				Title = "Notification",
				Icon = NebulaIcons:GetIcon('sparkle', 'Material'),
				Content = "Could not find a valid cleaner!",
			}, "INDEX")
			return
		end

		local hrp = player.Character.HumanoidRootPart
		local oldCFrame = hrp.CFrame

		Teleport(Cleaner.WorldPivot, "Cleaner")
		task.wait(0.4)

		local cashPrompt = Cleaner:FindFirstChild("CashPrompt", true)
		if cashPrompt then fireproximityprompt(cashPrompt) end

		repeat task.wait()
		until Cleaner:FindFirstChild("On", true).Color == Color3.fromRGB(74, 156, 69)

		task.wait(0.5)
		if cashPrompt then fireproximityprompt(cashPrompt) end

		task.wait(0.25)
		Teleport(Cleaner.WorldPivot)
		task.wait(0.4)

		repeat task.wait()
		until player.Backpack:FindFirstChild("MoneyReady")

		player.Character.Humanoid:EquipTool(player.Backpack.MoneyReady)

		local grabPrompt = Cleaner:FindFirstChild("GrabPrompt", true)
		repeat
			task.wait(0.1)
			if grabPrompt then fireproximityprompt(grabPrompt) end
		until not player.Character:FindFirstChild("MoneyReady")

		repeat task.wait()
		until player.Backpack:FindFirstChild("BagOfMoney")

		local atmPart = workspace:FindFirstChild("ATMMoney")
		if atmPart then
			Teleport(atmPart.CFrame, "ATM")
			task.wait(0.4)
			if player.Backpack:FindFirstChild("BagOfMoney") then
				player.Character.Humanoid:EquipTool(player.Backpack.BagOfMoney)
				task.wait(0.1)
				if atmPart:FindFirstChild("Prompt") then
					fireproximityprompt(atmPart.Prompt)
				end
			end
		end

		Teleport(oldCFrame, "Return")
	end
}, "CLEAN_FILTHY_MONEY")

local VulnerabilitySection = VulnerabilitySection or MiscTab:CreateGroupbox({
	Name = "Vulnerability Section",
	Column = 2,
}, "VULNERABILITY_SECTION")

local function SafeTeleport(cf)
	local char = LocalPlayer.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	if getgenv().Teleport then
		pcall(getgenv().Teleport, cf)
	else
		hrp.CFrame = cf
	end
end

local function FirePrompt(prompt)
	if not prompt then return end
	if fireproximityprompt then
		fireproximityprompt(prompt)
		return
	end
	if prompt.InputHoldBegin then
		prompt:InputHoldBegin()
		task.wait(prompt.HoldDuration or 0)
		prompt:InputHoldEnd()
		return
	end
	local cam = workspace.CurrentCamera
	local pos = cam:WorldToViewportPoint(prompt.Parent.Position)
	VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 0)
	task.wait(0.05)
	VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
end

local function SpamPrompt(prompt, times)
	for i = 1, times do
		task.defer(FirePrompt, prompt)
	end
end

local manualReady = false
local SelectedMethod = "Auto"

local MethodLabel = VulnerabilitySection:CreateLabel({
	Name = "Select Method",
}, "VULN_METHOD_LABEL")

MethodLabel:AddDropdown({
	Options = { "Auto", "Manual" },
	CurrentOptions = { "Auto" },
	Placeholder = "Auto",
	Callback = function(opts)
		SelectedMethod = opts[1]
	end,
}, "VULN_METHOD_DROPDOWN")

local function GetFruitCup()
	for _, container in ipairs({ LocalPlayer.Backpack, LocalPlayer.Character }) do
		if not container then continue end
		for _, tool in ipairs(container:GetChildren()) do
			if tool:IsA("Tool") and tool.Name == "Ice-Fruit Cupz" then
				local cup = tool:FindFirstChild("IceFruit Cup", true)
				local mesh = cup and cup:FindFirstChild("IceFruit PunchMedium", true)
				if mesh and mesh.Transparency ~= 1 then
					return true, tool
				end
			end
		end
	end
	return false, nil
end

VulnerabilitySection:CreateButton({
	Name = "Generate Max Illegal Money",
	Callback = function()
		local char = LocalPlayer.Character
		if not char then return end
		local hum = char:FindFirstChildOfClass("Humanoid")
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not hum or not hrp then return end
		local oldCF = hrp.CFrame

		if SelectedMethod == "Manual" then
			if not manualReady then
				for _, item in ipairs({ "FijiWater", "FreshWater", "Ice-Fruit Bag", "Ice-Fruit Cupz" }) do
					if not LocalPlayer.Backpack:FindFirstChild(item) then
						ReplicatedStorage.ExoticShopRemote:InvokeServer(item)
						task.wait(1)
					end
				end
				manualReady = true
				return
			end
			manualReady = false
			SafeTeleport(workspace["IceFruit Sell"].CFrame)
			task.wait(1)
			hrp.Anchored = true
			workspace["IceFruit Sell"].ProximityPrompt.HoldDuration = 0
			SpamPrompt(workspace["IceFruit Sell"].ProximityPrompt, 4000)
			task.wait(0.5)
			hrp.Anchored = false
			SafeTeleport(oldCF)
			return
		end

		local Found, Cup = GetFruitCup()
		if Found and Cup then
			if Cup.Parent == LocalPlayer.Backpack then
				hum:EquipTool(Cup)
				task.wait(0.8)
			end
			SafeTeleport(workspace["IceFruit Sell"].CFrame)
			task.wait(0.5)
			SpamPrompt(workspace["IceFruit Sell"].ProximityPrompt, 4000)
			task.wait(0.5)
			SafeTeleport(oldCF)
			return
		end

		local stove
		for _, v in ipairs(workspace.CookingPots:GetChildren()) do
			local p = v:FindFirstChildWhichIsA("ProximityPrompt", true)
			if p and p.ActionText == "Turn On" and p.Enabled then
				stove = v
				break
			end
		end
		if not stove then return end

		for _, item in ipairs({ "FijiWater", "FreshWater", "Ice-Fruit Bag", "Ice-Fruit Cupz" }) do
			if not LocalPlayer.Backpack:FindFirstChild(item) then
				ReplicatedStorage.ExoticShopRemote:InvokeServer(item)
				task.wait(1)
			end
		end

		SafeTeleport(stove.CookPart.CFrame)
		task.wait(1)
		hrp.Anchored = true
		FirePrompt(stove:FindFirstChildWhichIsA("ProximityPrompt", true))
		task.wait(2)

		for _, item in ipairs({ "FijiWater", "FreshWater", "Ice-Fruit Bag" }) do
			hum:EquipTool(LocalPlayer.Backpack[item])
			task.wait(1)
			FirePrompt(stove:FindFirstChildWhichIsA("ProximityPrompt", true))
			task.wait(3)
		end

		repeat task.wait() until not stove.CookPart.Steam.LoadUI.Enabled

		hum:EquipTool(LocalPlayer.Backpack["Ice-Fruit Cupz"])
		task.wait(1)
		FirePrompt(stove:FindFirstChildWhichIsA("ProximityPrompt", true))
		task.wait(2)

		hrp.Anchored = false
		SafeTeleport(workspace["IceFruit Sell"].CFrame)
		task.wait(1)
		hrp.Anchored = true
		workspace["IceFruit Sell"].ProximityPrompt.HoldDuration = 0
		SpamPrompt(workspace["IceFruit Sell"].ProximityPrompt, 4000)
		task.wait(0.5)
		hrp.Anchored = false
		SafeTeleport(oldCF)
	end,
}, "GEN_MAX_ILLEGAL_MONEY")

VulnerabilitySection:CreateParagraph({
	Name = "",
	Content = "Money Generator takes around 3 minutes, and can take longer if some items are not in stock.\nYou need around 5K and a Good executor is required!",
}, "MONEY_GEN_DESC")

local KillAuraSection = MiscTab:CreateGroupbox({
	Name = "Kill Aura Section",
	Column = 2,
}, "KILL_AURA_SECTION")

local KillAuraEnabled = false
local KillAuraRange = 300

KillAuraSection:CreateToggle({
	Name = "Enabled - Hold Gun",
	CurrentValue = false,
	Style = 1,
	Callback = function(state)
		KillAuraEnabled = state
	end,
}, "KILL_AURA_ENABLED")

KillAuraSection:CreateSlider({
	Name = "Kill Aura Range",
	Range = { 1, 1000 },
	Increment = 1,
	CurrentValue = 300,
	Callback = function(Value)
		KillAuraRange = Value
	end,
}, "KILL_AURA_RANGE")

task.spawn(function()
	while task.wait(1) do
		if not KillAuraEnabled then continue end
		if not HasGunEquipped() then continue end

		for _, plr in ipairs(Players:GetPlayers()) do
			if plr == LocalPlayer then continue end
			if not plr.Character then continue end

			local hum = plr.Character:FindFirstChildOfClass("Humanoid")
			local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
			if not hum or not hrp then continue end
			if hum.Health <= 0 then continue end
			if plr.Character:FindFirstChildOfClass("ForceField") then continue end
			if not DistanceCheck(plr, KillAuraRange) then continue end

			kill_gun(plr.Name, "Head", math.huge)
		end
	end
end)

local BankActionsSection = MiscTab:CreateGroupbox({
    Name = "Bank Actions",
    Column = 1,
}, "BANK_ACTIONS_SECTION")

local MoneyAmount = ""
local SelectedBankAction = "Drop"

local function Notify(text)
	Starlight:Notification({
		Title = "Notification",
		Icon = NebulaIcons:GetIcon("sparkle", "Material"),
		Content = text,
	}, "INDEX")
end

BankActionsSection:CreateInput({
	Name = "Money Amount",
	Icon = NebulaIcons:GetIcon("text-cursor-input", "Lucide"),
	CurrentValue = "",
	PlaceholderText = "Enter Amount",
	Callback = function(Text)
		MoneyAmount = Text
	end,
}, "BANK_MONEY_INPUT")

local BankActionLabel = BankActionsSection:CreateLabel({
	Name = "Select Bank Action",
}, "BANK_ACTION_LABEL")

BankActionLabel:AddDropdown({
	Options = { "Deposit", "Withdraw", "Drop" },
	CurrentOptions = { "Drop" },
	Placeholder = "Drop",
	Callback = function(Options)
		SelectedBankAction = Options[1]
	end,
}, "BANK_ACTION_DROPDOWN")

BankActionsSection:CreateButton({
	Name = "Apply Selected Bank Action",
	Callback = function()
		local amount = tonumber(MoneyAmount)
		if not amount or amount <= 0 then return end

		local stored = LocalPlayer:FindFirstChild("stored")
		if not stored then return end

		if SelectedBankAction == "Drop" then
			if amount > 10000 then
				Notify("Max that can be dropped is $10,000!")
				return
			end

			local money = stored:FindFirstChild("Money")
			if not money or money.Value < amount then
				Notify("Not enough money!")
				return
			end

			local before = money.Value
			ReplicatedStorage:WaitForChild("BankProcessRemote"):InvokeServer("Drop", tostring(amount))
			task.wait(0.15)

			if money.Value < before then
				Notify("Successfully dropped $" .. amount .. "!")
			else
				Notify("Drop failed!")
			end

		elseif SelectedBankAction == "Withdraw" then
			local bank = stored:FindFirstChild("Bank")
			if not bank or bank.Value < amount then
				Notify("Not enough bank money!")
				return
			end

			local before = bank.Value
			ReplicatedStorage:WaitForChild("BankAction"):FireServer("with", tostring(amount))
			task.wait(0.15)

			if bank.Value < before then
				Notify("Successfully withdrew $" .. amount .. "!")
			else
				Notify("Withdraw failed!")
			end

		elseif SelectedBankAction == "Deposit" then
			local money = stored:FindFirstChild("Money")
			local bank = stored:FindFirstChild("Bank")
			if not money or not bank or money.Value < amount then
				Notify("Not enough money!")
				return
			end

			local before = bank.Value
			ReplicatedStorage:WaitForChild("BankAction"):FireServer("depo", tostring(amount))
			task.wait(0.15)

			if bank.Value > before then
				Notify("Successfully deposited $" .. amount .. "!")
			else
				Notify("Deposit failed!")
			end
		end
	end,
}, "APPLY_BANK_ACTION")

local AutoDepositRunning = false
local AutoWithdrawRunning = false
local AutoDropRunning = false

BankActionsSection:CreateToggle({
	Name = "Auto Deposit",
	CurrentValue = false,
	Style = 1,
	Callback = function(state)
		AutoDepositRunning = state
		if not state then return end

		task.spawn(function()
			while AutoDepositRunning do
				local stored = LocalPlayer:FindFirstChild("stored")
				local money = stored and stored:FindFirstChild("Money")
				local bank = stored and stored:FindFirstChild("Bank")

				local amount = tonumber(MoneyAmount) or 0
				if not money or not bank or amount <= 0 then
					task.wait(1)
					continue
				end

				if money.Value < amount then
					Notify("Not enough money!")
					task.wait(1)
					continue
				end

				local before = bank.Value
				ReplicatedStorage:WaitForChild("BankAction"):FireServer("depo", tostring(amount))
				task.wait(0.15)

				if bank.Value > before then
					Notify("Auto deposited $" .. amount .. "!")
				else
					Notify("Auto deposit failed!")
				end

				task.wait(1)
			end
		end)
	end,
}, "AUTO_DEPOSIT")

BankActionsSection:CreateToggle({
	Name = "Auto Withdraw",
	CurrentValue = false,
	Style = 1,
	Callback = function(state)
		AutoWithdrawRunning = state
		if not state then return end

		task.spawn(function()
			while AutoWithdrawRunning do
				local stored = LocalPlayer:FindFirstChild("stored")
				local bank = stored and stored:FindFirstChild("Bank")

				local amount = tonumber(MoneyAmount) or 0
				if not bank or amount <= 0 then
					task.wait(1)
					continue
				end

				if bank.Value < amount then
					Notify("Not enough bank money!")
					task.wait(1)
					continue
				end

				local before = bank.Value
				ReplicatedStorage:WaitForChild("BankAction"):FireServer("with", tostring(amount))
				task.wait(0.15)

				if bank.Value < before then
					Notify("Auto withdrew $" .. amount .. "!")
				else
					Notify("Auto withdraw failed!")
				end

				task.wait(1)
			end
		end)
	end,
}, "AUTO_WITHDRAW")

BankActionsSection:CreateToggle({
	Name = "Auto Drop",
	CurrentValue = false,
	Style = 1,
	Callback = function(state)
		AutoDropRunning = state
		if not state then return end

		task.spawn(function()
			while AutoDropRunning do
				local stored = LocalPlayer:FindFirstChild("stored")
				local money = stored and stored:FindFirstChild("Money")

				local amount = tonumber(MoneyAmount)
				if not money or not amount or amount <= 0 then
					task.wait(1)
					continue
				end

				if amount > 10000 then
					Notify("Max that can be dropped is $10,000!")
					task.wait(1)
					continue
				end

				if money.Value < amount then
					Notify("Not enough money!")
					task.wait(1)
					continue
				end

				local before = money.Value
				ReplicatedStorage:WaitForChild("BankProcessRemote"):InvokeServer("Drop", tostring(amount))
				task.wait(0.15)

				if money.Value < before then
					Notify("Auto dropped $" .. amount .. "!")
				else
					Notify("Auto drop failed!")
				end

				task.wait(1)
			end
		end)
	end,
}, "AUTO_DROP")

local AFKSafetyTeleport = false
local AutoSellTrash = false

local FarmingSettingsSection = MiscTab:CreateGroupbox({
	Name = "Farming Settings",
	Column = 2,
}, "FARMING_SETTINGS_SECTION")

FarmingSettingsSection:CreateToggle({
	Name = "AFK Safety Teleport",
	CurrentValue = false,
	Style = 2,
	Callback = function(v)
		AFKSafetyTeleport = v
	end
}, "AFK_SAFETY_TELEPORT")

FarmingSettingsSection:CreateToggle({
	Name = "Auto Sell Trash",
	CurrentValue = false,
	Style = 2,
	Callback = function(v)
		AutoSellTrash = v
	end
}, "AUTO_SELL_TRASH")

task.spawn(function()
	while task.wait(1) do
		if not AutoSellTrash then continue end

		for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
			if tool:IsA("Tool") then
				ReplicatedStorage:WaitForChild("PawnRemote"):FireServer(tool.Name)
				task.wait()
			end
		end
	end
end)

local SafeTab = GameSection:CreateTab({
	Name = "Safe",
	Icon = NebulaIcons:GetIcon("lock", "Material"),
	Columns = 2,
}, "SAFE_TAB")

local InventoryRemote = ReplicatedStorage:WaitForChild("Inventory")

local function GetBackpackItems()
	local t = {}
	local bp = LocalPlayer:FindFirstChild("Backpack")
	if not bp then return t end
	for _, v in ipairs(bp:GetChildren()) do
		t[#t + 1] = v.Name
	end
	table.sort(t)
	return t
end

local function GetInvDataItems()
	local t = {}
	local inv = LocalPlayer:FindFirstChild("InvData")
	if not inv then return t end
	for _, v in ipairs(inv:GetChildren()) do
		t[#t + 1] = v.Name
	end
	table.sort(t)
	return t
end

local function GetRandomSafe()
	local safes = {}
	for _, v in ipairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v.Name == "Safe" then
			local p = v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart")
			if p then
				safes[#safes + 1] = { Part = p, Model = v }
			end
		end
	end
	if #safes == 0 then return nil end
	return safes[math.random(#safes)]
end

local SelectedBackpackItem
local SelectedSafeItem

local SafeSelectedGroupbox = SafeTab:CreateGroupbox({
	Name = "Safe Selected Item",
	Column = 1,
}, "SAFE_SELECTED_ITEM")

local BackpackLabel = SafeSelectedGroupbox:CreateLabel({
	Name = "Backpack Items",
}, "BACKPACK_ITEMS_LABEL")

local BackpackDropdown
local SafeDropdown

BackpackDropdown = BackpackLabel:AddDropdown({
	Options = GetBackpackItems(),
	CurrentOptions = {},
	Placeholder = "--",
	Callback = function(v)
		SelectedBackpackItem = v and v[1]
		if not SelectedBackpackItem then return end

		local char = LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if not hrp then return end

		local safe = GetRandomSafe()
		if not safe then return end

		local oldCF = hrp.CFrame

		getgenv().Teleport(safe.Part.CFrame * CFrame.new(0, 3, 0), "Safe")
		task.wait(0.25)

		InventoryRemote:FireServer("Change", SelectedBackpackItem, "Backpack", safe.Model)

		task.wait(0.25)
		getgenv().Teleport(oldCF, "Previous Location")

		BackpackDropdown:Set({ Options = GetBackpackItems() })
		SafeDropdown:Set({ Options = GetInvDataItems() })
	end,
}, "BACKPACK_ITEMS_DROPDOWN")

local TakeSelectedGroupbox = SafeTab:CreateGroupbox({
	Name = "Take Selected Item",
	Column = 2,
}, "TAKE_SELECTED_ITEM")

local SafeItemsLabel = TakeSelectedGroupbox:CreateLabel({
	Name = "Safe Items",
}, "SAFE_ITEMS_LABEL")

SafeDropdown = SafeItemsLabel:AddDropdown({
	Options = GetInvDataItems(),
	CurrentOptions = {},
	Placeholder = "--",
	Callback = function(v)
		SelectedSafeItem = v and v[1]
		if not SelectedSafeItem then return end

		local char = LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if not hrp then return end

		local safe = GetRandomSafe()
		if not safe then return end

		local oldCF = hrp.CFrame

		getgenv().Teleport(safe.Part.CFrame * CFrame.new(0, 3, 0), "Safe")
		task.wait(0.25)

		InventoryRemote:FireServer("Change", SelectedSafeItem, "Inv", safe.Model)

		task.wait(0.25)
		getgenv().Teleport(oldCF, "Previous Location")

		BackpackDropdown:Set({ Options = GetBackpackItems() })
		SafeDropdown:Set({ Options = GetInvDataItems() })
	end,
}, "SAFE_ITEMS_DROPDOWN")

LocalPlayer.Backpack.ChildAdded:Connect(function()
	BackpackDropdown:Set({ Options = GetBackpackItems() })
end)

LocalPlayer.Backpack.ChildRemoved:Connect(function()
	BackpackDropdown:Set({ Options = GetBackpackItems() })
end)

LocalPlayer.InvData.ChildAdded:Connect(function()
	SafeDropdown:Set({ Options = GetInvDataItems() })
end)

LocalPlayer.InvData.ChildRemoved:Connect(function()
	SafeDropdown:Set({ Options = GetInvDataItems() })
end)

CombatSection:CreateTab({
    Name = "Silent Aim",
    Icon = NebulaIcons:GetIcon("gps_fixed", "Material"),
    Columns = 2,
}, "SILENT_AIM")

CombatSection:CreateTab({
    Name = "Aimlock",
    Icon = NebulaIcons:GetIcon("center_focus_strong", "Material"),
    Columns = 2,
}, "AIMLOCK")

local WeaponModsTab = ModSection:CreateTab({
    Name = "Weapon Modifications",
    Icon = NebulaIcons:GetIcon("build", "Material"),
    Columns = 2,
}, "WEAPON_MODS")

local WeaponModsSection = WeaponModsTab:CreateGroupbox({
    Name = "Weapon Mods",
    Column = 1,
}, "WEAPON_MODS_SECTION")

local InfiniteAmmo = false
local InfiniteClips = false
local InfiniteDamage = false
local FullyAutomatic = false
local DisableJamming = false
local ModifyRecoil = false
local ModifySpread = false
local ModifyReloadSpeed = false
local ModifyEquipSpeed = false
local ModifyFireRate = false

local RecoilPercent = 50
local SpreadPercent = 50
local FireRatePercent = 50
local ReloadSpeedPercent = 50
local EquipSpeedPercent = 50

WeaponModsSection:CreateToggle({
    Name = "Infinite Ammo",
    CurrentValue = false,
    Callback = function(v)
        InfiniteAmmo = v
    end
}, "INF_AMMO")

WeaponModsSection:CreateToggle({
    Name = "Infinite Clips",
    CurrentValue = false,
    Callback = function(v)
        InfiniteClips = v
    end
}, "INF_CLIPS")

WeaponModsSection:CreateToggle({
    Name = "Infinite Damage",
    CurrentValue = false,
    Callback = function(v)
        InfiniteDamage = v
    end
}, "INF_DAMAGE")

WeaponModsSection:CreateToggle({
    Name = "Fully Automatic",
    CurrentValue = false,
    Callback = function(v)
        FullyAutomatic = v
    end
}, "FULL_AUTO")

WeaponModsSection:CreateToggle({
    Name = "Disable Jamming",
    CurrentValue = false,
    Callback = function(v)
        DisableJamming = v
    end
}, "NO_JAM")

WeaponModsSection:CreateToggle({
    Name = "Modify Recoil Value",
    CurrentValue = false,
    Callback = function(v)
        ModifyRecoil = v
    end
}, "MOD_RECOIL")

WeaponModsSection:CreateToggle({
    Name = "Modify Spread Value",
    CurrentValue = false,
    Callback = function(v)
        ModifySpread = v
    end
}, "MOD_SPREAD")

WeaponModsSection:CreateToggle({
    Name = "Modify Reload Speed",
    CurrentValue = false,
    Callback = function(v)
        ModifyReloadSpeed = v
    end
}, "MOD_RELOAD")

WeaponModsSection:CreateToggle({
    Name = "Modify Equip Speed",
    CurrentValue = false,
    Callback = function(v)
        ModifyEquipSpeed = v
    end
}, "MOD_EQUIP")

WeaponModsSection:CreateToggle({
    Name = "Modify Fire Rate",
    CurrentValue = false,
    Callback = function(v)
        ModifyFireRate = v
    end
}, "MOD_FIRERATE")

local Divider = WeaponModsSection:CreateDivider()

WeaponModsSection:CreateSlider({
    Name = "Recoil Percentage",
    Range = {0, 100},
    Increment = 1,
    CurrentValue = 50,
    Callback = function(v)
        RecoilPercent = v
    end
}, "RECOIL_PERCENT")

WeaponModsSection:CreateSlider({
    Name = "Spread Percentage",
    Range = {0, 100},
    Increment = 1,
    CurrentValue = 50,
    Callback = function(v)
        SpreadPercent = v
    end
}, "SPREAD_PERCENT")

WeaponModsSection:CreateSlider({
    Name = "Fire Rate Percentage",
    Range = {0, 100},
    Increment = 1,
    CurrentValue = 50,
    Callback = function(v)
        FireRatePercent = v
    end
}, "FIRERATE_PERCENT")

WeaponModsSection:CreateSlider({
    Name = "Reload Speed Percentage",
    Range = {0, 100},
    Increment = 1,
    CurrentValue = 50,
    Callback = function(v)
        ReloadSpeedPercent = v
    end
}, "RELOAD_PERCENT")

WeaponModsSection:CreateSlider({
    Name = "Equip Speed Percentage",
    Range = {0, 100},
    Increment = 1,
    CurrentValue = 50,
    Callback = function(v)
        EquipSpeedPercent = v
    end
}, "EQUIP_PERCENT")

ModSection:CreateTab({
    Name = "Hitbox Modifications",
    Icon = NebulaIcons:GetIcon("crop_square", "Material"),
    Columns = 2,
}, "HITBOX_MODS")

ModSection:CreateTab({
    Name = "Fist Modifications",
    Icon = NebulaIcons:GetIcon("pan_tool", "Material"),
    Columns = 2,
}, "FIST_MODS")

VisualsSection:CreateTab({
    Name = "Players",
    Icon = NebulaIcons:GetIcon("visibility", "Material"),
    Columns = 2,
}, "VISUAL_PLAYERS")

ConfigSection:CreateTab({
    Name = "Config",
    Icon = NebulaIcons:GetIcon("tune", "Material"),
    Columns = 2,
}, "CONFIG")


Starlight:SetTheme("OperaGX")

end)()
