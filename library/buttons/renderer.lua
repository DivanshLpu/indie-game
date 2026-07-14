--- Renderer module for the Buttons library.
-- Responsible ONLY for drawing virtual controls.
-- Never checks keyboard, never changes button states.
-- Only reads data from Button and DPad objects.
-- @module buttons.renderer

local Utils = require("buttons.utils")

local Renderer = {}
Renderer.__index = Renderer

--- Create a new Renderer instance.
-- @return Renderer A new Renderer instance.
function Renderer.new()
    local self = setmetatable({}, Renderer)
    self._config = nil
    self._assets = nil
    self._theme = nil
    self._cachedFont = nil
    return self
end

--- Set the config reference.
-- @param config table The Config module instance.
function Renderer:setConfig(config)
    self._config = config
end

--- Set the assets reference.
-- @param assets table The Assets module instance.
function Renderer:setAssets(assets)
    self._assets = assets
end

--- Set the theme reference.
-- @param theme table The active theme table.
function Renderer:setTheme(theme)
    self._theme = theme
end

--- Get the appropriate font for button text.
-- @param size number Font size in pixels.
-- @return userdata LÖVE Font object.
function Renderer:_getFont(size)
    size = math.max(8, Utils.round(size))
    if self._cachedFont and self._cachedFontSize == size then
        return self._cachedFont
    end
    self._cachedFont = love.graphics.newFont(size)
    self._cachedFontSize = size
    return self._cachedFont
end

--- Draw all virtual controls.
-- @param buttons table Array of Button objects.
-- @param dpads table Array of DPad objects.
function Renderer:draw(buttons, dpads)
    local opacity = self._config and self._config:get("opacity") or 0.70
    local visible = self._config and self._config:get("visible")
    if visible == false then return end

    -- Draw D-pads first (below buttons)
    if dpads then
        for _, dpad in ipairs(dpads) do
            if dpad.visible then
                self:drawDPad(dpad, opacity)
            end
        end
    end

    -- Draw buttons
    if buttons then
        for _, btn in ipairs(buttons) do
            if btn.visible then
                self:drawButton(btn, opacity)
            end
        end
    end
end

--- Draw a single button.
-- @param btn Button The button object to draw.
-- @param opacity number Global opacity multiplier (0-1).
function Renderer:drawButton(btn, opacity)
    local px, py = btn:getPixelPosition()
    local size = btn:getPixelSize()
    local halfSize = size * 0.5
    local animScale = btn.anim:getScale()
    local animAlpha = btn.anim:getOverlayAlpha()
    local globalAlpha = opacity * btn.anim:getOpacity()

    -- Resolve images
    local idleImg = self._assets and btn.idleImage and self._assets:load(btn.idleImage) or nil
    local pressedImg = self._assets and btn.pressedImage and self._assets:load(btn.pressedImage) or nil

    love.graphics.push()
    love.graphics.translate(px, py)
    love.graphics.scale(animScale)

    if idleImg then
        self:drawButtonImage(btn, idleImg, pressedImg, halfSize, globalAlpha, animAlpha)
    else
        self:drawButtonFallback(btn, halfSize, globalAlpha, animAlpha)
    end

    -- Draw label text
    self:drawButtonText(btn, halfSize, globalAlpha, animAlpha)

    love.graphics.pop()
end

--- Draw a button using images.
-- @param btn Button The button object.
-- @param idleImg userdata The idle image.
-- @param pressedImg userdata|nil The pressed image (optional).
-- @param halfSize number Half the button size in pixels.
-- @param globalAlpha number Global opacity.
-- @param animAlpha number Press overlay alpha.
function Renderer:drawButtonImage(btn, idleImg, pressedImg, halfSize, globalAlpha, animAlpha)
    local isDown = btn:isDown()

    if isDown and pressedImg then
        -- Draw idle at reduced opacity, then pressed overlay
        love.graphics.setColor(1, 1, 1, globalAlpha * (1 - animAlpha))
        self:drawImageCentered(idleImg, halfSize)
        love.graphics.setColor(1, 1, 1, globalAlpha * animAlpha)
        self:drawImageCentered(pressedImg, halfSize)
    elseif isDown and not pressedImg then
        -- No pressed image: use idle with reduced opacity as visual feedback
        love.graphics.setColor(1, 1, 1, globalAlpha * 0.55)
        self:drawImageCentered(idleImg, halfSize)
    else
        -- Normal idle state
        love.graphics.setColor(1, 1, 1, globalAlpha)
        self:drawImageCentered(idleImg, halfSize)
    end
end

--- Draw a centered image scaled to fit.
-- @param image userdata The LÖVE Image.
-- @param halfSize number Half the target size in pixels.
function Renderer:drawImageCentered(image, halfSize)
    local iw, ih = image:getDimensions()
    local scale = (halfSize * 2) / math.max(iw, ih)
    love.graphics.draw(image, -iw * scale * 0.5, -ih * scale * 0.5, 0, scale, scale)
