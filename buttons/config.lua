--- Configuration module for the Buttons library.
-- Stores and manages all configurable settings.
-- @module buttons.config

local Utils = require("buttons.utils")

local Config = {}

--- Default configuration values.
-- @table defaults
Config.defaults = {
    --- Path to the assets directory.
    assets = "assets",
    --- Global opacity for virtual controls.
    opacity = 0.70,
    --- Active theme name.
    theme = "default",
    --- Layout preset name (nil = no preset, user must create controls manually).
    layout = nil,
    --- Enable touch input.
    touch = true,
    --- Enable mouse input.
    mouse = true,
    --- Enable keyboard input.
    keyboard = true,
    --- Enable debug mode.
    debug = false,
    --- Keyboard control bindings.
    controls = {},
    --- Repeat delay in seconds before a held key repeats.
    repeatDelay = 0.50,
    --- Repeat interval in seconds between repeats.
    repeatInterval = 0.10,
    --- Double-press window in seconds.
    doublePressWindow = 0.30,
    --- Hold threshold in seconds before a press is considered held.
    holdThreshold = 0.50,
    --- Font size multiplier relative to button size.
    fontScale = 0.40,
    --- Default button color (fallback drawing).
    buttonColor = {0.25, 0.50, 0.85, 1.0},
    --- Default pressed button color (fallback drawing).
    pressedColor = {0.95, 0.95, 0.95, 1.0},
    --- Default button text color.
    textColor = {1.0, 1.0, 1.0, 1.0},
    --- Default pressed text color.
    pressedTextColor = {0.1, 0.1, 0.1, 1.0},
    --- Fallback button corner radius as fraction of button size.
    cornerRadius = 0.15,
    --- D-pad position.
    dpadX = 0.18,
    dpadY = 0.72,
    --- D-pad size (normalized).
    dpadSize = 0.28,
    --- Scale factor for touch hit areas (makes touch targets larger).
    touchScale = 1.25,
    --- Whether virtual controls are visible.
    visible = true,
}

--- Current configuration state.
-- @table current
Config.current = {}

--- Create a new Config module.
-- @return Config A new Config instance.
function Config.new()
    local instance = setmetatable({}, {__index = Config})
    instance.current = Utils.deepCopy(Config.defaults)
    return instance
end

--- Load configuration from a user options table.
-- Merges user options with defaults.
-- @param opts table User-provided configuration options.
function Config:load(opts)
    opts = opts or {}
    self.current = Utils.mergeTables(Utils.deepCopy(Config.defaults), opts)
end

--- Get a configuration value.
-- @param key string The configuration key.
-- @return any The configuration value, or nil if not found.
function Config:get(key)
    return self.current[key]
end

--- Set a configuration value at runtime.
-- @param key string The configuration key.
-- @param value any The new value.
function Config:set(key, value)
    self.current[key] = value
end

--- Reset config to defaults.
function Config:reset()
    self.current = Utils.deepCopy(Config.defaults)
end

return Config
