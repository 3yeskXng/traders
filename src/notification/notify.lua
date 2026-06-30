local Logger = require("src.core.logger")
local log = Logger:new("notify")

local Notifications = {}
Notifications.__index = Notifications

function Notifications:new(maxMessages)
    return setmetatable({
        messages = {},
        maxMessages = maxMessages or 20,
        duration = 6.0
    }, self)
end

function Notifications:add(text, category)
    local msg = {
        text = text,
        category = category or "info",
        time = 0,
    }
    table.insert(self.messages, msg)
    if #self.messages > self.maxMessages then
        table.remove(self.messages, 1)
    end
    log:info("[%s] %s", msg.category, text)
end

function Notifications:update(dt)
    for i = #self.messages, 1, -1 do
        self.messages[i].time = self.messages[i].time + dt
        if self.messages[i].time > self.duration then
            table.remove(self.messages, i)
        end
    end
end

function Notifications:draw(x, y, w)
    local font = love.graphics.getFont()
    local ly = y
    love.graphics.setFont(love.graphics.newFont(13))
    for i = #self.messages, 1, -1 do
        local msg = self.messages[i]
        local alpha = 1.0
        if msg.time > self.duration - 1.5 then
            alpha = (self.duration - msg.time) / 1.5
        end
        local catColors = {
            info = {0.7, 0.8, 1.0},
            trade = {0.6, 1.0, 0.6},
            travel = {1.0, 0.8, 0.5},
            warning = {1.0, 0.6, 0.4},
            gold = {1.0, 0.9, 0.4}
        }
        local col = catColors[msg.category] or catColors.info
        love.graphics.setColor(col[1], col[2], col[3], alpha * 0.9)
        love.graphics.print(msg.text, x, ly)
        ly = ly + 18
    end
    love.graphics.setFont(font)
end

function Notifications:serialize()
    return {}
end

function Notifications:deserialize() end

return Notifications
