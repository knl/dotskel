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
  };
}
