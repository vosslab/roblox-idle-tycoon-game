local BuilderUtil = require(script.Parent.BuilderUtil)
local SchoolDoorsBuilder = require(script.Parent.SchoolDoorsBuilder)
local SchoolWindowsBuilder = require(script.Parent.SchoolWindowsBuilder)

local SchoolBuilder = {}

local function ensureSurfaceLabel(part, text, options)
  local surface = part:FindFirstChildOfClass("SurfaceGui")
  if not surface then
    surface = Instance.new("SurfaceGui")
    surface.Face = Enum.NormalId.Front
    surface.AlwaysOnTop = true
    surface.Parent = part
  end

  local label = surface:FindFirstChildOfClass("TextLabel")
  if not label then
    label = Instance.new("TextLabel")
    label.Parent = surface
  end

  label.Size = UDim2.fromScale(1, 1)
  label.BackgroundTransparency = 1
  label.TextScaled = (options and options.textScaled) ~= false
  if options and options.textSize then
    label.TextSize = options.textSize
  end
  label.Font = Enum.Font.GothamBold
  label.TextColor3 = (options and options.textColor) or Color3.fromRGB(255, 255, 255)
  label.TextStrokeTransparency = (options and options.textStrokeTransparency) or 0.4
  label.Text = text
end

function SchoolBuilder.Build(playground, constants)
  if not playground then
    return
  end

  local context = BuilderUtil.getPlaygroundContext(constants)
  if not context then
    return
  end

  local schoolModel = BuilderUtil.findOrCreateModel(playground, "BloxsburgSchool")

  local layout = context.layout
  local schoolWidth = 120
  local schoolLength = 80
  if layout and layout.zones and layout.zones.school then
    schoolWidth = layout.zones.school.width or schoolWidth
    schoolLength = layout.zones.school.length or schoolLength
  end
  local floorSize = Vector3.new(schoolWidth, 1, schoolLength)
  local wallHeight = 16
  local wallThickness = 1
  local roofThickness = 1
  local entranceDoorWidth = 5.5
  local entranceDoorHeight = 9
  local entranceDoorGap = 0
  local entranceSpan = (entranceDoorWidth * 2) + entranceDoorGap
  local entranceGap = entranceSpan
  local wallColor = BrickColor.new("Fawn")
  local trimColor = BrickColor.new("Linen")
  local roofColor = BrickColor.new("Reddish brown")
  local accentColor = BrickColor.new("Dark stone grey")
  local accentBandColor = BrickColor.new("Terra Cotta")
  local baseBandColor = BrickColor.new("Cocoa")
  local columnColor = BrickColor.new("Dusty Rose")
  local windowFrameColor = BrickColor.new("White")
  local glassColor = BrickColor.new("Light blue")
  local glassTransparency = 0.45

  if not layout then
    return
  end

  local schoolCenter = layout.schoolCenter
  local schoolCFrame = CFrame.lookAt(schoolCenter, layout.schoolFacing, Vector3.new(0, 1, 0))

  local function setCFrame(part, localPosition)
    part.CFrame = schoolCFrame * CFrame.new(localPosition)
  end

  local function setCFrameRot(part, localPosition, rotation)
    part.CFrame = schoolCFrame * CFrame.new(localPosition) * rotation
  end

  local floor = BuilderUtil.findOrCreatePart(schoolModel, "SchoolFloor", "Part")
  BuilderUtil.applyPhysics(floor, true, true, false)
  floor.Size = floorSize
  setCFrame(floor, Vector3.new(0, floor.Size.Y / 2, 0))
  floor.Material = Enum.Material.SmoothPlastic
  floor.BrickColor = BrickColor.new("Linen")

  local roof = BuilderUtil.findOrCreatePart(schoolModel, "SchoolRoof", "Part")
  BuilderUtil.applyPhysics(roof, true, true, false)
  roof.Size = Vector3.new(floorSize.X, roofThickness, floorSize.Z)
  setCFrame(roof, Vector3.new(0, wallHeight + (roofThickness / 2), 0))
  roof.Material = Enum.Material.SmoothPlastic
  roof.BrickColor = roofColor

  local backWall = BuilderUtil.findOrCreatePart(schoolModel, "BackWall", "Part")
  BuilderUtil.applyPhysics(backWall, true, true, false)
  backWall.Size = Vector3.new(floorSize.X, wallHeight, wallThickness)
  local frontZ = -(floorSize.Z / 2)
  local backZ = floorSize.Z / 2
  setCFrame(backWall, Vector3.new(0, wallHeight / 2, backZ))
  backWall.Material = Enum.Material.SmoothPlastic
  backWall.BrickColor = wallColor

  local leftWall = BuilderUtil.findOrCreatePart(schoolModel, "LeftWall", "Part")
  local rightWall = BuilderUtil.findOrCreatePart(schoolModel, "RightWall", "Part")
  BuilderUtil.applyPhysics(leftWall, true, true, false)
  BuilderUtil.applyPhysics(rightWall, true, true, false)
  leftWall.Size = Vector3.new(wallThickness, wallHeight, floorSize.Z)
  rightWall.Size = Vector3.new(wallThickness, wallHeight, floorSize.Z)
  local leftEdge = -(floorSize.X / 2)
  local rightEdge = floorSize.X / 2
  setCFrame(leftWall, Vector3.new(leftEdge, wallHeight / 2, 0))
  setCFrame(rightWall, Vector3.new(rightEdge, wallHeight / 2, 0))
  leftWall.Material = Enum.Material.SmoothPlastic
  rightWall.Material = Enum.Material.SmoothPlastic
  leftWall.BrickColor = wallColor
  rightWall.BrickColor = wallColor

  local corridorWidth = entranceGap
  local frontLeft = BuilderUtil.findOrCreatePart(schoolModel, "FrontWallLeft", "Part")
  local frontRight = BuilderUtil.findOrCreatePart(schoolModel, "FrontWallRight", "Part")
  BuilderUtil.applyPhysics(frontLeft, true, true, false)
  BuilderUtil.applyPhysics(frontRight, true, true, false)
  frontLeft.Size = Vector3.new((floorSize.X - entranceGap) / 2, wallHeight, wallThickness)
  frontRight.Size = Vector3.new((floorSize.X - entranceGap) / 2, wallHeight, wallThickness)
  setCFrame(
    frontLeft,
    Vector3.new(-(entranceGap / 2) - (frontLeft.Size.X / 2), wallHeight / 2, frontZ)
  )
  setCFrame(
    frontRight,
    Vector3.new((entranceGap / 2) + (frontRight.Size.X / 2), wallHeight / 2, frontZ)
  )
  frontLeft.Material = Enum.Material.SmoothPlastic
  frontRight.Material = Enum.Material.SmoothPlastic
  frontLeft.BrickColor = wallColor
  frontRight.BrickColor = wallColor

  local sign = BuilderUtil.findOrCreatePart(schoolModel, "SchoolSign", "Part")
  BuilderUtil.applyPhysics(sign, true, false, false)
  sign.Size = Vector3.new(52, 8, 1)
  setCFrame(sign, Vector3.new(0, wallHeight + 2, frontZ - 0.5))
  sign.Material = Enum.Material.SmoothPlastic
  sign.BrickColor = windowFrameColor
  ensureSurfaceLabel(sign, "Bloxberg", {
    textColor = Color3.fromRGB(20, 20, 20),
    textStrokeTransparency = 1,
  })

  local function buildBand(name, size, localPosition, color)
    local band = BuilderUtil.findOrCreatePart(schoolModel, name, "Part")
    BuilderUtil.applyPhysics(band, true, true, false)
    band.Size = size
    setCFrame(band, localPosition)
    band.Material = Enum.Material.SmoothPlastic
    band.BrickColor = color
  end

  local function buildCornerColumn(name, localPosition, size)
    local column = BuilderUtil.findOrCreatePart(schoolModel, name, "Part")
    BuilderUtil.applyPhysics(column, true, true, false)
    column.Size = size
    setCFrame(column, localPosition)
    column.Material = Enum.Material.SmoothPlastic
    column.BrickColor = columnColor
  end

  local function buildLintel(name, centerX, centerZ, width, doorHeight)
    local lintelHeight = wallHeight - doorHeight
    if lintelHeight <= 0 then
      return
    end
    local lintel = BuilderUtil.findOrCreatePart(schoolModel, name, "Part")
    BuilderUtil.applyPhysics(lintel, true, true, false)
    lintel.Size = Vector3.new(width, lintelHeight, wallThickness)
    setCFrame(lintel, Vector3.new(centerX, doorHeight + (lintelHeight / 2), centerZ))
    lintel.Material = Enum.Material.SmoothPlastic
    lintel.BrickColor = wallColor
  end

  local hallDepth = 12
  local hallBackZ = frontZ + hallDepth
  local classroomDepth = 18
  local classBackZ = hallBackZ + classroomDepth

  local bandHeight = 2
  local bandOffset = wallThickness / 2 + 0.05
  local baseBandY = 2
  local midBandY = 8
  local frontBandZ = frontZ - bandOffset
  local backBandZ = backZ + bandOffset
  local leftBandX = leftEdge - bandOffset
  local rightBandX = rightEdge + bandOffset

  buildBand(
    "FrontBaseBandLeft",
    Vector3.new((floorSize.X - entranceGap) / 2, bandHeight, wallThickness),
    Vector3.new(-(entranceGap / 2) - ((floorSize.X - entranceGap) / 4), baseBandY, frontBandZ),
    baseBandColor
  )
  buildBand(
    "FrontBaseBandRight",
    Vector3.new((floorSize.X - entranceGap) / 2, bandHeight, wallThickness),
    Vector3.new((entranceGap / 2) + ((floorSize.X - entranceGap) / 4), baseBandY, frontBandZ),
    baseBandColor
  )
  buildBand(
    "FrontMidBandLeft",
    Vector3.new((floorSize.X - entranceGap) / 2, bandHeight, wallThickness),
    Vector3.new(-(entranceGap / 2) - ((floorSize.X - entranceGap) / 4), midBandY, frontBandZ),
    accentBandColor
  )
  buildBand(
    "FrontMidBandRight",
    Vector3.new((floorSize.X - entranceGap) / 2, bandHeight, wallThickness),
    Vector3.new((entranceGap / 2) + ((floorSize.X - entranceGap) / 4), midBandY, frontBandZ),
    accentBandColor
  )
  buildBand(
    "BackBaseBand",
    Vector3.new(floorSize.X, bandHeight, wallThickness),
    Vector3.new(0, baseBandY, backBandZ),
    baseBandColor
  )
  buildBand(
    "BackMidBand",
    Vector3.new(floorSize.X, bandHeight, wallThickness),
    Vector3.new(0, midBandY, backBandZ),
    accentBandColor
  )
  buildBand(
    "LeftBaseBand",
    Vector3.new(wallThickness, bandHeight, floorSize.Z),
    Vector3.new(leftBandX, baseBandY, 0),
    baseBandColor
  )
  buildBand(
    "LeftMidBand",
    Vector3.new(wallThickness, bandHeight, floorSize.Z),
    Vector3.new(leftBandX, midBandY, 0),
    accentBandColor
  )
  buildBand(
    "RightBaseBand",
    Vector3.new(wallThickness, bandHeight, floorSize.Z),
    Vector3.new(rightBandX, baseBandY, 0),
    baseBandColor
  )
  buildBand(
    "RightMidBand",
    Vector3.new(wallThickness, bandHeight, floorSize.Z),
    Vector3.new(rightBandX, midBandY, 0),
    accentBandColor
  )

  local columnSize = Vector3.new(2, wallHeight, 2)
  buildCornerColumn(
    "CornerColumnFrontLeft",
    Vector3.new(leftEdge, wallHeight / 2, frontZ),
    columnSize
  )
  buildCornerColumn(
    "CornerColumnFrontRight",
    Vector3.new(rightEdge, wallHeight / 2, frontZ),
    columnSize
  )
  buildCornerColumn(
    "CornerColumnBackLeft",
    Vector3.new(leftEdge, wallHeight / 2, backZ),
    columnSize
  )
  buildCornerColumn(
    "CornerColumnBackRight",
    Vector3.new(rightEdge, wallHeight / 2, backZ),
    columnSize
  )

  local roomWidth = (floorSize.X - corridorWidth) / 4
  local doorWidth = 4
  local doorHeight = 8
  local corridorLeft = -(corridorWidth / 2)
  local corridorRight = corridorWidth / 2
  local wallSegmentIndex = 1
  local roomCenters = {}
  local doorOpenings = {}

  for i = 1, 4 do
    local roomCenterX = 0
    if i <= 2 then
      roomCenterX = leftEdge + (roomWidth / 2) + (roomWidth * (i - 1))
    else
      roomCenterX = corridorRight + (roomWidth / 2) + (roomWidth * (i - 3))
    end
    roomCenters[i] = roomCenterX
    local doorLeft = roomCenterX - (doorWidth / 2)
    local doorRight = roomCenterX + (doorWidth / 2)
    table.insert(doorOpenings, {
      left = doorLeft,
      right = doorRight,
    })
  end

  table.insert(doorOpenings, {
    left = corridorLeft,
    right = corridorRight,
    skipLintel = true,
  })
  table.sort(doorOpenings, function(a, b)
    return a.left < b.left
  end)

  local currentX = leftEdge
  for _, opening in ipairs(doorOpenings) do
    local segmentWidth = opening.left - currentX
    if segmentWidth > 0 then
      local segment =
        BuilderUtil.findOrCreatePart(schoolModel, "HallWallSegment" .. wallSegmentIndex, "Part")
      wallSegmentIndex += 1
      BuilderUtil.applyPhysics(segment, true, true, false)
      segment.Size = Vector3.new(segmentWidth, wallHeight, wallThickness)
      setCFrame(segment, Vector3.new((currentX + opening.left) / 2, wallHeight / 2, hallBackZ))
      segment.Material = Enum.Material.SmoothPlastic
      segment.BrickColor = wallColor
    end
    currentX = opening.right
  end

  local tailWidth = rightEdge - currentX
  if tailWidth > 0 then
    local segment =
      BuilderUtil.findOrCreatePart(schoolModel, "HallWallSegment" .. wallSegmentIndex, "Part")
    BuilderUtil.applyPhysics(segment, true, true, false)
    segment.Size = Vector3.new(tailWidth, wallHeight, wallThickness)
    setCFrame(segment, Vector3.new((currentX + rightEdge) / 2, wallHeight / 2, hallBackZ))
    segment.Material = Enum.Material.SmoothPlastic
    segment.BrickColor = wallColor
  end

  local lintelIndex = 1
  for _, opening in ipairs(doorOpenings) do
    local width = opening.right - opening.left
    if not opening.skipLintel then
      buildLintel(
        "HallLintel" .. lintelIndex,
        (opening.left + opening.right) / 2,
        hallBackZ,
        width,
        doorHeight
      )
      lintelIndex += 1
    end
  end

  local dividerXs = {
    leftEdge + roomWidth,
    corridorLeft,
    corridorRight,
    corridorRight + roomWidth,
  }
  for i, dividerX in ipairs(dividerXs) do
    local wall = BuilderUtil.findOrCreatePart(schoolModel, "RoomDivider" .. i, "Part")
    BuilderUtil.applyPhysics(wall, true, true, false)
    wall.Size = Vector3.new(wallThickness, wallHeight, classBackZ - hallBackZ)
    setCFrame(
      wall,
      Vector3.new(dividerX, wallHeight / 2, hallBackZ + ((classBackZ - hallBackZ) / 2))
    )
    wall.Material = Enum.Material.SmoothPlastic
    wall.BrickColor = wallColor
  end

  local gymWallGap = corridorWidth
  local gymWallLeft = BuilderUtil.findOrCreatePart(schoolModel, "GymWallLeft", "Part")
  local gymWallRight = BuilderUtil.findOrCreatePart(schoolModel, "GymWallRight", "Part")
  BuilderUtil.applyPhysics(gymWallLeft, true, true, false)
  BuilderUtil.applyPhysics(gymWallRight, true, true, false)
  gymWallLeft.Size = Vector3.new((floorSize.X - gymWallGap) / 2, wallHeight, wallThickness)
  gymWallRight.Size = Vector3.new((floorSize.X - gymWallGap) / 2, wallHeight, wallThickness)
  setCFrame(
    gymWallLeft,
    Vector3.new(-(gymWallGap / 2) - (gymWallLeft.Size.X / 2), wallHeight / 2, classBackZ)
  )
  setCFrame(
    gymWallRight,
    Vector3.new((gymWallGap / 2) + (gymWallRight.Size.X / 2), wallHeight / 2, classBackZ)
  )
  gymWallLeft.Material = Enum.Material.SmoothPlastic
  gymWallRight.Material = Enum.Material.SmoothPlastic
  gymWallLeft.BrickColor = wallColor
  gymWallRight.BrickColor = wallColor

  buildLintel("EntranceLintel", 0, frontZ, entranceSpan, entranceDoorHeight)
  buildLintel("GymLintel", 0, classBackZ, entranceSpan, entranceDoorHeight)

  local frontWindowSize = Vector3.new(6, 6, 0.4)
  local windowCenterY = 6
  local frontWindowZ = frontZ - (wallThickness / 2) - (frontWindowSize.Z / 2)
  local backWindowZ = backZ + (wallThickness / 2) + (frontWindowSize.Z / 2)
  local windowMargin = 4
  local leftSegmentMinX = leftEdge + windowMargin
  local leftSegmentMaxX = -(entranceGap / 2) - windowMargin
  local rightSegmentMinX = (entranceGap / 2) + windowMargin
  local rightSegmentMaxX = rightEdge - windowMargin
  local windowGap = 3
  local windowCountLeft = 2
  local windowCountRight = 2
  local backWindowCount = 5

  SchoolDoorsBuilder.Build(schoolModel, {
    wallThickness = wallThickness,
    baseCFrame = schoolCFrame,
    trimColor = trimColor,
    accentColor = accentColor,
    windowFrameColor = windowFrameColor,
    glassColor = glassColor,
    glassTransparency = glassTransparency,
    doorTag = constants.TAGS.SchoolDoor,
    entranceDoorTag = constants.TAGS.SchoolSlidingDoor,
    gymDoorGroup = "GymDoors",
    entrance = {
      centerX = 0,
      centerZ = frontZ,
      doorWidth = entranceDoorWidth,
      doorHeight = entranceDoorHeight,
      gap = entranceDoorGap,
      motion = {
        left = {
          kind = "slide",
          slideDir = -1,
          slideDistance = entranceDoorWidth * 0.9,
        },
        right = {
          kind = "slide",
          slideDir = 1,
          slideDistance = entranceDoorWidth * 0.9,
        },
      },
    },
    gym = {
      centerX = 0,
      centerZ = classBackZ,
      doorWidth = entranceDoorWidth,
      doorHeight = entranceDoorHeight,
      gap = entranceDoorGap,
    },
    rooms = {
      centers = roomCenters,
      centerZ = hallBackZ,
      doorWidth = doorWidth,
      doorHeight = doorHeight,
    },
  })

  SchoolWindowsBuilder.Build(schoolModel, {
    windowSize = frontWindowSize,
    windowCenterY = windowCenterY,
    windowZ = frontWindowZ,
    windowGap = windowGap,
    baseCFrame = schoolCFrame,
    leftSegment = {
      minX = leftSegmentMinX,
      maxX = leftSegmentMaxX,
      count = windowCountLeft,
      prefix = "FrontLeftWindow",
    },
    rightSegment = {
      minX = rightSegmentMinX,
      maxX = rightSegmentMaxX,
      count = windowCountRight,
      prefix = "FrontRightWindow",
    },
    style = {
      frameColor = windowFrameColor,
      glassColor = glassColor,
      glassTransparency = glassTransparency,
    },
    modelName = "Windows",
  })

  SchoolWindowsBuilder.Build(schoolModel, {
    windowSize = frontWindowSize,
    windowCenterY = windowCenterY,
    windowZ = backWindowZ,
    windowGap = windowGap,
    baseCFrame = schoolCFrame,
    leftSegment = {
      minX = leftEdge + windowMargin,
      maxX = rightEdge - windowMargin,
      count = backWindowCount,
      prefix = "BackWindow",
    },
    rightSegment = {
      minX = 0,
      maxX = 0,
      count = 0,
      prefix = "BackWindowUnused",
    },
    style = {
      frameColor = windowFrameColor,
      glassColor = glassColor,
      glassTransparency = glassTransparency,
    },
    modelName = "BackWindows",
  })

  local sideWindowRotation = CFrame.Angles(0, math.rad(90), 0)
  local sideWindowXLeft = leftEdge - (wallThickness / 2) - (frontWindowSize.Z / 2)
  local sideWindowXRight = rightEdge + (wallThickness / 2) + (frontWindowSize.Z / 2)
  local hallwayCenterZ = frontZ + (hallDepth / 2)
  local classroomCenterZ = hallBackZ + (classroomDepth / 2)
  local gymCenterZ = classBackZ + ((backZ - classBackZ) / 2)

  SchoolWindowsBuilder.BuildSingle(schoolModel, {
    baseCFrame = schoolCFrame,
    localPosition = Vector3.new(sideWindowXLeft, windowCenterY, classroomCenterZ),
    windowRotation = sideWindowRotation,
    windowSize = frontWindowSize,
    style = {
      frameColor = windowFrameColor,
      glassColor = glassColor,
      glassTransparency = glassTransparency,
    },
    name = "SideWindowLeftClassroom",
    modelName = "SideWindows",
  })
  SchoolWindowsBuilder.BuildSingle(schoolModel, {
    baseCFrame = schoolCFrame,
    localPosition = Vector3.new(sideWindowXLeft, windowCenterY, hallwayCenterZ),
    windowRotation = sideWindowRotation,
    windowSize = frontWindowSize,
    style = {
      frameColor = windowFrameColor,
      glassColor = glassColor,
      glassTransparency = glassTransparency,
    },
    name = "SideWindowLeftHallway",
    modelName = "SideWindows",
  })
  SchoolWindowsBuilder.BuildSingle(schoolModel, {
    baseCFrame = schoolCFrame,
    localPosition = Vector3.new(sideWindowXLeft, windowCenterY, gymCenterZ),
    windowRotation = sideWindowRotation,
    windowSize = frontWindowSize,
    style = {
      frameColor = windowFrameColor,
      glassColor = glassColor,
      glassTransparency = glassTransparency,
    },
    name = "SideWindowLeftGym",
    modelName = "SideWindows",
  })
  SchoolWindowsBuilder.BuildSingle(schoolModel, {
    baseCFrame = schoolCFrame,
    localPosition = Vector3.new(sideWindowXRight, windowCenterY, classroomCenterZ),
    windowRotation = sideWindowRotation,
    windowSize = frontWindowSize,
    style = {
      frameColor = windowFrameColor,
      glassColor = glassColor,
      glassTransparency = glassTransparency,
    },
    name = "SideWindowRightClassroom",
    modelName = "SideWindows",
  })
  SchoolWindowsBuilder.BuildSingle(schoolModel, {
    baseCFrame = schoolCFrame,
    localPosition = Vector3.new(sideWindowXRight, windowCenterY, hallwayCenterZ),
    windowRotation = sideWindowRotation,
    windowSize = frontWindowSize,
    style = {
      frameColor = windowFrameColor,
      glassColor = glassColor,
      glassTransparency = glassTransparency,
    },
    name = "SideWindowRightHallway",
    modelName = "SideWindows",
  })
  SchoolWindowsBuilder.BuildSingle(schoolModel, {
    baseCFrame = schoolCFrame,
    localPosition = Vector3.new(sideWindowXRight, windowCenterY, gymCenterZ),
    windowRotation = sideWindowRotation,
    windowSize = frontWindowSize,
    style = {
      frameColor = windowFrameColor,
      glassColor = glassColor,
      glassTransparency = glassTransparency,
    },
    name = "SideWindowRightGym",
    modelName = "SideWindows",
  })

  local roomModel = BuilderUtil.findOrCreateModel(schoolModel, "Rooms")
  local roomNumbers = { "100", "101", "102", "103" }
  local roomLabelSize = Vector3.new(6, 3, 0.2)
  local roomLabelOffsetX = (doorWidth / 2) + (roomLabelSize.X / 2) + 1
  local roomLabelY = doorHeight - 1
  local roomLabelZ = hallBackZ - (wallThickness / 2) - (roomLabelSize.Z / 2)
  for i = 1, 4 do
    local roomCenterX = roomCenters[i]
    local room = BuilderUtil.findOrCreatePart(roomModel, "Room" .. roomNumbers[i], "Part")
    BuilderUtil.applyPhysics(room, true, false, true)
    room.Size = roomLabelSize
    setCFrame(room, Vector3.new(roomCenterX - roomLabelOffsetX, roomLabelY, roomLabelZ))
    room.Material = Enum.Material.SmoothPlastic
    room.BrickColor = windowFrameColor
    ensureSurfaceLabel(room, roomNumbers[i], {
      textColor = Color3.fromRGB(20, 20, 20),
      textStrokeTransparency = 1,
      textScaled = false,
      textSize = 96,
    })
  end

  local gymLabel = schoolModel:FindFirstChild("GymLabel")
  if gymLabel and not gymLabel:IsA("BasePart") then
    gymLabel.Name = "GymLabel_Unexpected"
    gymLabel = nil
  end
  if not gymLabel then
    local oldGymFloor = schoolModel:FindFirstChild("GymFloor")
    if oldGymFloor and oldGymFloor:IsA("BasePart") then
      oldGymFloor.Name = "GymLabel"
      gymLabel = oldGymFloor
    else
      if oldGymFloor then
        oldGymFloor.Name = "GymFloor_Unexpected"
      end
    end
  end
  if not gymLabel then
    gymLabel = Instance.new("Part")
    gymLabel.Name = "GymLabel"
    gymLabel.Parent = schoolModel
  end
  BuilderUtil.applyPhysics(gymLabel, true, false, true)
  gymLabel.Size = Vector3.new(32, 8, 0.2)
  setCFrame(
    gymLabel,
    Vector3.new(0, wallHeight - 3, classBackZ - (wallThickness / 2) - (gymLabel.Size.Z / 2))
  )
  gymLabel.Material = Enum.Material.SmoothPlastic
  gymLabel.BrickColor = windowFrameColor
  ensureSurfaceLabel(gymLabel, "Gym", {
    textColor = Color3.fromRGB(20, 20, 20),
    textStrokeTransparency = 1,
  })

  local function buildHoop(namePrefix, wallX, facingDir)
    local backboard = BuilderUtil.findOrCreatePart(schoolModel, namePrefix .. "Backboard", "Part")
    BuilderUtil.applyPhysics(backboard, true, false, true)
    backboard.Size = Vector3.new(0.3, 4, 6)
    backboard.Material = Enum.Material.SmoothPlastic
    backboard.BrickColor = BrickColor.new("Institutional white")
    setCFrame(backboard, Vector3.new(wallX, 11, gymCenterZ))

    local rim = BuilderUtil.findOrCreatePart(schoolModel, namePrefix .. "Rim", "Part")
    BuilderUtil.applyPhysics(rim, true, false, true)
    rim.Size = Vector3.new(0.2, 0.2, 3)
    rim.Material = Enum.Material.SmoothPlastic
    rim.BrickColor = BrickColor.new("Bright orange")
    setCFrame(rim, Vector3.new(wallX + (facingDir * 1.2), 9, gymCenterZ))

    local arm = BuilderUtil.findOrCreatePart(schoolModel, namePrefix .. "Arm", "Part")
    BuilderUtil.applyPhysics(arm, true, false, true)
    arm.Size = Vector3.new(1.2, 0.2, 0.2)
    arm.Material = Enum.Material.SmoothPlastic
    arm.BrickColor = BrickColor.new("Dark stone grey")
    setCFrameRot(arm, Vector3.new(wallX + (facingDir * 0.6), 10, gymCenterZ), CFrame.new())
  end

  local hoopInset = (wallThickness / 2) + 0.2
  buildHoop("EastHoop", rightEdge - hoopInset, -1)
  buildHoop("WestHoop", leftEdge + hoopInset, 1)
end

return SchoolBuilder
