{ config, lib, pkgs, ... }:

{
  config = {
    programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      withRuby = false;
      extraConfig = ''
        syntax on
        syntax enable                     " Turn on syntax highlighting allowing local overrides
        set hidden                        " hide buffers instead of removing them
        set number                        " Show line numbers
        set relativenumber                " Show them relative to line
        set ruler                         " Show line and column number
        set termguicolors                 " Use full colors
        set clipboard=unnamed             " Allow for x-app pasting
      '';
    };
  };
}
