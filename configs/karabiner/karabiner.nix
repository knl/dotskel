# Karabiner-Elements configuration as a Nix attrset.
#
# Rendered to ~/.config/karabiner/karabiner.json via `builtins.toJSON` at
# build time (see the `xdg.configFile` binding in home.nix). This is the
# single source of truth; edit here, not the generated JSON.
let
  # Device matchers (vendor/product ids) live in devices.nix so the import tool
  # reads the same source — see scripts/karabiner-nix. Reference as device.<name>.
  device = import ./devices.nix;
in
{
  profiles = [
    {
      name = "Default profile";
      selected = true;

      complex_modifications.rules = [
        {
          description = "Change caps_lock key to command+control+option+shift. (Post escape key when pressed alone)";
          manipulators = [
            {
              type = "basic";
              from = {
                key_code = "caps_lock";
                modifiers.optional = [ "any" ];
              };
              to = [
                {
                  key_code = "left_shift";
                  modifiers = [ "left_command" "left_control" "left_option" ];
                }
              ];
              to_if_alone = [ { key_code = "escape"; } ];
            }
          ];
        }
        {
          description = "Map Shift + Backspace to Forward Delete";
          manipulators = [
            {
              type = "basic";
              from = {
                key_code = "delete_or_backspace";
                modifiers.mandatory = [ "shift" ];
              };
              to = [ { key_code = "delete_forward"; } ];
            }
          ];
        }
        {
          description = "Shift_L tap -> '(', Shift_R tap -> ')'";
          manipulators = [
            {
              type = "basic";
              from = {
                key_code = "left_shift";
                modifiers.optional = [ "any" ];
              };
              to = { key_code = "left_shift"; };
              to_if_alone = [
                {
                  key_code = "9";
                  modifiers = [ "left_shift" ];
                }
              ];
            }
            {
              type = "basic";
              from = {
                key_code = "right_shift";
                modifiers.optional = [ "any" ];
              };
              to = { key_code = "right_shift"; };
              to_if_alone = [
                {
                  key_code = "0";
                  modifiers = [ "left_shift" ];
                }
              ];
            }
          ];
        }
      ];

      simple_modifications = [
        {
          from = { key_code = "keypad_num_lock"; };
          to = [ { key_code = "fn"; } ];
        }
      ];

      fn_function_keys = [
        { from = { key_code = "f3"; }; to = [ { key_code = "mission_control"; } ]; }
        { from = { key_code = "f4"; }; to = [ { key_code = "launchpad"; } ]; }
        { from = { key_code = "f5"; }; to = [ { key_code = "illumination_decrement"; } ]; }
        { from = { key_code = "f6"; }; to = [ { key_code = "illumination_increment"; } ]; }
        { from = { key_code = "f9"; }; to = [ { consumer_key_code = "fastforward"; } ]; }
      ];

      devices = [
        {
          identifiers = device.appleWirelessKeyboard;
          simple_modifications = [
            {
              from = { key_code = "non_us_backslash"; };
              to = [ { key_code = "grave_accent_and_tilde"; } ];
            }
          ];
        }
        {
          identifiers = device.logitechK120;
          manipulate_caps_lock_led = false;
          simple_modifications = [
            { from = { key_code = "left_command"; }; to = [ { key_code = "left_option"; } ]; }
            { from = { key_code = "left_option"; }; to = [ { key_code = "left_command"; } ]; }
            { from = { key_code = "right_command"; }; to = [ { key_code = "right_option"; } ]; }
            { from = { key_code = "right_option"; }; to = [ { key_code = "right_command"; } ]; }
          ];
        }
        {
          identifiers = device.yubikey;
          manipulate_caps_lock_led = false;
        }
        {
          disable_built_in_keyboard_if_exists = true;
          identifiers = device.zsaMoonlander;
          simple_modifications = [
            {
              from = { key_code = "keypad_num_lock"; };
              to = [ { apple_vendor_keyboard_key_code = "language"; } ];
            }
          ];
        }
      ];

      virtual_hid_keyboard = { keyboard_type_v2 = "ansi"; };
    }
  ];
}
