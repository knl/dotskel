local application = require "hs.application"
local hotkey = require "hs.hotkey"
local window = require "hs.window"

local winter = require "winter"
local win = winter.new()

local grille = require "grille"

local grid22 = grille.new(2, 2)
local grid33 = grille.new(3, 3)


local cmdalt   = {"cmd", "alt"}
local scmdalt  = {"cmd", "alt", "shift"}
local ctcmdalt = {"cmd", "alt", "ctrl"}
local ctalt    = {"alt", "ctrl"}
local hyper    = {"cmd", "alt", "ctrl", "shift"}

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
-- hotkey.bind(cmdalt, '[', win:focused():prevscreen():move())
-- hotkey.bind(cmdalt, ']', win:focused():nextscreen():move())
hotkey.bind(cmdalt, '[', win:focused():keep_proportions():prevscreen():move())
hotkey.bind(cmdalt, ']', win:focused():keep_proportions():nextscreen():move())

-- halving, half moves
-- assumes that windows are already on the grid and will move it one grid unit
-- this allows for some nice reorg of the windows
-- hotkey.bind(cmdalt, ',', grille.autogrid():left():move())
-- hotkey.bind(cmdalt, '.', grille.autogrid():right():move())
-- hotkey.bind(cmdalt, 'p', grille.autogrid():up():move())
-- hotkey.bind(cmdalt, 'l', grille.autogrid():down():move())

-- hotkey.bind(cmdalt, ';', grille.autogrid():thinner():resize())
-- hotkey.bind(scmdalt, ';', grille.autogrid():wider():resize())
-- hotkey.bind(cmdalt, '\'', grille.autogrid():shorter():resize())
-- hotkey.bind(scmdalt, '\'', grille.autogrid():taller():resize())

-- Application starters
hotkey.bind(hyper, "e", function() application.launchOrFocus("Emacs") end)
hotkey.bind(hyper, "t", function() application.launchOrFocus("iTerm") end)
hotkey.bind(hyper, "c", function() application.launchOrFocus("Calendar") end)
hotkey.bind(hyper, "m", function() application.launchOrFocus("Mail") end)
hotkey.bind(hyper, "h", function() application.launchOrFocus("Dash") end)
hotkey.bind(hyper, "s", function() application.launchOrFocus("Slack") end)
