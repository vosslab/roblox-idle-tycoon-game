local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local AutoSwingDoors = {}

local constants = nil
local doors = {}
local checkInterval = 0.2
local defaultDistance = 8

local function getDoorCFrame(door, name)
  local value = door:GetAttribute(name)
  if typeof(value) == "CFrame" then
    return value
  end
  return nil
end

local function getAutoDistance(door)
  local value = door:GetAttribute("AutoDistance")
  if typeof(value) == "number" and value > 0 then
    return value
  end
  return defaultDistance
end

local function hasNearbyPlayer(door)
  local doorPos = door.Position
  local distance = getAutoDistance(door)
  for _, player in ipairs(Players:GetPlayers()) do
    local character = player.Character
    if character then
      local hrp = character:FindFirstChild("HumanoidRootPart")
      if hrp then
        if (hrp.Position - doorPos).Magnitude <= distance then
          return true
        end
      end
    end
  end
  return false
end

local function ensureDoor(door)
  if not door or not door:IsA("BasePart") then
    return
  end

  if door:GetAttribute("IsOpen") == nil then
    door:SetAttribute("IsOpen", false)
  end
  if not getDoorCFrame(door, "ClosedCFrame") then
    door:SetAttribute("ClosedCFrame", door.CFrame)
  end

  doors[door] = {
    busy = false,
  }
end

local function tweenDoor(door, targetCFrame, openState)
  local state = doors[door]
  if not state or state.busy then
    return
  end
  state.busy = true

  local tween = TweenService:Create(
    door,
    TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    { CFrame = targetCFrame }
  )
  tween:Play()
  tween.Completed:Once(function()
    door:SetAttribute("IsOpen", openState)
    state.busy = false
  end)
end

function AutoSwingDoors.Init(constantsModule)
  constants = constantsModule
  if not constants or not constants.TAGS then
    return
  end

  for _, door in ipairs(CollectionService:GetTagged(constants.TAGS.AutoSwingDoor)) do
    ensureDoor(door)
  end

  CollectionService:GetInstanceAddedSignal(constants.TAGS.AutoSwingDoor):Connect(function(door)
    ensureDoor(door)
  end)

  local accumulator = 0
  RunService.Heartbeat:Connect(function(dt)
    accumulator += dt
    if accumulator < checkInterval then
      return
    end
    accumulator = 0

    for door in pairs(doors) do
      if door and door.Parent then
        local shouldOpen = hasNearbyPlayer(door)
        local isOpen = door:GetAttribute("IsOpen") == true
        if shouldOpen ~= isOpen then
          local target = shouldOpen and getDoorCFrame(door, "OpenCFrame")
            or getDoorCFrame(door, "ClosedCFrame")
          if target then
            tweenDoor(door, target, shouldOpen)
          end
        end
      end
    end
  end)
end

return AutoSwingDoors
