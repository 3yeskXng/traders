local Components = require("src.ui.components")
local EventBus = require("src.core.event")
local Logger = require("src.core.logger")
local log = Logger:new("gameui")

local GameUI = {}
GameUI.__index = GameUI

function GameUI:enter()
    self.selectedCity = nil
    self.cityView = false
    self.tradeAmount = 1
    self.hoveredCity = nil
    self.hoveredButton = nil
    self.info = ""
    self.infoTimer = 0
    log:info("Game UI opened")
end

function GameUI:leave() end

function GameUI:update(dt)
    if self.infoTimer > 0 then
        self.infoTimer = self.infoTimer - dt
    end
end

function GameUI:showInfo(text, duration)
    self.info = text
    self.infoTimer = duration or 3
end

function GameUI:draw()
    local ww, wh = love.graphics.getDimensions()
    local game = require("src.core.init").GlobalGame
    if not game then return end

    if not self.cityView and game.map then
        love.graphics.setColor(0.03, 0.04, 0.08)
        love.graphics.rectangle("fill", 0, 0, ww, wh)
        game.map:draw(game.cities, game.player.city, game.travel)
    end

    self:drawTopBar(game)
    self:drawCityList(game)
    self:drawCityInfoPopup(game)
    self:drawBottomBar(game)
    self:drawNotifications(game)
    self:drawInfoMessage()

    if self.cityView and self.selectedCity then
        self:drawCityMarket(game)
    end
end

function GameUI:drawTopBar(game)
    local ww, wh = love.graphics.getDimensions()
    love.graphics.setColor(0.06, 0.04, 0.02, 0.95)
    love.graphics.rectangle("fill", 0, 0, ww, 36)
    love.graphics.setColor(0.35, 0.28, 0.12)
    love.graphics.setLineWidth(0.5)
    love.graphics.line(0, 36, ww, 36)
    love.graphics.setColor(0.5, 0.45, 0.25)
    love.graphics.line(0, 37, ww, 37)
    love.graphics.setLineWidth(1)

    love.graphics.setColor(0.55, 0.45, 0.2)
    love.graphics.print("Hansa Traders", 12, 10)

    if game and game.time then
        local dateStr = game.time:getDateString()
        love.graphics.setColor(0.7, 0.65, 0.4)
        local tw = love.graphics.getFont():getWidth(dateStr)
        love.graphics.print(dateStr, (ww - tw) / 2, 10)
    end

    if game and game.player then
        local cityName = game.player.city and game.player.city.name or "-"
        local locStr = "Standort: " .. cityName
        love.graphics.setColor(0.5, 0.55, 0.7)
        love.graphics.print(locStr, 200, 10)
    end

    if game and game.player then
        local goldStr = tostring(game.player.gold) .. " G"
        local tw = love.graphics.getFont():getWidth(goldStr)
        love.graphics.setColor(1, 0.9, 0.4)
        love.graphics.print(goldStr, ww - tw - 12, 10)
    end

    if game and game.travel and game.travel.traveling then
        local info = game.travel:getInfo()
        if info then
            local travelStr = "Reise: " .. info.from .. " -> " .. info.to
            love.graphics.setColor(1, 0.7, 0.3)
            love.graphics.print(travelStr, ww / 2 + 100, 10)
        end
    end
end

function GameUI:drawCityList(game)
    local ww, wh = love.graphics.getDimensions()
    local panelW = 160
    Components.drawPanel(4, 40, panelW, wh - 80, "Städte")
    local y = 72
    love.graphics.setFont(love.graphics.newFont(13))
    if not game or not game.cities then return end
    for _, city in ipairs(game.cities) do
        local isCurrent = city == game.player.city
        local isSelected = city == self.selectedCity
        local isHovered = city == self.hoveredCity
        local r, g, b = 0.12, 0.1, 0.05
        if isSelected then r, g, b = 0.3, 0.25, 0.12 end
        if isHovered and not isSelected then r, g, b = 0.2, 0.17, 0.08 end
        love.graphics.setColor(r, g, b)
        love.graphics.rectangle("fill", 10, y, panelW - 16, 24, 3)
        if isCurrent then
            love.graphics.setColor(0.4, 0.35, 0.15)
            love.graphics.setLineWidth(1)
            love.graphics.rectangle("line", 10, y, panelW - 16, 24, 3)
        end
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(city.name, 16, y + 4)
        if isCurrent then
            love.graphics.setColor(0.8, 0.7, 0.3)
            love.graphics.print(">", 6, y + 4)
        end
        y = y + 27
    end
