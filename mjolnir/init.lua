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
hotkey.bind(cmdalt, 'k', grid22:focused():leftmost():topmost():widest():tall(1):act())
hotkey.bind(cmdalt, 'j', grid22:focused():leftmost():bottommost():widest():tall(1):act())
hotkey.bind(cmdalt, 'h', grid22:focused():leftmost():topmost():wide(1):tallest():act())
hotkey.bind(cmdalt, 'l', grid22:focused():rightmost():topmost():wide(1):tallest():act())

hotkey.bind(cmdalt, 'b', grid22:focused():leftmost():bottommost():wide(1):tall(1):act())
hotkey.bind(cmdalt, 'y', grid22:focused():leftmost():topmost():wide(1):tall(1):act())
hotkey.bind(cmdalt, 'p', grid22:focused():rightmost():topmost():wide(1):tall(1):act())
hotkey.bind(cmdalt, '.', grid22:focused():rightmost():bottommost():wide(1):tall(1):act())

-- 3x3 grid, but only horizontal grids
-- one thirds
hotkey.bind(ctcmdalt, 'j', grid33:focused():leftmost():topmost():wide(1):tallest():act())
hotkey.bind(ctcmdalt, 'k', grid33:focused():xpos(1):topmost():wide(1):tallest():act())
hotkey.bind(ctcmdalt, 'l', grid33:focused():xpos(2):topmost():wide(1):tallest():act())

-- two thirds
hotkey.bind(ctalt, 'j', grid33:focused():leftmost():topmost():wide(2):tallest():act())
hotkey.bind(ctalt, 'l', grid33:focused():rightmost():topmost():wide(2):tallest():act())

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

-- a bit of convolution, as grille doesn't support centering
hotkey.bind(ctalt, 'k', function () fn = grid33:focused():leftmost():topmost():wide(2):tallest():act(); fn(); vcenter() end)

-- bind return:shift;cmd ${full}

-- # Screen changing Bindings
-- bind 1:alt;cmd throw 0
-- bind 2:alt;cmd throw 1
-- bind [:alt;cmd throw left
-- bind ]:alt;cmd throw right


hotkey.bind(scmdalt, '\\', grid22:focused():tallest():resize())
hotkey.bind(scmdalt, '-', grid22:focused():widest():resize())
hotkey.bind(scmdalt, '=', grid22:focused():widest():tallest():resize())
