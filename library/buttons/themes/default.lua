--- Default theme for the Buttons library.
-- Provides clean, modern styling with smooth colors.
-- @module buttons.themes.default

return {
    name = "default",

    --- Button fill color (idle).
    buttonColor = {0.25, 0.50, 0.85, 1.0},

    --- Button fill color (pressed).
    pressedColor = {0.90, 0.92, 0.96, 1.0},

    --- Text color (idle).
    textColor = {1.0, 1.0, 1.0, 1.0},

    --- Text color (pressed).
    pressedTextColor = {0.1, 0.1, 0.2, 1.0},

    --- Border color (idle).
    borderColor = {0.15, 0.30, 0.55, 0.6},

    --- Border color (pressed).
    pressedBorderColor = {0.7, 0.75, 0.85, 0.8},

    --- D-pad center color.
    dpadCenterColor = {0.20, 0.40, 0.75, 1.0},

    --- D-pad arm color (idle).
    dpadArmColor = {0.25, 0.45, 0.80, 1.0},

    --- D-pad arm color (pressed).
    dpadArmPressedColor = {0.90, 0.92, 0.96, 1.0},

    --- Corner radius as fraction of button size.
    cornerRadius = 0.15,

    --- Font scale relative to button size.
    fontScale = 0.40,

    --- Default animation lerp speed.
    animSpeed = 10.0,

    --- Scale factor when pressed.
    pressScale = 0.90,
}
