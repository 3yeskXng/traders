local Logger = {}
Logger.__index = Logger

local levels = {DEBUG = 1, INFO = 2, WARN = 3, ERROR = 4}
local levelNames = {"DEBUG", "INFO", "WARN", "ERROR"}
local currentLevel = levels.INFO

function Logger:new(name)
    return setmetatable({name = name or "global"}, self)
end

function Logger:log(level, message, ...)
    if level < currentLevel then return end
    local info = debug.getinfo(2, "Sl")
    local source = info and info.short_src or "?"
    local line = info and info.currentline or "?"
    local args = {...}
    if #args > 0 then
        message = string.format(message, unpack(args))
    end
    local timestamp = os.date("%H:%M:%S")
    print(string.format("[%s] [%s] [%s:%s] %s: %s",
        timestamp, levelNames[level], source, line, self.name, message))
end

function Logger:debug(msg, ...) self:log(levels.DEBUG, msg, ...) end
function Logger:info(msg, ...) self:log(levels.INFO, msg, ...) end
function Logger:warn(msg, ...) self:log(levels.WARN, msg, ...) end
function Logger:error(msg, ...) self:log(levels.ERROR, msg, ...) end

function Logger.setLevel(level)
    currentLevel = levels[level] or levels.INFO
end

return Logger
