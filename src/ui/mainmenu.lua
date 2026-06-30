local Components = require("src.ui.components")
local EventBus = require("src.core.event")
local Logger = require("src.core.logger")
local log = Logger:new("mainmenu")

local MainMenu = {}
MainMenu.__index = MainMenu
MainMenu.selected = 1
MainMenu.time = 0
MainMenu.items = {
    {id = "new", label = "Neues Spiel"},
    {id = "load", label = "Spiel laden"},
    {id = "settings", label = "Einstellungen"},
    {id = "quit", label = "Beenden"}
}

function MainMenu:enter()
    self.selected = 1
    self.time = 0
    log:info("Main menu opened")
end

function MainMenu:leave() end

function MainMenu:update(dt)
    self.time = self.time + dt
end

function MainMenu:draw()
    local ww, wh = love.graphics.getDimensions()
    local t = self.time

    love.graphics.setColor(0.03, 0.04, 0.08)
    love.graphics.rectangle("fill", 0, 0, ww, wh)

    for i = 0, 50 do
        local bright = 0.02 + math.random() * 0.03
        love.graphics.setColor(bright, bright * 1.2, bright * 1.5)
        local sx = math.random() * ww
        local sy = math.random() * wh * 0.6
        love.graphics.rectangle("fill", sx, sy, 1.5, 1.5)
    end
    math.randomseed(os.time())

    love.graphics.setColor(0.05, 0.08, 0.15, 0.3)
    for i = 0, 5 do
        local wx = 0
        local wy = wh * 0.6 + i * 20
        Components.drawWave(wx, wy, ww, 3 + math.sin(t + i) * 0.5, t * 1.5 + i, {0.05, 0.1, 0.2, 0.15})
    end

    Components.drawCompass(ww - 120, 120, 60)

    love.graphics.setColor(0.12, 0.1, 0.06, 0.3)
    love.graphics.rectangle("fill", ww * 0.5 - 200, 10, 400, 90)

    love.graphics.setColor(0.5, 0.4, 0.2, 0.4)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", ww * 0.5 - 200, 10, 400, 90)
    love.graphics.setLineWidth(1)

    love.graphics.setColor(0.5, 0.4, 0.2, 0.3)
    local decoW = 300
    love.graphics.line(ww * 0.5 - decoW, wh * 0.28, ww * 0.5 - 20, wh * 0.28)
    love.graphics.line(ww * 0.5 + 20, wh * 0.28, ww * 0.5 + decoW, wh * 0.28)
    love.graphics.circle("fill", ww * 0.5 - decoW, wh * 0.28, 3)
    love.graphics.circle("fill", ww * 0.5 + decoW, wh * 0.28, 3)

    love.graphics.setFont(love.graphics.newFont(56))
    love.graphics.setColor(0.1, 0.08, 0.04)
    local title = "Hansa Traders"
    local tw = love.graphics.getFont():getWidth(title)
    love.graphics.print(title, (ww - tw) / 2 + 2, wh * 0.15 + 2)

    love.graphics.setColor(0.8, 0.7, 0.35)
    love.graphics.print(title, (ww - tw) / 2, wh * 0.15)

    love.graphics.setColor(0.9, 0.85, 0.55, 0.3)
    love.graphics.setFont(love.graphics.newFont(14))
    local subtitle = "Eine mittelalterliche Handelssimulation"
    local stw = love.graphics.getFont():getWidth(subtitle)
    love.graphics.print(subtitle, (ww - stw) / 2, wh * 0.15 + 62)

    local btnW, btnH = 280, 50
    local startY = wh * 0.4
    local gap = 62

    for i, item in ipairs(self.items) do
        local bx = (ww - btnW) / 2
        local by = startY + (i - 1) * gap
        Components.drawOrnateButton(item.label, bx, by, btnW, btnH, i == self.selected)
    end

    love.graphics.setColor(0.3, 0.25, 0.15)
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.print("v0.1.0", 10, wh - 15)
end

function MainMenu:keypressed(key)
    if key == "up" then
        self.selected = ((self.selected - 2) % #self.items) + 1
    elseif key == "down" then
        self.selected = (self.selected % #self.items) + 1
    elseif key == "return" or key == "space" then
        self:activateItem()
    elseif key == "escape" then
        love.event.quit()
    end
end

function MainMenu:mousepressed(x, y, button)
    if button ~= 1 then return end
    local ww, wh = love.graphics.getDimensions()
    local btnW, btnH = 280, 50
    local startY = wh * 0.4
    local gap = 62
    for i, item in ipairs(self.items) do
        local bx = (ww - btnW) / 2
        local by = startY + (i - 1) * gap
        if Components.isInRect(x, y, bx, by, btnW, btnH) then
            self.selected = i
            self:activateItem()
            return true
        end
    end
end

function MainMenu:mousemoved(x, y, dx, dy)
    local ww, wh = love.graphics.getDimensions()
    local btnW, btnH = 280, 50
    local startY = wh * 0.4
    local gap = 62
    for i, item in ipairs(self.items) do
        local bx = (ww - btnW) / 2
        local by = startY + (i - 1) * gap
        if Components.isInRect(x, y, bx, by, btnW, btnH) then
            self.selected = i
            return
        end
    end
end

function MainMenu:activateItem()
    local item = self.items[self.selected]
    log:info("Menu item selected: %s", item.id)
    if item.id == "new" then
        EventBus:emit("game:new")
    elseif item.id == "load" then
        EventBus:emit("game:load")
    elseif item.id == "settings" then
        EventBus:emit("state:change", "settings")
    elseif item.id == "quit" then
        love.event.quit()
    end
end

return MainMenu
