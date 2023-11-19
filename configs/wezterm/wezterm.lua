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
    return 'Tempus Totus'
  end
end


config.color_scheme = scheme_for_appearance(get_appearance())

config.font = wezterm.font 'Iosevka Term SS08'
config.font_size = 13.0

local function tab_title(tab_info)
  local title = tab_info.tab_title
  local zoom = ''
  if tab_info.active_pane.is_zoomed then zoom = ' (Z)' end

  if title and #title > 0 then return title .. zoom end
  return tab_info.active_pane.title .. zoom
end

wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
  local title = tab_title(tab)

  if tab.is_active then return {
    { Background = { Color = 'Black' } },
    { Text = ' ' .. title .. ' ' },
  } end
  return title
end)

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
}

-- Suggested Alphabet for Colemak
config.quick_select_alphabet = "arstqwfpzxcvneioluymdhgjbk"

-- and finally, return the configuration to wezterm
return config

