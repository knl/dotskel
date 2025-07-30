{ config, lib, pkgs, ... }:

{
  config = {
    programs.bat = {
      enable = true;
      config = {
        style = "header,changes";
        theme = "Monokai Extended Light";
      };
    };
  };
}
