local wezterm = require("wezterm")
return {
  -- font
  font = wezterm.font("FiraCode Nerd Font Mono", { stretch = "Expanded", weight = "Regular" }),
  font_size = 16,

  -- apperance
  color_scheme = "nord",

  -- keymap
  keys = {
    -- Make Option-Left equivalent to Alt-b which many line editors interpret as backward-word
    { key = "LeftArrow", mods = "OPT", action = wezterm.action({ SendString = "\x1bb" }) },
    -- Make Option-Right equivalent to Alt-f; forward-word
    { key = "RightArrow", mods = "OPT", action = wezterm.action({ SendString = "\x1bf" }) },
  },
}
