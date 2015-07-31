--- === mjolnir.7bits.mjomatic ===
---
--- tmuxomatic-like window management
---
--- Usage:
--- ~~~lua
--- local mjomatic = require "mjolnir.7bits.mjomatic"
--- ~~~

local mjomatic = {}

local alert = require 'hs.alert'
local grille = require 'grille'

alert.show('mjomatic loaded')

local function resizetogrid(grid, title, coords, screen)
    local window = grid:window(title):mainscreen()

    if screen then
      for pos = 1, #screen do
        local char = screen:sub(pos, pos)
        local dir  = ''
        if     char == 'n' then window = window:screen('north')
        elseif char == 'e' then window = window:screen('east')
        elseif char == 'w' then window = window:screen('west')
        elseif char == 's' then window = window:screen('south')
        elseif char == 'x' then window = window:nextscreen()
        elseif char == 'p' then window = window:prevscreen()
        elseif char == 'm' then window = window:mainscreen()
        else error(string.format('Character "%s" does not designate any screen', char))
        end
      end
    end

    window:xpos(coords.c1-1):
         ypos(coords.r1-1):
         wide(coords.c2-coords.c1+1):
         tall(coords.r2-coords.r1+1):
         act()()
    -- alert.show(string.format('new frame for %q is %d*%d at %d,%d', window:title(), newframe.w, newframe.h, newframe.x, newframe.y), 20)
end

local function parse(cfg)
  local grid = {}        -- will contain an entry for each section
  local map = {}         -- will contain the mapping

  local target = {}

  local states = {start = 'start',
                  section = 'section',
                  separator = 'separator',
  }
  local state = states.start -- possible states are 'start', 'section', 'separator'

  for i,l in ipairs(cfg) do
    l = l:gsub('#.*','')        -- strip comments
    l = l:gsub('%s*$','')       -- strip trailing whitespace
    -- alert.show(l)
    -- empty line denotes a split between sections
    if l:len() ~= 0 then
      if state == states.start then
        state = states.section
        table.insert(target, l)
      elseif state == states.section then
        table.insert(target, l)
      elseif state == states.separator then
        table.insert(grid, target)
        target = {}
        state = states.section
        table.insert(target, l)
      end
    else
      if state == states.start then
        -- nothing
      elseif state == states.section then
        state = states.separator
      elseif state == states.separator then
        -- nothing
      end
    end
  end

  if state == states.start then
    error('The config was empty')
  end

  if #grid == 0 then
    error('There is only one section in the config (missing grid or map)')
  end

  map = target

  return grid, map
end

local function parse_map(map)
  local titlemap = {}

  for i, v in ipairs(map) do
    local key = v:sub(1,1)
    local title = v:sub(3)
    -- alert.show(string.format('%s=%s', key, title))
    if key == "." or key == ">" or key == ":" then
      error(string.format('Chars ".", ":", or ">" cannot be used as a key (at line %d)', i))
    end
    titlemap[key] = title
  end
  return titlemap
end

local function parse_grid_section(grid)
  local screen = nil
  local gridw  = nil -- gridw must be identical in all layers
  local gridh  = {} -- we count gridh for each layer
  local windows = {}

  local screen_desc = '^(%w+):(>*)'
  for row, v in ipairs(grid) do
    if gridw then
      if screen and not v:match('^' .. screen .. ':') then
        error(string.format('Line %d does not contain screen identifier "%s"', row, screen))
      elseif screen then
        v = v:sub(screen:len()+2)
      end
      if gridw ~= v:len() then
        error('inconsistent grid width')
      end
    else
      local captures = v:match(screen_desc)
      print(captures)
      if captures then
        screen = captures
        v = v:sub(screen:len()+2)
      end

      gridw=v:len()
    end

    -- alert.show('grid h='..gridh..' w='..gridw)
    for column = 1, #v do
      local char = v:sub(column, column)
      -- print(string.format("checking row %d, column %d => char %s", row, column, char))
      if char == "." then
        -- do nothing
      elseif not windows[char] then
        -- new window, create it with size 1x1
        windows[char] = {r1=row, c1=column, r2=row, c2=column}
      else
        -- expand it
        -- print("expanding for (" .. char .. ") to " .. tostring(row) .. ", " .. tostring(column))
        windows[char].r2=row
        windows[char].c2=column
      end
    end
  end
  return screen, gridw, gridh, windows
