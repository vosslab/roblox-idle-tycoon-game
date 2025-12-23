local BuilderUtil = require(script.Parent.BuilderUtil)
local WindowBuilder = require(script.Parent.WindowBuilder)

local SchoolWindowsBuilder = {}

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
    WindowBuilder.buildSixPaneWindow(windowModel, prefix .. i, windowCFrame, windowSize, config.style)
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

  WindowBuilder.buildSixPaneWindow(windowModel, config.name, windowCFrame, config.windowSize, config.style)
end

return SchoolWindowsBuilder