end

--- Draw a fallback button shape when no image is available.
-- @param btn Button The button object.
-- @param halfSize number Half the button size in pixels.
-- @param globalAlpha number Global opacity.
-- @param animAlpha number Press overlay alpha.
function Renderer:drawButtonFallback(btn, halfSize, globalAlpha, animAlpha)
    local theme = self._theme or {}
    local isDown = btn:isDown()
    local cornerRadius = self._config and self._config:get("cornerRadius") or 0.15
    local cr = halfSize * cornerRadius

    -- Resolve colors from theme or config
    local btnColor, pressedColor
    if isDown then
        pressedColor = theme.pressedColor or (self._config and self._config:get("pressedColor")) or {0.95, 0.95, 0.95, 1.0}
        btnColor = pressedColor
    else
        btnColor = theme.buttonColor or (self._config and self._config:get("buttonColor")) or {0.25, 0.50, 0.85, 1.0}
    end

    love.graphics.setColor(btnColor[1], btnColor[2], btnColor[3], btnColor[4] * globalAlpha)

    if btn.shape == "circle" then
        love.graphics.circle("fill", 0, 0, halfSize)
        -- Draw highlight ring
        if isDown then
            love.graphics.setColor(1, 1, 1, 0.3 * globalAlpha)
            love.graphics.circle("fill", 0, -halfSize * 0.15, halfSize * 0.75)
        else
            love.graphics.setColor(1, 1, 1, 0.1 * globalAlpha)
            love.graphics.circle("fill", 0, -halfSize * 0.15, halfSize * 0.75)
        end
    elseif btn.shape == "rounded" then
        love.graphics.rectangle("fill", -halfSize, -halfSize * 0.5, halfSize * 2, halfSize, cr, cr)
    else
        love.graphics.rectangle("fill", -halfSize, -halfSize, halfSize * 2, halfSize * 2, cr, cr)
    end
end

--- Draw the button's text label.
-- @param btn Button The button object.
-- @param halfSize number Half the button size in pixels.
-- @param globalAlpha number Global opacity.
-- @param animAlpha number Press overlay alpha.
function Renderer:drawButtonText(btn, halfSize, globalAlpha, animAlpha)
    if not btn.text or btn.text == "" then return end
    local fontScale = self._config and self._config:get("fontScale") or 0.40
    local fontSize = Utils.round(halfSize * 2 * fontScale)
    local font = self:_getFont(fontSize)
    local isDown = btn:isDown()

    local textColor
    if isDown then
        textColor = self._theme and self._theme.pressedTextColor
            or (self._config and self._config:get("pressedTextColor"))
            or {0.1, 0.1, 0.1, 1.0}
    else
        textColor = self._theme and self._theme.textColor
            or (self._config and self._config:get("textColor"))
            or {1.0, 1.0, 1.0, 1.0}
    end

    love.graphics.setColor(textColor[1], textColor[2], textColor[3], textColor[4] * globalAlpha)
    love.graphics.setFont(font)
    local tw = font:getWidth(btn.text)
    local th = font:getHeight()
    love.graphics.print(btn.text, -tw * 0.5, -th * 0.5)
end

--- Draw a D-pad with its overlay image system.
-- @param dpad DPad The D-pad object to draw.
-- @param opacity number Global opacity multiplier.
function Renderer:drawDPad(dpad, opacity)
    local px, py = dpad:getPixelPosition()
    local size = dpad:getPixelSize()
    local halfSize = size * 0.5
    local globalAlpha = opacity * dpad.anim:getOpacity()

    love.graphics.push()
    love.graphics.translate(px, py)

    -- Try image-based D-pad rendering
    local idleImg = self._assets and dpad.idleImage and self._assets:load(dpad.idleImage) or nil

    if idleImg then
        -- Draw idle image
        love.graphics.setColor(1, 1, 1, globalAlpha)
        self:drawImageCentered(idleImg, halfSize)

        -- Draw pressed direction overlays
        local dirs = dpad:getDirectionIDs()
        for _, dir in ipairs(dirs) do
            local dirBtn = dpad:getDirection(dir)
            if dirBtn and dirBtn:isDown() and dpad.pressedImages[dir] then
                local overlayImg = self._assets:load(dpad.pressedImages[dir])
                if overlayImg then
                    love.graphics.setColor(1, 1, 1, globalAlpha)
                    self:drawImageCentered(overlayImg, halfSize)
                end
            end
        end
    else
        -- Fallback D-pad drawing
        self:drawDPadFallback(dpad, halfSize, globalAlpha)
    end

    love.graphics.pop()
end

