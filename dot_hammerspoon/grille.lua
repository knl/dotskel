--- === grille ===
---
--- A module for moving/resizing your windows along a virtual and horizontal grid(s),
--- using a fluent interface (see Usage below).
---
--- hs.grille was based on hs.sd.grid and hs.bg.grid modules, but went through
--- significant modifications to suit my workflows. For example, it allows one to use multiple grids
--- at the same time and uses a fluent interface, so the intentions are more readable.
---
--- Since version 0.6.0, hs.grille uses [hs.winter](https://github.com/knl/hs.winter),
--- and one can use all the commands that hs.winter supports.
---
--- The grid is an partition of your screen; by default it is 3x3, i.e. 3 cells wide by 3 cells tall.
---
--- Grid cells are just a table with keys: x, y, w, h
---
--- For a grid of 2x2:
---
--- * a cell {x=0, y=0, w=1, h=1} will be in the upper-left corner
--- * a cell {x=1, y=0, w=1, h=1} will be in the upper-right corner
--- * and so on...
---
--- Usage:
---   local grille = require "grille"
---
---   -- default grid is 3x3
---   local grid33 = grille.new(3, 3)
---   local grid42 = grille.new(4, 2)
---
---   local cmdalt  = {"cmd", "alt"}
---   local scmdalt  = {"cmd", "alt", "shift"}
---   local ccmdalt = {"ctrl", "cmd", "alt"}
---
---    == the code below needs to be reworked ==
---    -- move windows as per grid segments
---    hotkey.bind(cmdalt, 'LEFT', grid33:focused():left():move())
---    hotkey.bind(cmdalt, 'RIGHT', grid33:focused():right():move())
---
---    -- resize windows to grid
---    hotkey.bind(scmdalt, 'LEFT', grid33:focused():thinner():resize())
---    hotkey.bind(scmdalt, 'RIGHT', grid33:focused():wider():resize())
---
---    -- on a 3x3 grid make a 2x3 window and place it on left
---    hotkey.bind(cmdalt, 'h', grid33:focused():wide(2):tallest():leftmost():place())
---
---    -- on a 3x3 grid make a 1x3 window and place it rightmost
---    hotkey.bind(cmdalt, 'j', grid33:focused():tallest():rightmost():place())
---
---  defaults are:
---    1 cell wide, 1 cell tall, top-left corner, focused window
---
---  One must start with grid:focused() or grid:window('title') and end with a command move(),
---  place(), resize(), or act() (they are all synonyms for the same action). This chain of
---  command will return a function that one can pass to hotkey.bind.
---
---
--- [Github Page](https://github.com/knl/hs.grille)
---
--- @author    Nikola Knezevic
--- @copyright 2014
--- @license   BSD
---
--- @module hs.grille
local grille = {
  _VERSION     = '0.6.0',
  _DESCRIPTION = 'A module for moving/resizing windows on a grid, using a fluent interface. This module supports multiple grids at the same time.',
  _URL         = 'https://github.com/knl/hs.grille',
}

local window = require "hs.window"
local winter = require "winter"

local function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

-- class that deals with coordinate transformations
local GrilleCoordTrans = {}

function GrilleCoordTrans.new(_width, _height, _xmargin, _ymargin)
  local self = {
    -- The number of vertical cells of the grid (default 3)
    height = math.max(_height or 3, 1),

    -- The number of horizontal cells of the grid
    width = math.max(_width or 3, 1),

    -- The margin between each window horizontally.
    xmargin = math.max(_xmargin or 0, 0),

    -- The margin between each window vertically.
    ymargin = math.max(_ymargin or 0, 0),
  }
  setmetatable(self, { __index = GrilleCoordTrans })
  print('GCT:new')
  for k,v in pairs(self) do print(k,v) end
  return self
end

--- hs.grille:get(win)
--- Function
--- Gets the cell this window is on
function GrilleCoordTrans:get(win, _screen)
  local winframe = win:frame()
  local screen = _screen or win:screen()
  local screenrect = screen:frame()
  local screenwidth = screenrect.w / self.width
  local screenheight = screenrect.h / self.height
  return {
    x = round((winframe.x - screenrect.x) / screenwidth),
    y = round((winframe.y - screenrect.y) / screenheight),
    w = math.max(1, round(winframe.w / screenwidth)),
    h = math.max(1, round(winframe.h / screenheight)),
    screenw = self.width,
    screenh = self.height,
  }
end

--- hs.grille:set(win, screen, frame)
--- Function
--- Sets the cell this window should be on
function GrilleCoordTrans:set(win, screen, f, _keep_proportions)
  local screenrect = screen:frame()
  local screenwidth = screenrect.w / self.width
  local screenheight = screenrect.h / self.height
  print('GCT:set')
  for k,v in pairs(self) do print(k,v) end
  print('GCT:set f')
  for k,v in pairs(f) do print(k,v) end
  local newframe = {
    x = (f.x * screenwidth) + screenrect.x,
    y = (f.y * screenheight) + screenrect.y,
    w = f.w * screenwidth,
    h = f.h * screenheight,
  }

  newframe.x = newframe.x + self.xmargin
  newframe.y = newframe.y + self.ymargin
  newframe.w = newframe.w - (self.xmargin * 2)
  newframe.h = newframe.h - (self.ymargin * 2)

  win:setFrame(newframe)
end

-- class table
local Grille = {}

--- hs.grille.new(width, height)
--- Function
--- Creates a new Grille object with given width and height. Default width and height are 3.
function grille.new(width, height, xmargin, ymargin)
  local ct = GrilleCoordTrans.new(width, height, xmargin, ymargin)
  local self = winter.new(ct)
  print(string.format("New grille ready, width = %d, height =%d", width, height))
  return self
end

--- hs.grille:fits_cell(win)
--- Function
--- Returns whether a window fits cells (doesn't need readjustments)
function Grille:fits_cell(win)
  local winframe = win:frame()
  local screenrect = win:screen():frame()
  local screenwidth = screenrect.w / self.width
  local screenheight = screenrect.h / self.height
  return ((winframe.x - screenrect.x) % screenwidth == 0)
         and ((winframe.y - screenrect.y) % screenheight == 0)
end

return grille
