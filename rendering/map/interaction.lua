local Interaction = {}

function Interaction.screenToWorld(renderer, sx, sy)
  local scale = renderer.camera.scale or 1
  return sx / scale + renderer.camera.x, sy / scale + renderer.camera.y
end

function Interaction.getCityAt(renderer, sx, sy, w, h, world)
  local wx, wy = Interaction.screenToWorld(renderer, sx, sy)
  for _, city in ipairs(world.cities:getAll()) do
    local cx, cy = city.x * w, city.y * h
    local dx, dy = wx - cx, wy - cy
    if dx * dx + dy * dy <= 225 then
      return city
    end
  end
  return nil
end

function Interaction.startDrag(renderer, x, y)
  renderer.dragging = true
  renderer.dragStartX = x
  renderer.dragStartY = y
  renderer.dragCamX = renderer.camera.x
  renderer.dragCamY = renderer.camera.y
end

function Interaction.updateDrag(renderer, x, y)
  if not renderer.dragging then
    return
  end
  renderer.camera.x = renderer.dragCamX - (x - renderer.dragStartX)
  renderer.camera.y = renderer.dragCamY - (y - renderer.dragStartY)
end

function Interaction.stopDrag(renderer)
  renderer.dragging = false
end

return Interaction
