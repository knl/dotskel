---@diagnostic disable: undefined-field
-- see: <https://github.com/wez/wezterm/discussions/628#discussioncomment-1874614>

local wez = require "wezterm" ---@class WezTerm

local M = {}

function M.setup()
  wez.on("format-tab-title", function(tab, _, _, config, hover, max_width)
    local nf = require "utils.nerdfont-icons" ---@class NerdFontIcons
    local fn = require "utils.functions" ---@class UtilityFunctions

    local layout = require("utils.layout"):new() ---@class WezTermLayout
    local separators = nf.Separators.TabBar ---@class TabBarIcons

    local bg = "#f8f2e5"
    local fg
    local pane, tab_idx = tab.active_pane, tab.tab_index

    ---set colors based on states
    if tab.is_active then
      fg = '#b63052'
    elseif hover then
      fg = "#464340"
    else
      fg = '#68607d'
    end

    ---Check if any pane has unseen output
    local is_unseen_output_present = false
    for _, p in ipairs(tab.panes) do
      if p.has_unseen_output then
        is_unseen_output_present = true
        break
      end
    end

    -- proc = fn.basename(pane.user_vars.WEZTERM_PROG) or fn.basename(pane.user_vars.WEZTERM_SHELL) or pane.title
    -- wez.log_info("proc = " .. proc)
    -- wez.log_info("pane.title = " .. pane.title)
    -- wez.log_info("pane = " .. pane)

    ---get pane title, remove any `.exe` from the title, swap `Administrator` for the
    ---desired icon, swap `pwsh` and `bash` for their icons
    local title = fn.basename(pane.title)

    ---HACK: running Neovim will turn the tab title to "C:\WINDOWS\system32\cmd.exe".
    ---After getting the basename the tab name ends up being "cmd".
    ---This is not the best way to detect when neovim is running but I will never use
    ---`cmd.exe` from WezTerm.
    local is_truncation_needed = true
    if title == "zsh" or title == "bash" then
      ---full title truncation is not necessary since the dir name will be truncated
      is_truncation_needed = false
      -- local cwd = fn.basename(pane:get_current_working_dir().file_path)
      local cwd_uri = pane.current_working_dir
      -- wez.log_info("cwd_uri = " .. cwd_uri)
      if type(cwd_uri) == 'userdata' then
        -- Running on a newer version of wezterm and we have
        -- a URL object here, making this simple!

        cwd = cwd_uri.file_path
        hostname = cwd_uri.host or wezterm.hostname()
      else
        -- an older version of wezterm, 20230712-072601-f4abf8fd or earlier,
        -- which doesn't have the Url object
        cwd_uri = cwd_uri:sub(8)
        local slash = cwd_uri:find '/'
        if slash then
          hostname = cwd_uri:sub(1, slash - 1)
          -- and extract the cwd from the uri, decoding %-encoding
          cwd = cwd_uri:sub(slash):gsub('%%(%x%x)', function(hex)
            return string.char(tonumber(hex, 16))
          end)
        end
      end

      -- wez.log_info("cwd = '" .. cwd .. "' ~ = " .. wez.home_dir)
      -- if pane.current_working_dir == wez.home_dir then
      cwd = cwd:gsub(wez.home_dir .. '/', '~')
      -- if cwd == wez.home_dir then
      --   cwd = "~"
      -- end
      if cwd:sub(-1, -1) == "/" then
        cwd=cwd:sub(1, -2)
      end

      ---instead of truncating the whole title, truncate to length the cwd to ensure
      ---that the right parenthesis always closes.
      -- wez.log_info("max_width = " .. max_width)
      -- wez.log_info("config.tab_max_width = " .. config.tab_max_width)
      if max_width >= config.tab_max_width then
        cwd = ".../" .. wez.truncate_left(cwd, max_width-10) -- .. "..."
      end
      title = title .. " " .. cwd
    end

    title = title
      :gsub("nknezevi1@", "")
      :gsub("root", nf.Admin.fill)
      :gsub("bash", nf.Bash.seti)
      :gsub("zsh", nf.Zsh.cod)
      -- :gsub(fn.basename(os.getenv "USERPROFILE" or ""), "󰋜 ")

    ---truncate the tab title when it overflows the maximum available space, then
    ---concatenate some dots to indicate the occurred truncation
    if is_truncation_needed and max_width >= config.tab_max_width then
      title = wez.truncate_left(title, max_width - 14) .. "..."
    end

    ---add the either the leftmost element or the normal left separator. This is done
    ---to esure a bit of space from the left margin.
    -- layout:push(bg, fg, tab_idx == 0 and separators.leftmost or separators.left)
    layout:push(bg, fg, separators.leftmost)

    ---add the tab number. can be substituted by the `has_unseen_output` notification
    layout:push(
      fg,
      bg,
      nf.Numbers[tab_idx + 1] .. " "
    )

    ---the formatted tab title
    layout:push(fg, bg, title .. " ")

    if is_unseen_output_present then
      layout:push(
        fg,
        bg,
        nf.UnseenNotification .. " "
      )
    end

    ---the right tab bar separator
    -- layout:push(bg, fg, nf.Separators.FullBlock .. separators.right)

    return layout
  end)
end

return M
