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

-- center mouse on the current screen
hotkey.bind(hyper, '`', function()
  local screen = hs.screen.mainScreen()
  local rect = screen:fullFrame()
  local center = hs.geometry.rectMidPoint(rect)

  hs.mouse.setAbsolutePosition(center)
end)


-- Application starter
hotkey.bind(hyper, 'e', function() application.launchOrFocus(os.getenv('HOME') .. '/Applications/Home Manager Apps/Emacs.app') end)
hotkey.bind(hyper, 'f', function() application.launchOrFocus("Firefox") end)
hotkey.bind(hyper, 'h', function() application.launchOrFocus("Dash") end)
hotkey.bind(hyper, 'k', function() application.launchOrFocus("Cobook") end)
hotkey.bind(hyper, 'm', function() application.launchOrFocus("Postbox") end)
hotkey.bind(hyper, 'o', function() application.launchOrFocus("Trello") end)
hotkey.bind(hyper, 't', function() application.launchOrFocus("iTerm") end)

-- A little-known OS X builtin keybinding I rely on extensively is
-- Control-F2. It focuses the menu bar, from which you can navigate by
-- typing the next name you want to focus. Windows users will know how much
-- better this is.
--
-- There is an unfortunate issue with this keybinding, which is that sometimes
-- it just mysteriously fails to do anything. So far I have discerned no
-- pattern, but I do have a (ridiculous) workaround:
--
-- Do Control-F3 first. That focuses the Dock, and for some reason, once
-- the Dock is focused, Control-F2 works consistently.
--
-- And now you know why the following bizarre keybinding exists - because I
-- hate doing two keyboard shortcuts to get the effect of one. "," is not a
-- great mnemonic, but it'll work for now.
--
-- (Bonus - I don't have to hold down the Fn modifier to trigger the menubar [I
-- use it on both my laptop's internal keyboard and in my ErgoDox EZ layout for
-- triggering Fkeys]).
--
-- Note that an arguably-better feature in OS X is the Command-Shift-? keyboard
-- shortcut, which lets you search across menus.
hotkey.bind(hyper, ",", nil, function()
    hs.eventtap.keyStroke({"ctrl"}, "f3", 100)
    hs.eventtap.keyStroke({"ctrl"}, "f2", 100)
end)

-- Mute speakers on waking from sleep
-- Based on https://spinscale.de/posts/2016-11-08-creating-a-productive-osx-environment-hammerspoon.html

function muteOnWake(eventType)
	if eventType == hs.caffeinate.watcher.systemDidWake then
		print("Waking from sleep")
		local output = hs.audiodevice.defaultOutputDevice()
		if output:name() == "Built-in Output" and not output:jackConnected() then
			print("Muting speakers")
			output:setMuted(true)
		end
	end
end
caffeinateWatcher = hs.caffeinate.watcher.new(muteOnWake)
caffeinateWatcher:start()


-- Unmute on play/pause

tap = hs.eventtap.new({hs.eventtap.event.types.NSSystemDefined}, function(event)
	-- print("event tap debug got event:")
	-- print(hs.inspect.inspect(event:getRawEventData()))
	-- print(hs.inspect.inspect(event:getFlags()))
	-- print(hs.inspect.inspect(event:systemKey()))
	if not event:systemKey() or event:systemKey().key ~= "PLAY" or event:systemKey().down then
		return false
	end
	-- Play/pause key was just released
	local output = hs.audiodevice.defaultOutputDevice()
	if output:name() ~= "Built-in Output" or output:jackConnected() then
		return false
	end
	-- Audio output device is built-in speakers
	if output:outputMuted() then
		print("Unmuting speakers on play/pause")
		output:setMuted(false)
	end
	return false
end)
tap:start()

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
