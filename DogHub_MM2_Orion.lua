-- Dog Hub MM2 [Beta] — Orion UI version
-- NOTE: All features preserved; UI text translated to English; Hub renamed to Dog Hub

-- Orion UI
local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Orion/main/source'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local CurrentCamera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

-- Helper
local function safeInvokeGetPlayerData()
    local ok, res = pcall(function()
        return ReplicatedStorage:FindFirstChild("GetPlayerData", true):InvokeServer()
    end)
    if ok and type(res) == "table" then
        return res
    end
    return {}
end

-- Window
local Window = OrionLib:MakeWindow({
    Name = "Dog Hub MM2 [Beta]",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "DogHubMM2"
})

-- Tabs
local MainTab       = Window:MakeTab({Name = "MAIN", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local CharacterTab  = Window:MakeTab({Name = "CHARACTER", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local TeleportTab   = Window:MakeTab({Name = "TELEPORT", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local EspTab        = Window:MakeTab({Name = "ESP", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local AimbotTab     = Window:MakeTab({Name = "AIMBOT", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local AutoFarmTab   = Window:MakeTab({Name = "AUTOFARM", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local InnocentTab   = Window:MakeTab({Name = "INNOCENT", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local MurderTab     = Window:MakeTab({Name = "MURDER", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local SheriffTab    = Window:MakeTab({Name = "SHERIFF", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local ServerTab     = Window:MakeTab({Name = "SERVER", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local SettingsTab   = Window:MakeTab({Name = "SETTINGS", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local ChangelogsTab = Window:MakeTab({Name = "CHANGELOGS", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local SocialsTab    = Window:MakeTab({Name = "SOCIALS", Icon = "rbxassetid://4483345998", PremiumOnly = false})

-- Startup popup (notification in Orion)
OrionLib:MakeNotification({
    Name    = "Dog Hub",
    Content = "Script loaded successfully!",
    Image   = "rbxassetid://4483345998",
    Time    = 4
})

----------------------------------------------------------------
-- CHARACTER
----------------------------------------------------------------
local CharacterSettings = {
    WalkSpeed = {Value = 16, Default = 16, Locked = false},
    JumpPower = {Value = 50, Default = 50, Locked = false}
}

local function updateCharacter()
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        if not CharacterSettings.WalkSpeed.Locked then
            humanoid.WalkSpeed = CharacterSettings.WalkSpeed.Value
        end
        if not CharacterSettings.JumpPower.Locked then
            humanoid.JumpPower = CharacterSettings.JumpPower.Value
        end
    end
end

CharacterTab:AddSection({Name = "WalkSpeed"})
CharacterTab:AddSlider({
    Name = "WalkSpeed",
    Min = 0, Max = 200, Default = 16,
    Callback = function(v) CharacterSettings.WalkSpeed.Value = v; updateCharacter() end
})
CharacterTab:AddButton({
    Name = "Reset WalkSpeed",
    Callback = function() CharacterSettings.WalkSpeed.Value = CharacterSettings.WalkSpeed.Default; updateCharacter() end
})
CharacterTab:AddToggle({
    Name = "Lock WalkSpeed",
    Default = false,
    Callback = function(state) CharacterSettings.WalkSpeed.Locked = state; updateCharacter() end
})

CharacterTab:AddSection({Name = "JumpPower"})
CharacterTab:AddSlider({
    Name = "JumpPower",
    Min = 0, Max = 200, Default = 50,
    Callback = function(v) CharacterSettings.JumpPower.Value = v; updateCharacter() end
})
CharacterTab:AddButton({
    Name = "Reset JumpPower",
    Callback = function() CharacterSettings.JumpPower.Value = CharacterSettings.JumpPower.Default; updateCharacter() end
})
CharacterTab:AddToggle({
    Name = "Lock JumpPower",
    Default = false,
    Callback = function(state) CharacterSettings.JumpPower.Locked = state; updateCharacter() end
})

----------------------------------------------------------------
-- ESP
----------------------------------------------------------------
local ESPConfig = {HighlightMurderer = false, HighlightInnocent = false, HighlightSheriff = false}
local Murder, Sheriff, Hero
local roles = {}

local function IsAlive(player)
    for name, data in pairs(roles) do
        if player.Name == name then return not data.Killed and not data.Dead end
    end
    return false
end

local function UpdateRoles()
    roles = safeInvokeGetPlayerData()
    Murder, Sheriff, Hero = nil, nil, nil
    for name, data in pairs(roles) do
        if data.Role == "Murderer" then Murder = name
        elseif data.Role == "Sheriff" then Sheriff = name
        elseif data.Role == "Hero" then Hero = name end
    end
end

local function CreateHighlight(player)
    if player ~= LocalPlayer and player.Character and not player.Character:FindFirstChild("Highlight") then
        local h = Instance.new("Highlight")
        h.Parent = player.Character
        h.Adornee = player.Character
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        return h
    end
    return player.Character and player.Character:FindFirstChild("Highlight")
end

local function UpdateHighlights()
    for _, pl in pairs(Players:GetPlayers()) do
        if pl ~= LocalPlayer and pl.Character then
            local h = pl.Character:FindFirstChild("Highlight")
            if not (ESPConfig.HighlightMurderer or ESPConfig.HighlightInnocent or ESPConfig.HighlightSheriff) then
                if h then h:Destroy() end
            else
                local should = false
                local color = Color3.new(0,1,0)
                if pl.Name == Murder and IsAlive(pl) and ESPConfig.HighlightMurderer then
                    color = Color3.fromRGB(255,0,0); should = true
                elseif pl.Name == Sheriff and IsAlive(pl) and ESPConfig.HighlightSheriff then
                    color = Color3.fromRGB(0,0,255); should = true
                elseif ESPConfig.HighlightInnocent and IsAlive(pl) and (pl.Name ~= Murder and pl.Name ~= Sheriff and pl.Name ~= Hero) then
                    color = Color3.fromRGB(0,255,0); should = true
                elseif pl.Name == Hero and IsAlive(pl) and (not IsAlive(Players[Sheriff] or {})) and ESPConfig.HighlightSheriff then
                    color = Color3.fromRGB(255,250,0); should = true
                end
                if should then
                    h = CreateHighlight(pl); if h then h.FillColor = color; h.OutlineColor = color; h.Enabled = true end
                elseif h then
                    h.Enabled = false
                end
            end
        end
    end
end

EspTab:AddSection({Name = "Special ESP"})
EspTab:AddToggle({
    Name = "Highlight Murderer",
    Default = false,
    Callback = function(s) ESPConfig.HighlightMurderer = s; if not s then UpdateHighlights() end end
})
EspTab:AddToggle({
    Name = "Highlight Innocent",
    Default = false,
    Callback = function(s) ESPConfig.HighlightInnocent = s; if not s then UpdateHighlights() end end
})
EspTab:AddToggle({
    Name = "Highlight Sheriff/Hero",
    Default = false,
    Callback = function(s) ESPConfig.HighlightSheriff = s; if not s then UpdateHighlights() end end
})

-- GunDrop Highlight
local gunDropESPEnabled = false
local mapPaths = {"ResearchFacility","Hospital3","MilBase","House2","Workplace","Mansion2","BioLab","Hotel","Factory","Bank2","PoliceStation"}

local function createGunDropHighlight(gunDrop)
    if gunDropESPEnabled and gunDrop and not gunDrop:FindFirstChild("GunDropHighlight") then
        local h = Instance.new("Highlight")
        h.Name = "GunDropHighlight"
        h.FillColor = Color3.fromRGB(255,215,0)
        h.OutlineColor = Color3.fromRGB(255,165,0)
        h.Adornee = gunDrop
        h.Parent = gunDrop
    end
end

local function updateGunDropESP()
    for _, mapName in ipairs(mapPaths) do
        local map = workspace:FindFirstChild(mapName)
        if map then
            local gunDrop = map:FindFirstChild("GunDrop")
            if gunDrop and gunDrop:FindFirstChild("GunDropHighlight") then
                gunDrop.GunDropHighlight:Destroy()
            end
        end
    end
    if gunDropESPEnabled then
        for _, mapName in ipairs(mapPaths) do
            local map = workspace:FindFirstChild(mapName)
            if map then
                local gunDrop = map:FindFirstChild("GunDrop")
                if gunDrop then createGunDropHighlight(gunDrop) end
            end
        end
    end
end

local function monitorGunDrops()
    for _, mapName in ipairs(mapPaths) do
        local map = workspace:FindFirstChild(mapName)
        if map then
            map.ChildAdded:Connect(function(child)
                if child.Name == "GunDrop" then createGunDropHighlight(child) end
            end)
        end
    end
end
monitorGunDrops()

EspTab:AddToggle({
    Name = "GunDrop Highlight",
    Default = false,
    Callback = function(state) gunDropESPEnabled = state; updateGunDropESP() end
})

RunService.RenderStepped:Connect(function()
    UpdateRoles()
    if ESPConfig.HighlightMurderer or ESPConfig.HighlightInnocent or ESPConfig.HighlightSheriff then
        UpdateHighlights()
    end
end)

----------------------------------------------------------------
-- TELEPORT
----------------------------------------------------------------
TeleportTab:AddSection({Name = "Default TP"})
local teleportTarget = nil
local function playersList()
    local list = {"Select Player"}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(list, p.Name) end
    end
    return list
end

local dd = TeleportTab:AddDropdown({
    Name = "Players",
    Default = "Select Player",
    Options = playersList(),
    Callback = function(selected)
        teleportTarget = (selected ~= "Select Player") and Players:FindFirstChild(selected) or nil
    end
})

Players.PlayerAdded:Connect(function() dd:Refresh(playersList(), true) end)
Players.PlayerRemoving:Connect(function() dd:Refresh(playersList(), true) end)

TeleportTab:AddButton({
    Name = "Teleport to player",
    Callback = function()
        if teleportTarget and teleportTarget.Character then
            local tRoot = teleportTarget.Character:FindFirstChild("HumanoidRootPart")
            local lRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if tRoot and lRoot then
                lRoot.CFrame = tRoot.CFrame
                OrionLib:MakeNotification({Name="Teleportation", Content="Successfully teleported to "..teleportTarget.Name, Time=3})
            end
        else
            OrionLib:MakeNotification({Name="Error", Content="Target not found or unavailable", Time=3})
        end
    end
})

TeleportTab:AddButton({Name="Update players list", Callback=function() dd:Refresh(playersList(), true) end})

TeleportTab:AddSection({Name = "Special TP"})
TeleportTab:AddButton({
    Name = "Teleport to Lobby",
    Callback = function()
        local lobby = workspace:FindFirstChild("Lobby")
        if not lobby then
            OrionLib:MakeNotification({Name="Teleport", Content="Lobby not found!", Time=2}); return
        end
        local sp = lobby:FindFirstChild("SpawnPoint") or lobby:FindFirstChildOfClass("SpawnLocation") or lobby:FindFirstChildWhichIsA("BasePart") or lobby
        local lRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if lRoot and sp then
            lRoot.CFrame = CFrame.new(sp.Position + Vector3.new(0,3,0))
            OrionLib:MakeNotification({Name="Teleport", Content="Teleported to Lobby!", Time=2})
        end
    end
})

TeleportTab:AddButton({
    Name = "Teleport to Sheriff",
    Callback = function()
        UpdateRoles()
        if Sheriff then
            local sPlr = Players:FindFirstChild(Sheriff)
            if sPlr and sPlr.Character then
                local tRoot = sPlr.Character:FindFirstChild("HumanoidRootPart")
                local lRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if tRoot and lRoot then
                    lRoot.CFrame = tRoot.CFrame
                    OrionLib:MakeNotification({Name="Teleportation", Content="Teleported to Sheriff "..Sheriff, Time=3})
                end
            else
                OrionLib:MakeNotification({Name="Error", Content="Sheriff not found or unavailable", Time=3})
            end
        else
            OrionLib:MakeNotification({Name="Error", Content="Sheriff is not set in this round", Time=3})
        end
    end
})

TeleportTab:AddButton({
    Name = "Teleport to Murderer",
    Callback = function()
        UpdateRoles()
        if Murder then
            local mPlr = Players:FindFirstChild(Murder)
            if mPlr and mPlr.Character then
                local tRoot = mPlr.Character:FindFirstChild("HumanoidRootPart")
                local lRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if tRoot and lRoot then
                    lRoot.CFrame = tRoot.CFrame
                    OrionLib:MakeNotification({Name="Teleportation", Content="Teleported to Murderer "..Murder, Time=3})
                end
            else
                OrionLib:MakeNotification({Name="Error", Content="Murderer not found or unavailable", Time=3})
            end
        else
            OrionLib:MakeNotification({Name="Error", Content="Murderer is not set in this round", Time=3})
        end
    end
})

----------------------------------------------------------------
-- AIMBOT (Spectate/Lock Camera to role)
----------------------------------------------------------------
AimbotTab:AddSection({Name = "Default AimBot"})
local isCameraLocked = false
local isSpectating = false
local lockedRole = nil
local originalCameraType = Enum.CameraType.Custom
local originalCameraSubject = nil

AimbotTab:AddDropdown({
    Name = "Target Role",
    Default = "None",
    Options = {"None","Sheriff","Murderer"},
    Callback = function(sel) lockedRole = (sel ~= "None") and sel or nil end
})

AimbotTab:AddToggle({
    Name = "Spectate Mode",
    Default = false,
    Callback = function(s)
        isSpectating = s
        if s then
            originalCameraType = CurrentCamera.CameraType
            originalCameraSubject = CurrentCamera.CameraSubject
            CurrentCamera.CameraType = Enum.CameraType.Scriptable
        else
            CurrentCamera.CameraType = originalCameraType
            CurrentCamera.CameraSubject = originalCameraSubject
        end
    end
})

AimbotTab:AddToggle({
    Name = "Lock Camera",
    Default = false,
    Callback = function(s)
        isCameraLocked = s
        if (not s and not isSpectating) then
            CurrentCamera.CameraType = originalCameraType
            CurrentCamera.CameraSubject = originalCameraSubject
        end
    end
})

local function GetTargetPosition()
    if not lockedRole then return nil end
    local targetName = (lockedRole == "Sheriff") and Sheriff or Murder
    if not targetName then return nil end
    local p = Players:FindFirstChild(targetName)
    if not p or not IsAlive(p) then return nil end
    local char = p.Character; if not char then return nil end
    local head = char:FindFirstChild("Head")
    return head and head.Position or nil
end

local function UpdateSpectate()
    if not isSpectating or not lockedRole then return end
    local targetName = (lockedRole == "Sheriff") and Sheriff or Murder
    local target = targetName and Players:FindFirstChild(targetName) or nil
    if not target or not target.Character then return end
    local root = target.Character:FindFirstChild("HumanoidRootPart")
    if root then
        CurrentCamera.CFrame = root.CFrame * CFrame.new(0,2,8)
    end
end

local function UpdateLockCamera()
    if not isCameraLocked or not lockedRole then return end
    local tPos = GetTargetPosition()
    if not tPos then return end
    local cur = CurrentCamera.CFrame.Position
    CurrentCamera.CFrame = CFrame.new(cur, tPos)
end

RunService.RenderStepped:Connect(function()
    if isSpectating then UpdateSpectate()
    elseif isCameraLocked then UpdateLockCamera() end
end)

AimbotTab:AddSection({Name = "Silent Aimbot (On rework)"})

----------------------------------------------------------------
-- AUTOFARM (Coins)
----------------------------------------------------------------
local AutoFarm = {
    Enabled=false, Mode="Teleport", TeleportDelay=0, MoveSpeed=50, WalkSpeed=32,
    CoinCheckInterval=0.5,
    CoinContainers={"Factory","Hospital3","MilBase","House2","Workplace","Mansion2","BioLab","Hotel","Bank2","PoliceStation","ResearchFacility","Lobby"}
}

local function findNearestCoin()
    local closest, minDist = nil, math.huge
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    for _, containerName in ipairs(AutoFarm.CoinContainers) do
        local container = workspace:FindFirstChild(containerName)
        if container then
            local coinContainer = (containerName == "Lobby") and container or container:FindFirstChild("CoinContainer")
            if coinContainer then
                for _, coin in ipairs(coinContainer:GetChildren()) do
                    if coin:IsA("BasePart") then
                        local d = (hrp.Position - coin.Position).Magnitude
                        if d < minDist then minDist = d; closest = coin end
                    end
                end
            end
        end
    end
    return closest
end

local function teleportToCoin(coin)
    if not (coin and LocalPlayer.Character) then return end
    local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    hrp.CFrame = CFrame.new(coin.Position + Vector3.new(0,3,0))
    task.wait(AutoFarm.TeleportDelay)
end

local function smoothMoveToCoin(coin)
    if not (coin and LocalPlayer.Character) then return end
    local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local startTime = tick()
    local startPos = hrp.Position
    local endPos = coin.Position + Vector3.new(0,3,0)
    local distance = (startPos - endPos).Magnitude
    local duration = distance / AutoFarm.MoveSpeed
    while ((tick()-startTime) < duration) and AutoFarm.Enabled do
        if not coin or not coin.Parent then break end
        local progress = math.min((tick()-startTime)/duration, 1)
        hrp.CFrame = CFrame.new(startPos:Lerp(endPos, progress))
        task.wait()
    end
end

local function walkToCoin(coin)
    if not (coin and LocalPlayer.Character) then return end
    local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); if not hum then return end
    hum.WalkSpeed = AutoFarm.WalkSpeed
    hum:MoveTo(coin.Position + Vector3.new(0,0,3))
    local t0 = tick()
    while AutoFarm.Enabled and hum.MoveDirection.Magnitude > 0 and ((tick()-t0) < 10) do task.wait(0.5) end
end

local function collectCoin(coin)
    if not (coin and LocalPlayer.Character) then return end
    local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    firetouchinterest(hrp, coin, 0)
    firetouchinterest(hrp, coin, 1)
end

local function farmLoop()
    while AutoFarm.Enabled do
        local coin = findNearestCoin()
        if coin then
            if AutoFarm.Mode == "Teleport" then teleportToCoin(coin)
            elseif AutoFarm.Mode == "Smooth" then smoothMoveToCoin(coin)
            else walkToCoin(coin) end
            collectCoin(coin)
        else
            OrionLib:MakeNotification({Name="AutoFarm", Content="No coins found nearby!", Time=2})
            task.wait(2)
        end
        task.wait(AutoFarm.CoinCheckInterval)
    end
end

AutoFarmTab:AddSection({Name = "Coin Farming"})
AutoFarmTab:AddDropdown({
    Name = "Movement Mode",
    Default = "Teleport",
    Options = {"Teleport","Smooth","Walk"},
    Callback = function(mode) AutoFarm.Mode = mode; OrionLib:MakeNotification({Name="AutoFarm", Content="Mode set to: "..mode, Time=2}) end
})
AutoFarmTab:AddSlider({Name="Teleport Delay (sec)", Min=0, Max=1, Default=0, Increment=0.1, Callback=function(v) AutoFarm.TeleportDelay = v end})
AutoFarmTab:AddSlider({Name="Smooth Move Speed", Min=20, Max=200, Default=50, Callback=function(v) AutoFarm.MoveSpeed = v end})
AutoFarmTab:AddSlider({Name="Walk Speed", Min=16, Max=100, Default=32, Callback=function(v) AutoFarm.WalkSpeed = v end})
AutoFarmTab:AddSlider({Name="Check Interval (sec)", Min=0.1, Max=2, Default=0.5, Increment=0.1, Callback=function(v) AutoFarm.CoinCheckInterval = v end})
AutoFarmTab:AddToggle({
    Name = "Enable AutoFarm",
    Default = false,
    Callback = function(s)
        AutoFarm.Enabled = s
        if s then task.spawn(farmLoop); OrionLib:MakeNotification({Name="AutoFarm", Content="Started farming nearest coins!", Time=2})
        else OrionLib:MakeNotification({Name="AutoFarm", Content="Stopped farming coins", Time=2}) end
    end
})

----------------------------------------------------------------
-- GUN SYSTEM / INNOCENT
----------------------------------------------------------------
local GunSystem = { AutoGrabEnabled=false, GunDropCheckInterval=1, ActiveGunDrops={} }

local function ScanForGunDrops()
    GunSystem.ActiveGunDrops = {}
    for _, mapName in ipairs(mapPaths) do
        local map = workspace:FindFirstChild(mapName)
        if map then
            local gunDrop = map:FindFirstChild("GunDrop")
            if gunDrop then table.insert(GunSystem.ActiveGunDrops, gunDrop) end
        end
    end
    local rootGunDrop = workspace:FindFirstChild("GunDrop")
    if rootGunDrop then table.insert(GunSystem.ActiveGunDrops, rootGunDrop) end
end

local function EquipGun()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Gun") then return true end
    local gun = LocalPlayer.Backpack:FindFirstChild("Gun")
    if gun then gun.Parent = LocalPlayer.Character; task.wait(0.1); return (LocalPlayer.Character:FindFirstChild("Gun") ~= nil) end
    return false
end

local function GrabGun(gunDrop)
    if not gunDrop then
        ScanForGunDrops()
        if #GunSystem.ActiveGunDrops == 0 then
            OrionLib:MakeNotification({Name="Gun System", Content="No guns available on the map", Time=3})
            return false
        end
        local nearest, minDist = nil, math.huge
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            for _, drop in ipairs(GunSystem.ActiveGunDrops) do
                local d = (hrp.Position - drop.Position).Magnitude
                if d < minDist then minDist = d; nearest = drop end
            end
        end
        gunDrop = nearest
    end
    if gunDrop and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = gunDrop.CFrame
            task.wait(0.3)
            local prompt = gunDrop:FindFirstChildOfClass("ProximityPrompt")
            if prompt then
                fireproximityprompt(prompt)
                OrionLib:MakeNotification({Name="Gun System", Content="Successfully grabbed the gun!", Time=3})
                return true
            end
        end
    end
    return false
end

local function AutoGrabGun()
    while GunSystem.AutoGrabEnabled do
        ScanForGunDrops()
        if #GunSystem.ActiveGunDrops > 0 and LocalPlayer.Character then
            local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local nearest, minDist = nil, math.huge
                for _, drop in ipairs(GunSystem.ActiveGunDrops) do
                    local d = (hrp.Position - drop.Position).Magnitude
                    if d < minDist then minDist = d; nearest = drop end
                end
                if nearest then
                    hrp.CFrame = nearest.CFrame
                    task.wait(0.3)
                    local prompt = nearest:FindFirstChildOfClass("ProximityPrompt")
                    if prompt then fireproximityprompt(prompt); task.wait(1) end
                end
            end
        end
        task.wait(GunSystem.GunDropCheckInterval)
    end
end

local function GrabAndShootMurderer()
    if not (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Gun")) then
        if not GrabGun() then OrionLib:MakeNotification({Name="Gun System", Content="Failed to get gun!", Time=3}); return end
        task.wait(0.1)
    end
    if not EquipGun() then OrionLib:MakeNotification({Name="Gun System", Content="Failed to equip gun!", Time=3}); return end

    local data = safeInvokeGetPlayerData()
    local murdererName = nil
    for n, d in pairs(data) do if d.Role == "Murderer" then murdererName = n; break end end
    local murderer = murdererName and Players:FindFirstChild(murdererName) or nil
    if not (murderer and murderer.Character) then OrionLib:MakeNotification({Name="Gun System", Content="Murderer not found!", Time=3}); return end

    local tRoot = murderer.Character:FindFirstChild("HumanoidRootPart")
    local lRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if tRoot and lRoot then lRoot.CFrame = tRoot.CFrame * CFrame.new(0,0,-4); task.wait(0.1) end

    local gun = LocalPlayer.Character:FindFirstChild("Gun"); if not gun then OrionLib:MakeNotification({Name="Gun System", Content="Gun not equipped!", Time=3}); return end
    local targetPart = murderer.Character:FindFirstChild("HumanoidRootPart"); if not targetPart then return end
    if gun:FindFirstChild("KnifeLocal") and gun.KnifeLocal:FindFirstChild("CreateBeam") then
        local args = {[1]=1,[2]=targetPart.Position,[3]="AH2"}
        gun.KnifeLocal.CreateBeam.RemoteFunction:InvokeServer(unpack(args))
        OrionLib:MakeNotification({Name="Gun System", Content="Successfully shot the murderer!", Time=3})
    end
end

-- Innocent UI
InnocentTab:AddToggle({
    Name = "Auto Grab Gun",
    Default = false,
    Callback = function(state)
        GunSystem.AutoGrabEnabled = state
        if state then task.spawn(AutoGrabGun); OrionLib:MakeNotification({Name="Gun System", Content="Auto Grab Gun enabled!", Time=3})
        else OrionLib:MakeNotification({Name="Gun System", Content="Auto Grab Gun disabled", Time=3}) end
    end
})
InnocentTab:AddButton({Name="Grab Gun", Callback=function() GrabGun() end})
InnocentTab:AddButton({Name="Grab Gun & Shoot Murderer", Callback=function() GrabAndShootMurderer() end})

----------------------------------------------------------------
-- MURDER
----------------------------------------------------------------
local killActive = false
local attackDelay = 0.5
local targetRoles = {"Sheriff","Hero","Innocent"}

local function getPlayerRole(plr)
    local data = safeInvokeGetPlayerData()
    local r = data[plr.Name]; return r and r.Role or nil
end

local function equipKnife()
    local character = LocalPlayer.Character; if not character then return false end
    if character:FindFirstChild("Knife") then return true end
    local k = LocalPlayer.Backpack:FindFirstChild("Knife")
    if k then k.Parent = character; return true end
    return false
end

local function getNearestTarget()
    local candidates = {}
    local data = safeInvokeGetPlayerData()
    local lRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not lRoot then return nil end
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LocalPlayer and pl.Character then
            local role = getPlayerRole(pl)
            local hum = pl.Character:FindFirstChild("Humanoid")
            local tRoot = pl.Character:FindFirstChild("HumanoidRootPart")
            if role and hum and hum.Health > 0 and tRoot and table.find(targetRoles, role) then
                table.insert(candidates, {Player=pl, Distance=(lRoot.Position - tRoot.Position).Magnitude})
            end
        end
    end
    table.sort(candidates, function(a,b) return a.Distance < b.Distance end)
    return candidates[1] and candidates[1].Player or nil
end

local function attackTarget(target)
    if not (target and target.Character) then return false end
    local hum = target.Character:FindFirstChild("Humanoid"); if not hum or hum.Health <= 0 then return false end
    if not equipKnife() then OrionLib:MakeNotification({Name="Kill Targets", Content="No knife found!", Time=2}); return false end
    local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
    local lRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if tRoot and lRoot then
        lRoot.CFrame = CFrame.new(tRoot.Position + ((lRoot.Position - tRoot.Position).Unit * 2), tRoot.Position)
    end
    local knife = LocalPlayer.Character:FindFirstChild("Knife")
    if knife and knife:FindFirstChild("Stab") then
        for i=1,3 do knife.Stab:FireServer("Down") end
        return true
    end
    return false
end

local function killTargets()
    if killActive then return end
    killActive = true
    OrionLib:MakeNotification({Name="Kill Targets", Content="Starting attack on nearest targets...", Time=2})
    task.spawn(function()
        while killActive do
            local t = getNearestTarget()
            if not t then
                OrionLib:MakeNotification({Name="Kill Targets", Content="No valid targets found!", Time=3})
                killActive = false
                break
            end
            if attackTarget(t) then
                OrionLib:MakeNotification({Name="Kill Targets", Content="Attacked "..t.Name, Time=1})
            end
            task.wait(attackDelay)
        end
    end)
end

local function stopKilling()
    killActive = false
    OrionLib:MakeNotification({Name="Kill Targets", Content="Attack sequence stopped", Time=2})
end

MurderTab:AddSection({Name="Kill Functions"})
MurderTab:AddToggle({Name="Kill All", Default=false, Callback=function(s) if s then killTargets() else stopKilling() end end})
MurderTab:AddSlider({Name="Attack Delay", Min=0.1, Max=2, Default=0.5, Increment=0.1, Callback=function(v) attackDelay = v; OrionLib:MakeNotification({Name="Kill Targets", Content="Delay set to "..v.."s", Time=2}) end})
MurderTab:AddButton({Name="Equip Knife", Callback=function() if equipKnife() then OrionLib:MakeNotification({Name="Knife", Content="Knife equipped!", Time=2}) else OrionLib:MakeNotification({Name="Knife", Content="No knife found!", Time=2}) end end})

----------------------------------------------------------------
-- SHERIFF
----------------------------------------------------------------
local shotType = "Default"
local buttonSize = 50
local shotButton, shotButtonFrame

local function RemoveShotButton()
    if shotButton then shotButton:Destroy(); shotButton = nil end
    if shotButtonFrame then shotButtonFrame:Destroy(); shotButtonFrame = nil end
    local screenGui = game:GetService("CoreGui"):FindFirstChild("DogHub_SheriffGui")
    if screenGui then screenGui:Destroy() end
    OrionLib:MakeNotification({Name="Shot Button", Content="Deactivated", Time=3})
end

local function CreateShotButton()
    if shotButton then return end
    local screenGui = game:GetService("CoreGui"):FindFirstChild("DogHub_SheriffGui") or Instance.new("ScreenGui")
    screenGui.Name = "DogHub_SheriffGui"
    screenGui.Parent = game:GetService("CoreGui")
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = 999
    screenGui.IgnoreGuiInset = true

    shotButtonFrame = Instance.new("Frame")
    shotButtonFrame.Name = "ShotButtonFrame"
    shotButtonFrame.Size = UDim2.new(0, buttonSize, 0, buttonSize)
    shotButtonFrame.Position = UDim2.new(1, -buttonSize - 20, 0.5, -buttonSize/2)
    shotButtonFrame.AnchorPoint = Vector2.new(1, 0.5)
    shotButtonFrame.BackgroundTransparency = 1
    shotButtonFrame.ZIndex = 100

    shotButton = Instance.new("TextButton")
    shotButton.Name = "SheriffShotButton"
    shotButton.Size = UDim2.new(1, 0, 1, 0)
    shotButton.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
    shotButton.BackgroundTransparency = 0.5
    shotButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    shotButton.Text = "SHOT"
    shotButton.TextScaled = true
    shotButton.Font = Enum.Font.GothamBold
    shotButton.BorderSizePixel = 0
    shotButton.ZIndex = 101

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 40, 150)
    stroke.Thickness = 2
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Transparency = 0.3
    stroke.Parent = shotButton

    local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0.3, 0); corner.Parent = shotButton

    local function animatePress()
        local TweenService = game:GetService("TweenService")
        local pressDown = TweenService:Create(shotButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0.9,0,0.9,0)})
        local pressUp   = TweenService:Create(shotButton, TweenInfo.new(0.2, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {Size = UDim2.new(1,0,1,0)})
        pressDown:Play(); pressDown.Completed:Wait(); pressUp:Play()
    end

    shotButton.MouseButton1Click:Connect(function()
        animatePress()
        local data = safeInvokeGetPlayerData()
        local murdererName = nil; for n, d in pairs(data) do if d.Role == "Murderer" then murdererName = n; break end end
        local murderer = murdererName and Players:FindFirstChild(murdererName) or nil
        if not (murderer and murderer.Character and murderer.Character:FindFirstChild("Humanoid") and murderer.Character.Humanoid.Health > 0) then return end

        local gun = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Gun") or LocalPlayer.Backpack:FindFirstChild("Gun")
        if shotType == "Default" and not gun then return end
        if gun and not (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Gun")) then gun.Parent = LocalPlayer.Character end

        if shotType == "Teleport" then
            local tRoot = murderer.Character:FindFirstChild("HumanoidRootPart")
            local lRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if tRoot and lRoot then lRoot.CFrame = tRoot.CFrame * CFrame.new(0,0,-4) end
        end

        gun = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Gun")
        if gun and gun:FindFirstChild("KnifeLocal") then
            local targetPart = murderer.Character:FindFirstChild("HumanoidRootPart")
            if targetPart then
                local args = {[1] = 10, [2] = targetPart.Position, [3] = "AH2"}
                gun.KnifeLocal.CreateBeam.RemoteFunction:InvokeServer(unpack(args))
            end
        end
    end)

    shotButton.Parent = shotButtonFrame
    shotButtonFrame.Parent = screenGui
    OrionLib:MakeNotification({Name="Sheriff System", Content="Shot button activated", Time=3})
end

local function ShootMurderer()
    local data = safeInvokeGetPlayerData()
    local murdererName = nil; for n, d in pairs(data) do if d.Role == "Murderer" then murdererName = n; break end end
    local murderer = murdererName and Players:FindFirstChild(murdererName) or nil
    if not (murderer and murderer.Character and murderer.Character:FindFirstChild("Humanoid") and murderer.Character.Humanoid.Health > 0) then return end

    local gun = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Gun") or LocalPlayer.Backpack:FindFirstChild("Gun")
    if shotType == "Default" and not gun then return end
    if gun and not (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Gun")) then gun.Parent = LocalPlayer.Character end

    if shotType == "Teleport" then
        local tRoot = murderer.Character:FindFirstChild("HumanoidRootPart")
        local lRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if tRoot and lRoot then lRoot.CFrame = tRoot.CFrame * CFrame.new(0,0,-4) end
    end

    gun = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Gun")
    if gun and gun:FindFirstChild("KnifeLocal") then
        local targetPart = murderer.Character:FindFirstChild("HumanoidRootPart")
        if targetPart then
            local args = {[1] = 1, [2] = targetPart.Position, [3] = "AH2"}
            gun.KnifeLocal.CreateBeam.RemoteFunction:InvokeServer(unpack(args))
        end
    end
end

SheriffTab:AddSection({Name="Shot functions"})
SheriffTab:AddDropdown({
    Name="Shot Type",
    Default="Default",
    Options={"Default","Teleport"},
    Callback=function(sel) shotType = sel; OrionLib:MakeNotification({Name="Sheriff System", Content="Shot Type: "..sel, Time=3}) end
})
SheriffTab:AddButton({Name="Shoot murderer", Callback=function() ShootMurderer() end})
SheriffTab:AddSection({Name="Shot Button"})
SheriffTab:AddButton({Name="Toggle Shot Button", Callback=function()
    if shotButton then RemoveShotButton() else CreateShotButton() end
end})
SheriffTab:AddSlider({Name="Button Size", Min=10, Max=100, Default=50, Increment=1, Callback=function(size)
    buttonSize = size
    if shotButtonFrame then
        local currentPos = shotButtonFrame.Position
        RemoveShotButton()
        CreateShotButton()
        if shotButtonFrame then shotButtonFrame.Position = currentPos end
    end
    OrionLib:MakeNotification({Name="Sheriff System", Content="Size: "..size, Time=2})
end})

----------------------------------------------------------------
-- SETTINGS (Hitboxes / Noclip / Anti-AFK / Auto-Inject)
----------------------------------------------------------------
local Settings = {
    Hitbox = {Enabled=false, Size=5, Color=Color3.new(1,0,0), Adornments={}},
    Noclip = {Enabled=false, Connection=nil},
    AntiAFK = {Enabled=false, Connection=nil},
    AutoInject = {Enabled=false, ScriptURL="https://raw.githubusercontent.com/Snowt-Team/KRT-HUB/refs/heads/main/MM2.txt"}
}

local function UpdateHitboxes()
    for _, pl in pairs(Players:GetPlayers()) do
        if pl ~= LocalPlayer then
            local chr = pl.Character
            local box = Settings.Hitbox.Adornments[pl]
            if chr and Settings.Hitbox.Enabled then
                local root = chr:FindFirstChild("HumanoidRootPart")
                if root then
                    if not box then
                        box = Instance.new("BoxHandleAdornment")
                        box.Adornee = root
                        box.Size = Vector3.new(Settings.Hitbox.Size, Settings.Hitbox.Size, Settings.Hitbox.Size)
                        box.Color3 = Settings.Hitbox.Color
                        box.Transparency = 0.4
                        box.ZIndex = 10
                        box.Parent = root
                        Settings.Hitbox.Adornments[pl] = box
                    else
                        box.Size = Vector3.new(Settings.Hitbox.Size, Settings.Hitbox.Size, Settings.Hitbox.Size)
                        box.Color3 = Settings.Hitbox.Color
                    end
                end
            elseif box then
                box:Destroy()
                Settings.Hitbox.Adornments[pl] = nil
            end
        end
    end
end

local function ToggleNoclip(state)
    if state then
        Settings.Noclip.Connection = RunService.Stepped:Connect(function()
            local chr = LocalPlayer.Character
            if chr then
                for _, part in pairs(chr:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    else
        if Settings.Noclip.Connection then Settings.Noclip.Connection:Disconnect() end
    end
end

local function ToggleAntiAFK(state)
    if state then
        Settings.AntiAFK.Connection = RunService.Heartbeat:Connect(function()
            pcall(function()
                local vu = game:GetService("VirtualUser")
                vu:CaptureController()
                vu:ClickButton2(Vector2.new())
            end)
        end)
    else
        if Settings.AntiAFK.Connection then Settings.AntiAFK.Connection:Disconnect() end
    end
end

local function SetupAutoInject()
    if not Settings.AutoInject.Enabled then return end
    task.spawn(function()
        task.wait(2)
        if Settings.AutoInject.Enabled then
            pcall(function() loadstring(game:HttpGet(Settings.AutoInject.ScriptURL))() end)
        end
    end)
    LocalPlayer.OnTeleport:Connect(function(state)
        if state == Enum.TeleportState.Started and Settings.AutoInject.Enabled then
            queue_on_teleport([[
                wait(2)
                loadstring(game:HttpGet("]]..Settings.AutoInject.ScriptURL..[[", true))()
            ]])
        end
    end)
end

SettingsTab:AddSection({Name="Hitboxes"})
SettingsTab:AddToggle({Name="Hitboxes", Default=false, Callback=function(s) Settings.Hitbox.Enabled = s; if s then RunService.Heartbeat:Connect(UpdateHitboxes) else for _,b in pairs(Settings.Hitbox.Adornments) do if b then b:Destroy() end end Settings.Hitbox.Adornments = {} end end})
SettingsTab:AddSlider({Name="Hitbox size", Min=1, Max=10, Default=5, Callback=function(v) Settings.Hitbox.Size = v; UpdateHitboxes() end})
SettingsTab:AddColorpicker({Name="Hitbox color", Default=Color3.new(1,0,0), Callback=function(col) Settings.Hitbox.Color = col; UpdateHitboxes() end})

SettingsTab:AddSection({Name="Character Functions"})
SettingsTab:AddToggle({Name="Anti-AFK", Default=false, Callback=function(s) Settings.AntiAFK.Enabled = s; ToggleAntiAFK(s) end})
SettingsTab:AddToggle({Name="NoClip",  Default=false, Callback=function(s) Settings.Noclip.Enabled = s; ToggleNoclip(s) end})

SettingsTab:AddSection({Name="Auto Inject"})
SettingsTab:AddToggle({
    Name="Auto Inject on Rejoin/Hop",
    Default=false,
    Callback=function(s)
        Settings.AutoInject.Enabled = s
        if s then
            SetupAutoInject()
            OrionLib:MakeNotification({Name="Auto Inject", Content="Auto-inject enabled! Script will restart automatically.", Time=3})
        else
            OrionLib:MakeNotification({Name="Auto Inject", Content="Auto-inject disabled", Time=3})
        end
    end
})
SettingsTab:AddButton({Name="Manual Re-Inject", Callback=function()
    pcall(function()
        loadstring(game:HttpGet(Settings.AutoInject.ScriptURL))()
        OrionLib:MakeNotification({Name="Manual Inject", Content="Script reloaded successfully!", Time=3})
    end)
end})

----------------------------------------------------------------
-- SERVER
----------------------------------------------------------------
ServerTab:AddButton({Name="Rejoin", Callback=function()
    pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end)
end})

ServerTab:AddButton({Name="Server Hop", Callback=function()
    local placeId = game.PlaceId
    local currentJobId = game.JobId
    local function serverHop()
        local servers = {}
        local ok, result = pcall(function()
            return HttpService:JSONDecode(HttpService:GetAsync("https://games.roblox.com/v1/games/"..placeId.."/servers/Public?sortOrder=Asc&limit=100"))
        end)
        if ok and result and result.data then
            for _, server in ipairs(result.data) do
                if server.id ~= currentJobId then table.insert(servers, server) end
            end
            if #servers > 0 then
                TeleportService:TeleportToPlaceInstance(placeId, servers[math.random(#servers)].id)
            else
                TeleportService:Teleport(placeId)
            end
        else
            TeleportService:Teleport(placeId)
        end
    end
    pcall(serverHop)
end})

ServerTab:AddButton({Name="Join Lower Server", Callback=function()
    local placeId = game.PlaceId
    local currentJobId = game.JobId
    local function joinLowerServer()
        local servers = {}
        local ok, result = pcall(function()
            return HttpService:JSONDecode(HttpService:GetAsync("https://games.roblox.com/v1/games/"..placeId.."/servers/Public?sortOrder=Asc&limit=100"))
        end)
        if ok and result and result.data then
            for _, srv in ipairs(result.data) do
                if srv.id ~= currentJobId and srv.playing < (srv.maxPlayers or 30) then
                    table.insert(servers, srv)
                end
            end
            table.sort(servers, function(a,b) return a.playing < b.playing end)
            if #servers > 0 then
                TeleportService:TeleportToPlaceInstance(placeId, servers[1].id)
            else
                TeleportService:Teleport(placeId)
            end
        else
            TeleportService:Teleport(placeId)
        end
    end
    pcall(joinLowerServer)
end})

----------------------------------------------------------------
-- SOCIALS
----------------------------------------------------------------
SocialsTab:AddParagraph("Dog Hub", "My socials")
SocialsTab:AddButton({
    Name="Dog Hub TG",
    Callback=function()
        if pcall(setclipboard, "https://t.me/KRT_client") then
            OrionLib:MakeNotification({Name="Copied!", Content="Link copied to clipboard.", Time=3})
        else
            OrionLib:MakeNotification({Name="Copy error", Content="Failed to copy link. setclipboard might be unavailable.", Time=5})
        end
    end
})
SocialsTab:AddParagraph("Kawasaki", "Socials My Friend")
SocialsTab:AddButton({
    Name="TG Channel",
    Callback=function()
        if pcall(setclipboard, "https://t.me/+XFKScmKEPS41OWQ1") then
            OrionLib:MakeNotification({Name="Copied!", Content="Link copied to clipboard.", Time=3})
        else
            OrionLib:MakeNotification({Name="Copy error", Content="Failed to copy link. setclipboard might be unavailable.", Time=5})
        end
    end
})

----------------------------------------------------------------
-- CHANGELOGS
----------------------------------------------------------------
ChangelogsTab:AddParagraph("Changelogs", [[
• Silent Aimbot
• Sheriff functions (+variants: default/teleport)
• Improved shots
• Murder functions (Kill All, fix kill player)
• Innocent functions (Grab Gun, Auto Grab, Grab & Shoot)
• GunDrop notifications/highlight
• Autofarm Money (Teleport/Smooth/Walk)
• Teleport to Lobby
• Fixes and notifications
]])

ChangelogsTab:AddParagraph("Next", [[
Next update: v1.1
• Autofarm rare eggs
• Bug fixes
• New ESP (tracers, names, highlights, more)
• Gun variables (TP to gun; bring gun)
]])

-- Init
OrionLib:Init()
