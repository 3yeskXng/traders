local Components = require("src.ui.components")
local EventBus = require("src.core.event")
local Logger = require("src.core.logger")
local json = require("src.lib.json")
local log = Logger:new("settings")

local Settings = {}
Settings.__index = Settings
Settings.settings = {}
Settings.keys = {"masterVolume", "musicVolume", "sfxVolume", "showFPS", "fullscreen"}
Settings.labels = {
    masterVolume = "Master-Lautstärke",
    musicVolume = "Musik-Lautstärke",
    sfxVolume = "SFX-Lautstärke",
    showFPS = "FPS anzeigen",
    fullscreen = "Vollbild"
}
Settings.selected = 1
Settings.dirty = false

function Settings:enter()
    self.selected = 1
    self:loadSettings()
    log:info("Settings opened")
end

function Settings:leave()
    if self.dirty then
        self:saveSettings()
        self.dirty = false
    end
end

function Settings:loadSettings()
    local ok, data = pcall(love.filesystem.read, "settings.json")
    if ok and data then
        local decoded, err = json.decode(data)
        if decoded then
            self.settings = decoded
        end
    end
    if not self.settings or not next(self.settings) then
        self.settings = {
            masterVolume = 80, musicVolume = 70, sfxVolume = 80,
            fullscreen = false, showFPS = false, scrollSpeed = 1.0
        }
    end
end

function Settings:saveSettings()
    local ok, err = pcall(love.filesystem.write, "settings.json",
        json.encode(self.settings))
    if ok then
        log:info("Settings saved")
    else
        log:error("Failed to save settings: %s", tostring(err))
    end
end

function Settings:update(dt) end

function Settings:draw()
    local ww, wh = love.graphics.getDimensions()

    love.graphics.setColor(0.03, 0.04, 0.08)
    love.graphics.rectangle("fill", 0, 0, ww, wh)

    love.graphics.setColor(0.5, 0.4, 0.2, 0.4)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", ww * 0.5 - 200, 15, 400, 45)

    love.graphics.setFont(love.graphics.newFont(36))
    love.graphics.setColor(0.1, 0.08, 0.04)
    local title = "Einstellungen"
    local tw = love.graphics.getFont():getWidth(title)
    love.graphics.print(title, (ww - tw) / 2 + 2, 22)
    love.graphics.setColor(0.8, 0.7, 0.35)
    love.graphics.print(title, (ww - tw) / 2, 20)

    love.graphics.setFont(love.graphics.newFont(16))
    local panelX = ww * 0.5 - 200
    local panelW = 400
    local startY = 100
    local lineH = 50

    love.graphics.setColor(0.08, 0.06, 0.04, 0.9)
    love.graphics.rectangle("fill", panelX - 10, startY - 10, panelW + 20, lineH * 5 + 20, 6)
    love.graphics.setColor(0.3, 0.25, 0.15)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", panelX - 10, startY - 10, panelW + 20, lineH * 5 + 20, 6)

    local function drawSliderSetting(key, index)
        local y = startY + (index - 1) * lineH
        local val = self.settings[key] or 80
        local selected = (index == self.selected)
        if selected then
            love.graphics.setColor(0.2, 0.18, 0.1, 0.5)
            love.graphics.rectangle("fill", panelX, y - 5, panelW, 40, 4)
            love.graphics.setColor(0.4, 0.35, 0.15)
            love.graphics.setLineWidth(1)
            love.graphics.rectangle("line", panelX, y - 5, panelW, 40, 4)
        end
        love.graphics.setColor(0.75, 0.7, 0.5)
        love.graphics.print(self.labels[key] or key, panelX + 10, y + 5)
        Components.drawSlider(panelX + 200, y + 4, 140, val, 0, 100)
        love.graphics.setColor(1, 0.9, 0.5)
        love.graphics.print(tostring(math.floor(val)), panelX + 350, y + 5)
    end

    local function drawToggleSetting(key, index)
        local y = startY + (index - 1) * lineH
        local val = self.settings[key] or false
        local selected = (index == self.selected)
        if selected then
            love.graphics.setColor(0.2, 0.18, 0.1, 0.5)
            love.graphics.rectangle("fill", panelX, y - 5, panelW, 40, 4)
            love.graphics.setColor(0.4, 0.35, 0.15)
            love.graphics.setLineWidth(1)
            love.graphics.rectangle("line", panelX, y - 5, panelW, 40, 4)
        end
        love.graphics.setColor(0.75, 0.7, 0.5)
        love.graphics.print(self.labels[key] or key, panelX + 10, y + 5)
        if val then
            love.graphics.setColor(0.4, 0.5, 0.2)
            love.graphics.rectangle("fill", panelX + 200, y + 2, 60, 22, 4)
            love.graphics.setColor(0.8, 0.9, 0.6)
            love.graphics.print("An", panelX + 220, y + 5)
        else
            love.graphics.setColor(0.4, 0.2, 0.15)
            love.graphics.rectangle("fill", panelX + 200, y + 2, 60, 22, 4)
            love.graphics.setColor(0.7, 0.5, 0.4)
            love.graphics.print("Aus", panelX + 218, y + 5)
        end
    end

    drawSliderSetting("masterVolume", 1)
    drawSliderSetting("musicVolume", 2)
    drawSliderSetting("sfxVolume", 3)
    drawToggleSetting("showFPS", 4)
    drawToggleSetting("fullscreen", 5)

    Components.drawOrnateButton("Zurück", ww / 2 - 100, wh - 80, 200, 45, false)
end

function Settings:keypressed(key)
    if key == "up" then
        self.selected = ((self.selected - 2) % 5) + 1
    elseif key == "down" then
        self.selected = (self.selected % 5) + 1
    elseif key == "left" or key == "right" then
        local k = self.keys[self.selected]
        if not k then return end
        if k == "showFPS" or k == "fullscreen" then
            self.settings[k] = not self.settings[k]
        else
            local step = key == "left" and -5 or 5
            self.settings[k] = math.max(0, math.min(100, (self.settings[k] or 80) + step))
        end
        self.dirty = true
    elseif key == "escape" or key == "return" then
        self:leave()
        EventBus:emit("state:change", "mainmenu")
    end
end

function Settings:mousepressed(x, y, button)
    local ww, wh = love.graphics.getDimensions()
    if button == 1 then
        if Components.isInRect(x, y, ww / 2 - 100, wh - 80, 200, 45) then
            self:leave()
            EventBus:emit("state:change", "mainmenu")
            return true
        end
    end
end

function Settings:mousemoved(x, y, dx, dy) end

return Settings
