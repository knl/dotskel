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


-- no point, comes from nixpkgs
config.check_for_updates = false

config.color_scheme = scheme_for_appearance(get_appearance())

config.font = wezterm.font 'Iosevka Term SS08'
config.font_size = 16.0
config.freetype_load_target = 'Light'
config.freetype_render_target = 'HorizontalLcd'
config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }

-- Tab Bar Options
config.enable_tab_bar = true
config.use_fancy_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.show_tab_index_in_tab_bar = true

config.adjust_window_size_when_changing_font_size = false
config.max_fps = 120

config.set_environment_variables = {
  TERMINFO_DIRS = '/home/user/.nix-profile/share/terminfo',
  -- fix a bug with latest jq
  JQ_COLORS = '1;30:0;39:0;39:0;39:0;32:1;39:1;39',
}
config.term = "wezterm"

config.window_decorations = "RESIZE"
config.scrollback_lines = 65000
config.enable_scroll_bar = true

config.quick_select_alphabet = "colemak"
config.selection_word_boundary = " \t\n{}[]()\"'`,;:│=&!%"

config.leader = { key = '/', mods = 'SUPER', timeout_milliseconds = 2000 }
config.keys = {
  -- Rebind OPT-Left, OPT-Right as ALT-b, ALT-f respectively to match Terminal.app behavior
  {
    key = 'LeftArrow',
    mods = 'OPT',
    action = act.SendKey { key = 'b', mods = 'ALT', },
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
  { key = 'UpArrow', mods = 'SHIFT', action = act.ScrollToPrompt(-1) },
  { key = 'DownArrow', mods = 'SHIFT', action = act.ScrollToPrompt(1) },
}

config.mouse_bindings = {
  -- Change the default click behavior so that it only selects
  -- text and doesn't open hyperlinks. It also populates the clipboard
  {
    event = { Up = { streak = 1, button = "Left" } },
    mods = "NONE",
    action = wezterm.action.CompleteSelection "Clipboard",
  },

  -- and make CMD-Click open hyperlinks
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'SUPER',
    action = act.OpenLinkAtMouseCursor,
  },
  {
    event = { Down = { streak = 1, button = 'Left' } },
    mods = 'SUPER',
    action = act.Nop,
  },
}

-- Equivalent to POSIX basename(3)
-- Given "/foo/bar" returns "bar"
-- Given "c:\\foo\\bar" returns "bar"
function basename(s)
  return string.gsub(s, '(.*[/\\])(.*)', '%2')
end

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local GLYPH_CIRCLE = ""
  -- local GLYPH_CIRCLE = utf8.char(0xf111)
  local pane = tab.active_pane
  local home_dir = wezterm.home_dir

  local cwd = pane.current_working_dir or '<->'
  cwd = string.gsub(cwd, home_dir, "~")
  cwd = string.gsub(cwd, "~/work", "~w")
  cwd = string.gsub(cwd, "~/dotfiles/dotskel", "~skel")
  cwd = string.gsub(cwd, "file://", "")
  cwd = string.gsub(cwd, "/$", "")
  if string.len(cwd) > 20 then
    cwd = ".../" .. basename(cwd)
  end

  local proc = basename(pane.foreground_process_name)
  proc = string.gsub(proc, "zsh", "")
  if proc ~= "" then
    proc = proc .. " "
  end

  local title = proc .. cwd

  local std_tbl = {
    -- {Background={Color="blue"}},
    {Text=tab.tab_index + 1 .. ": "},
    {Text=title .. " "},
  }
  if tab.is_active then
    return std_tbl
  end
  local has_unseen_output = false
  for _, pane in ipairs(tab.panes) do
    if pane.has_unseen_output then
      has_unseen_output = true
      break;
    end
  end
  if has_unseen_output then
    return {
      {Text=tab.tab_index + 1 .. ": "},
      {Foreground={AnsiColor="Navy"}},
      -- {Intensity="Bold"},
      {Text=title .. " "},
      -- {Text=" *"},
    }
  end
  return std_tbl
end)

-- and finally, return the configuration to wezterm
return config