end

function GameUI:drawCityInfoPopup(game)
    if not self.selectedCity then return end
    local city = self.selectedCity
    local ww, wh = love.graphics.getDimensions()
    local px = ww - 210
    local py = 40
    local pw, ph = 206, 120
    Components.drawPanel(px, py, pw, ph, city.name)
    local font = love.graphics.getFont()
    love.graphics.setFont(love.graphics.newFont(12))
    local ly = py + 36
    love.graphics.setColor(0.6, 0.55, 0.4)
    love.graphics.print("Bev: " .. tostring(city.population), px + 10, ly); ly = ly + 16
    love.graphics.print("Wohlstand: " .. tostring(city.wealth), px + 10, ly); ly = ly + 16
    love.graphics.print("Waren: " .. #city.produces .. " produziert", px + 10, ly); ly = ly + 16
    love.graphics.setFont(font)
end

function GameUI:drawCityMarket(game)
    local ww, wh = love.graphics.getDimensions()
    local pw, ph = 700, 420
    local px, py = (ww - pw) / 2, (wh - ph) / 2
    Components.drawPanel(px, py, pw, ph, self.selectedCity.name .. " - Markt")

    local city = self.selectedCity
    local goodList = game and game.goods or {}
    local font = love.graphics.getFont()
    love.graphics.setFont(love.graphics.newFont(13))
    local ly = py + 38

    love.graphics.setColor(0.5, 0.45, 0.25)
    love.graphics.print("Ware", px + 15, ly)
    love.graphics.print("Bestand", px + 180, ly)
    love.graphics.print("Preis", px + 300, ly)
    love.graphics.print("Dein Lager", px + 390, ly)
    love.graphics.setColor(0.3, 0.25, 0.12)
    love.graphics.line(px + 12, ly + 16, px + pw - 12, ly + 16)
    ly = ly + 22

    for i, good in ipairs(goodList) do
        local stock = city.inventory and city.inventory[good.id] or 0
        local price = city.prices and city.prices[good.id] or good.basePrice
        local playerStock = game.player.inventory[good.id] or 0

        if i % 2 == 0 then
            love.graphics.setColor(0.08, 0.06, 0.03, 0.5)
            love.graphics.rectangle("fill", px + 8, ly - 2, pw - 16, 24)
        end

        love.graphics.setColor(0.75, 0.7, 0.5)
        love.graphics.print(good.name, px + 15, ly + 2)
        love.graphics.setColor(0.6, 0.65, 0.8)
        love.graphics.print(tostring(stock), px + 180, ly + 2)
        love.graphics.setColor(1, 0.9, 0.4)
        love.graphics.print(tostring(price) .. " G", px + 300, ly + 2)
        love.graphics.setColor(0.5, 0.6, 0.8)
        love.graphics.print(tostring(playerStock), px + 390, ly + 2)

        local bw, bh = 50, 20
        local bx1 = px + 440
        local isBuyHover = Components.isInRect(love.mouse.getX(), love.mouse.getY(), bx1, ly, bw, bh)
        Components.drawOrnateButton("Kauf", bx1, ly, bw, bh, false, isBuyHover)

        local bx2 = bx1 + bw + 4
        local isSellHover = Components.isInRect(love.mouse.getX(), love.mouse.getY(), bx2, ly, bw, bh)
        Components.drawOrnateButton("Verk", bx2, ly, bw, bh, false, isSellHover)

        ly = ly + 27
    end

    love.graphics.setFont(love.graphics.newFont(13))
    love.graphics.setColor(0.5, 0.45, 0.25)
    love.graphics.line(px + 12, ly, px + pw - 12, ly)

    local label = "Menge: " .. tostring(self.tradeAmount)
    love.graphics.setColor(0.6, 0.55, 0.4)
    love.graphics.print(label, px + 15, ly + 4)

    local bw2, bh2 = 30, 22
    for _, v in ipairs({1, 5, 10, 50, "Max"}) do
        local btx = px + 120 + (_ * 35)
        local isH = Components.isInRect(love.mouse.getX(), love.mouse.getY(), btx, ly + 2, bw2, bh2)
        Components.drawOrnateButton(tostring(v), btx, ly + 2, bw2, bh2, self.tradeAmount == v, isH)
    end

    Components.drawCloseButton(px + pw - 30, py + 8, 22)

    if self.hoveredCity and self.hoveredCity ~= self.selectedCity then
        local mx, my = love.mouse.getPosition()
        Components.drawTooltip(self.hoveredCity.name, mx, my)
    end

    love.graphics.setFont(font)
end

function GameUI:drawBottomBar(game)
    local ww, wh = love.graphics.getDimensions()
    love.graphics.setColor(0.06, 0.04, 0.02, 0.95)
    love.graphics.rectangle("fill", 0, wh - 34, ww, 34)
    love.graphics.setColor(0.35, 0.28, 0.12)
    love.graphics.setLineWidth(0.5)
    love.graphics.line(0, wh - 35, ww, wh - 35)
    love.graphics.setLineWidth(1)

    if game and game.time then
        local speedLabel = game.time:getSpeedLabel()
        love.graphics.setColor(0.5, 0.55, 0.7)
        love.graphics.print("Zeit: ", 12, wh - 27)
        love.graphics.setColor(0.8, 0.8, 1.0)
        love.graphics.print(speedLabel, 50, wh - 27)

        local btnSpeed = {x = 110, w = 26, label = "<"}
        local isH = Components.isInRect(love.mouse.getX(), love.mouse.getY(), btnSpeed.x, wh - 28, btnSpeed.w, 22)
        Components.drawOrnateButton(btnSpeed.label, btnSpeed.x, wh - 28, btnSpeed.w, 22, false, isH)
        local btnSpeed2 = {x = 140, w = 26, label = ">"}
        local isH2 = Components.isInRect(love.mouse.getX(), love.mouse.getY(), btnSpeed2.x, wh - 28, btnSpeed2.w, 22)
        Components.drawOrnateButton(btnSpeed2.label, btnSpeed2.x, wh - 28, btnSpeed2.w, 22, false, isH2)
    end

    local buttons = {
        {x = 200, label = "Speichern", id = "save"},
        {x = 300, label = "Menü", id = "menu"},
    }
    local bx = 200
    for _, btn in ipairs(buttons) do
        local isH = Components.isInRect(love.mouse.getX(), love.mouse.getY(), bx, wh - 28, 90, 22)
        Components.drawOrnateButton(btn.label, bx, wh - 28, 90, 22, false, isH)
        bx = bx + 100
    end

    local travelBtnX = ww - 160
    local isTravelCancel = game and game.travel and game.travel.traveling
    local travelLabel = isTravelCancel and "Reise abbrechen" or "Reisen"
    local isH = Components.isInRect(love.mouse.getX(), love.mouse.getY(), travelBtnX, wh - 28, 150, 22)
    Components.drawOrnateButton(travelLabel, travelBtnX, wh - 28, 150, 22, false, isH)
end

function GameUI:drawNotifications(game)
    if not game or not game.notifications then return end
    local ww, wh = love.graphics.getDimensions()
    game.notifications:draw(ww - 320, wh * 0.25, 310)
end

function GameUI:drawInfoMessage()
    if self.infoTimer <= 0 then return end
    local alpha = math.min(1, self.infoTimer)
    love.graphics.setColor(0.8, 0.7, 0.4, alpha * 0.9)
    local ww, wh = love.graphics.getDimensions()
    local tw = love.graphics.getFont():getWidth(self.info)
    love.graphics.print(self.info, (ww - tw) / 2, wh * 0.35)
end

function GameUI:keypressed(key)
    if key == "escape" then
        if self.cityView then
            self.cityView = false
            return
        end
        EventBus:emit("state:change", "mainmenu")
    end
end

function GameUI:mousepressed(x, y, button)
    if button ~= 1 then return end
    local ww, wh = love.graphics.getDimensions()
    local game = require("src.core.init").GlobalGame
    if not game then return true end

    if self.cityView and self.selectedCity then
        return self:handleMarketClick(x, y, game)
    end

    if y < 36 then return true end
    if y > wh - 34 then
        return self:handleBottomBarClick(x, y, game)
    end

    if self.selectedCity and x > ww - 210 and x < ww - 4 then
        return true
    end

    if game.cities then
        local panelW = 160
        if x >= 4 and x <= panelW + 4 then
            local yp = 72
            for _, city in ipairs(game.cities) do
                if Components.isInRect(x, y, 10, yp, panelW - 16, 24) then
                    if city == game.player.city then
                        self.selectedCity = city
                        self.cityView = true
                    else
                        EventBus:emit("travel:start", {city = city})
                    end
                    return true
                end
                yp = yp + 27
            end
        end
    end

    if game.map then
        local clicked = game.map:getCityAt(x, y, game.cities)
        if clicked then
            self.selectedCity = clicked
            if clicked == game.player.city then
                self.cityView = true
            end
            return true
        end
    end

    return true
end

function GameUI:handleMarketClick(x, y, game)
    local ww, wh = love.graphics.getDimensions()
    local pw, ph = 700, 420
    local px, py = (ww - pw) / 2, (wh - ph) / 2
    local goodList = game.goods or {}

    if Components.isInRect(x, y, px + pw - 30, py + 8, 22, 22) then
        self.cityView = false
        return true
    end

    local ly = py + 38 + 22
    for i, good in ipairs(goodList) do
        local bw, bh = 50, 20
        local bx1 = px + 440
        if Components.isInRect(x, y, bx1, ly, bw, bh) then
            local amount = self.tradeAmount
            if type(amount) == "string" and amount == "Max" then
                local price = self.selectedCity.prices[good.id] or good.basePrice
                amount = math.floor(game.player.gold / price)
            end
            EventBus:emit("trade:buy", {city = self.selectedCity, good = good, amount = amount})
            self:showInfo("Gekauft: " .. amount .. "x " .. good.name, 2)
            return true
        end
        local bx2 = bx1 + bw + 4
        if Components.isInRect(x, y, bx2, ly, bw, bh) then
            local amount = self.tradeAmount
            if type(amount) == "string" and amount == "Max" then
                amount = game.player.inventory[good.id] or 0
            end
            EventBus:emit("trade:sell", {city = self.selectedCity, good = good, amount = amount})
            self:showInfo("Verkauft: " .. amount .. "x " .. good.name, 2)
            return true
        end
        ly = ly + 27
    end

    local _, amtLy = py + 38, 0
    for _ in ipairs(goodList) do amtLy = amtLy + 27 end
    local yOff = amtLy + 22
    local bw2, bh2 = 30, 22
    local amountOptions = {1, 5, 10, 50, "Max"}
    for j, v in ipairs(amountOptions) do
        local btx = px + 120 + (j - 1) * 35
        if Components.isInRect(x, y, btx, py + 38 + yOff + 4, bw2, bh2) then
            self.tradeAmount = v
            return true
        end
    end

    return true
end

function GameUI:handleBottomBarClick(x, y, game)
    local ww, wh = love.graphics.getDimensions()

    if Components.isInRect(x, y, 200, wh - 28, 90, 22) then
        EventBus:emit("game:save")
        self:showInfo("Spiel gespeichert.", 2)
        return true
    end

    if Components.isInRect(x, y, 300, wh - 28, 90, 22) then
        EventBus:emit("state:change", "mainmenu")
        return true
    end

    if Components.isInRect(x, y, 110, wh - 28, 26, 22) then
        if game.time then
            game.time:prevSpeed()
            self:showInfo("Geschwindigkeit: " .. game.time:getSpeedLabel(), 1.5)
        end
        return true
    end

    if Components.isInRect(x, y, 140, wh - 28, 26, 22) then
        if game.time then
            game.time:nextSpeed()
            self:showInfo("Geschwindigkeit: " .. game.time:getSpeedLabel(), 1.5)
        end
        return true
    end

    local travelBtnX = ww - 160
    if Components.isInRect(x, y, travelBtnX, wh - 28, 150, 22) then
        if game.travel and game.travel.traveling then
            game.travel:cancel()
            self:showInfo("Reise abgebrochen.", 2)
        elseif self.selectedCity and self.selectedCity ~= game.player.city then
            local ok = game.travel:startTravel(game.player.city, self.selectedCity)
            if ok then
                self:showInfo("Reise nach " .. self.selectedCity.name .. " begonnen.", 2)
            end
        else
            self:showInfo("Wähle eine andere Stadt zum Reisen.", 2)
        end
        return true
    end

    return true
end

function GameUI:mousemoved(x, y, dx, dy)
    local game = require("src.core.init").GlobalGame
    local ww, wh = love.graphics.getDimensions()
    self.hoveredCity = nil

    if self.cityView then return end

    if game and game.cities then
        local panelW = 160
        if x >= 4 and x <= panelW + 4 then
            local yp = 72
            for _, city in ipairs(game.cities) do
                if Components.isInRect(x, y, 10, yp, panelW - 16, 24) then
                    self.hoveredCity = city
                    return
                end
                yp = yp + 27
            end
        end
    end

    if game and game.map then
        local city = game.map:getCityAt(x, y, game.cities)
        if city then
            self.hoveredCity = city
            game.map.hoveredCity = city
        else
            game.map.hoveredCity = nil
        end
    end
end

return GameUI
