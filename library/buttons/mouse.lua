--- Mouse input manager for the Buttons library.
-- Translates mouse events into button presses.
-- Simulates touch for desktop testing.
-- Never draws; only processes input.
-- @module buttons.mouse

local Mouse = {}
Mouse.__index = Mouse

--- Create a new Mouse manager.
-- @return Mouse A new Mouse instance.
function Mouse.new()
    local self = setmetatable({}, Mouse)
    --- Whether mouse input is enabled.
    self.enabled = true
    --- Currently held button IDs (mouse button is pressed on these).
    self._activeButtons = {}
    --- Currently active D-pad (if mouse is on a dpad).
    self._activeDPadDirection = nil
    return self
end

--- Handle a mousepressed event.
-- @param x number Pixel x coordinate.
-- @param y number Pixel y coordinate.
-- @param button number The mouse button index.
-- @param buttons table Array of Button objects.
-- @param dpads table Array of DPad objects (optional).
-- @param touchScale number Scale factor for touch hit areas.
function Mouse:mousepressed(x, y, button, buttons, dpads, touchScale)
    if not self.enabled then return end
    touchScale = touchScale or 1.25

    -- Check D-pads first (they have priority)
    if dpads then
        for _, dpad in ipairs(dpads) do
            if dpad.visible then
                local dir = dpad:containsPoint(x, y, touchScale)
                if dir and dir ~= "Center" then
                    dpad:pressDirection(dir)
                    self._activeDPadDirection = dir
                    return
                end
            end
        end
    end

    -- Check buttons
    for _, btn in ipairs(buttons) do
        if btn.visible and btn.enabled and btn:containsPoint(x, y, touchScale) then
            btn:pressByPointer()
            self._activeButtons[btn.id] = true
        end
    end
end

--- Handle a mousereleased event.
-- @param x number Pixel x coordinate.
-- @param y number Pixel y coordinate.
-- @param button number The mouse button index.
-- @param buttons table Array of Button objects.
-- @param dpads table Array of DPad objects.
function Mouse:mousereleased(x, y, button, buttons, dpads)
    if not self.enabled then return end

    -- Release active buttons
    for btnId, _ in pairs(self._activeButtons) do
        for _, btn in ipairs(buttons) do
            if btn.id == btnId then
                btn:releaseByPointer()
                break
            end
        end
    end
    self._activeButtons = {}

    -- Release active D-pad direction
    if self._activeDPadDirection and dpads then
        for _, dpad in ipairs(dpads) do
            dpad:releaseDirection(self._activeDPadDirection)
        end
        self._activeDPadDirection = nil
    end
end

return Mouse
