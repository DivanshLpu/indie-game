--- Button class for the Buttons library.
-- Each virtual button is an instance of this class.
-- Manages state, input, hit-testing, and provides data to the renderer.
-- @classmod buttons.button

local Utils = require("buttons.utils")
local Animation = require("buttons.animation")

local Button = {}
Button.__index = Button

--- Create a new Button instance.
-- @param opts table Button configuration options.
-- @field opts.id string Unique identifier for this button.
-- @field opts.text string|nil Display text (default: id).
-- @field opts.x number Normalized x position (0-1).
-- @field opts.y number Normalized y position (0-1).
-- @field opts.size number Normalized size (0-1, relative to shortest dimension).
-- @field opts.keys table|nil Array of keyboard key bindings.
-- @field opts.idleImage string|nil Filename for the idle image.
-- @field opts.pressedImage string|nil Filename for the pressed image.
-- @field opts.visible boolean|nil Whether the button is drawn (default: true).
-- @field opts.enabled boolean|nil Whether the button accepts input (default: true).
-- @field opts.shape string|nil Shape for fallback drawing: "circle", "rect", "rounded" (default: "circle").
-- @field opts.font string|nil Font filename for button text.
-- @return Button A new Button object.
function Button.new(opts)
    opts = opts or {}
    local self = setmetatable({}, Button)

    self.id = opts.id or Utils.generateID()
    self.text = opts.text or opts.id or ""
    self.x = opts.x or 0.5
    self.y = opts.y or 0.5
    self.size = opts.size or 0.08
    self.keys = opts.keys or {}
    self.idleImage = opts.idleImage or nil
    self.pressedImage = opts.pressedImage or nil
    self.visible = opts.visible ~= false
    self.enabled = opts.enabled ~= false
    self.shape = opts.shape or "circle"
    self.font = opts.font or nil

    self._pressed = false
    self._justPressed = false
    self._justReleased = false
    self._holdTime = 0
    self._lastReleaseTime = 0
    self._doublePressed = false
    self._repeatTime = 0
    self._repeatFired = false
    self._keyHoldCount = 0
    self._pointerHoldCount = 0

    self.anim = Animation.new()
    self._config = nil
    self._screenW = love and love.graphics and love.graphics.getWidth() or 800
    self._screenH = love and love.graphics and love.graphics.getHeight() or 600

    return self
end

--- Update button state and animation each frame.
-- @param dt number Delta time in seconds.
function Button:update(dt)
    self._justPressed = false
    self._justReleased = false
    self._doublePressed = false
    self._repeatFired = false

    local wasPressed = self._pressed
    local isHeld = (self._keyHoldCount > 0) or (self._pointerHoldCount > 0)

    if isHeld and not wasPressed then
        self._pressed = true
        self._justPressed = true
        self._holdTime = 0
        self._repeatTime = 0
        self.anim:press()
    elseif not isHeld and wasPressed then
        self._pressed = false
        self._justReleased = true

        local currentTime = love and love.timer and love.timer.getTime() or 0
        local doubleWindow = self._config and self._config:get("doublePressWindow") or 0.30
        if (currentTime - self._lastReleaseTime) <= doubleWindow then
            self._doublePressed = true
        end
        self._lastReleaseTime = currentTime
        self.anim:release()
    end

    if self._pressed then
        self._holdTime = self._holdTime + dt
        local repeatDelay = self._config and self._config:get("repeatDelay") or 0.50
        local repeatInterval = self._config and self._config:get("repeatInterval") or 0.10
        if self._holdTime >= repeatDelay then
            self._repeatTime = self._repeatTime + dt
            if self._repeatTime >= repeatInterval then
                self._repeatTime = self._repeatTime - repeatInterval
                self._repeatFired = true
            end
        end
    end

    self.anim:update(dt)
end

--- Check if a screen-space point is within this button's hit area.
-- @param px number Pixel x coordinate.
-- @param py number Pixel y coordinate.
-- @param touchScale number|nil Scale factor for the hit area (default: 1.0).
-- @return boolean True if the point is within this button.
function Button:containsPoint(px, py, touchScale)
    touchScale = touchScale or 1.0
    local bx, by = self:getPixelPosition()
    local bsize = self:getPixelSize()
    local halfSize = bsize * 0.5 * touchScale

    if self.shape == "circle" then
        local dist = Utils.distance(bx, by, px, py)
        return dist <= halfSize
    else
        return px >= (bx - halfSize) and px <= (bx + halfSize)
           and py >= (by - halfSize) and py <= (by + halfSize)
    end
end

--- Mark that a keyboard key bound to this button has been pressed.
function Button:pressByKey()
    self._keyHoldCount = self._keyHoldCount + 1
end

--- Mark that a keyboard key bound to this button has been released.
function Button:releaseByKey()
    self._keyHoldCount = math.max(0, self._keyHoldCount - 1)
end

--- Mark that a pointer (touch/mouse) has pressed this button.
function Button:pressByPointer()
    self._pointerHoldCount = self._pointerHoldCount + 1
end

--- Mark that a pointer (touch/mouse) has released this button.
function Button:releaseByPointer()
    self._pointerHoldCount = math.max(0, self._pointerHoldCount - 1)
end

--- Get the pixel position of this button's center.
-- @return number Pixel x, number Pixel y.
function Button:getPixelPosition()
    return Utils.normalizedToPixels(self.x, self.y, self._screenW, self._screenH)
end

--- Get the pixel size of this button.
-- @return number Size in pixels.
function Button:getPixelSize()
    return Utils.sizeToPixels(self.size, self._screenW, self._screenH)
end

--- Notify the button of a screen resize.
-- @param w number New screen width.
-- @param h number New screen height.
function Button:resize(w, h)
    self._screenW = w
    self._screenH = h
end

--- Get the button's current pressed state.
-- @return boolean True if currently pressed.
function Button:isDown()
    return self._pressed and self.enabled
end

--- Get whether the button was just pressed this frame.
-- @return boolean True on the first frame of a press.
function Button:isPressed()
    return self._justPressed and self.enabled
end

--- Get whether the button was just released this frame.
-- @return boolean True on the frame of release.
function Button:isReleased()
    return self._justReleased and self.enabled
end

--- Get whether the button is in the "up" (not pressed) state.
-- @return boolean True if not pressed.
function Button:isUp()
    return not self._pressed and self.enabled
end

--- Get whether the button has been held beyond the hold threshold.
-- @return boolean True if held long enough.
function Button:isHeld()
    if not self._pressed or not self.enabled then return false end
    local holdThreshold = self._config and self._config:get("holdThreshold") or 0.50
    return self._holdTime >= holdThreshold
end

--- Get the duration the button has been held.
-- @return number Seconds held (0 if not pressed).
function Button:duration()
    if not self._pressed then return 0 end
    return self._holdTime
end

--- Get whether a double press was detected this frame.
-- @return boolean True if double-pressed.
function Button:isDoublePressed()
    return self._doublePressed and self.enabled
end

--- Get whether a key repeat fired this frame.
-- @return boolean True if repeat fired.
function Button:isRepeat()
    return self._repeatFired and self.enabled
end

--- Directly press the button (for programmatic presses).
function Button:press()
    self:pressByPointer()
end

--- Directly release the button (for programmatic releases).
function Button:release()
    self:releaseByPointer()
end

return Button