end

local function parse_grid(grid)
  local windows = {}
  for gid, section in ipairs(grid) do
    local screen, gridw, gridh, windef = parse_grid_section(section)
    if not screen then
      screen = 'm'
    end
    if windows[screen] then
      error(string.format('Section %d repeats screen "%s"', gid, screen))
    end
    windows[screen] = { gridw = gridw, gridh = gridh, windef = windef }
  end
  return windows
end

local function parser(config)
  local input = { data = config, line = 1, column = 1 }
  local function advanceColumn(input, delta)
    input.column = input.column + delta
    if input.column > input.data[input.line]:len() then
      input.column = 1
      advanceRow(input, 1)
    end
  end
  local function advanceRow(input, delta)
    input.line = input.line + delta
    if input.line > #input.data then
      input.line = #input.data
    end
  end
  local function isEof(input)
    if input.line == #input.data and input.data[input.line]:len() == input.column then
      return true
    else
      return false
    end
  end
  local function getPos(input)
    return { line = input.line, column = input.column }
  end
  local function setPos(input, pos)
    input.line = pos.line
    input.column = pos.column
  end

  -- error is { str = 'str', input = input }
  local function lit(char)
    return function (input)
      if input.data[line]:sub(column,column) == char then
	advanceColumn(input, 1)
	-- TODO: what is char?
	return char
      else
	error({str = string.format("'%s' expected, not found", char), input = input})
      end
    end
  end
  local function por(parser1, parser2)
    return function (input)
      local p1, result1 = pcall(parser1(input))
      if p1 then return result1 end
      local p2, result2 = pcall(parser2(input))
      if p2 then return result2 end
      error({str = string.format("or not satisfied"), input = input})
    end
  end
  local function pand(parser1, parser2)
    return function (input)
      local pos = getPos(input)
      local p1, result1 = pcall(parser1(input))
      if not p1 then setPos(input, pos); error(result1) end
      local p2, result2 = pcall(parser2(input))
      if not p2 then setPos(input, pos); error(result2) end
      -- TODO: what is +?
      return result1 + result2
    end
  end
  local function apply(f, parser)
    return function (input)
      local p, result = pcall(parser(input))
      if not p then error(result) end
      return f(result)
    end
  end
  local function parse_gridline(iterator)
  end
  local function parse_windowmap(iterator)
  end
end

