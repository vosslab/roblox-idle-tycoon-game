-- PlaygroundBootstrap.server.lua
-- Failsafe builder for the playground if the main entrypoint doesn't run.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function buildPlayground()
  local shared = ReplicatedStorage:WaitForChild("Shared")
  local _ = require(shared:WaitForChild("Constants"))

  local WorldBuilder = require(script.Parent.World.WorldBuilder)
  local baseplate, homeSpawn = WorldBuilder.ensureBaseplateAndSpawn()
  WorldBuilder.ensurePlayground(baseplate, homeSpawn)
end

local ok, err = pcall(buildPlayground)
if not ok then
  warn("[PlaygroundBootstrap] Failed to build playground:", err)
end
