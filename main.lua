local Logger = require("src.core.logger")
local EventBus = require("src.core.event")
local StateMachine = require("src.core.state")
local Core = require("src.core.init")
local log = Logger:new("main")

local stateMachine
local game

function love.load()
    math.randomseed(os.time())
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setFont(love.graphics.newFont(16))

    stateMachine = StateMachine:new()

    local MainMenu = require("src.ui.mainmenu")
    local Settings = require("src.ui.settings")
    local GameUI = require("src.ui.gameui")

    stateMachine:add("mainmenu", MainMenu)
    stateMachine:add("settings", Settings)
    stateMachine:add("game", GameUI)

    EventBus:on("state:change", function(data)
        stateMachine:change(data)
    end)

    EventBus:on("game:new", function()
        game = require("src.game"):new()
        if game:init() then
            Core.GlobalGame = game
            stateMachine:change("game")
        else
            log:error("Failed to start new game")
        end
    end)

    EventBus:on("game:load", function()
        game = require("src.game"):new()
        if game:init() then
            Core.GlobalGame = game
            if game.save:load(game, 1) then
                stateMachine:change("game")
            else
                log:warn("No save found, starting new game")
                stateMachine:change("game")
            end
        end
    end)

    EventBus:on("game:save", function()
        if game then
            game.save:save(game, 1)
        end
    end)

    EventBus:on("trade:buy", function(data)
        if game and game.trade then
            local bought = game.trade:buy(game.player, data.city, data.good.id, data.amount)
            if bought > 0 and game.notifications then
                game.notifications:add(string.format("%dx %s gekauft (%d G)", bought, data.good.name, bought * (data.city.prices[data.good.id] or 0)), "trade")
            end
        end
    end)

    EventBus:on("trade:sell", function(data)
        if game and game.trade then
            local sold = game.trade:sell(game.player, data.city, data.good.id, data.amount)
            if sold > 0 and game.notifications then
                game.notifications:add(string.format("%dx %s verkauft (%d G)", sold, data.good.name, sold * (data.city.prices[data.good.id] or 0)), "trade")
            end
        end
    end)

    EventBus:on("travel:start", function(data)
        if game and game.travel and game.player and data.city then
            local ok = game.travel:startTravel(game.player.city, data.city)
            if ok and game.notifications then
                game.notifications:add("Reise nach " .. data.city.name .. " begonnen.", "travel")
            end
        end
    end)

    stateMachine:change("mainmenu")
    log:info("Application started")
end

function love.update(dt)
    stateMachine:update(dt)
    if game and game.running then
        game:update(dt)
    end
end

function love.draw()
    stateMachine:draw()
end

function love.keypressed(key, scancode, isrepeat)
    stateMachine:keypressed(key, scancode, isrepeat)
end

function love.mousepressed(x, y, button)
    return stateMachine:mousepressed(x, y, button)
end

function love.mousemoved(x, y, dx, dy)
    stateMachine:mousemoved(x, y, dx, dy)
end

function love.resize(w, h) end

function love.quit()
    log:info("Application shutting down")
    if game then game:cleanup() end
end
