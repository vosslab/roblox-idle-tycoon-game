local BuilderUtil = require(script.Parent.BuilderUtil)

local SchoolWindowsBuilder = {}

local function buildSixPaneWindow(parent, name, windowCFrame, windowSize, style)
  local frameThickness = math.min(windowSize.X, windowSize.Y) * 0.08
  local mullionThickness = frameThickness * 0.8
  local frameDepth = windowSize.Z

  local windowModel = BuilderUtil.findOrCreateModel(parent, name)

  local function styleFrame(part)
    BuilderUtil.applyPhysics(part, true, false, true)
    part.Material = Enum.Material.SmoothPlastic
    part.BrickColor = style.frameColor
  end

  local glass = BuilderUtil.findOrCreatePart(windowModel, "Glass", "Part")
  BuilderUtil.applyPhysics(glass, true, false, true)
  glass.Size = Vector3.new(
    windowSize.X - (frameThickness * 2),
    windowSize.Y - (frameThickness * 2),
    math.max(0.2, frameDepth * 0.6)
  )
  glass.Material = Enum.Material.Glass
  glass.Transparency = style.glassTransparency
  glass.BrickColor = style.glassColor
  glass.CFrame = windowCFrame

  local top = BuilderUtil.findOrCreatePart(windowModel, "FrameTop", "Part")
  local bottom = BuilderUtil.findOrCreatePart(windowModel, "FrameBottom", "Part")
  local left = BuilderUtil.findOrCreatePart(windowModel, "FrameLeft", "Part")
  local right = BuilderUtil.findOrCreatePart(windowModel, "FrameRight", "Part")
  styleFrame(top)
  styleFrame(bottom)
  styleFrame(left)
  styleFrame(right)
  top.Size = Vector3.new(windowSize.X, frameThickness, frameDepth)
  bottom.Size = Vector3.new(windowSize.X, frameThickness, frameDepth)
  local sideHeight = windowSize.Y - (frameThickness * 2)
  left.Size = Vector3.new(frameThickness, sideHeight, frameDepth)
  right.Size = Vector3.new(frameThickness, sideHeight, frameDepth)
  top.CFrame = windowCFrame * CFrame.new(0, (windowSize.Y / 2) - (frameThickness / 2), 0)
  bottom.CFrame = windowCFrame * CFrame.new(0, -(windowSize.Y / 2) + (frameThickness / 2), 0)
  left.CFrame = windowCFrame * CFrame.new(-(windowSize.X / 2) + (frameThickness / 2), 0, 0)
  right.CFrame = windowCFrame * CFrame.new((windowSize.X / 2) - (frameThickness / 2), 0, 0)

  local mullionV = BuilderUtil.findOrCreatePart(windowModel, "MullionV", "Part")
  styleFrame(mullionV)
  mullionV.Size = Vector3.new(mullionThickness, glass.Size.Y, frameDepth)
  mullionV.CFrame = windowCFrame

  local mullionH1 = BuilderUtil.findOrCreatePart(windowModel, "MullionH1", "Part")
  local mullionH2 = BuilderUtil.findOrCreatePart(windowModel, "MullionH2", "Part")
  styleFrame(mullionH1)
  styleFrame(mullionH2)
  mullionH1.Size = Vector3.new(glass.Size.X, mullionThickness, frameDepth)
  mullionH2.Size = Vector3.new(glass.Size.X, mullionThickness, frameDepth)
  local offsetY = glass.Size.Y / 6
  mullionH1.CFrame = windowCFrame * CFrame.new(0, offsetY, 0)
  mullionH2.CFrame = windowCFrame * CFrame.new(0, -offsetY, 0)
end

local function layoutWindows(windowModel, config, prefix, minX, maxX, count)
  if maxX <= minX or count <= 0 then
    return
  end

  local windowSize = config.windowSize
  local totalWidth = (count * windowSize.X) + ((count - 1) * config.windowGap)
  if totalWidth > (maxX - minX) then
    return
  end

  local centerX = (minX + maxX) / 2
  local startX = centerX - (totalWidth / 2) + (windowSize.X / 2)
  for i = 1, count do
    local x = startX + ((i - 1) * (windowSize.X + config.windowGap))
    local windowCFrame = config.baseCFrame
      * CFrame.new(x, config.windowCenterY, config.windowZ)
      * (config.windowRotation or CFrame.new())
    buildSixPaneWindow(windowModel, prefix .. i, windowCFrame, windowSize, config.style)
  end
end

function SchoolWindowsBuilder.Build(schoolModel, config)
  if not schoolModel or not config or not config.baseCFrame then
    return
  end

  local windowModel = BuilderUtil.findOrCreateModel(schoolModel, config.modelName or "Windows")

  local leftPrefix = config.leftSegment.prefix or "FrontLeftWindow"
  local rightPrefix = config.rightSegment.prefix or "FrontRightWindow"

  layoutWindows(
    windowModel,
    config,
    leftPrefix,
    config.leftSegment.minX,
    config.leftSegment.maxX,
    config.leftSegment.count
  )
  layoutWindows(
    windowModel,
    config,
    rightPrefix,
    config.rightSegment.minX,
    config.rightSegment.maxX,
    config.rightSegment.count
  )
end

function SchoolWindowsBuilder.BuildSingle(schoolModel, config)
  if not schoolModel or not config or not config.baseCFrame then
    return
  end

  local windowModel = BuilderUtil.findOrCreateModel(schoolModel, config.modelName or "Windows")
  local windowCFrame = config.baseCFrame
    * CFrame.new(config.localPosition)
    * (config.windowRotation or CFrame.new())

  buildSixPaneWindow(windowModel, config.name, windowCFrame, config.windowSize, config.style)
end

return SchoolWindowsBuilder
