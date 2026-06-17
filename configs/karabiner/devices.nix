# USB device matchers — the single source of truth for device identity.
#
# Imported by karabiner.nix (per-device rules reference `device.<name>`) and
# evaluated to JSON by scripts/karabiner-nix so `karabiner-nix import` can label
# devices by these names. Defining each vendor/product id here exactly once keeps
# the Nix config and the import tool from drifting apart. Edit device identity
# here only.
#
# product_id is shown in hex in the comment; the model is the USB VID:PID
# identity (use Karabiner-EventViewer to confirm or add devices).
let
  # USB vendor IDs (from the USB-IF registry).
  vendor = {
    apple = 1452; # 0x05ac
    logitech = 1133; # 0x046d
    yubico = 4176; # 0x1050
    zsa = 12951; # 0x3297
  };
in
{
  # Apple Wireless Keyboard A1314, ISO layout (hence the non_us_backslash fix).
  appleWirelessKeyboard = {
    is_keyboard = true;
    vendor_id = vendor.apple;
    product_id = 570; # 0x023a
  };
  # Logitech K120 wired keyboard.
  logitechK120 = {
    is_keyboard = true;
    vendor_id = vendor.logitech;
    product_id = 49948; # 0xc31c
  };
  # YubiKey (OTP+FIDO+CCID), enumerates as a keyboard.
  yubikey = {
    is_keyboard = true;
    vendor_id = vendor.yubico;
    product_id = 1031; # 0x0407
  };
  # ZSA Moonlander Mark I (the primary external board).
  zsaMoonlander = {
    is_keyboard = true;
    vendor_id = vendor.zsa;
    product_id = 6505; # 0x1969
  };
}
