local Satellite = {}

local SEED = 42
local cachedCanvas = nil
local cachedConfig = nil
local lastW, lastH = 0, 0

local function sampleNoise(x, y)
  local n1 = love.math.noise(x * 3, y * 3, SEED)
  local n2 = love.math.noise(x * 6, y * 6, SEED + 1) * 0.5
  local n3 = love.math.noise(x * 12, y * 12, SEED + 2) * 0.25
  return n1 + n2 + n3
end

local function isOnLand(wx, wy, mapConfig)
  if not mapConfig then return false end
  for _, poly in ipairs(mapConfig.landPolygons or {}) do
    if mapConfig:pointInPolygon(wx, wy, poly.points) then
      return true
    end
  end
  for _, island in ipairs(mapConfig.islands or {}) do
    if mapConfig:pointInPolygon(wx, wy, island.points) then
      return true
    end
  end
  return false
end

function Satellite.generateOrGet(w, h, mapConfig)
  if cachedCanvas and cachedConfig == mapConfig and lastW == w and lastH == h then
    return cachedCanvas
  end

  local size = math.max(256, math.floor(math.min(w, h) * 0.5))
  local imgData = love.image.newImageData(size, size)

  for y = 0, size - 1 do
    for x = 0, size - 1 do
      local wx = (x + 0.5) / size
      local wy = (y + 0.5) / size

      local noise = sampleNoise(wx, wy)
      local onLand = isOnLand(wx, wy, mapConfig)

      local r, g, b

      if onLand then
        local h = noise * 0.5 + 0.55
        if h < 0.42 then
          local t = (h - 0.35) / 0.07
          r = 0.72 + (0.62 - 0.72) * t
          g = 0.65 + (0.55 - 0.65) * t
          b = 0.45 + (0.38 - 0.45) * t
        elseif h < 0.55 then
          local t = (h - 0.42) / 0.13
          r = 0.62 + (0.42 - 0.62) * t
          g = 0.55 + (0.58 - 0.55) * t
          b = 0.38 + (0.28 - 0.38) * t
        elseif h < 0.68 then
          local t = (h - 0.55) / 0.13
          r = 0.42 + (0.22 - 0.42) * t
          g = 0.58 + (0.48 - 0.58) * t
          b = 0.28 + (0.18 - 0.28) * t
        elseif h < 0.80 then
          local t = (h - 0.68) / 0.12
          r = 0.22 + (0.48 - 0.22) * t
          g = 0.48 + (0.42 - 0.48) * t
          b = 0.18 + (0.22 - 0.18) * t
        else
          local t = math.min(1, (h - 0.80) / 0.20)
          r = 0.48 + (0.78 - 0.48) * t
          g = 0.42 + (0.76 - 0.42) * t
          b = 0.22 + (0.82 - 0.22) * t
        end
      else
        local depth = math.min(1, noise * 0.6 + 0.5)
        if depth < 0.5 then
          local t = depth / 0.5
          r = 0.06 + (0.08 - 0.06) * t
          g = 0.15 + (0.22 - 0.15) * t
          b = 0.30 + (0.38 - 0.30) * t
        else
          local t = (depth - 0.5) / 0.5
          r = 0.08 + (0.12 - 0.08) * t
          g = 0.22 + (0.30 - 0.22) * t
          b = 0.38 + (0.48 - 0.38) * t
        end
      end

      imgData:setPixel(x, y, r, g, b, 1)
    end
  end

  local img = love.graphics.newImage(imgData)
  img:setFilter("nearest", "nearest")
  cachedCanvas = img
  cachedConfig = mapConfig
  lastW, lastH = w, h
  return cachedCanvas
end

function Satellite.draw(w, h, mapConfig)
  local canvas = Satellite.generateOrGet(w, h, mapConfig)
  local cw, ch = canvas:getDimensions()
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(canvas, 0, 0, 0, w / cw, h / ch)
end

function Satellite.invalidate()
  cachedCanvas = nil
  cachedConfig = nil
  lastW, lastH = 0, 0
end

return Satellite
