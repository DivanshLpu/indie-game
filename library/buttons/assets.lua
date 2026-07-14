--- Asset management module for the Buttons library.
-- Loads, caches, and provides images for buttons and D-pads.
-- Never crashes on missing assets; always provides a fallback.
-- @module buttons.assets

local Utils = require("buttons.utils")

local Assets = {}

--- Asset cache to avoid reloading images every frame.
-- @local
local _cache = {}

--- Currently configured asset path.
-- @local
local _basePath = "assets"

--- Reference to the config module.
-- @local
local _config = nil

--- Create a new Assets module.
-- @return Assets A new Assets instance.
function Assets.new()
    local instance = setmetatable({}, {__index = Assets})
    instance._cache = {}
    instance._basePath = "assets"
    instance._config = nil
    return instance
end

--- Set the config reference.
-- @param config table The Config module instance.
function Assets:setConfig(config)
    self._config = config
end

--- Set the base path for assets.
-- @param path string The asset directory path.
function Assets:setBasePath(path)
    self._basePath = path or "assets"
end

--- Build a full asset path for a given filename.
-- @param filename string The image filename.
-- @return string The full path.
function Assets:_resolvePath(filename)
    return self._basePath .. "/" .. filename
end

--- Attempt to load an image, returning nil on failure without crashing.
-- @param path string The full file path to load.
-- @return userdata|nil The LÖVE Image or nil if loading failed.
function Assets:_tryLoadImage(path)
    if Utils.fileExists(path) then
        local ok, image = pcall(love.graphics.newImage, path)
        if ok and image then
            return image
        end
    end
    return nil
end

--- Load an image by filename, using the cache.
-- On miss or file-not-found, returns nil (caller should use fallback).
-- @param filename string The image filename (relative to assets dir).
-- @return userdata|nil The cached LÖVE Image, or nil.
function Assets:load(filename)
    if not filename then return nil end

    -- Check cache first
    if self._cache[filename] then
        return self._cache[filename]
    end

    local path = self:_resolvePath(filename)
    local image = self:_tryLoadImage(path)

    if image then
        self._cache[filename] = image
        return image
    end

    return nil
end

--- Preload a list of images into the cache.
-- @param filenames table Array of image filenames to preload.
function Assets:preload(filenames)
    for _, filename in ipairs(filenames) do
        self:load(filename)
    end
end

--- Get a cached image, or nil.
-- @param filename string The image filename.
-- @return userdata|nil The cached image or nil.
function Assets:get(filename)
    return self._cache[filename] or nil
end

--- Clear the entire image cache and release GPU resources.
function Assets:clear()
    for filename, image in pairs(self._cache) do
        if image and image.release then
            image:release()
        end
    end
    self._cache = {}
end

--- Reload all cached images (e.g., after a theme change).
function Assets:reload()
    local filenames = {}
    for filename, _ in pairs(self._cache) do
        filenames[#filenames + 1] = filename
    end
    self:clear()
    self:preload(filenames)
end

--- Check if an image is available (cached or loadable).
-- @param filename string The image filename.
-- @return boolean True if the image exists.
function Assets:exists(filename)
    if self._cache[filename] then
        return true
    end
    return Utils.fileExists(self:_resolvePath(filename))
end

return Assets
