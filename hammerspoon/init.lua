local application = require "hs.application"
local hotkey = require "hs.hotkey"
local window = require "hs.window"
local fnutils = require "hs.fnutils"

local grille = require "grille"
local winter = require "window.fluent"

local grid22 = grille.new(2, 2)
local grid33 = grille.new(3, 3)
local grid42 = grille.new(4, 2)

local cmdalt   = {"cmd", "alt"}
local scmdalt  = {"cmd", "alt", "shift"}
local ctcmdalt = {"cmd", "alt", "ctrl"}
local ctalt    = {"alt", "ctrl"}

--hotkey.bind(mash, 'N', grid.pushwindow_nextscreen)
--hotkey.bind(mash, 'P', grid.pushwindow_prevscreen)

-- reloading
hs.hotkey.bind(ctcmdalt, "R", function()
  hs.reload()
end)

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
  local win = window.focusedWindow()
  local winframe = win:frame()
  local screenrect = win:screen():frame()
  local f = {
     w = winframe.w,
     h = winframe.h,
     x = math.max(0, (screenrect.w - winframe.w)/2),
     y = winframe.y,
  }
  win:setFrame(f)
end

function hcenter()
  local win = window.focusedWindow()
  local winframe = win:frame()
  local screenrect = win:screen():frame()
  local f = {
     w = winframe.w,
     h = winframe.h,
     x = winframe.x,
     y = math.max(0, (screenrect.h - winframe.h)/2),
  }
  win:setFrame(f)
end

-- a bit of convolution, as grille doesn't support centering
hotkey.bind(ctalt, 'k', function () fn = grid33:focused():leftmost():topmost():wide(2):tallest():act(); fn(); vcenter() end)

-- bind return:shift;cmd ${full}

-- # Screen changing Bindings
-- bind 1:alt;cmd throw 0
-- bind 2:alt;cmd throw 1
-- bind [:alt;cmd throw left
-- bind ]:alt;cmd throw right


hotkey.bind(scmdalt, '\\', winter.focused():tallest():resize())
hotkey.bind(scmdalt, '-', winter.focused():widest():resize())
hotkey.bind(scmdalt, '=', winter.focused():widest():tallest():resize())

local kinematic = require "kinematic"

-- layouts!
-- development
hotkey.bind(cmdalt, '1', function() kinematic.go({
"CCCCCCCCCCCCCiiiiiiiiiii      # <-- The windowgram, it defines the shapes and positions of windows",
"CCCCCCCCCCCCCiiiiiiiiiii",
"..EEEEEEEEEEEiiiiiiiiiii",
"..EEEEEEEEEEESSSSSSSSSSS",
"..EEEEEEEEEEESSSSSSSSSSS",
"",
"C Google Chrome            # <-- window C has application():title() 'Google Chrome'",
"i iTerm",
"S Skype",
"E Emacs"}) end)

-- productivity
hotkey.bind(cmdalt, '2', function() kinematic.go({
"m:PPPP",
"m:OPPP",
"m:OPPP",
"m:OPPP",
"m:OPPP",
"",
"p:TTTTTTAAIIIIIIIIII",
"",
"P Postbox",
"O Day One",
"T Things",
"A Adium",
"I Calendar"}) end)
