--- Utility functions for the Buttons library.
-- Provides common helpers used throughout the library.
-- @module buttons.utils

local Utils = {}

--- Clamp a value between a minimum and maximum.
-- @param value number The value to clamp.
-- @param min number The minimum bound.
-- @param max number The maximum bound.
-- @return number The clamped value.
function Utils.clamp(value, min, max)
    if value < min then return min end
    if value > max then return max end
    return value
end

--- Linearly interpolate between two values.
-- @param a number The start value.
-- @param b number The end value.
-- @param t number The interpolation factor (0-1).
-- @return number The interpolated value.
function Utils.lerp(a, b, t)
    return a + (b - a) * Utils.clamp(t, 0, 1)
end

--- Check if a file exists using LÖVE's filesystem.
-- @param path string The file path to check.
-- @return boolean True if the file exists.
function Utils.fileExists(path)
    return love.filesystem.getInfo(path) ~= nil
end

--- Deep copy a table.
-- @param orig table The table to copy.
-- @return table A deep copy of the table.
function Utils.deepCopy(orig)
    if type(orig) ~= "table" then return orig end
    local copy = {}
    for k, v in pairs(orig) do
        copy[Utils.deepCopy(k)] = Utils.deepCopy(v)
    end
    return setmetatable(copy, getmetatable(orig))
end

--- Merge two tables, with overrides from the second.
-- @param base table The base table.
-- @param override table The table with overriding values.
-- @return table The merged table.
function Utils.mergeTables(base, override)
    local result = Utils.deepCopy(base)
    if override then
        for k, v in pairs(override) do
            if type(v) == "table" and type(result[k]) == "table" then
                result[k] = Utils.mergeTables(result[k], v)
            else
                result[k] = Utils.deepCopy(v)
            end
        end
    end
    return result
end

--- Compute distance between two points.
-- @param x1 number First x coordinate.
-- @param y1 number First y coordinate.
-- @param x2 number Second x coordinate.
-- @param y2 number Second y coordinate.
-- @return number The distance.
function Utils.distance(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    return math.sqrt(dx * dx + dy * dy)
end

--- Round a number to the nearest integer.
-- @param n number The number to round.
-- @return number The rounded integer.
function Utils.round(n)
    return math.floor(n + 0.5)
end

--- Generate a unique ID string.
-- @return string A unique ID.
local _idCounter = 0
function Utils.generateID()
    _idCounter = _idCounter + 1
    return "btn_" .. _idCounter
end

--- Convert normalized coordinates to pixel coordinates.
-- @param nx number Normalized x (0-1).
-- @param ny number Normalized y (0-1).
-- @param screenW number Screen width in pixels.
-- @param screenH number Screen height in pixels.
-- @return number Pixel x, number Pixel y.
function Utils.normalizedToPixels(nx, ny, screenW, screenH)
    return Utils.round(nx * screenW), Utils.round(ny * screenH)
end

--- Convert pixel coordinates to normalized coordinates.
-- @param px number Pixel x.
-- @param py number Pixel y.
-- @param screenW number Screen width in pixels.
-- @param screenH number Screen height in pixels.
-- @return number Normalized x, number Normalized y.
function Utils.pixelsToNormalized(px, py, screenW, screenH)
    if screenW == 0 or screenH == 0 then return 0, 0 end
    return px / screenW, py / screenH
end

--- Calculate button size in pixels based on the shortest dimension.
-- @param normalizedSize number The normalized size (0-1).
-- @param screenW number Screen width in pixels.
-- @param screenH number Screen height in pixels.
-- @return number Size in pixels.
function Utils.sizeToPixels(normalizedSize, screenW, screenH)
    local shortest = math.min(screenW, screenH)
    return Utils.round(normalizedSize * shortest)
end

return Utils
