--- Pixel theme for the Buttons library.
-- Provides retro pixel-art styled controls with sharp edges.
-- @module buttons.themes.pixel

return {
    name = "pixel",

    --- Button fill color (idle).
    buttonColor = {0.18, 0.20, 0.30, 1.0},

    --- Button fill color (pressed).
    pressedColor = {0.85, 0.90, 0.40, 1.0},

    --- Text color (idle).
    textColor = {0.70, 0.75, 0.80, 1.0},

    --- Text color (pressed).
    pressedTextColor = {0.10, 0.12, 0.15, 1.0},

    --- Border color (idle).
    borderColor = {0.40, 0.45, 0.55, 1.0},

    --- Border color (pressed).
    pressedBorderColor = {0.60, 0.65, 0.20, 1.0},

    --- D-pad center color.
    dpadCenterColor = {0.15, 0.18, 0.25, 1.0},

    --- D-pad arm color (idle).
    dpadArmColor = {0.18, 0.20, 0.30, 1.0},

    --- D-pad arm color (pressed).
    dpadArmPressedColor = {0.85, 0.90, 0.40, 1.0},

    --- No rounded corners for pixel art.
    cornerRadius = 0.0,

    --- Slightly larger font for readability.
    fontScale = 0.45,

    --- Snappier animation.
    animSpeed = 15.0,

    --- No scale squash for pixel art.
    pressScale = 0.95,
}
