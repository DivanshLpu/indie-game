--- Animation module for the Buttons library.
-- Handles press/release animations, fade effects, and visual feedback.
-- @module buttons.animation

local Utils = require("buttons.utils")

local Animation = {}
Animation.__index = Animation

--- Animation constants.
-- @local
local PRESS_LERP_SPEED = 12.0
local RELEASE_LERP_SPEED = 8.0
local FADE_LERP_SPEED = 6.0
local SCALE_PRESSED = 0.90
local SCALE_RELEASED = 1.00
local OVERLAY_PRESSED_ALPHA = 1.00
local OVERLAY_RELEASED_ALPHA = 0.00

--- Create a new Animation instance.
-- @return Animation A new Animation object.
function Animation.new()
    local self = setmetatable({}, Animation)
    --- Current visual scale (1.0 = normal, shrinks on press).
    self.scale = SCALE_RELEASED
    --- Target scale for smooth interpolation.
    self.targetScale = SCALE_RELEASED
    --- Current overlay alpha (for press highlight).
    self.overlayAlpha = OVERLAY_RELEASED_ALPHA
    --- Target overlay alpha.
    self.targetOverlayAlpha = OVERLAY_RELEASED_ALPHA
    --- Current overall opacity.
    self.opacity = 1.0
    --- Target opacity.
    self.targetOpacity = 1.0
    --- Wobble timer for feedback effects.
    self.wobbleTime = 0
    --- Wobble intensity (0 = no wobble).
    self.wobbleIntensity = 0
    return self
end

--- Update animation state each frame.
-- @param dt number Delta time in seconds.
function Animation:update(dt)
    -- Interpolate scale
    self.scale = Utils.lerp(self.scale, self.targetScale, math.min(dt * PRESS_LERP_SPEED, 1.0))

    -- Interpolate overlay alpha
    self.overlayAlpha = Utils.lerp(self.overlayAlpha, self.targetOverlayAlpha, math.min(dt * PRESS_LERP_SPEED, 1.0))

    -- Interpolate opacity
    self.opacity = Utils.lerp(self.opacity, self.targetOpacity, math.min(dt * FADE_LERP_SPEED, 1.0))

    -- Decay wobble
    if self.wobbleIntensity > 0.01 then
        self.wobbleTime = self.wobbleTime + dt
        self.wobbleIntensity = Utils.lerp(self.wobbleIntensity, 0, math.min(dt * RELEASE_LERP_SPEED, 1.0))
    else
        self.wobbleIntensity = 0
        self.wobbleTime = 0
    end
end

--- Trigger the press animation.
-- @param intensity number|nil Optional intensity multiplier (default 1.0).
function Animation:press(intensity)
    self.targetScale = SCALE_PRESSED
    self.targetOverlayAlpha = OVERLAY_PRESSED_ALPHA
    self.wobbleIntensity = (intensity or 1.0) * 0.06
    self.wobbleTime = 0
end

--- Trigger the release animation.
function Animation:release()
    self.targetScale = SCALE_RELEASED
    self.targetOverlayAlpha = OVERLAY_RELEASED_ALPHA
end

--- Set the target opacity.
-- @param opacity number Target opacity (0-1).
function Animation:setOpacity(opacity)
    self.targetOpacity = Utils.clamp(opacity, 0, 1)
end

--- Get the current visual scale including any wobble.
-- @return number The current scale factor.
function Animation:getScale()
    local wobble = 0
    if self.wobbleIntensity > 0 then
        wobble = math.sin(self.wobbleTime * 30) * self.wobbleIntensity
    end
    return self.scale + wobble
end

--- Get the current overlay alpha for press highlighting.
-- @return number Alpha value (0-1).
function Animation:getOverlayAlpha()
    return self.overlayAlpha
end

--- Get the current opacity.
-- @return number Current opacity (0-1).
function Animation:getOpacity()
    return self.opacity
end

--- Check if the animation has settled (no active transitions).
-- @return boolean True if settled.
function Animation:isSettled()
    local threshold = 0.005
    return math.abs(self.scale - self.targetScale) < threshold
        and math.abs(self.overlayAlpha - self.targetOverlayAlpha) < threshold
        and math.abs(self.opacity - self.targetOpacity) < threshold
        and self.wobbleIntensity < threshold
end

return Animation