--- Draw a fallback D-pad when no images are available.
-- Draws a cross shape with 4 direction arms (no center circle).
-- @param dpad DPad The D-pad object.
-- @param halfSize number Half the D-pad size in pixels.
-- @param globalAlpha number Global opacity.
function Renderer:drawDPadFallback(dpad, halfSize, globalAlpha)
    local theme = self._theme or {}
    local btnColor = theme.buttonColor or (self._config and self._config:get("buttonColor")) or {0.25, 0.50, 0.85, 1.0}
    local pressedColor = theme.pressedColor or (self._config and self._config:get("pressedColor")) or {0.95, 0.95, 0.95, 1.0}
    local cr = halfSize * 0.08

    -- Cross-shaped D-pad: each arm is a rounded rectangle
    local armW = halfSize * 0.32   -- arm width
    local armH = halfSize * 0.55   -- arm height

    local dirs = dpad:getDirectionIDs()
    local armDefs = {
        Up    = { ox = 0,           oy = -1, w = armW, h = armH },
        Down  = { ox = 0,           oy =  1, w = armW, h = armH },
        Left  = { ox = -1,          oy =  0, w = armH, h = armW },
        Right = { ox = 1,           oy =  0, w = armH, h = armW },
    }

    -- Draw cross background (center connector)
    love.graphics.setColor(btnColor[1], btnColor[2], btnColor[3], btnColor[4] * globalAlpha)
    love.graphics.rectangle("fill", -armW * 0.5, -armW * 0.5, armW, armW, cr, cr)

    -- Draw each direction arm
    for _, dir in ipairs(dirs) do
        local dirBtn = dpad:getDirection(dir)
        local isDown = dirBtn and dirBtn:isDown()
        local color = isDown and pressedColor or btnColor
        local def = armDefs[dir]

        love.graphics.setColor(color[1], color[2], color[3], color[4] * globalAlpha)

        -- Calculate arm rectangle position
        local rx, ry, rw, rh
        if dir == "Up" then
            rx = -def.w * 0.5
            ry = -armW * 0.5 - def.h
            rw = def.w
            rh = def.h
        elseif dir == "Down" then
            rx = -def.w * 0.5
            ry = armW * 0.5
            rw = def.w
            rh = def.h
        elseif dir == "Left" then
            rx = -armW * 0.5 - def.w
            ry = -def.h * 0.5
            rw = def.w
            rh = def.h
        else -- Right
            rx = armW * 0.5
            ry = -def.h * 0.5
            rw = def.w
            rh = def.h
        end

        love.graphics.rectangle("fill", rx, ry, rw, rh, cr, cr)

        -- Draw direction label (arrow symbol)
        if dirBtn then
            local fontSize = Utils.round(armW * 0.8)
            local font = self:_getFont(fontSize)
            love.graphics.setFont(font)
            local textColor = isDown
                and (theme.pressedTextColor or {0.1, 0.1, 0.1, 1.0})
                or (theme.textColor or {1.0, 1.0, 1.0, 1.0})
            love.graphics.setColor(textColor[1], textColor[2], textColor[3], textColor[4] * globalAlpha)
            local arrows = { Up = "^", Down = "v", Left = "<", Right = ">" }
            local label = arrows[dir] or dir:sub(1, 1)
            local tw = font:getWidth(label)
            local th = font:getHeight()
            -- Center label in the arm
            local lx = rx + rw * 0.5 - tw * 0.5
            local ly = ry + rh * 0.5 - th * 0.5
            love.graphics.print(label, lx, ly)
        end
    end
end

--- Draw debug overlays (hit areas, IDs, etc.).
-- @param buttons table Array of Button objects.
-- @param dpads table Array of DPad objects.
function Renderer:drawDebug(buttons, dpads)
    love.graphics.setColor(1, 0, 0, 0.3)

    if buttons then
        for _, btn in ipairs(buttons) do
            local px, py = btn:getPixelPosition()
            local size = btn:getPixelSize()
            local halfSize = size * 0.5
            if btn.shape == "circle" then
                love.graphics.circle("line", px, py, halfSize)
            else
                love.graphics.rectangle("line", px - halfSize, py - halfSize, size, size)
            end
            -- Draw ID label
            local font = self:_getFont(12)
            love.graphics.setFont(font)
            love.graphics.setColor(1, 1, 0, 0.7)
            love.graphics.print(btn.id, px - font:getWidth(btn.id) * 0.5, py - 6)
        end
    end

    if dpads then
        for _, dpad in ipairs(dpads) do
            local px, py = dpad:getPixelPosition()
            local size = dpad:getPixelSize()
            local halfSize = size * 0.5
            love.graphics.setColor(1, 0, 0, 0.3)
            love.graphics.rectangle("line", px - halfSize, py - halfSize, size, size)
        end
    end
end

return Renderer