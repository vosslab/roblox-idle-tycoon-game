local CityLayout = {}

CityLayout.GRID_STEP = 100
CityLayout.PLAYGROUND_EXTRA = 50
CityLayout.OFFSETS = {
  spawn = Vector3.new(0, 0, 0),
  playground = Vector3.new(0, 0, CityLayout.GRID_STEP + CityLayout.PLAYGROUND_EXTRA),
  school = Vector3.new(0, 0, -CityLayout.GRID_STEP),
  neighborhood = Vector3.new(CityLayout.GRID_STEP, 0, 0),
  shopping = Vector3.new(-CityLayout.GRID_STEP, 0, 0),
  gas = Vector3.new(-CityLayout.GRID_STEP - 10, 0, -CityLayout.GRID_STEP - 60),
}
CityLayout.ZONES = {
  playground = {
    width = 140,
    length = 60,
    origin = "center",
    centerKey = "playgroundCenter",
  },
  school = {
    width = 120,
    length = 80,
    origin = "center",
    centerKey = "schoolCenter",
  },
  spawn = {
    width = 48,
    length = 32,
    origin = "center",
    centerKey = "spawnCenter",
  },
  shopping = {
    width = 120,
    length = 120,
    origin = "center",
    centerKey = "shoppingCenter",
  },
  neighborhood = {
    width = 140,
    length = 140,
    origin = "center",
    centerKey = "neighborhoodCenter",
  },
  gas = {
    width = 110,
    length = 90,
    origin = "center",
    centerKey = "gasCenter",
  },
}

local function safeUnit(vector)
  if vector.Magnitude > 0.01 then
    return vector.Unit
  end
  return Vector3.new(0, 0, -1)
end

local function getAnchorNormal(side)
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

function CityLayout.getLayout(baseplate)
  if not baseplate then
    return nil
  end

  local groundY = baseplate.Position.Y + (baseplate.Size.Y / 2)
  local baseCenter = Vector3.new(baseplate.Position.X, groundY, baseplate.Position.Z)

  local offsets = CityLayout.OFFSETS

  local spawnCenter = baseCenter + offsets.spawn
  local playgroundCenter = baseCenter + offsets.playground
  local schoolCenter = baseCenter + offsets.school
  local neighborhoodCenter = baseCenter + offsets.neighborhood
  local shoppingCenter = baseCenter + offsets.shopping
  local gasCenter = baseCenter + offsets.gas

  return {
    baseCenter = baseCenter,
    playgroundCenter = playgroundCenter,
    zones = CityLayout.ZONES,
    spawnCenter = spawnCenter,
    schoolCenter = schoolCenter,
    shoppingCenter = shoppingCenter,
    gasCenter = gasCenter,
    neighborhoodCenter = neighborhoodCenter,
    spawnDirection = safeUnit(spawnCenter - playgroundCenter),
    schoolFacing = spawnCenter,
  }
end

function CityLayout.getZoneBounds(layout, zoneName)
  if not layout then
    return nil
  end
  local zone = CityLayout.ZONES[zoneName]
  if not zone then
    return nil
  end
  local center = layout[zone.centerKey]
  if not center then
    return nil
  end
  local size = Vector3.new(zone.width, 1, zone.length)
  local half = size / 2
  if zone.origin == "northwest" then
    local min = Vector3.new(center.X, center.Y, center.Z - zone.length)
    local max = Vector3.new(center.X + zone.width, center.Y, center.Z)
    return {
      center = center + Vector3.new(zone.width / 2, 0, -zone.length / 2),
      size = size,
      half = half,
      min = min,
      max = max,
    }
  end
  return {
    center = center,
    size = size,
    half = half,
    min = center - half,
    max = center + half,
  }
end

function CityLayout.getZoneAnchor(layout, zoneName, side, offset)
  local bounds = CityLayout.getZoneBounds(layout, zoneName)
  if not bounds then
    return nil
  end

  local anchor = bounds.center
  if side == "north" then
    anchor = Vector3.new(bounds.center.X, bounds.center.Y, bounds.max.Z)
  elseif side == "south" then
    anchor = Vector3.new(bounds.center.X, bounds.center.Y, bounds.min.Z)
  elseif side == "east" then
    anchor = Vector3.new(bounds.max.X, bounds.center.Y, bounds.center.Z)
  elseif side == "west" then
    anchor = Vector3.new(bounds.min.X, bounds.center.Y, bounds.center.Z)
  end

  if offset and offset ~= 0 then
    anchor = anchor + (getAnchorNormal(side) * offset)
  end

  return anchor
end

function CityLayout.getZoneFootprints(layout)
  if not layout then
    return nil
  end
  local footprints = {}
  for name, _ in pairs(CityLayout.ZONES) do
    local bounds = CityLayout.getZoneBounds(layout, name)
    if bounds then
      footprints[name] = bounds
    end
  end
  return footprints
end

function CityLayout.getOverlaps(layout)
  local footprints = CityLayout.getZoneFootprints(layout)
  if not footprints then
    return nil
  end

  local names = {}
  for name, _ in pairs(footprints) do
    table.insert(names, name)
  end

  local overlaps = {}
  for i = 1, #names do
    for j = i + 1, #names do
      local a = footprints[names[i]]
      local b = footprints[names[j]]
      if a and b then
        local overlapX = a.min.X <= b.max.X and a.max.X >= b.min.X
        local overlapZ = a.min.Z <= b.max.Z and a.max.Z >= b.min.Z
        if overlapX and overlapZ then
          table.insert(overlaps, {
            a = names[i],
            b = names[j],
          })
        end
      end
    end
  end

  return overlaps
end

return CityLayout
