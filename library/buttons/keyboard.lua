--- Keyboard input manager for the Buttons library.
-- Translates keyboard events into button presses.
-- Never draws; only processes input.
-- @module buttons.keyboard

local Keyboard = {}
Keyboard.__index = Keyboard

--- Create a new Keyboard manager.
-- @return Keyboard A new Keyboard instance.
function Keyboard.new()
    local self = setmetatable({}, Keyboard)
    --- Map from key name to array of button IDs bound to that key.
    self._keyToButtons = {}
    --- Map from button ID to map of currently-held keys.
    self._heldKeys = {}
    --- Whether keyboard input is enabled.
    self.enabled = true
    return self
end

--- Build the key-to-button mapping from control bindings.
-- @param buttons table Array of Button objects.
-- @param controls table Map of buttonID -> array of key names (from config).
function Keyboard:buildMapping(buttons, controls)
    self._keyToButtons = {}
    self._heldKeys = {}

    -- Build from control config
    if controls then
        for buttonId, keys in pairs(controls) do
            for _, key in ipairs(keys) do
                self._keyToButtons[key] = self._keyToButtons[key] or {}
                self._keyToButtons[key][buttonId] = true
            end
        end
    end

    -- Also build from individual button .keys properties
    if buttons then
        for _, btn in ipairs(buttons) do
            if btn.keys then
                for _, key in ipairs(btn.keys) do
                    self._keyToButtons[key] = self._keyToButtons[key] or {}
                    self._keyToButtons[key][btn.id] = true
                end
            end
        end
    end
end

--- Handle a keypressed event.
-- @param key string The key that was pressed.
-- @param getButton function Function to get a Button by ID.
function Keyboard:keypressed(key, getButton)
    if not self.enabled then return end
    local bindings = self._keyToButtons[key]
    if not bindings then return end
    for buttonId, _ in pairs(bindings) do
        local btn = getButton(buttonId)
        if btn and btn.enabled then
            btn:pressByKey()
            self._heldKeys[btn.id] = self._heldKeys[btn.id] or {}
            self._heldKeys[btn.id][key] = true
        end
    end
end

--- Handle a keyreleased event.
-- @param key string The key that was released.
-- @param getButton function Function to get a Button by ID.
function Keyboard:keyreleased(key, getButton)
    if not self.enabled then return end
    local bindings = self._keyToButtons[key]
    if not bindings then return end
    for buttonId, _ in pairs(bindings) do
        local btn = getButton(buttonId)
        if btn and self._heldKeys[btn.id] then
            self._heldKeys[btn.id][key] = nil
            btn:releaseByKey()
        end
    end
end

return Keyboard
