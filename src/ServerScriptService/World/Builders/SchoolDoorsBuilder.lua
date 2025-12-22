local BuilderUtil = require(script.Parent.BuilderUtil)

local SchoolDoorsBuilder = {}

local function ensureDoorPart(door, oldName, newName)
  local part = door:FindFirstChild(newName)
  if part and not part:IsA("BasePart") then
    part.Name = newName .. "_Unexpected"
    part = nil
  end
  if not part then
    part = door:FindFirstChild(oldName)
    if part and part:IsA("BasePart") then
      part.Name = newName
    else
      if part then
        part.Name = oldName .. "_Unexpected"
      end
      part = nil
    end
  end
  if not part then
    part = Instance.new("Part")
    part.Name = newName
    part.Parent = door
  end
  return part
end

local function ensureWeld(part, parent)
  local weld = part:FindFirstChildOfClass("WeldConstraint")
  if not weld then
    weld = Instance.new("WeldConstraint")
    weld.Parent = part
  end
  weld.Part0 = parent
  weld.Part1 = part
end

local function buildSixPaneGlass(parent, namePrefix, size, offset, depth, style)
  local glass = ensureDoorPart(parent, "Window", namePrefix .. "Glass")
  BuilderUtil.applyPhysics(glass, false, false, true)
  glass.Size = Vector3.new(size.X, size.Y, depth)
  glass.Material = Enum.Material.Glass
  glass.Transparency = style.glassTransparency
  glass.BrickColor = style.glassColor
  glass.CFrame = parent.CFrame * CFrame.new(offset)
  ensureWeld(glass, parent)

  local mullionThickness = math.min(size.X, size.Y) * 0.08

  local mullionV = BuilderUtil.findOrCreatePart(parent, namePrefix .. "MullionV", "Part")
  BuilderUtil.applyPhysics(mullionV, false, false, true)
  mullionV.Size = Vector3.new(mullionThickness, size.Y, depth)
  mullionV.Material = Enum.Material.SmoothPlastic
  mullionV.BrickColor = style.frameColor
  mullionV.CFrame = parent.CFrame * CFrame.new(offset)
  ensureWeld(mullionV, parent)

  local mullionH1 = BuilderUtil.findOrCreatePart(parent, namePrefix .. "MullionH1", "Part")
  local mullionH2 = BuilderUtil.findOrCreatePart(parent, namePrefix .. "MullionH2", "Part")
  BuilderUtil.applyPhysics(mullionH1, false, false, true)
  BuilderUtil.applyPhysics(mullionH2, false, false, true)
  mullionH1.Size = Vector3.new(size.X, mullionThickness, depth)
  mullionH2.Size = Vector3.new(size.X, mullionThickness, depth)
  mullionH1.Material = Enum.Material.SmoothPlastic
  mullionH2.Material = Enum.Material.SmoothPlastic
  mullionH1.BrickColor = style.frameColor
  mullionH2.BrickColor = style.frameColor

  local offsetY = size.Y / 6
  mullionH1.CFrame = parent.CFrame * CFrame.new(offset + Vector3.new(0, offsetY, 0))
  mullionH2.CFrame = parent.CFrame * CFrame.new(offset + Vector3.new(0, -offsetY, 0))
  ensureWeld(mullionH1, parent)
  ensureWeld(mullionH2, parent)
end

local function setCFrame(part, baseCFrame, localPosition)
  part.CFrame = baseCFrame * CFrame.new(localPosition)
end

local function makeDoorFrame(
  model,
  namePrefix,
  centerX,
  centerZ,
  doorWidth,
  doorHeight,
  style,
  wallThickness,
  baseCFrame
)
  local sideThickness = 0.4
  local topThickness = 0.4
  local frameDepth = wallThickness + 0.2

  local left = BuilderUtil.findOrCreatePart(model, namePrefix .. "FrameLeft", "Part")
  local right = BuilderUtil.findOrCreatePart(model, namePrefix .. "FrameRight", "Part")
  local top = BuilderUtil.findOrCreatePart(model, namePrefix .. "FrameTop", "Part")
  BuilderUtil.applyPhysics(left, true, true, false)
  BuilderUtil.applyPhysics(right, true, true, false)
  BuilderUtil.applyPhysics(top, true, true, false)

  left.Size = Vector3.new(sideThickness, doorHeight, frameDepth)
  right.Size = Vector3.new(sideThickness, doorHeight, frameDepth)
  top.Size = Vector3.new(doorWidth + (sideThickness * 2), topThickness, frameDepth)

  setCFrame(
    left,
    baseCFrame,
    Vector3.new(centerX - (doorWidth / 2) - (sideThickness / 2), doorHeight / 2, centerZ)
  )
  setCFrame(
    right,
    baseCFrame,
    Vector3.new(centerX + (doorWidth / 2) + (sideThickness / 2), doorHeight / 2, centerZ)
  )
  setCFrame(top, baseCFrame, Vector3.new(centerX, doorHeight + (topThickness / 2), centerZ))

  left.Material = Enum.Material.SmoothPlastic
  right.Material = Enum.Material.SmoothPlastic
  top.Material = Enum.Material.SmoothPlastic
  left.BrickColor = style.accentColor
  right.BrickColor = style.accentColor
  top.BrickColor = style.accentColor
end

