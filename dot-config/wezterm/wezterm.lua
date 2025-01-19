local wezterm = require("wezterm")

config = {
    automatically_reload_config = true,
    enable_tab_bar = false,
    window_close_confirmation = "NeverPrompt",
    window_decorations = "RESIZE",
    default_cursor_style = "BlinkingBar",
    color_scheme = "Nord (base16)",
    font = wezterm.font("JetBrains Mono", { weight = "Bold"}),
    font_size = 12.5
}

config.keys = {
  { key = ' ', mods = 'SHIFT|CMD', action = wezterm.action.QuickSelect },
}

return config
