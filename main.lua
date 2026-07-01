local Logger = require("core.logger")
local EventBus = require("core.eventbus")
local Config = require("core.config")
local Translator = require("core.translator")
local Fonts = require("core.fonts")
local PluginManager = require("core.pluginmanager")
local StateMachine = require("core.statemachine")
local ModLoader = require("core.modloader")
local MainMenu = require("ui.mainmenu")
local Settings = require("ui.settings")
local NewGame = require("ui.newgame")
local InGame = require("ui.ingame")
local SaveManager = require("savegame.savemanager")
local Events = require("core.events")

local log = Logger.new("main")
local stateMachine = StateMachine.new()
local saveManager = SaveManager.new()
local worldRef = { world = nil, player = nil }

function love.load()
  math.randomseed(os.time())
  love.graphics.setDefaultFilter("nearest", "nearest")
  Config:load("data/settings.json")
  Config.language = Config.language or "de"
  Config.uiStyle = Config.uiStyle or "retro"
  Fonts.setGlobalFont(Config.language)
  Translator:loadLanguage("en", "data/lang/en.json")
  Translator:loadLanguage("de", "data/lang/de.json")
  Translator:loadLanguage("zh", "data/lang/zh.json")
  Translator:setLanguage(Config.language)

  local fullscreen = Config.fullscreen or false
  if love.window and love.window.setFullscreen then
    love.window.setFullscreen(fullscreen, "desktop")
  end
  if love.window and love.window.setMode and love.graphics.getDimensions then
    local w, h = love.graphics.getDimensions()
    love.window.setMode(w, h, { fullscreen = fullscreen, resizable = true, vsync = true })
  end

  local Components = require("ui.components")
  Components.setTheme(Config.uiStyle)

  local pluginManager = PluginManager.new()
  ModLoader:loadAll(pluginManager)

  stateMachine:add("mainmenu", MainMenu)
  stateMachine:add("settings", Settings)
  stateMachine:add("newgame", NewGame)
  stateMachine:add("game", InGame)
  Events.register(stateMachine, worldRef, saveManager)
  stateMachine:change("mainmenu")
  log:info("Traders started")
end

function love.update(dt)
  stateMachine:update(dt)
  if worldRef.world then worldRef.world:update(dt) end
end

function love.draw()
  stateMachine:draw()
  if Config.showFPS then
    love.graphics.setColor(1, 1, 1, 0.85)
    love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 10, 10)
  end
end

function love.keypressed(key, scancode, isrepeat)
  stateMachine:keypressed(key, scancode, isrepeat)
end

function love.mousepressed(x, y, button)
  stateMachine:mousepressed(x, y, button)
end

function love.mousemoved(x, y, dx, dy)
  stateMachine:mousemoved(x, y, dx, dy)
end

function love.mousereleased(x, y, button)
  stateMachine:mousereleased(x, y, button)
end

function love.resize(w, h) end

function love.quit()
  log:info("Shutting down")
  if worldRef.world then EventBus:emit("game:save") end
  EventBus:clear()
end
