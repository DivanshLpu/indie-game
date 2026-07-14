--- Buttons - A professional virtual controller library for LÖVE2D.
-- Provides input management and rendering for virtual buttons, D-pads,
-- and other controls. Never assumes gameplay meaning — only exposes state.
--
-- Usage:
--   local Buttons = require("buttons")
--   Buttons.load({ controls = { Jump = {"space"} } })
--
-- @module buttons

-- local Manager = require("buttons.manager")
local base = ...

local Manager = require(base .. ".manager")
local Button = require(base .. ".button")


------------------------------------------------------------------------
-- Singleton instance
------------------------------------------------------------------------
local _instance = nil

--- Get or create the singleton Manager instance.
-- @return Manager The active manager instance.
local function _getManager()
    if not _instance then
        _instance = Manager.new()
    end
    return _instance
end

------------------------------------------------------------------------
-- Public API
------------------------------------------------------------------------
local Buttons = {}

--- Initialize the Buttons library with configuration.
-- Must be called once in love.load().
-- @param opts table|nil Configuration options.
-- @field opts.assets string Path to assets directory (default: "assets").
-- @field opts.opacity number Global opacity for virtual controls (0-1).
-- @field opts.theme string Theme name (default: "default").
-- @field opts.layout string Layout preset name ("classic","minimal","platformer","rpg").
-- @field opts.touch boolean Enable touch input (default: true).
-- @field opts.mouse boolean Enable mouse input (default: true).
-- @field opts.keyboard boolean Enable keyboard input (default: true).
-- @field opts.debug boolean Enable debug mode (default: false).
-- @field opts.controls table Map of buttonID -> array of key names.
function Buttons.load(opts)
    _getManager():load(opts)
end

--- Update all button states and animations.
-- Call once per frame in love.update().
-- @param dt number Delta time in seconds.
function Buttons.update(dt)
    _getManager():update(dt)
end

--- Draw all virtual controls.
-- Call once per frame in love.draw().
function Buttons.draw()
    _getManager():draw()
end

--- Handle screen resize.
-- Call from love.resize().
-- @param w number New screen width.
-- @param h number New screen height.
function Buttons.resize(w, h)
    _getManager():resize(w, h)
end

--- Handle keyboard key press.
-- Call from love.keypressed().
-- @param key string The key that was pressed.
function Buttons.keypressed(key)
    _getManager():keypressed(key)
end

--- Handle keyboard key release.
-- Call from love.keyreleased().
-- @param key string The key that was released.
function Buttons.keyreleased(key)
    _getManager():keyreleased(key)
end

--- Handle mouse press.
-- Call from love.mousepressed().
-- @param x number Pixel x coordinate.
-- @param y number Pixel y coordinate.
-- @param b number Mouse button index.
function Buttons.mousepressed(x, y, b)
    _getManager():mousepressed(x, y, b)
end

--- Handle mouse release.
-- Call from love.mousereleased().
-- @param x number Pixel x coordinate.
-- @param y number Pixel y coordinate.
-- @param b number Mouse button index.
function Buttons.mousereleased(x, y, b)
    _getManager():mousereleased(x, y, b)
end

--- Handle touch press.
-- Call from love.touchpressed().
-- @param id userdata Touch ID.
-- @param x number Pixel x coordinate.
-- @param y number Pixel y coordinate.
function Buttons.touchpressed(id, x, y)
    _getManager():touchpressed(id, x, y)
end

--- Handle touch move.
-- Call from love.touchmoved().
-- @param id userdata Touch ID.
-- @param x number Pixel x coordinate.
-- @param y number Pixel y coordinate.
function Buttons.touchmoved(id, x, y)
    _getManager():touchmoved(id, x, y)
end

--- Handle touch release.
-- Call from love.touchreleased().
-- @param id userdata Touch ID.
function Buttons.touchreleased(id)
    _getManager():touchreleased(id)
end

------------------------------------------------------------------------
-- Button State API
------------------------------------------------------------------------

--- Check if a button is currently held down.
-- @param id string The button identifier.
-- @return boolean True if the button is pressed.
function Buttons.down(id)
    return _getManager():down(id)
end

--- Check if a button is in the up (released) state.
-- @param id string The button identifier.
-- @return boolean True if the button is not pressed.
function Buttons.up(id)
    return _getManager():up(id)
end

--- Check if a button was just pressed this frame.
-- @param id string The button identifier.
-- @return boolean True on the first frame of a press.
function Buttons.pressed(id)
    return _getManager():pressed(id)
end

--- Check if a button was just released this frame.
-- @param id string The button identifier.
-- @return boolean True on the frame of release.
function Buttons.released(id)
    return _getManager():released(id)
end

--- Check if a button has been held beyond the hold threshold.
-- @param id string The button identifier.
-- @return boolean True if held long enough.
function Buttons.held(id)
    return _getManager():held(id)
end

