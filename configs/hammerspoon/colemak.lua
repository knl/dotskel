local usbLogger = hs.logger.new('usb', 'debug')
local DEFAULT_KEYBOARD_LAYOUT = "Colemak DH Matrix"
local EXTERNAL_KEYBOARD_LAYOUT = "ABC"

function isExternalKeyboard(usbDevice)
  usbLogger.df("pname %s, vname %s, vId %s, pId %s", usbDevice.productName, usbDevice.vendorName, usbDevice.vendorID, usbDevice.productID)
  return usbDevice.vendorID == 12951 and usbDevice.productID == 6505
end

function configureKeyboard(event)
  if isExternalKeyboard(event) and event.eventType == "added" then
    usbLogger.df("External keyboard added, setting layout to '%s'", EXTERNAL_KEYBOARD_LAYOUT)
    hs.keycodes.setLayout(EXTERNAL_KEYBOARD_LAYOUT)
    return
  end
  if isExternalKeyboard(event) and event.eventType == "removed" then
    usbLogger.df("External keyboard removed, setting layout to '%s'", DEFAULT_KEYBOARD_LAYOUT)
    hs.keycodes.setLayout(DEFAULT_KEYBOARD_LAYOUT)
  end
end

function checkKeyboardOnWakeup(event)
  -- For some reason, the `systemDidWake` event is triggered multiple times
  -- over a longer period without the system being asleep in between.
  -- Trying this work-around to just trigger keyboard changes if the system
  -- actually woke up from sleep.
  if event == hs.caffeinate.watcher.systemWillSleep then
    isAwake = false
    return
  end

  if event ~= hs.caffeinate.watcher.systemDidWake or isAwake then
    return
  end

  isAwake = true

  local usbDevices = hs.usb.attachedDevices()
  if usbDevices == nil then
    return
  end

  local keyboardLayout = DEFAULT_KEYBOARD_LAYOUT
  for index, usbDevice in pairs(usbDevices) do
    if isExternalKeyboard(usbDevice) then
      keyboardLayout = EXTERNAL_KEYBOARD_LAYOUT
    end
  end
  usbLogger.df("System woke up, setting keyboard layout to '%s'", keyboardLayout)
  hs.keycodes.setLayout(keyboardLayout)
end


local watcher = {}
isAwake = false

watcher.keyboardWatcher = hs.usb.watcher.new(configureKeyboard)
watcher.keyboardWatcher:start()

watcher.wakeupWatcher = hs.caffeinate.watcher.new(checkKeyboardOnWakeup)
watcher.wakeupWatcher:start()

return watcher
