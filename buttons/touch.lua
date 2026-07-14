--- Touch input manager for the Buttons library.
-- Handles multi-touch input for virtual controls.
-- Never draws; only processes input.
-- @module buttons.touch

local Touch = {}
Touch.__index = Touch

--- Create a new Touch manager.
-- @return Touch A new Touch instance.
function Touch.new()
    local self = setmetatable({}, Touch)
    self.enabled = true
    --- Map from touch ID to {buttonId=string, isDPad=bool, direction=string|nil}.
    self._activeTouches = {}
    return self
end

--- Handle a touchpressed event.
-- @param id userdata Touch ID.
-- @param x number Pixel x coordinate.
-- @param y number Pixel y coordinate.
-- @param buttons table Array of Button objects.
-- @param dpads table Array of DPad objects (optional).
-- @param touchScale number Scale factor for touch hit areas.
function Touch:touchpressed(id, x, y, buttons, dpads, touchScale)
    if not self.enabled then return end
    touchScale = touchScale or 1.25

    -- Check D-pads first
    if dpads then
        for _, dpad in ipairs(dpads) do
            if dpad.visible then
                local dir = dpad:containsPoint(x, y, touchScale)
                if dir and dir ~= "Center" then
                    dpad:pressDirection(dir)
                    self._activeTouches[id] = { isDPad = true, direction = dir, dpadIndex = _ }
                    return
                end
            end
        end
    end

    -- Check buttons
    for _, btn in ipairs(buttons) do
        if btn.visible and btn.enabled and btn:containsPoint(x, y, touchScale) then
            btn:pressByPointer()
            self._activeTouches[id] = { buttonId = btn.id, isDPad = false }
            return
        end
    end
end

--- Handle a touchmoved event.
-- @param id userdata Touch ID.
-- @param x number Pixel x coordinate.
-- @param y number Pixel y coordinate.
-- @param buttons table Array of Button objects.
-- @param dpads table Array of DPad objects.
-- @param touchScale number Scale factor for touch hit areas.
function Touch:touchmoved(id, x, y, buttons, dpads, touchScale)
    if not self.enabled then return end
    touchScale = touchScale or 1.25
    local info = self._activeTouches[id]
    if not info then return end

    if info.isDPad and dpads then
        -- Release old direction and test new position
        local dpad = dpads[info.dpadIndex or 1]
        if dpad then
            dpad:releaseDirection(info.direction)
            local dir = dpad:containsPoint(x, y, touchScale)
            if dir and dir ~= "Center" then
                dpad:pressDirection(dir)
                info.direction = dir
            else
                self._activeTouches[id] = nil
            end
        end
    end
end

--- Handle a touchreleased event.
-- @param id userdata Touch ID.
-- @param buttons table Array of Button objects.
-- @param dpads table Array of DPad objects.
function Touch:touchreleased(id, buttons, dpads)
    if not self.enabled then return end
    local info = self._activeTouches[id]
    if not info then return end

    if info.isDPad then
        if dpads then
            local dpad = dpads[info.dpadIndex or 1]
            if dpad then
                dpad:releaseDirection(info.direction)
            end
        end
    else
        for _, btn in ipairs(buttons) do
            if btn.id == info.buttonId then
                btn:releaseByPointer()
                break
            end
        end
    end

    self._activeTouches[id] = nil
end

--- Release all active touches (e.g., on resize).
-- @param buttons table Array of Button objects.
-- @param dpads table Array of DPad objects.
function Touch:releaseAll(buttons, dpads)
    for id, info in pairs(self._activeTouches) do
        if info.isDPad and dpads then
            for _, dpad in ipairs(dpads) do
                dpad:releaseDirection(info.direction)
            end
        elseif not info.isDPad then
            for _, btn in ipairs(buttons) do
                if btn.id == info.buttonId then
                    btn:releaseByPointer()
                    break
                end
            end
        end
    end
    self._activeTouches = {}
end

return Touch
