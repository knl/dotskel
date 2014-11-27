package.path = package.path .. ';/Users/knl/work/mjolnir.grille/?.lua'

package.path = package.path .. ';/Users/knl/.luarocks/share/lua/5.2/?.lua'
package.cpath = package.cpath .. ';/Users/knl/.luarocks/lib/lua/5.2/?.so'

local application = require "mjolnir.application"
local hotkey = require "mjolnir.hotkey"
local window = require "mjolnir.window"
local fnutils = require "mjolnir.fnutils"

local grille = require "grille"

local grid22 = grille.new(2, 2)
local grid33 = grille.new(3, 3)
local grid42 = grille.new(4, 2)

local cmdalt   = {"cmd", "alt"}
local scmdalt  = {"cmd", "alt", "shift"}
local ctcmdalt = {"cmd", "alt", "ctrl"}
local ctalt    = {"alt", "ctrl"}

--hotkey.bind(mash, 'N', grid.pushwindow_nextscreen)
--hotkey.bind(mash, 'P', grid.pushwindow_prevscreen)

-- 2x2 grid
hotkey.bind(cmdalt, 'k', function () grid22:adjust_focused_window(function(f) f.x = 0; f.y = 0; f.w = grid22.width; f.h = 1 end) end)
hotkey.bind(cmdalt, 'j', function () grid22:adjust_focused_window(function(f) f.x = 0; f.y = 1; f.w = grid22.width; f.h = 1 end) end)
hotkey.bind(cmdalt, 'h', function () grid22:adjust_focused_window(function(f) f.x = 0; f.y = 0; f.w = 1; f.h = grid22.height end) end)
hotkey.bind(cmdalt, 'l', function () grid22:adjust_focused_window(function(f) f.x = 1; f.y = 0; f.w = 1; f.h = grid22.height end) end)

hotkey.bind(cmdalt, 'b', function () grid22:adjust_focused_window(function(f) f.x = 0; f.y = 1; f.w = 1; f.h = 1 end) end)
hotkey.bind(cmdalt, 'y', function () grid22:adjust_focused_window(function(f) f.x = 0; f.y = 0; f.w = 1; f.h = 1 end) end)
hotkey.bind(cmdalt, 'p', function () grid22:adjust_focused_window(function(f) f.x = 1; f.y = 0; f.w = 1; f.h = 1 end) end)
hotkey.bind(cmdalt, '.', function () grid22:adjust_focused_window(function(f) f.x = 1; f.y = 1; f.w = 1; f.h = 1 end) end)

-- 3x3 grid, but only horizontal grids
-- one thirds
hotkey.bind(ctcmdalt, 'j', function () grid33:adjust_focused_window(function(f) f.x = 0; f.y = 0; f.w = 1; f.h = grid33.height end) end)
hotkey.bind(ctcmdalt, 'k', function () grid33:adjust_focused_window(function(f) f.x = 1; f.y = 0; f.w = 1; f.h = grid33.height end) end)
hotkey.bind(ctcmdalt, 'l', function () grid33:adjust_focused_window(function(f) f.x = 2; f.y = 0; f.w = 1; f.h = grid33.height end) end)

-- two thirds
hotkey.bind(ctalt, 'j', function () grid33:adjust_focused_window(function(f) f.x = 0; f.y = 0; f.w = 2; f.h = grid33.height end) end)
hotkey.bind(ctalt, 'l', function () grid33:adjust_focused_window(function(f) f.x = 1; f.y = 0; f.w = 2; f.h = grid33.height end) end)

function vcenter()
  local win = window.focusedwindow()
  local winframe = win:frame()
  local screenrect = win:screen():frame()
  local f = {
     w = winframe.w,
     h = winframe.h,
     x = math.max(0, (screenrect.w - winframe.w)/2),
     y = winframe.y,
  }
  win:setframe(f)
end

function hcenter()
  local win = window.focusedwindow()
  local winframe = win:frame()
  local screenrect = win:screen():frame()
  local f = {
     w = winframe.w,
     h = winframe.h,
     x = winframe.x,
     y = math.max(0, (screenrect.h - winframe.h)/2),
  }
  win:setframe(f)
end

hotkey.bind(ctalt, 'k', function () grid33:adjust_focused_window(function(f) f.x = 1; f.y = 0; f.w = 2; f.h = grid33.height end); vcenter() end)

-- bind return:shift;cmd ${full}

-- # Screen changing Bindings
-- bind 1:alt;cmd throw 0
-- bind 2:alt;cmd throw 1
-- bind [:alt;cmd throw left
-- bind ]:alt;cmd throw right


--- Passes the focused window to fn and uses the returned result as window's new dimensions.
function adjust_focused_window(fn)
  local win = window.focusedwindow()
  local winframe = win:frame()
  local screenrect = win:screen():frame()
  win:setframe(fn(winframe, screenrect))
end

function full_height(winframe, screenrect)
  return {
     x = winframe.x,
     y = screenrect.y,
     w = winframe.w,
     h = screenrect.h,
  }
end

function full_width(winframe, screenrect)
  return {
     x = screenrect.x,
     y = winframe.y,
     w = screenrect.w,
     h = winframe.h,

  }
end

function compose2(fn1, fn2)
  return function(winframe, screenrect)
    return fn2(fn1(winframe, screenrect), screenrect)
  end
end

hotkey.bind(scmdalt, '\\', function() adjust_focused_window(full_height) end)
hotkey.bind(scmdalt, '-', function() adjust_focused_window(full_width) end)
hotkey.bind(scmdalt, '=', function() adjust_focused_window(compose2(full_width, full_height)) end)
