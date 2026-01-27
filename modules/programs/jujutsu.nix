{ config, lib, pkgs, ... }:

let
  link = config.lib.file.mkOutOfStoreSymlink;
in
{
  config = {
    programs.jujutsu = {
      enable = true;
    };
    xdg.configFile."jj/config.toml".source = link ../../configs/jj/config.toml;

    home.activation.installScripts = lib.hm.dag.entryAfter ["writeBoundary"] ''
      for script in ${../../scripts}/{indent,jju,jjx}; do
        ln -sf "$script" "$HOME/bin/$(basename "$script")"
      done
    '';
  };
}
