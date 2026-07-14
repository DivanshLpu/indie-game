--- Manager module for the Buttons library.
-- Central coordinator that owns all buttons, D-pads, and input managers.
-- @module buttons.manager

local Config = require("buttons.config")
local Assets = require("buttons.assets")
local Button = require("buttons.button")
local DPad = require("buttons.dpad")
local Renderer = require("buttons.renderer")
local Keyboard = require("buttons.keyboard")
local Mouse = require("buttons.mouse")
local Touch = require("buttons.touch")
local Layout = require("buttons.layout")
local Utils = require("buttons.utils")

local Manager = {}
Manager.__index = Manager

------------------------------------------------------------------------
-- Constructor
------------------------------------------------------------------------

function Manager.new()
    local self = setmetatable({}, Manager)
    self._config = Config.new()
    self._assets = Assets.new()
    self._renderer = Renderer.new()
    self._keyboard = Keyboard.new()
    self._mouse = Mouse.new()
    self._touch = Touch.new()
    self._buttons = {}
    self._dpads = {}
    self._buttonMap = {}
    self._theme = nil
    self._loaded = false
    self._debugFont = nil
    return self
end

------------------------------------------------------------------------
-- Lifecycle
------------------------------------------------------------------------

function Manager:load(opts)
    opts = opts or {}
    self._config:load(opts)

    self._assets:setBasePath(self._config:get("assets"))
    self._assets:setConfig(self._config)

    self._renderer:setConfig(self._config)
    self._renderer:setAssets(self._assets)

    self._keyboard.enabled = self._config:get("keyboard") ~= false
    self._mouse.enabled = self._config:get("mouse") ~= false
    self._touch.enabled = self._config:get("touch") ~= false

    self:_loadTheme(self._config:get("theme") or "default")

    local layoutName = self._config:get("layout")
    if layoutName and Layout[layoutName] then
        self:_applyLayout(Layout[layoutName]())
    end

    local controls = self._config:get("controls")
    if controls then
        for buttonId, keys in pairs(controls) do
            if not self._buttonMap[buttonId] then
                local btn = Button.new({
                    id = buttonId,
                    text = buttonId:sub(1, 1),
                    visible = false,
                    keys = keys,
                })
                btn._config = self._config
                self._buttons[#self._buttons + 1] = btn
                self._buttonMap[buttonId] = btn
            else
                local existingBtn = self._buttonMap[buttonId]
                if existingBtn.keys then
                    for _, k in ipairs(keys) do
                        local found = false
                        for _, ek in ipairs(existingBtn.keys) do
                            if ek == k then found = true; break end
                        end
                        if not found then
                            existingBtn.keys[#existingBtn.keys + 1] = k
                        end
                    end
                else
                    existingBtn.keys = keys
                end
                if not existingBtn._config then
                    existingBtn._config = self._config
                end
            end
        end
    end

    self:_rebuildKeyboardMapping()
    self._loaded = true
end

------------------------------------------------------------------------
-- Internal helpers
------------------------------------------------------------------------

function Manager:_rebuildKeyboardMapping()
    local controls = self._config:get("controls")
    local allButtons = {}
    for _, btn in ipairs(self._buttons) do
        allButtons[#allButtons + 1] = btn
    end
    for _, dpad in ipairs(self._dpads) do
        for _, dir in ipairs(dpad:getDirectionIDs()) do
            local dirBtn = dpad:getDirection(dir)
            if dirBtn then
                allButtons[#allButtons + 1] = dirBtn
            end
        end
    end
    self._keyboard:buildMapping(allButtons, controls)
end

function Manager:_loadTheme(themeName)
    local ok, theme = pcall(require, "buttons.themes." .. themeName)
    if ok and theme then
        self._theme = theme
    else
        self._theme = require("buttons.themes.default")
    end
    self._renderer:setTheme(self._theme)
end

function Manager:_applyLayout(layoutDef)
    if layoutDef.dpad then
        local dpad = DPad.new(layoutDef.dpad)
        dpad._config = self._config
        self._dpads[#self._dpads + 1] = dpad
        for _, dir in ipairs(dpad:getDirectionIDs()) do
            local dirBtn = dpad:getDirection(dir)
            if dirBtn then
                dirBtn._config = self._config
                self._buttonMap[dir] = dirBtn
            end
        end
    end
    if layoutDef.buttons then
        for _, btnOpts in ipairs(layoutDef.buttons) do
            self:addButton(btnOpts)
        end
    end
end

------------------------------------------------------------------------
-- Frame lifecycle
------------------------------------------------------------------------

function Manager:update(dt)
    for _, dpad in ipairs(self._dpads) do
        dpad:update(dt)
    end
    for _, btn in ipairs(self._buttons) do
        btn:update(dt)
    end
end

function Manager:draw()
    self._renderer:draw(self._buttons, self._dpads)
    if self._config:get("debug") then
        self._renderer:drawDebug(self._buttons, self._dpads)
        self:drawDebugInfo()
    end
end

function Manager:resize(w, h)
    for _, btn in ipairs(self._buttons) do btn:resize(w, h) end
    for _, dpad in ipairs(self._dpads) do dpad:resize(w, h) end
    self._touch:releaseAll(self._buttons, self._dpads)
end

------------------------------------------------------------------------
-- Input forwarding
------------------------------------------------------------------------

function Manager:keypressed(key)
    self._keyboard:keypressed(key, function(id) return self:getButton(id) end)
end

function Manager:keyreleased(key)
    self._keyboard:keyreleased(key, function(id) return self:getButton(id) end)
end

function Manager:mousepressed(x, y, button)
    local touchScale = self._config:get("touchScale") or 1.25
    self._mouse:mousepressed(x, y, button, self._buttons, self._dpads, touchScale)
end

function Manager:mousereleased(x, y, button)
    self._mouse:mousereleased(x, y, button, self._buttons, self._dpads)
end

function Manager:touchpressed(id, x, y)
    local touchScale = self._config:get("touchScale") or 1.25
    self._touch:touchpressed(id, x, y, self._buttons, self._dpads, touchScale)
end

function Manager:touchmoved(id, x, y)
    local touchScale = self._config:get("touchScale") or 1.25
    self._touch:touchmoved(id, x, y, self._buttons, self._dpads, touchScale)
end

function Manager:touchreleased(id)
    self._touch:touchreleased(id, self._buttons, self._dpads)
end

------------------------------------------------------------------------
-- Button State API
------------------------------------------------------------------------

function Manager:down(id)
    local btn = self:getButton(id)
    return btn and btn:isDown() or false
end

function Manager:up(id)
    local btn = self:getButton(id)
    return btn and btn:isUp() or false
end

function Manager:pressed(id)
    local btn = self:getButton(id)
    return btn and btn:isPressed() or false
end

function Manager:released(id)
    local btn = self:getButton(id)
    return btn and btn:isReleased() or false
end

function Manager:held(id)
    local btn = self:getButton(id)
    return btn and btn:isHeld() or false
end

function Manager:duration(id)
    local btn = self:getButton(id)
    return btn and btn:duration() or 0
end

function Manager:doublePressed(id)
    local btn = self:getButton(id)
    return btn and btn:isDoublePressed() or false
end

-- "repeat" is a reserved keyword in Lua, so we use alternative syntax
Manager["repeat"] = function(self, id)
    local btn = self:getButton(id)
    return btn and btn:isRepeat() or false
end

------------------------------------------------------------------------
-- Button Management
------------------------------------------------------------------------

function Manager:getButton(id)
    return self._buttonMap[id]
end

function Manager:addButton(opts)
    opts = opts or {}

    -- Update existing button if ID already exists
    if opts.id and self._buttonMap[opts.id] then
        local existing = self._buttonMap[opts.id]
        if opts.text then existing.text = opts.text end
        if opts.x then existing.x = opts.x end
        if opts.y then existing.y = opts.y end
        if opts.size then existing.size = opts.size end
        if opts.keys then existing.keys = opts.keys end
        if opts.idleImage then existing.idleImage = opts.idleImage end
        if opts.pressedImage then existing.pressedImage = opts.pressedImage end
        if opts.visible ~= nil then existing.visible = opts.visible end
        if opts.enabled ~= nil then existing.enabled = opts.enabled end
        if opts.shape then existing.shape = opts.shape end
        if opts.font then existing.font = opts.font end
        self:_rebuildKeyboardMapping()
        return existing
    end

    local btn = Button.new(opts)
    btn._config = self._config
    self._buttons[#self._buttons + 1] = btn
    self._buttonMap[btn.id] = btn
    self:_rebuildKeyboardMapping()
    return btn
end

function Manager:removeButton(id)
    if not self._buttonMap[id] then return false end
    self._buttonMap[id] = nil
    for i, btn in ipairs(self._buttons) do
        if btn.id == id then
            table.remove(self._buttons, i)
            break
        end
    end
    self:_rebuildKeyboardMapping()
    return true
end

function Manager:getButtonIDs()
    local ids = {}
    for _, btn in ipairs(self._buttons) do ids[#ids + 1] = btn.id end
    return ids
end

------------------------------------------------------------------------
-- Built-in Helper Creators
------------------------------------------------------------------------

function Manager:createDPad(opts)
    opts = opts or {}
    local dpadOpts = {
        x = opts.x or self._config:get("dpadX") or 0.18,
        y = opts.y or self._config:get("dpadY") or 0.72,
        size = opts.size or self._config:get("dpadSize") or 0.28,
        idleImage = opts.idleImage,
        pressedImages = opts.pressedImages or {},
        visible = opts.visible,
        controls = opts.controls or {
            Up = {"w", "up"}, Down = {"s", "down"},
            Left = {"a", "left"}, Right = {"d", "right"},
        },
    }
    local dpad = DPad.new(dpadOpts)
    dpad._config = self._config
    self._dpads[#self._dpads + 1] = dpad
    for _, dir in ipairs(dpad:getDirectionIDs()) do
        local dirBtn = dpad:getDirection(dir)
        if dirBtn then
            dirBtn._config = self._config
            self._buttonMap[dir] = dirBtn
        end
    end
    self:_rebuildKeyboardMapping()
    return dpad
end

function Manager:createABXY(opts)
    opts = opts or {}
    local baseX = opts.x or 0.82
    local baseY = opts.y or 0.68
    local size = opts.size or 0.08
    local offset = size * 1.15
    local abxyKeys = opts.keys or {
        A = {"z"}, B = {"x"},
        X = {"c"}, Y = {"v"},
    }
    local positions = {
        A = { x = baseX,            y = baseY + offset * 0.5 },
        B = { x = baseX + offset,  y = baseY - offset * 0.4 },
        X = { x = baseX - offset,  y = baseY - offset * 0.4 },
        Y = { x = baseX,            y = baseY - offset * 1.3 },
    }
    local created = {}
    for _, name in ipairs({"A", "B", "X", "Y"}) do
        local pos = positions[name]
        local btn = self:addButton({
            id = name, text = name,
            x = pos.x, y = pos.y, size = size,
            keys = abxyKeys[name] or {},
        })
        created[#created + 1] = btn
    end
    return created
end

function Manager:createMenuButtons(opts)
    opts = opts or {}
    local baseX = opts.x or 0.50
    local baseY = opts.y or 0.88
    local size = opts.size or 0.04
    local menuKeys = opts.keys or { Start = {"return"}, Select = {"tab"} }
    local created = {}
    local btn = self:addButton({
        id = "Start", text = "Start", x = baseX + 0.06, y = baseY,
        size = size, keys = menuKeys.Start or {}, shape = "rounded",
    })
    created[#created + 1] = btn
    btn = self:addButton({
        id = "Select", text = "Select", x = baseX - 0.06, y = baseY,
        size = size, keys = menuKeys.Select or {}, shape = "rounded",
    })
    created[#created + 1] = btn
    return created
end

--- Create menu buttons with Start, Select, and Menu.
-- @param opts table|nil Optional overrides for position, size, keys.
-- @return table Array of created Button objects (Start, Select, Menu).
function Manager:createMenu(opts)
    opts = opts or {}
    local baseX = opts.x or 0.50
    local baseY = opts.y or 0.88
    local size = opts.size or 0.04
    local menuKeys = opts.keys or { Start = {"return"}, Select = {"tab"}, Menu = {"escape"} }
    local created = {}
    local btn = self:addButton({
        id = "Menu", text = "Menu", x = baseX, y = baseY,
        size = size, keys = menuKeys.Menu or {}, shape = "rounded",
    })
    created[#created + 1] = btn
    btn = self:addButton({
        id = "Start", text = "Start", x = baseX + 0.08, y = baseY,
        size = size, keys = menuKeys.Start or {}, shape = "rounded",
    })
    created[#created + 1] = btn
    btn = self:addButton({
        id = "Select", text = "Select", x = baseX - 0.08, y = baseY,
        size = size, keys = menuKeys.Select or {}, shape = "rounded",
    })
    created[#created + 1] = btn
    return created
end

function Manager:createShoulders(opts)
    opts = opts or {}
    local size = opts.size or 0.06
    local baseY = opts.y or 0.44
    local shoulderKeys = opts.keys or { L = {"q"}, R = {"e"} }
    local created = {}
    local btn = self:addButton({
        id = "L", text = "L", x = opts.lx or 0.14, y = baseY,
        size = size, keys = shoulderKeys.L or {}, shape = "rounded",
    })
    created[#created + 1] = btn
    btn = self:addButton({
        id = "R", text = "R", x = opts.rx or 0.86, y = baseY,
        size = size, keys = shoulderKeys.R or {}, shape = "rounded",
    })
    created[#created + 1] = btn
    return created
end

------------------------------------------------------------------------
-- Debug
------------------------------------------------------------------------

function Manager:drawDebugInfo()
    if not self._debugFont then
        self._debugFont = love.graphics.newFont(12)
    end
    love.graphics.setFont(self._debugFont)
    love.graphics.setColor(1, 1, 0, 0.8)
    local y = 4
    for _, btn in ipairs(self._buttons) do
        local s = btn:isDown() and "DOWN" or "UP"
        love.graphics.print(string.format("%s: %s  h=%.2f  k=%d  p=%d",
            btn.id, s, btn:duration(), btn._keyHoldCount, btn._pointerHoldCount), 4, y)
        y = y + 14
    end
    for _, dpad in ipairs(self._dpads) do
        for _, dir in ipairs(dpad:getDirectionIDs()) do
            local dirBtn = dpad:getDirection(dir)
            if dirBtn then
                local s = dirBtn:isDown() and "DOWN" or "UP"
                love.graphics.print(string.format("D-Pad %s: %s", dir, s), 4, y)
                y = y + 14
            end
        end
    end
end

------------------------------------------------------------------------
-- Layout save/load
------------------------------------------------------------------------

function Manager:moveButton(id, x, y)
    local btn = self:getButton(id)
    if btn then btn.x = x; btn.y = y end
end

function Manager:resizeButton(id, size)
    local btn = self:getButton(id)
    if btn then btn.size = size end
end

function Manager:saveLayout(filename)
    local data = { buttons = {}, dpads = {} }
    for _, btn in ipairs(self._buttons) do
        data.buttons[#data.buttons + 1] = {
            id = btn.id, text = btn.text, x = btn.x, y = btn.y,
            size = btn.size, shape = btn.shape, visible = btn.visible,
            keys = btn.keys, idleImage = btn.idleImage, pressedImage = btn.pressedImage,
        }
    end
    for _, dpad in ipairs(self._dpads) do
        data.dpads[#data.dpads + 1] = {
            x = dpad.x, y = dpad.y, size = dpad.size,
            idleImage = dpad.idleImage, pressedImages = dpad.pressedImages,
            visible = dpad.visible,
        }
    end
    love.filesystem.write(filename, self:_serialize(data))
end

function Manager:loadLayout(filename)
    if not love.filesystem.getInfo(filename) then return end
    local content = love.filesystem.read(filename)
    if not content then return end
    local fn = load or loadstring
    local ok, result = pcall(fn, "return " .. content)
    if not ok or not result then return end
    local ok2, data = pcall(result)
    if not ok2 or not data then return end
    self._buttons = {}
    self._buttonMap = {}
    self._dpads = {}
    if data.dpads then
        for _, d in ipairs(data.dpads) do
            local dpad = DPad.new(d)
            dpad._config = self._config
            self._dpads[#self._dpads + 1] = dpad
            for _, dir in ipairs(dpad:getDirectionIDs()) do
                local dirBtn = dpad:getDirection(dir)
                if dirBtn then
                    dirBtn._config = self._config
                    self._buttonMap[dir] = dirBtn
                end
            end
        end
    end
    if data.buttons then
        for _, b in ipairs(data.buttons) do
            self:addButton(b)
        end
    end
    self:_rebuildKeyboardMapping()
end

function Manager:_serialize(tbl, indent)
    indent = indent or 0
    local pad = string.rep("  ", indent)
    if type(tbl) ~= "table" then return tostring(tbl) end
    local parts = {"{\n"}
    for k, v in pairs(tbl) do
        local key = type(k) == "number" and (tostring(k) .. " ") or ('[\"' .. k .. '\"] = ')
        local val
        if type(v) == "table" then val = self:_serialize(v, indent + 1)
        elseif type(v) == "string" then val = '"' .. v .. '"'
        elseif type(v) == "boolean" then val = v and "true" or "false"
        else val = tostring(v) end
        parts[#parts + 1] = pad .. "  " .. key .. val .. ",\n"
    end
    parts[#parts + 1] = pad .. "}"
    return table.concat(parts)
end

------------------------------------------------------------------------
-- Config & Theme
------------------------------------------------------------------------

function Manager:setConfig(key, value)
    self._config:set(key, value)
    if key == "theme" then self:_loadTheme(value)
    elseif key == "keyboard" then self._keyboard.enabled = value ~= false
    elseif key == "mouse" then self._mouse.enabled = value ~= false
    elseif key == "touch" then self._touch.enabled = value ~= false
    end
end

function Manager:getConfig(key)
    return self._config:get(key)
end

function Manager:setTheme(themeName)
    self:_loadTheme(themeName)
end

function Manager:isLoaded()
    return self._loaded
end

return Manager
