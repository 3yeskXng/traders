local Logger = require("core.logger")
local State = require("rendering.map.state")
local Updater = require("rendering.map.updater")
local Renderer = require("rendering.map.renderer")
local Interaction = require("rendering.map.interaction")
local log = Logger.new("maprenderer")

local MapRenderer = {}
MapRenderer.__index = MapRenderer

function MapRenderer.new()
  return setmetatable(State.new(), { __index = MapRenderer })
end

function MapRenderer:update(dt, world)
  Updater.update(self, dt, world)
end

function MapRenderer:draw(w, h, world)
  Renderer.draw(self, w, h, world)
end

function MapRenderer:screenToWorld(sx, sy)
  return Interaction.screenToWorld(self, sx, sy)
end

function MapRenderer:getCityAt(sx, sy, w, h, world)
  return Interaction.getCityAt(self, sx, sy, w, h, world)
end

function MapRenderer:startDrag(x, y)
  Interaction.startDrag(self, x, y)
end

function MapRenderer:updateDrag(x, y)
  Interaction.updateDrag(self, x, y)
end

function MapRenderer:stopDrag()
  Interaction.stopDrag(self)
end

return MapRenderer
