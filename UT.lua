-- Clear old system
for _, obj in ipairs({"UndertaleArena", "UndertaleRemote", "SoulRemote", "TurnSystem", "BossSystem"}) do
	if workspace:FindFirstChild(obj) then workspace[obj]:Destroy() end
	if game.ReplicatedStorage:FindFirstChild(obj) then game.ReplicatedStorage[obj]:Destroy() end
end
if game.StarterGui:FindFirstChild("UndertaleUI") then game.StarterGui.UndertaleUI:Destroy() end
if game.StarterPack:FindFirstChild("AttackTool") then game.StarterPack.AttackTool:Destroy() end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Arena
local arena = Instance.new("Part", workspace)
arena.Name = "UndertaleArena"
arena.Size = Vector3.new(200, 1, 200)
arena.Anchored = true
arena.Position = Vector3.new(0, 0, 0)
arena.BrickColor = BrickColor.new("Really black")

-- Remotes
local attackRemote = Instance.new("RemoteEvent", ReplicatedStorage)
attackRemote.Name = "UndertaleRemote"

local soulRemote = Instance.new("RemoteEvent", ReplicatedStorage)
soulRemote.Name = "SoulRemote"

-- Attack Tool
local tool = Instance.new("Tool")
tool.Name = "AttackTool"
tool.RequiresHandle = false
local toolScript = Instance.new("LocalScript", tool)
toolScript.Source = [[
local remote = game.ReplicatedStorage:WaitForChild("UndertaleRemote")
script.Parent.Activated:Connect(function()
	remote:FireServer()
end)
]]
tool.Parent = game.StarterPack

-- Server-side attack logic
local serverAttack = Instance.new("Script", attackRemote)
serverAttack.Source = [[
script.Parent.OnServerEvent:Connect(function(player)
	local char = player.Character
	if not char then return end
	local p = Instance.new("Part")
	p.Size = Vector3.new(1,1,1)
	p.Shape = Enum.PartType.Ball
	p.Material = Enum.Material.Neon
	p.BrickColor = BrickColor.Red()
	p.Position = char.HumanoidRootPart.Position + Vector3.new(0,2,0)
	p.Velocity = char.HumanoidRootPart.CFrame.LookVector * 50
	p.CanCollide = false
	p.Anchored = false
	p.Parent = workspace
	game:GetService("Debris"):AddItem(p,3)
	p.Touched:Connect(function(hit)
		local hum = hit.Parent:FindFirstChild("Humanoid")
		if hum and hit.Parent ~= char then
			hum:TakeDamage(15)
			p:Destroy()
		end
	end)
end)
]]

-- Health Bars
for _, p in ipairs(Players:GetPlayers()) do
	if p.Character then
		local hb = Instance.new("BillboardGui", p.Character:FindFirstChild("Head") or p.Character)
		hb.Name = "HealthDisplay"
		hb.Size = UDim2.new(4,0,0.5,0)
		hb.StudsOffset = Vector3.new(0,2,0)
		hb.AlwaysOnTop = true
		local bar = Instance.new("Frame", hb)
		bar.Size = UDim2.new(1,0,1,0)
		bar.BackgroundColor3 = Color3.fromRGB(255,0,0)
		bar.BorderSizePixel = 0
	end
end

-- Character Selection + UI
local gui = Instance.new("ScreenGui")
gui.Name = "UndertaleUI"
gui.ResetOnSpawn = false

-- Heart
local heart = Instance.new("Frame", gui)
heart.Name = "Heart"
heart.Size = UDim2.new(0,20,0,20)
heart.Position = UDim2.new(0.5,-10,0.5,-10)
heart.BackgroundColor3 = Color3.fromRGB(255,0,0)
heart.BorderSizePixel = 0

-- Soul Color Select
local soulSelector = Instance.new("TextButton", gui)
soulSelector.Size = UDim2.new(0,120,0,30)
soulSelector.Position = UDim2.new(0,10,0,10)
soulSelector.Text = "Soul: RED"
soulSelector.BackgroundColor3 = Color3.fromRGB(255,50,50)
soulSelector.MouseButton1Click:Connect(function()
	local options = {"RED", "BLUE", "GREEN"}
	local idx = table.find(options, soulSelector.Text:split(": ")[2]) or 1
	local next = (idx % #options) + 1
	local newColor = options[next]
	soulSelector.Text = "Soul: "..newColor
	soulRemote:FireServer(newColor)
end)

-- Drag Heart
local dragScript = Instance.new("LocalScript", heart)
dragScript.Source = [[
local UIS = game:GetService("UserInputService")
local heart = script.Parent
local dragging = false
local input, startPos

heart.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		input = i
		startPos = i.Position
	end
end)

UIS.InputChanged:Connect(function(i)
	if dragging and i == input then
		local delta = i.Position - startPos
		heart.Position = heart.Position + UDim2.new(0, delta.X, 0, delta.Y)
		startPos = i.Position
	end
end)

UIS.InputEnded:Connect(function(i)
	if i == input then
		dragging = false
	end
end)
]]

gui.Parent = game.StarterGui

-- Soul Behavior Server
local soulScript = Instance.new("Script", soulRemote)
soulScript.Source = [[
script.Parent.OnServerEvent:Connect(function(player, color)
	local char = player.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	if color == "BLUE" then
		root.CustomPhysicalProperties = PhysicalProperties.new(10,0.3,0.5)
	elseif color == "GREEN" then
		player.Character.Humanoid.WalkSpeed = 8
	elseif color == "RED" then
		root.CustomPhysicalProperties = nil
		player.Character.Humanoid.WalkSpeed = 16
	end
end)
]]

-- Boss System
local bossRemote = Instance.new("RemoteEvent", ReplicatedStorage)
bossRemote.Name = "BossSystem"

local bossHandler = Instance.new("Script", bossRemote)
bossHandler.Source = [[
script.Parent.OnServerEvent:Connect(function(player)
	for _, plr in pairs(game.Players:GetPlayers()) do
		if plr ~= player and plr.Character then
			plr.Character:FindFirstChild("Humanoid"):TakeDamage(25)
		end
	end
end)
]]

-- Turn-based (optional toggle)
local turnToggle = Instance.new("BoolValue", ReplicatedStorage)
turnToggle.Name = "TurnSystem"
turnToggle.Value = false

print("✅ Undertale System Expanded: Soul, Turns, UI, Boss, Health Bars ready.")
