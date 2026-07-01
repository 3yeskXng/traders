local Notifications = {}

function Notifications.add(list, text, color)
  table.insert(list, { text = text, color = color or { 0.9, 0.9, 0.6 }, ttl = 4 })
end

function Notifications.update(list, dt)
  for i = #list, 1, -1 do
    list[i].ttl = list[i].ttl - dt
    if list[i].ttl <= 0 then
      table.remove(list, i)
    end
  end
end

function Notifications.draw(list, w, h)
  if not list then return end
  local ny = h * 0.15
  for _, n in ipairs(list) do
    local alpha = math.min(1, n.ttl)
    love.graphics.setColor(n.color[1], n.color[2], n.color[3], alpha)
    love.graphics.printf(n.text, w * 0.3, ny, w * 0.4, "center")
    ny = ny + 22
  end
end

return Notifications
