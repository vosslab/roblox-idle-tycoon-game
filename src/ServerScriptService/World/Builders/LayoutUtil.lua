local CityLayout = require(script.Parent.CityLayout)

local LayoutUtil = {}

function LayoutUtil.getGroundY(baseplate)
  if not baseplate then
    return nil
  end
  return baseplate.Position.Y + (baseplate.Size.Y / 2)
end

function LayoutUtil.getSurfaceY(baseplate, thickness)
  local groundY = LayoutUtil.getGroundY(baseplate)
  if not groundY then
    return nil
  end
  return groundY + (thickness or 0)
end

function LayoutUtil.anchor(layout, zoneName, side, offset)
  if not layout then
    return nil
  end
  return CityLayout.getZoneAnchor(layout, zoneName, side, offset)
end

function LayoutUtil.placeOnSurface(position, surfaceY, yOffset)
  if not position or not surfaceY then
    return nil
  end
  return Vector3.new(position.X, surfaceY + (yOffset or 0), position.Z)
end

return LayoutUtil
