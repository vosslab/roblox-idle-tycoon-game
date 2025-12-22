local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local SchoolSlidingDoors = {}

local constants = nil
local doors = {}
local checkInterval = 0.2
local autoDistance = 10

local function getDoorCFrame(door, name)
  local value = door:GetAttribute(name)
  if typeof(value) == "CFrame" then
    return value
  end
  return nil
end

local function hasNearbyPlayer(door)
  local doorPos = door.Position
  for _, player in ipairs(Players:GetPlayers()) do
    local character = player.Character
    if character then
      local hrp = character:FindFirstChild("HumanoidRootPart")
      if hrp then
        if (hrp.Position - doorPos).Magnitude <= autoDistance then
          return true
        end
      end
    end
  end
  return false
end

local function clearPrompt(door)
  local prompt = door:FindFirstChild("DoorPrompt")
  if prompt and prompt:IsA("ProximityPrompt") then
    prompt.Enabled = false
    prompt.Parent = nil
  end
end

local function ensureDoor(door)
  if not door or not door:IsA("BasePart") then
    return
  end

  if constants and constants.TAGS and constants.TAGS.SchoolDoor then
    CollectionService:RemoveTag(door, constants.TAGS.SchoolDoor)
  end
  clearPrompt(door)

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

function SchoolSlidingDoors.Init(constantsModule)
  constants = constantsModule
  if not constants then
    return
  end

  for _, door in ipairs(CollectionService:GetTagged(constants.TAGS.SchoolSlidingDoor)) do
    ensureDoor(door)
  end

  CollectionService:GetInstanceAddedSignal(constants.TAGS.SchoolSlidingDoor):Connect(function(door)
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

return SchoolSlidingDoors
