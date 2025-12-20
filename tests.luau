local roblox = require("@lune/roblox")
local fs = require("@lune/fs")
local path = require("@lune/path")

local Instance = roblox.Instance
local game = roblox.game

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local function isModuleFile(fileName)
  if fileName:match("%.server%.lua$") or fileName:match("%.client%.lua$") then
    return false
  end
  return fileName:match("%.lua$") or fileName:match("%.luau$")
end

local function importDir(srcDir, parent)
  for _, entry in ipairs(fs.readDir(srcDir)) do
    local fullPath = path.join(srcDir, entry)
    if fs.isDir(fullPath) then
      local folder = Instance.new("Folder")
      folder.Name = entry
      folder.Parent = parent
      importDir(fullPath, folder)
    elseif isModuleFile(entry) then
      local module = Instance.new("ModuleScript")
      module.Name = entry:gsub("%.luau$", ""):gsub("%.lua$", "")
      module.Source = fs.readFile(fullPath)
      module.Parent = parent
    end
  end
end

local function ensureFolder(parent, name)
  local folder = parent:FindFirstChild(name)
  if not folder then
    folder = Instance.new("Folder")
    folder.Name = name
    folder.Parent = parent
  end
  return folder
end

local replicatedShared = ensureFolder(ReplicatedStorage, "Shared")
importDir("src/ReplicatedStorage/Shared", replicatedShared)

local testezFolder = ensureFolder(ReplicatedStorage, "TestEZ")
importDir("src/ReplicatedStorage/TestEZ", testezFolder)

local questsFolder = ensureFolder(ServerScriptService, "Quests")
importDir("src/ServerScriptService/Quests", questsFolder)

local economyFolder = ensureFolder(ServerScriptService, "Economy")
importDir("src/ServerScriptService/Economy", economyFolder)

local TestEZ = require(testezFolder)
local testsRoot = questsFolder:FindFirstChild("__tests__")
assert(testsRoot, "No __tests__ folder found under ServerScriptService/Quests")

TestEZ.run(testsRoot, function(results)
  TestEZ.Reporters.TextReporter.report(results)
  if results.failureCount > 0 or #results.errors > 0 then
    error("Tests failed")
  end
end)
