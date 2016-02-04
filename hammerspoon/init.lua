local application = require "hs.application"
local hotkey = require "hs.hotkey"
local window = require "hs.window"

local winter = require "winter"
local win = winter.new()

local grille = require "grille"

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

-- and now layouts, everyone likes layouts
local kinematic = require "kinematic"

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

hotkey.bind(cmdalt, '2', function() kinematic.go({
"..CCCCCCCCCCCiiiiiiiiiii      # <-- The windowgram, it defines the shapes and positions of windows",
"..CCCCCCCCCCCiiiiiiiiiii",
"",
"C Google Chrome            # <-- window C has application():title() 'Google Chrome'",
"i iTerm"}) end)

hotkey.bind(cmdalt, '3', function() kinematic.go({
            "CCCCCCCCCCCCCiiiiiiiiiii      # <-- The windowgram, it defines the shapes and positions of windows",
            "CCCCCCCCCCCCCiiiiiiiiiii",
            "SSSSSSSSSSSSSiiiiiiiiiii",
            "SSSSSSSSSSSSSYYYYYYYYYYY",
            "SSSSSSSSSSSSSYYYYYYYYYYY",
            "",
            "#  foc                     # <-- Three 3-letter commands to remember: Focus, Directory, Run",
            "#  dir ~                   # <-- Unlinked directory, becomes default for all undefined panes",
            "C Google Chrome            # <-- window C has application():title() 'Google Chrome'",
            "i iTerm",
            "Y Preview",
            "S Skype"}) end)