local function makeDoor(
  model,
  name,
  centerX,
  centerZ,
  doorWidth,
  doorHeight,
  hingeSide,
  swingDir,
  style,
  wallThickness,
  baseCFrame,
  doorTag,
  motion,
  doorGroup
)
  local door = BuilderUtil.findOrCreatePart(model, name, "Part")
  BuilderUtil.applyPhysics(door, true, true, false)
  door.Size = Vector3.new(doorWidth, doorHeight, wallThickness)
  door.Material = Enum.Material.SmoothPlastic
  door.BrickColor = style.trimColor
  door.CFrame = baseCFrame * CFrame.new(centerX, doorHeight / 2, centerZ)

  local windowSize = Vector3.new(doorWidth * 0.6, doorHeight * 0.45, wallThickness * 0.4)
  local windowOffset = Vector3.new(0, doorHeight * 0.1, 0)
  buildSixPaneGlass(door, "DoorWindow", windowSize, windowOffset, windowSize.Z, style)

  local openCFrame = nil
  if motion and motion.kind == "slide" then
    local slideDir = motion.slideDir or 1
    local slideDistance = motion.slideDistance or (doorWidth * 0.9)
    openCFrame = door.CFrame * CFrame.new(slideDistance * slideDir, 0, 0)
  else
    local hingeOffsetX = hingeSide == "Right" and (doorWidth / 2) or (-doorWidth / 2)
    local hingeOffset = Vector3.new(hingeOffsetX, 0, 0)
    openCFrame = door.CFrame
      * CFrame.new(hingeOffset)
      * CFrame.Angles(0, math.rad(90 * (swingDir or 1)), 0)
      * CFrame.new(-hingeOffset)
  end

  door:SetAttribute("ClosedCFrame", door.CFrame)
  door:SetAttribute("OpenCFrame", openCFrame)
  door:SetAttribute("IsOpen", false)
  if doorGroup then
    door:SetAttribute("DoorGroup", doorGroup)
  else
    door:SetAttribute("DoorGroup", nil)
  end
  BuilderUtil.applyTag(door, doorTag)
end

function SchoolDoorsBuilder.Build(schoolModel, config)
  if not schoolModel or not config or not config.baseCFrame then
    return
  end

  local wallThickness = config.wallThickness
  local baseCFrame = config.baseCFrame
  local style = {
    trimColor = config.trimColor,
    accentColor = config.accentColor,
    frameColor = config.windowFrameColor,
    glassColor = config.glassColor,
    glassTransparency = config.glassTransparency,
  }
  local doorTag = config.doorTag
  local entranceDoorTag = config.entranceDoorTag or doorTag
  local gymDoorTag = config.gymDoorTag or doorTag
  local roomDoorTag = config.roomDoorTag or doorTag
  local entranceDoorGroup = config.entranceDoorGroup
  local gymDoorGroup = config.gymDoorGroup
  local roomDoorGroup = config.roomDoorGroup

  local entrance = config.entrance
  if entrance then
    local entranceSpan = (entrance.doorWidth * 2) + entrance.gap
    makeDoorFrame(
      schoolModel,
      "Entrance",
      entrance.centerX,
      entrance.centerZ,
      entranceSpan,
      entrance.doorHeight,
      style,
      wallThickness,
      baseCFrame
    )
    makeDoor(
      schoolModel,
      "EntranceDoorLeft",
      entrance.centerX - (entrance.gap / 2) - (entrance.doorWidth / 2),
      entrance.centerZ,
      entrance.doorWidth,
      entrance.doorHeight,
      "Left",
      1,
      style,
      wallThickness,
      baseCFrame,
      entranceDoorTag,
      entrance.motion and entrance.motion.left or nil,
      entranceDoorGroup
    )
    makeDoor(
      schoolModel,
      "EntranceDoorRight",
      entrance.centerX + (entrance.gap / 2) + (entrance.doorWidth / 2),
      entrance.centerZ,
      entrance.doorWidth,
      entrance.doorHeight,
      "Right",
      -1,
      style,
      wallThickness,
      baseCFrame,
      entranceDoorTag,
      entrance.motion and entrance.motion.right or nil,
      entranceDoorGroup
    )
  end

  local gym = config.gym
  if gym then
    local gymSpan = (gym.doorWidth * 2) + gym.gap
    makeDoorFrame(
      schoolModel,
      "Gym",
      gym.centerX,
      gym.centerZ,
      gymSpan,
      gym.doorHeight,
      style,
      wallThickness,
      baseCFrame
    )
    makeDoor(
      schoolModel,
      "GymDoorLeft",
      gym.centerX - (gym.gap / 2) - (gym.doorWidth / 2),
      gym.centerZ,
      gym.doorWidth,
      gym.doorHeight,
      "Left",
      1,
      style,
      wallThickness,
      baseCFrame,
      gymDoorTag,
      gym.motion and gym.motion.left or nil,
      gymDoorGroup
    )
    makeDoor(
      schoolModel,
      "GymDoorRight",
      gym.centerX + (gym.gap / 2) + (gym.doorWidth / 2),
      gym.centerZ,
      gym.doorWidth,
      gym.doorHeight,
      "Right",
      -1,
      style,
      wallThickness,
      baseCFrame,
      gymDoorTag,
      gym.motion and gym.motion.right or nil,
      gymDoorGroup
    )
  end

  local rooms = config.rooms
  if rooms and rooms.centers then
    for i, centerX in ipairs(rooms.centers) do
      makeDoorFrame(
        schoolModel,
        "Room" .. i,
        centerX,
        rooms.centerZ,
        rooms.doorWidth,
        rooms.doorHeight,
        style,
        wallThickness,
        baseCFrame
      )
      makeDoor(
        schoolModel,
        "RoomDoor" .. i,
        centerX,
        rooms.centerZ,
        rooms.doorWidth,
        rooms.doorHeight,
        "Left",
        1,
        style,
        wallThickness,
        baseCFrame,
        roomDoorTag,
        rooms.motion and rooms.motion.left or nil,
        roomDoorGroup
      )
    end
  end
end

return SchoolDoorsBuilder
