local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")

local SchoolDoors = {}

local constants = nil
local doorBusy = {}

local function getDoorCFrame(door, name)
  local value = door:GetAttribute(name)
  if typeof(value) == "CFrame" then
    return value
  end
  return nil
end

local function setPromptText(prompt, isOpen)
  prompt.ActionText = isOpen and "Close" or "Open"
  prompt.ObjectText = "Door"
end

local function getPrompt(door)
  local prompt = door:FindFirstChild("DoorPrompt")
  if prompt and prompt:IsA("ProximityPrompt") then
    return prompt
  end
  return nil
end

local function getDoorGroup(door)
  local value = door:GetAttribute("DoorGroup")
  if type(value) == "string" and value ~= "" then
    return value
  end
  return nil
end

local function tweenDoor(door, target, openState)
  doorBusy[door] = true

  local tween =
    TweenService:Create(door, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
      CFrame = target,
    })
  tween:Play()
  tween.Completed:Once(function()
    door:SetAttribute("IsOpen", openState)
    local prompt = getPrompt(door)
    if prompt then
      setPromptText(prompt, openState)
    end
    doorBusy[door] = nil
  end)
end

local function setupDoor(door)
  if not door or not door:IsA("BasePart") then
    return
  end

  local prompt = door:FindFirstChild("DoorPrompt")
  if prompt and not prompt:IsA("ProximityPrompt") then
    prompt.Name = "DoorPrompt_Unexpected"
    prompt = nil
  end
  if not prompt then
    prompt = Instance.new("ProximityPrompt")
    prompt.Name = "DoorPrompt"
    prompt.Parent = door
  end

  prompt.ActionText = "Open"
  prompt.ObjectText = "Door"
  prompt.KeyboardKeyCode = Enum.KeyCode.E
  prompt.HoldDuration = 0
  prompt.MaxActivationDistance = 10
  prompt.RequiresLineOfSight = false

  if door:GetAttribute("IsOpen") == nil then
    door:SetAttribute("IsOpen", false)
  end

  if not getDoorCFrame(door, "ClosedCFrame") then
    door:SetAttribute("ClosedCFrame", door.CFrame)
  end

  prompt.Triggered:Connect(function()
    local isOpen = door:GetAttribute("IsOpen") == true
    local desiredOpen = not isOpen
    local group = getDoorGroup(door)
    local targets = { door }

    if group and constants and constants.TAGS and constants.TAGS.SchoolDoor then
      for _, otherDoor in ipairs(CollectionService:GetTagged(constants.TAGS.SchoolDoor)) do
        if otherDoor ~= door and getDoorGroup(otherDoor) == group then
          table.insert(targets, otherDoor)
        end
      end
    end

    for _, targetDoor in ipairs(targets) do
      if doorBusy[targetDoor] then
        return
      end
    end

    for _, targetDoor in ipairs(targets) do
      local target = desiredOpen and getDoorCFrame(targetDoor, "OpenCFrame")
        or getDoorCFrame(targetDoor, "ClosedCFrame")
      if target then
        tweenDoor(targetDoor, target, desiredOpen)
      end
    end
  end)
end

function SchoolDoors.Init(constantsModule)
  constants = constantsModule

  for _, door in ipairs(CollectionService:GetTagged(constants.TAGS.SchoolDoor)) do
    setupDoor(door)
  end

  CollectionService:GetInstanceAddedSignal(constants.TAGS.SchoolDoor):Connect(function(door)
    setupDoor(door)
  end)
end

return SchoolDoors
