local wezterm = require 'wezterm'
local act = wezterm.action

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
local config = wezterm.config_builder and wezterm.config_builder() or {}

-- wezterm.gui is not available to the mux server, so take care to
-- do something reasonable when this config is evaluated by the mux
function get_appearance()
  if wezterm.gui then
    return wezterm.gui.get_appearance()
  end
  return 'Light'
end

function scheme_for_appearance(appearance)
  if appearance:find 'Dark' then
    return 'Tempus Night'
  else
    return 'Tempus Day'
  end
end


config.color_scheme = scheme_for_appearance(get_appearance())

config.font = wezterm.font 'Iosevka Term SS08'
config.font_size = 16.0
config.freetype_load_target = 'Light'
config.freetype_render_target = 'HorizontalLcd'
-- config.line_height = 1.0
-- config.cell_width = 0.9
config.use_fancy_tab_bar = true
config.force_reverse_video_cursor = true
config.hide_tab_bar_if_only_one_tab = false
config.adjust_window_size_when_changing_font_size = false
config.max_fps = 120
config.tab_max_width = 32
config.window_decorations = "RESIZE"

config.leader = { key = '/', mods = 'SUPER', timeout_milliseconds = 2000 }
config.keys = {
  -- Rebind OPT-Left, OPT-Right as ALT-b, ALT-f respectively to match Terminal.app behavior
  {
    key = 'LeftArrow',
    mods = 'OPT',
    action = act.SendKey {
      key = 'b',
      mods = 'ALT',
    },
  },
  {
    key = 'RightArrow',
    mods = 'OPT',
    action = act.SendKey { key = 'f', mods = 'ALT' },
  },
  {
    key = ',',
    mods = 'LEADER',
    action = act.PromptInputLine {
      description = 'Enter new name for tab',
      action = wezterm.action_callback(function(window, pane, line)
        -- line is set only if enter is entered
        if line then window:active_tab():set_title(line) end
      end),
    },
  },
  -- from iTerm, clear everything
  {
    key = "k",
    mods = "CMD",
    action = act.ClearScrollback 'ScrollbackAndViewport',
  },
}

-- Suggested Alphabet for Colemak
config.quick_select_alphabet = "arstqwfpzxcvneioluymdhgjbk"

-- and finally, return the configuration to wezterm
return config

