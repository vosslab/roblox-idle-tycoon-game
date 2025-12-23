local BuilderUtil = require(script.Parent.BuilderUtil)
local DoorBuilder = require(script.Parent.DoorBuilder)
local WindowBuilder = require(script.Parent.WindowBuilder)

local SchoolDoorsBuilder = {}

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
  WindowBuilder.buildSixPaneInset(
    door,
    "DoorWindow",
    windowSize,
    windowOffset,
    windowSize.Z,
    style
  )

  local openCFrame = nil
  if motion and motion.kind == "slide" then
    local slideDir = motion.slideDir or 1
    local slideDistance = motion.slideDistance or (doorWidth * 0.9)
    openCFrame = DoorBuilder.getSlideOpenCFrame(door, "x", slideDistance, slideDir)
  else
    openCFrame = DoorBuilder.getHingeOpenCFrame(door, "x", doorWidth, hingeSide, swingDir, 90)
  end

  DoorBuilder.setDoorFrames(door, openCFrame, doorGroup, doorTag, nil)
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
    DoorBuilder.buildFrame(
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
    DoorBuilder.buildFrame(
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
      DoorBuilder.buildFrame(
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
