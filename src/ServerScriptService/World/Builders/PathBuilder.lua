local BuilderUtil = require(script.Parent.BuilderUtil)
local CityLayout = require(script.Parent.CityLayout)

local PathBuilder = {}

local function getCardinalSide(fromCenter, toCenter)
  local delta = toCenter - fromCenter
  if math.abs(delta.X) > math.abs(delta.Z) then
    return delta.X > 0 and "east" or "west"
  end
  return delta.Z > 0 and "north" or "south"
end

local function getSideNormal(side)
  if side == "north" then
    return Vector3.new(0, 0, 1)
  elseif side == "south" then
    return Vector3.new(0, 0, -1)
  elseif side == "east" then
    return Vector3.new(1, 0, 0)
  elseif side == "west" then
    return Vector3.new(-1, 0, 0)
  end
  return Vector3.new(0, 0, 1)
end

function PathBuilder.Build(playground, constants)
  if not playground then
    return
  end

  local context = BuilderUtil.getPlaygroundContext(constants)
  if not context then
    return
  end

  local pathModel = BuilderUtil.findOrCreateModel(playground, constants.NAMES.Path)
  local PATH_W = 10
  local PATH_H = 1
  local PATH_L = 8
  local PATH_GAP = 0.5
  local stepDistance = PATH_L + PATH_GAP

  local layout = context.layout
  if not layout then
    return
  end

  local spawnBounds = CityLayout.getZoneBounds(layout, "spawn")
  local playgroundBounds = CityLayout.getZoneBounds(layout, "playground")
  local spawnCenter = spawnBounds and spawnBounds.center or layout.spawnCenter
  local playgroundCenter = playgroundBounds and playgroundBounds.center or context.playgroundCenter

  local spawnSide = getCardinalSide(spawnCenter, playgroundCenter)
  local playgroundSide = getCardinalSide(playgroundCenter, spawnCenter)
  local spawnNormal = getSideNormal(spawnSide)
  local playgroundNormal = getSideNormal(playgroundSide)
  local fenceThickness = 1.5

  local spawnEdge = CityLayout.getZoneAnchor(layout, "spawn", spawnSide, 0) or spawnCenter
  local playgroundEdge = CityLayout.getZoneAnchor(layout, "playground", playgroundSide, 0)
    or playgroundCenter

  local gatePos = playgroundEdge + (playgroundNormal * (fenceThickness / 2))
  gatePos = Vector3.new(gatePos.X, context.surfaceY + 0.5, gatePos.Z)
  local startPos = spawnEdge + (spawnNormal * ((PATH_L / 2) + 2))
  startPos = Vector3.new(startPos.X, context.surfaceY + 0.5, startPos.Z)

  local pathDir = gatePos - spawnCenter
  if pathDir.Magnitude < 0.01 then
    pathDir = Vector3.new(0, 0, 1)
  else
    pathDir = pathDir.Unit
  end

  local endPos = gatePos - (pathDir * (PATH_L / 2))
  endPos = Vector3.new(endPos.X, context.surfaceY + 0.5, endPos.Z)

  local pathAxis = (endPos - startPos).Unit
  local distance = (endPos - startPos).Magnitude
  local pathSegments = math.max(1, math.floor(distance / stepDistance))

  for i = 1, pathSegments do
    local segmentName = "PathSegment" .. i
    local segment = BuilderUtil.findOrCreatePart(pathModel, segmentName, "Part")
    BuilderUtil.applyPhysics(segment, true, true, false)
    segment.Size = Vector3.new(PATH_W, PATH_H, PATH_L)
    segment.Material = Enum.Material.Concrete
    segment.BrickColor = BrickColor.new("Medium stone grey")
    local centerPos = startPos + (pathAxis * (stepDistance * i))
    segment.CFrame = CFrame.new(centerPos, centerPos + pathAxis)
  end

  for _, child in ipairs(pathModel:GetChildren()) do
    if child:IsA("BasePart") then
      local index = tonumber(child.Name:match("^PathSegment(%d+)$"))
      if index and index > pathSegments then
        child:Destroy()
      end
    end
  end
end

return PathBuilder
