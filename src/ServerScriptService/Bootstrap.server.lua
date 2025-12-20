-- Bootstrap.server.lua
-- Minimal safety net so players always have ground even if other scripts fail.

local baseplate = workspace:FindFirstChild("Baseplate")
if baseplate and not baseplate:IsA("BasePart") then
  baseplate.Name = "Baseplate_Unexpected"
  baseplate = nil
end

if not baseplate then
  baseplate = Instance.new("Part")
  baseplate.Name = "Baseplate"
  baseplate.Parent = workspace
end

baseplate.Anchored = true
baseplate.Size = Vector3.new(512, 10, 512)
baseplate.Position = Vector3.new(0, -5, 0)
baseplate.Material = Enum.Material.Grass
baseplate.BrickColor = BrickColor.new("Medium green")

local spawn = workspace:FindFirstChild("HomeSpawn")
if spawn and not spawn:IsA("SpawnLocation") then
  spawn.Name = "HomeSpawn_Unexpected"
  spawn = nil
end

if not spawn then
  spawn = Instance.new("SpawnLocation")
  spawn.Name = "HomeSpawn"
  spawn.Parent = workspace
end

spawn.Anchored = true
local topY = baseplate.Position.Y + (baseplate.Size.Y / 2)
spawn.Position = Vector3.new(0, topY + 3, 0)
