--- Layout presets for the Buttons library.
-- Provides commonly used controller layouts as reusable templates.
-- Users can create custom layouts; these are just convenience helpers.
-- @module buttons.layout

local Layout = {}

--- Classic controller layout.
-- D-pad on left, ABXY on right, shoulders and menu at top.
-- @param opts table|nil Optional overrides.
-- @return table Layout definition with buttons, dpads, etc.
function Layout.classic(opts)
    opts = opts or {}
    return {
        dpad = {
            x = opts.dpadX or 0.18,
            y = opts.dpadY or 0.72,
            size = opts.dpadSize or 0.28,
            controls = opts.dpadControls or {
                Up = {"w", "up"},
                Down = {"s", "down"},
                Left = {"a", "left"},
                Right = {"d", "right"},
            },
        },
        buttons = {
            { id = "A", text = "A", x = 0.82, y = 0.72, size = 0.08, keys = {"x", "z"} },
            { id = "B", text = "B", x = 0.90, y = 0.64, size = 0.08, keys = {"c", "x"} },
            { id = "X", text = "X", x = 0.74, y = 0.64, size = 0.08, keys = {"s", "a"} },
            { id = "Y", text = "Y", x = 0.82, y = 0.56, size = 0.08, keys = {"d", "w"} },
            { id = "Start",  text = "▶", x = 0.55, y = 0.85, size = 0.04, keys = {"return"}, shape = "rounded" },
            { id = "Select", text = "⏸", x = 0.45, y = 0.85, size = 0.04, keys = {"tab"}, shape = "rounded" },
            { id = "L", text = "L", x = 0.14, y = 0.42, size = 0.06, keys = {"q"}, shape = "rounded" },
            { id = "R", text = "R", x = 0.86, y = 0.42, size = 0.06, keys = {"e"}, shape = "rounded" },
        },
    }
end

--- Minimal layout with just a D-pad and two action buttons.
-- @param opts table|nil Optional overrides.
-- @return table Layout definition.
function Layout.minimal(opts)
    opts = opts or {}
    return {
        dpad = {
            x = opts.dpadX or 0.18,
            y = opts.dpadY or 0.72,
            size = opts.dpadSize or 0.24,
            controls = opts.dpadControls or {
                Up = {"w", "up"}, Down = {"s", "down"},
                Left = {"a", "left"}, Right = {"d", "right"},
            },
        },
        buttons = {
            { id = "A", text = "A", x = 0.85, y = 0.72, size = 0.09, keys = {"space", "j"} },
            { id = "B", text = "B", x = 0.80, y = 0.60, size = 0.07, keys = {"k"} },
        },
    }
end

--- Platformer layout: D-pad + Jump + Shoot.
-- @param opts table|nil Optional overrides.
-- @return table Layout definition.
function Layout.platformer(opts)
    opts = opts or {}
    return {
        dpad = {
            x = opts.dpadX or 0.18,
            y = opts.dpadY or 0.72,
            size = opts.dpadSize or 0.28,
            controls = opts.dpadControls or {
                Up = {"w", "up"}, Down = {"s", "down"},
                Left = {"a", "left"}, Right = {"d", "right"},
            },
        },
        buttons = {
            { id = "Jump",  text = "J", x = 0.82, y = 0.72, size = 0.09, keys = {"space", "j"} },
            { id = "Shoot", text = "S", x = 0.74, y = 0.62, size = 0.07, keys = {"k"} },
        },
    }
end

--- RPG layout: D-pad + menu + 4 action buttons.
-- @param opts table|nil Optional overrides.
-- @return table Layout definition.
function Layout.rpg(opts)
    opts = opts or {}
    return {
        dpad = {
            x = opts.dpadX or 0.18,
            y = opts.dpadY or 0.72,
            size = opts.dpadSize or 0.28,
            controls = opts.dpadControls or {
                Up = {"w", "up"}, Down = {"s", "down"},
                Left = {"a", "left"}, Right = {"d", "right"},
            },
        },
        buttons = {
            { id = "A", text = "A", x = 0.82, y = 0.72, size = 0.08, keys = {"space"} },
            { id = "B", text = "B", x = 0.90, y = 0.64, size = 0.08, keys = {"lshift"} },
            { id = "X", text = "X", x = 0.74, y = 0.64, size = 0.08, keys = {"q"} },
            { id = "Y", text = "Y", x = 0.82, y = 0.56, size = 0.08, keys = {"e"} },
            { id = "Menu",  text = "M", x = 0.50, y = 0.88, size = 0.04, keys = {"m"}, shape = "rounded" },
        },
    }
end

return Layout
