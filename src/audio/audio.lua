local Logger = require("src.core.logger")
local log = Logger:new("audio")

local AudioManager = {}
AudioManager.__index = AudioManager
AudioManager.sounds = {}
AudioManager.muted = false

function AudioManager:new()
    return setmetatable({sounds = {}, muted = false, volume = 0.5}, self)
end

function AudioManager:play(name)
    if self.muted then return end
    if not self.sounds[name] then
        self.sounds[name] = true
    end
end

function AudioManager:setVolume(vol)
    self.volume = math.max(0, math.min(1, vol))
end

function AudioManager:toggleMute()
    self.muted = not self.muted
    log:info("Audio %s", self.muted and "muted" or "unmuted")
end

function AudioManager:serialize()
    return {muted = self.muted, volume = self.volume}
end

function AudioManager:deserialize(data)
    self.muted = data.muted or false
    self.volume = data.volume or 0.5
end

return AudioManager
