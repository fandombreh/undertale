-- Cleanup
for _, name in ipairs({"UndertaleArena", "SoulRemote", "UndertaleUI", "AttackTool", "SoulColor", "CharacterSelect", "HealthUpdater"}) do
	if workspace:FindFirstChild(name) then workspace[name]:Destroy() end
	if game.ReplicatedStorage:FindFirstChild(name) then game.ReplicatedStorage[name]:Destroy() end
	if game.StarterGui:FindFirstChild(name) then game.StarterGui[name]:Destroy() end
	if game.StarterPack:FindFirstChild(name) then game.StarterPack[name]:Destroy() end
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Arena
local arena = Instance.new("Part", workspace)
arena.Name = "UndertaleArena"
arena.Size = Vector3.new(200, 1, 200)
arena.Position = Vector3.new(0, 0, 0)
arena.Anchored = true
arena.BrickColor = BrickColor.new("Really black")

-- Remote for SoulColor
local soulRemote = Instance.new("RemoteEvent", ReplicatedStorage)
soulRemote.Name = "SoulRemote"

-- Attack Tool
local tool = Instance.new("Tool")
tool.Name = "AttackTool"
tool.RequiresHandle = false

local toolScript = Instance.new("LocalScript", tool)
toolScript.Source = [[
local remote = game.ReplicatedStorage:WaitForChild("SoulRemote")
script.Parent.Activated:Connect(function()
	remote:FireServer("Shoot")
end)
]]

tool.Parent = game.StarterPack

-- Soul Remote Handler
local soulHandler = Instance.new("Script", soulRemote)
soulHandler.Name = "SoulColor"
soulHandler.Source = [[
script.Parent.OnServerEvent:Connect(function(player, mode)
	if mode == "Shoot" then
		local char = player.Character
		if not char then return end
		local part = Instance.new("Part")
		part.Size = Vector3.new(1,1,1)
		part.Shape = Enum.PartType.Ball
		part.Material = Enum.Material.Neon
		part.BrickColor = BrickColor.Red()
		part.Position = char.HumanoidRootPart.Position + Vector3.new(0,2,0)
		part.Velocity = char.HumanoidRootPart.CFrame.LookVector * 60
		part.CanCollide = false
		part.Anchored = false
		part.Parent = workspace
		game:GetService("Debris"):AddItem(part, 3)

		part.Touched:Connect(function(hit)
			local hum = hit.Parent and hit.Parent:FindFirstChild("Humanoid")
			if hum and hit.Parent ~= char then
				hum:TakeDamage(25)
				part:Destroy()
			end
		end)
	end
end)
]]

soulHandler.Parent = ReplicatedStorage

-- Health Bar Updater
for _, player in pairs(Players:GetPlayers()) do
	local char = player.Character
	if char then
		local gui = Instance.new("BillboardGui", char:FindFirstChild("Head") or char)
		gui.Size = UDim2.new(4,0,0.5,0)
		gui.StudsOffset = Vector3.new(0,2,0)
		gui.AlwaysOnTop = true
		gui.Name = "HealthUpdater"

		local bar = Instance.new("Frame", gui)
		bar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
		bar.Size = UDim2.new(1, 0, 1, 0)
		bar.BorderSizePixel = 0

		local updateScript = Instance.new("LocalScript", bar)
		updateScript.Source = [[
		local player = game.Players.LocalPlayer
		local char = player.Character or player.CharacterAdded:Wait()
		local hum = char:WaitForChild("Humanoid")
		local bar = script.Parent
		hum.HealthChanged:Connect(function()
			bar.Size = UDim2.new(hum.Health / hum.MaxHealth, 0, 1, 0)
		end)
		]]
	end
end

-- UI Setup
local gui = Instance.new("ScreenGui", game.StarterGui)
gui.Name = "UndertaleUI"

-- Soul Button
local soulBtn = Instance.new("TextButton", gui)
soulBtn.Size = UDim2.new(0, 130, 0, 30)
soulBtn.Position = UDim2.new(0, 10, 0, 10)
soulBtn.Text = "Soul: RED"
soulBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)

local soulScript = Instance.new("LocalScript", soulBtn)
soulScript.Source = [[
local btn = script.Parent
local player = game.Players.LocalPlayer
local rem = game.ReplicatedStorage:WaitForChild("SoulRemote")
local colors = {"RED", "BLUE", "GREEN", "PURPLE"}
local i = 1

btn.MouseButton1Click:Connect(function()
	i = (i % #colors) + 1
	local color = colors[i]
	btn.Text = "Soul: "..color
	if color == "RED" then
		btn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	elseif color == "BLUE" then
		btn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
	elseif color == "GREEN" then
		btn.BackgroundColor3 = Color3.fromRGB(0,255,0)
	elseif color == "PURPLE" then
		btn.BackgroundColor3 = Color3.fromRGB(170,0,255)
	end
	rem:FireServer(color)
end)
]]

-- Server-side soul color behavior
soulRemote.OnServerEvent:Connect(function(player, color)
	if color == "RED" then
		player.Character.Humanoid.WalkSpeed = 16
		player.Character.Humanoid.JumpPower = 50
	elseif color == "BLUE" then
		player.Character.Humanoid.WalkSpeed = 6
		player.Character.Humanoid.JumpPower = 100
	elseif color == "GREEN" then
		player.Character.Humanoid.WalkSpeed = 12
		player.Character.Humanoid.JumpPower = 30
	elseif color == "PURPLE" then
		player.Character.Humanoid.WalkSpeed = 8
		player.Character.Humanoid.JumpPower = 70
	end
end)

print("✅ Undertale PvP system: Soul UI, attacks, health bars, arena, and movement logic ready.")