--- mjolnir.7bits.mjomatic.go(cfg, screen)
--- Function
--- takes a config as a list of strings, configures your windows as
--- stated. Optionally, it takes a screen descriptor, and places
--- windows on that screen. If screen descriptor is not present, the
--- configuration _must_ contain only a single windowgram. If screen
--- descriptor is an empty string, main screen will be used.
---
--- Example:
--- ~~~lua
--- mjomatic.go({
--- "m:CCCCCCCCCCCCCiiiiiiiiiii      # <-- The windowgram, it defines the shapes and positions of windows",
--- "m:CCCCCCCCCCCCCiiiiiiiiiii      # <-- 'm' denotes the main screen",
--- "m:..SSSSSSSSSSSiiiiiiiiiii      # <-- dot (.) denotes an empty part of the screen",
--- "m:..SSSSSSSSSSSYYYYYYYYYYY",
--- "m:..SSSSSSSSSSSYYYYYYYYYYY",
--- "                                # empty lines (or lines consisting of whitespace/comments divide sections",
--- "e:..................KKKKKK",
--- "e:>................OOOOOOOO     # use one or more '>' after screen def to denote different layers",
--- "e:..................KKKKKK",
--- "e:>................OOOOOOOO     " each layer should contain overlapping windows",
--- "e:..................KKKKKK",
--- "e:>................OOOOOOOO",
--- "e:..................KKKKKK",
--- "e:>................OOOOOOOO",
--- "",
--- "C Google Chrome            # <-- window C has application():title() 'Google Chrome'",
--- "i iTerm                    # this section must come the last",
--- "Y YoruFukurou",
--- "K Contacts",
--- "O Day One",
--- "S Sublime Text 2"})
--- ~~~
---
--- Essentially, all lines in a windowgram can be prefixed by a screen
--- descriptor, followed by a colon (':'). If there is no such prefix,
--- only a single windowgram must be present in the config. Each
--- windowgram must have it's own, unique screen descriptor.
---
--- Values for describing the screens are:
---
--- * m - the main screen
--- * e, n, w, s - east, north, west, or south of the main screen
--- * p - the previous screen
--- * x - the next screen
--- * any combination of the above 6 - the first letter will be applied
---   to the main screen, the next to the newly found screen, and so on (see NOTE)
---
--- NOTE: due the the fact that for directional descriptions (ne, sw,
--- ...) the final screen location is determined iteratively starting
--- from the main screen, the resulting discovery path must go through
--- existing screens. For example, if there are 3 screens:
---
---     [3]
---     [2][m]
---
--- Value 'en' will reference screen '3', while 'ne' is not defined,
--- and might result in a selection of a different screen.
---
--- Layers allow one to overlay multiple windows on the same screen.
--- Layers are denoted by a '>' _immediately after_ the screen
--- descriptor. The number of '>' characters denotes the layer, that
--- is, all lines that begin with a single '>' belong to the first
--- layer, all the lines that begin with '>>' denote the second layer,
--- and so on.
---
--- Formally, the configuration for mjomatic is defined as:
---
--- ~~~
--- CONFIG     = (WINDOWGRAM EMPTY_LINE)+ WINDOWMAP
--- WINDOWGRAM = GRIDLINE+
--- GRIDLINE   = (SCREENDESC ":")? ">"* GRIDPOINTS
--- SCREENDESC = m | m (e|n|w|s|p|x)+
--- GRIDPOINTS  = ("." | WINDOW)+
--- WINDOW     = any char except ".", ":", or ">"
--- WINDOWMAP  = WINDOW TITLE
--- ~~~
---
--- With following limitations:
---
--- - if `GRIDLINE` does not begin with `SCREENDESC` there must be only one `WINDOWGRAM`
--- - all `GRIDPOINTS`s in `WINDOWGRAM` must be of same length
--- - all characters used in `WINDOW` must be present in `WINDOWMAP`
---
function mjomatic.go(cfg, screen)
  -- alert.show('mjomatic is go')

  local grid, map = parse(cfg)

  local titlemap = parse_map(map)

  local windows = parse_grid(grid)

  if screen and #grid > 1 then
    error("Cannot mix screen and multiple windowgrams")
  end
  if #grid == 1 then
    if not screen or screen == '' then
      alert.show("Passed empty screen, assume main screen")
    else
      print(tostring(windows))
      print(tostring(windows['m']))
      print(tostring(windows[screen]))
      windows[screen] = windows['m']
      windows['m'] = nil
    end
  end

  for screen, window in pairs(windows) do
    local gridw = window.gridw
    local gridh = window.gridh
    local grid  = grille.new(gridw, gridh)

    local windef = window.windef
    for key, coords in pairs(windef) do
      local title = titlemap[key]
      if not title then
        alert.show(string.format('no app defined for key (%s)', key))
      end
      -- alert.show(string.format("title %s key %s", title, key))
      resizetogrid(grid, title, coords, screen)
    end
  end
end

return mjomatic
