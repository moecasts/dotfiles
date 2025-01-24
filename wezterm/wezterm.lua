local wezterm = require("wezterm")

local function is_wayland()
  return os.getenv("WAYLAND_DISPLAY") ~= nil
end

local config = {
  -- font
  -- font = wezterm.font("FiraCode Nerd Font Mono", { stretch = "Expanded", weight = "Regular" }),
  -- font = wezterm.font("OperatorMono Nerd font", { stretch = "Expanded", weight = "Book" }),
  font = wezterm.font_with_fallback({
    {
      family = "Operator Mono Lig",
    },
    {
      family = "FiraCode Nerd Font Mono",
      weight = "Regular",
    },
  }),
  font_size = 16,

  -- apperance
  -- color_scheme = "nord",
  color_scheme = "nordfox",

  window_background_opacity = 0.96,

  -- keymap
  keys = {
    -- Make Option-Left equivalent to Alt-b which many line editors interpret as backward-word
    { key = "LeftArrow", mods = "OPT", action = wezterm.action({ SendString = "\x1bb" }) },
    -- Make Option-Right equivalent to Alt-f; forward-word
    { key = "RightArrow", mods = "OPT", action = wezterm.action({ SendString = "\x1bf" }) },
    -- Make Option-{  equivalent to Alt-{; move tab previous
    { key = "{", mods = "SHIFT|OPT", action = wezterm.action.MoveTabRelative(-1) },
    -- Make Option-}  equivalent to Alt-}; move tab next
    { key = "}", mods = "SHIFT|OPT", action = wezterm.action.MoveTabRelative(1) },
  },
}

if is_wayland() then
  config.enable_wayland = false
  config.dpi = 96.0
end

return config
