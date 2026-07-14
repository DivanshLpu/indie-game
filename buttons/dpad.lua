--- D-Pad class for the Buttons library.
-- Manages a 4-directional D-pad using an overlay image system.
-- Idle image is always drawn; pressed overlays are composited on top.
-- @classmod buttons.dpad

local Utils = require("buttons.utils")
local Button = require("buttons.button")
local Animation = require("buttons.animation")

local DPad = {}
DPad.__index = DPad

local DIRECTIONS = { "Up", "Down", "Left", "Right" }

local DIRECTION_OFFSETS = {
    Up    = { x =  0.0, y = -0.28 },
    Down  = { x =  0.0, y =  0.28 },
    Left  = { x = -0.28, y =  0.0 },
    Right = { x =  0.28, y =  0.0 },
}

function DPad.new(opts)
    opts = opts or {}
    local self = setmetatable({}, DPad)
    self.x = opts.x or 0.18
    self.y = opts.y or 0.72
    self.size = opts.size or 0.28
    self.visible = opts.visible ~= false
    self.idleImage = opts.idleImage or nil
    self.pressedImages = opts.pressedImages or {}
    self.anim = Animation.new()
    self._config = nil
    self._screenW = love and love.graphics and love.graphics.getWidth() or 800
    self._screenH = love and love.graphics and love.graphics.getHeight() or 600
    self.directions = {}
    local controls = opts.controls or {}
    for _, dir in ipairs(DIRECTIONS) do
        local btn = Button.new({
            id = dir, text = dir,
            x = self.x + (DIRECTION_OFFSETS[dir].x * self.size),
            y = self.y + (DIRECTION_OFFSETS[dir].y * self.size),
            size = self.size * 0.35,
            keys = controls[dir] or {},
            shape = "rect",
        })
        self.directions[dir] = btn
    end
    return self
end

function DPad:update(dt)
    for _, dir in ipairs(DIRECTIONS) do
        if self.directions[dir] then self.directions[dir]:update(dt) end
    end
    self.anim:update(dt)
end

function DPad:getPixelPosition()
    return Utils.normalizedToPixels(self.x, self.y, self._screenW, self._screenH)
end

function DPad:getPixelSize()
    return Utils.sizeToPixels(self.size, self._screenW, self._screenH)
end

--- Determine which direction a point hits.
-- @param px number Pixel x.
-- @param py number Pixel y.
-- @param touchScale number|nil Hit area scale.
-- @return string|nil Direction name or nil.
function DPad:containsPoint(px, py, touchScale)
    local bx, by = self:getPixelPosition()
    local bsize = self:getPixelSize()
    local half = bsize * 0.5 * (touchScale or 1.0)
    if px < (bx - half) or px > (bx + half) then return nil end
    if py < (by - half) or py > (by + half) then return nil end
    local relX, relY = px - bx, py - by
    if math.abs(relX) < half * 0.15 and math.abs(relY) < half * 0.15 then
        return "Center"
    end
    if math.abs(relX) > math.abs(relY) then
        return relX > 0 and "Right" or "Left"
    else
        return relY > 0 and "Down" or "Up"
    end
end

function DPad:pressDirection(direction)
    if self.directions[direction] then self.directions[direction]:pressByPointer() end
end

function DPad:releaseDirection(direction)
    if self.directions[direction] then self.directions[direction]:releaseByPointer() end
end

function DPad:pressKeyDirection(direction)
    if self.directions[direction] then self.directions[direction]:pressByKey() end
end

function DPad:releaseKeyDirection(direction)
    if self.directions[direction] then self.directions[direction]:releaseByKey() end
end

function DPad:releaseAllPointers()
    for _, dir in ipairs(DIRECTIONS) do
        if self.directions[dir] then self.directions[dir]._pointerHoldCount = 0 end
    end
end

function DPad:getDirection(direction)
    return self.directions[direction]
end

function DPad:resize(w, h)
    self._screenW = w
    self._screenH = h
    for _, dir in ipairs(DIRECTIONS) do
        if self.directions[dir] then
            self.directions[dir]._screenW = w
            self.directions[dir]._screenH = h
        end
    end
end

function DPad:getDirectionIDs()
    return DIRECTIONS
end

return DPad