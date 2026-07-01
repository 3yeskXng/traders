local MapIslands = {}

function MapIslands.drawIslands(mapConfig, w, h)
  for _, island in ipairs(mapConfig.islands) do
    local coords = {}
    for _, pt in ipairs(island.points) do
      table.insert(coords, pt[1] * w)
      table.insert(coords, pt[2] * h)
    end
    if #coords >= 6 then
      love.graphics.setColor(0.82, 0.75, 0.55)
      love.graphics.polygon("fill", coords)
      love.graphics.setColor(0.4, 0.32, 0.2, 0.8)
      love.graphics.setLineWidth(2)
      love.graphics.polygon("line", coords)
      love.graphics.setLineWidth(1)
    end
    love.graphics.setColor(0.4, 0.32, 0.2, 0.6)
    love.graphics.print(island.name, island.x * w + 8, island.y * h - 5)
  end
end

return MapIslands
