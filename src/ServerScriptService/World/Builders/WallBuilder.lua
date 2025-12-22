local BuilderUtil = require(script.Parent.BuilderUtil)

local WallBuilder = {}

local function styleWall(part, wallColor, material)
  part.Material = material or Enum.Material.SmoothPlastic
  part.BrickColor = wallColor or BrickColor.new("Linen")
end

local function getOpeningList(openings)
  if not openings then
    return {}
  end
  if openings.width then
    return { openings }
  end
  if #openings > 0 then
    return openings
  end
  return {}
end

local function getWallNormal(baseCFrame, axis)
  local normalLocal = axis == "x" and Vector3.new(0, 0, 1) or Vector3.new(1, 0, 0)
  return baseCFrame:VectorToWorldSpace(normalLocal)
end

function WallBuilder.buildWall(config)
  if
    not config
    or not config.model
    or not config.baseCFrame
    or not config.center
    or not config.length
    or not config.height
    or not config.thickness
    or not config.axis
    or not config.namePrefix
  then
    return nil
  end

  local openings = getOpeningList(config.openings)
  local axis = config.axis
  local length = config.length
  local height = config.height
  local thickness = config.thickness
  local halfLen = length / 2
  local wallColor = config.wallColor
  local material = config.material

  local cleaned = {}
  for _, opening in ipairs(openings) do
    local width = math.max(0, opening.width or 0)
    local clampedWidth = math.clamp(width, 0, length - 2)
    if clampedWidth > 0 then
      local offset = opening.offset or 0
      local start = offset - (clampedWidth / 2)
      local finish = offset + (clampedWidth / 2)
      start = math.clamp(start, -halfLen, halfLen)
      finish = math.clamp(finish, -halfLen, halfLen)
      if finish > start then
        table.insert(cleaned, {
          width = clampedWidth,
          height = math.clamp(opening.height or height, 1, height),
          bottom = math.clamp(opening.bottom or 0, 0, height - 1),
          offset = offset,
          start = start,
          finish = finish,
        })
      end
    end
  end

  table.sort(cleaned, function(a, b)
    return a.start < b.start
  end)

  local segmentCount = 0
  local cursor = -halfLen
  for _, opening in ipairs(cleaned) do
    if opening.start > cursor then
      segmentCount += 1
      local segStart = cursor
      local segFinish = opening.start
      local segLen = segFinish - segStart
      local segCenter = (segStart + segFinish) / 2
      local segment = BuilderUtil.findOrCreatePart(
        config.model,
        config.namePrefix .. "Seg" .. segmentCount,
        "Part"
      )
      BuilderUtil.applyPhysics(segment, true, true, false)
      if axis == "x" then
        segment.Size = Vector3.new(segLen, height, thickness)
        segment.CFrame = config.baseCFrame
          * CFrame.new(config.center + Vector3.new(segCenter, 0, 0))
      else
        segment.Size = Vector3.new(thickness, height, segLen)
        segment.CFrame = config.baseCFrame
          * CFrame.new(config.center + Vector3.new(0, 0, segCenter))
      end
      styleWall(segment, wallColor, material)
    end
    cursor = math.max(cursor, opening.finish)
  end

  if cursor < halfLen then
    segmentCount += 1
    local segStart = cursor
    local segFinish = halfLen
    local segLen = segFinish - segStart
    local segCenter = (segStart + segFinish) / 2
    local segment =
      BuilderUtil.findOrCreatePart(config.model, config.namePrefix .. "Seg" .. segmentCount, "Part")
    BuilderUtil.applyPhysics(segment, true, true, false)
    if axis == "x" then
      segment.Size = Vector3.new(segLen, height, thickness)
      segment.CFrame = config.baseCFrame * CFrame.new(config.center + Vector3.new(segCenter, 0, 0))
    else
      segment.Size = Vector3.new(thickness, height, segLen)
      segment.CFrame = config.baseCFrame * CFrame.new(config.center + Vector3.new(0, 0, segCenter))
    end
    styleWall(segment, wallColor, material)
  end

  local lintelCount = 0
  local sillCount = 0
  local openingFrames = {}
  for i, opening in ipairs(cleaned) do
    local openHeight = math.clamp(opening.height, 1, height)
    local bottom = math.clamp(opening.bottom or 0, 0, height - 1)
    local openTop = math.min(height, bottom + openHeight)
    local lintelHeight = height - openTop
    local sillHeight = bottom
    local offset = opening.offset
    local openingCenterY = bottom + (openHeight / 2)

    local openingCenter = config.center
    if axis == "x" then
      openingCenter = openingCenter + Vector3.new(offset, openingCenterY - config.center.Y, 0)
    else
      openingCenter = openingCenter + Vector3.new(0, openingCenterY - config.center.Y, offset)
    end

    openingFrames[i] = {
      cframe = config.baseCFrame * CFrame.new(openingCenter),
      normal = getWallNormal(config.baseCFrame, axis),
      width = opening.width,
      height = openHeight,
    }

    if lintelHeight > 0.1 then
      lintelCount += 1
      local lintel = BuilderUtil.findOrCreatePart(
        config.model,
        config.namePrefix .. "Lintel" .. lintelCount,
        "Part"
      )
      BuilderUtil.applyPhysics(lintel, true, true, false)
      if axis == "x" then
        lintel.Size = Vector3.new(opening.width, lintelHeight, thickness)
        lintel.CFrame = config.baseCFrame
          * CFrame.new(
            config.center + Vector3.new(offset, openTop + (lintelHeight / 2) - config.center.Y, 0)
          )
      else
        lintel.Size = Vector3.new(thickness, lintelHeight, opening.width)
        lintel.CFrame = config.baseCFrame
          * CFrame.new(
            config.center + Vector3.new(0, openTop + (lintelHeight / 2) - config.center.Y, offset)
          )
      end
      styleWall(lintel, wallColor, material)
    end

    if sillHeight > 0.1 then
      sillCount += 1
      local sill =
        BuilderUtil.findOrCreatePart(config.model, config.namePrefix .. "Sill" .. sillCount, "Part")
      BuilderUtil.applyPhysics(sill, true, true, false)
      if axis == "x" then
        sill.Size = Vector3.new(opening.width, sillHeight, thickness)
        sill.CFrame = config.baseCFrame
          * CFrame.new(config.center + Vector3.new(offset, (sillHeight / 2) - config.center.Y, 0))
      else
        sill.Size = Vector3.new(thickness, sillHeight, opening.width)
        sill.CFrame = config.baseCFrame
          * CFrame.new(config.center + Vector3.new(0, (sillHeight / 2) - config.center.Y, offset))
      end
      styleWall(sill, wallColor, material)
    end
  end

  local index = segmentCount + 1
  while true do
    local extra = config.model:FindFirstChild(config.namePrefix .. "Seg" .. index)
    if not extra then
      break
    end
    if extra:IsA("BasePart") then
      extra:Destroy()
    else
      extra.Name = config.namePrefix .. "Seg" .. index .. "_Unexpected"
    end
    index += 1
  end

  index = lintelCount + 1
  while true do
    local extra = config.model:FindFirstChild(config.namePrefix .. "Lintel" .. index)
    if not extra then
      break
    end
    if extra:IsA("BasePart") then
      extra:Destroy()
    else
      extra.Name = config.namePrefix .. "Lintel" .. index .. "_Unexpected"
    end
    index += 1
  end

  index = sillCount + 1
  while true do
    local extra = config.model:FindFirstChild(config.namePrefix .. "Sill" .. index)
    if not extra then
      break
    end
    if extra:IsA("BasePart") then
      extra:Destroy()
    else
      extra.Name = config.namePrefix .. "Sill" .. index .. "_Unexpected"
    end
    index += 1
  end

  return openingFrames
end

return WallBuilder