--- Get the duration a button has been held.
-- @param id string The button identifier.
-- @return number Seconds held (0 if not pressed).
function Buttons.duration(id)
    return _getManager():duration(id)
end

--- Check if a double press was detected this frame.
-- @param id string The button identifier.
-- @return boolean True if double-pressed.
function Buttons.doublePressed(id)
    return _getManager():doublePressed(id)
end

--- Check if a key repeat fired this frame.
-- "repeat" is a reserved keyword in Lua, so we use bracket syntax.
-- @param id string The button identifier.
-- @return boolean True if repeat fired.
Buttons["repeat"] = function(id)
    return _getManager()["repeat"](_getManager(), id)
end

------------------------------------------------------------------------
-- Button Management
------------------------------------------------------------------------

--- Add a new button to the library.
-- @param opts table Button configuration.
-- @field opts.id string Unique identifier.
-- @field opts.text string|nil Display text.
-- @field opts.x number Normalized x position (0-1).
-- @field opts.y number Normalized y position (0-1).
-- @field opts.size number Normalized size (0-1).
-- @field opts.keys table|nil Array of keyboard key bindings.
-- @field opts.idleImage string|nil Idle image filename.
-- @field opts.pressedImage string|nil Pressed image filename.
-- @field opts.visible boolean|nil Whether visible (default: true).
-- @field opts.shape string|nil Fallback shape: "circle","rect","rounded".
-- @return Button The newly created Button object.
function Buttons.addButton(opts)
    return _getManager():addButton(opts)
end

--- Remove a button by its ID.
-- @param id string The button identifier.
-- @return boolean True if found and removed.
function Buttons.removeButton(id)
    return _getManager():removeButton(id)
end

--- Get a Button object by ID.
-- @param id string The button identifier.
-- @return Button|nil The Button object or nil.
function Buttons.getButton(id)
    return _getManager():getButton(id)
end

--- Get all registered button IDs.
-- @return table Array of button ID strings.
function Buttons.getButtonIDs()
    return _getManager():getButtonIDs()
end

------------------------------------------------------------------------
-- Built-in Helper Creators
------------------------------------------------------------------------

--- Create a D-pad with default configuration.
-- @param opts table|nil Optional overrides.
-- @return DPad The newly created DPad object.
function Buttons.createDPad(opts)
    return _getManager():createDPad(opts)
end

--- Create an ABXY face button layout.
-- @param opts table|nil Optional overrides.
-- @return table Array of created Button objects.
function Buttons.createABXY(opts)
    return _getManager():createABXY(opts)
end

--- Create menu buttons (Start, Select).
-- @param opts table|nil Optional overrides.
-- @return table Array of created Button objects.
function Buttons.createMenuButtons(opts)
    return _getManager():createMenuButtons(opts)
end

--- Create menu buttons (Menu, Start, Select).
-- @param opts table|nil Optional overrides.
-- @return table Array of created Button objects.
function Buttons.createMenu(opts)
    return _getManager():createMenu(opts)
end

--- Create shoulder buttons (L, R).
-- @param opts table|nil Optional overrides.
-- @return table Array of created Button objects.
function Buttons.createShoulders(opts)
    return _getManager():createShoulders(opts)
end

------------------------------------------------------------------------
-- Debug / Runtime Editing
------------------------------------------------------------------------

--- Move a button to a new position (for debug editing).
-- @param id string Button ID.
-- @param x number New normalized x.
-- @param y number New normalized y.
function Buttons.moveButton(id, x, y)
    _getManager():moveButton(id, x, y)
end

--- Resize a button (for debug editing).
-- @param id string Button ID.
-- @param size number New normalized size.
function Buttons.resizeButton(id, size)
    _getManager():resizeButton(id, size)
end

--- Save the current layout to a file.
-- @param filename string The file path.
function Buttons.saveLayout(filename)
    _getManager():saveLayout(filename)
end

--- Load a layout from a file.
-- @param filename string The file path.
function Buttons.loadLayout(filename)
    _getManager():loadLayout(filename)
end

------------------------------------------------------------------------
-- Configuration & Theme
------------------------------------------------------------------------

--- Set a configuration value at runtime.
-- @param key string The configuration key.
-- @param value any The new value.
function Buttons.setConfig(key, value)
    _getManager():setConfig(key, value)
end

--- Get a configuration value.
-- @param key string The configuration key.
-- @return any The value.
function Buttons.getConfig(key)
    return _getManager():getConfig(key)
end

--- Set the active theme at runtime.
-- @param themeName string The theme name.
function Buttons.setTheme(themeName)
    _getManager():setTheme(themeName)
end

--- Check if the library has been loaded.
-- @return boolean True if loaded.
function Buttons.isLoaded()
    return _getManager():isLoaded()
end

------------------------------------------------------------------------
-- Version
------------------------------------------------------------------------

--- The library version.
Buttons.VERSION = "1.0.0"

return Buttons