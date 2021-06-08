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
local hyper    = {"cmd", "alt", "shift", "ctrl"}

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

-- Adjustments for the Moonlander
-- On the Moonlander, I have a dedicated layer that leverages the numpad for the actions

-- 2x2 grid
hotkey.bind({}, 'pad8', grid22:focused():leftmost():topmost():widest():tall(1):act())
hotkey.bind({}, 'pad2', grid22:focused():leftmost():bottommost():widest():tall(1):act())
hotkey.bind({}, 'pad4', grid22:focused():leftmost():topmost():wide(1):tallest():act())
hotkey.bind({}, 'pad6', grid22:focused():rightmost():topmost():wide(1):tallest():act())

hotkey.bind({}, 'pad1', grid22:focused():leftmost():bottommost():wide(1):tall(1):act())
hotkey.bind({}, 'pad7', grid22:focused():leftmost():topmost():wide(1):tall(1):act())
hotkey.bind({}, 'pad9', grid22:focused():rightmost():topmost():wide(1):tall(1):act())
hotkey.bind({}, 'pad3', grid22:focused():rightmost():bottommost():wide(1):tall(1):act())

-- 3x3 grid, but only horizontal grids
-- one thirds
hotkey.bind({"cmd"}, 'pad4', grid33:focused():leftmost():topmost():wide(1):tallest():act())
hotkey.bind({"cmd"}, 'pad5', grid33:focused():xpos(1):topmost():wide(1):tallest():act())
hotkey.bind({"cmd"}, 'pad6', grid33:focused():xpos(2):topmost():wide(1):tallest():act())

-- two thirds
hotkey.bind({"cmd"}, 'pad7', grid33:focused():leftmost():topmost():wide(2):tallest():act())
hotkey.bind({"cmd"}, 'pad9', grid33:focused():rightmost():topmost():wide(2):tallest():act())

-- a bit of convolution, as grille doesn't support centering
hotkey.bind({"cmd"}, 'pad8', function () fn1 = grid33:focused():leftmost():topmost():wide(2):tallest():act(); fn2 = win:focused():vcenter():move(); fn1(); fn2(); end)

-- fullwidth, fullheight and the combination (|,_,+)
hotkey.bind({}, 'pad/', win:focused():tallest():resize())
hotkey.bind({}, 'pad-', win:focused():widest():resize())
hotkey.bind({}, 'pad+', win:focused():widest():tallest():resize())


-- Application starter
hotkey.bind(hyper, 'e', function() application.launchOrFocus("Emacs") end)
hotkey.bind(hyper, 'f', function() application.launchOrFocus("Firefox") end)
hotkey.bind(hyper, 'h', function() application.launchOrFocus("Dash") end)
hotkey.bind(hyper, 'k', function() application.launchOrFocus("Cobook") end)
hotkey.bind(hyper, 'm', function() application.launchOrFocus("Postbox") end)
hotkey.bind(hyper, 'o', function() application.launchOrFocus("Trello") end)
hotkey.bind(hyper, 't', function() application.launchOrFocus("iTerm") end)

-- Automatically reload config
function reloadConfig(files)
  doReload = false
  for _,file in pairs(files) do
    if file:sub(-4) == ".lua" then
      doReload = true
    end
  end
  if doReload then
    hs.reload()
  end
end
myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
hs.alert.show("Hammerspoon config loaded")
