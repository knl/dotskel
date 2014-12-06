-- package.path = package.path .. ';/Users/knl/work/mjolnir.grille/?.lua'
-- package.path = package.path .. ';/Users/knl/work/mjolnir.winter/?.lua'

package.path = package.path .. ';/Users/knl/.luarocks/share/lua/5.2/?.lua'
package.cpath = package.cpath .. ';/Users/knl/.luarocks/lib/lua/5.2/?.so'

local application = require "mjolnir.application"
local hotkey = require "mjolnir.hotkey"
local window = require "mjolnir.window"
local fnutils = require "mjolnir.fnutils"

local winter = require "mjolnir.winter"
local win = winter.new()

local grille = require "mjolnir.grille"

local grid22 = grille.new(2, 2)
local grid33 = grille.new(3, 3)
local grid42 = grille.new(4, 2)


local cmdalt   = {"cmd", "alt"}
local scmdalt  = {"cmd", "alt", "shift"}
local ctcmdalt = {"cmd", "alt", "ctrl"}
local ctalt    = {"alt", "ctrl"}

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

-- a bit of convolution, as grille doesn't support centering
hotkey.bind(ctalt, 'k', function () fn1 = grid33:focused():leftmost():topmost():wide(2):tallest():act(); fn2 = win:focused():vcenter():move(); fn1(); fn2(); end)

-- fullwidth, fullheight and the combination (|,_,+)
hotkey.bind(scmdalt, '\\', win:focused():tallest():resize())
hotkey.bind(scmdalt, '-', win:focused():widest():resize())
hotkey.bind(scmdalt, '=', win:focused():widest():tallest():resize())

-- push to different screen
hotkey.bind(cmdalt, '[', win:focused():prevscreen():move())
hotkey.bind(cmdalt, ']', win:focused():nextscreen():move())

