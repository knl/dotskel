{ config, lib, pkgs, ... }:

let
  link = config.lib.file.mkOutOfStoreSymlink;
in
{
  config = {
    home.packages = with pkgs; [
      gitAndTools.delta
      # gitAndTools.git-branchless
      gitAndTools.gitSVN
      gitAndTools.hub
    ];

    programs.git = {
      enable = true;
      userEmail = "nikola@knezevic.ch";
      package = pkgs.gitAndTools.gitFull.override { openssh = pkgs.openssh_hpnWithKerberos; };
      userName = "Nikola Knezevic";
      # aliases are defined in ~/.gitaliases
      extraConfig = {
        color = {
          status = "auto";
          diff = "auto";
          branch = "auto";
          ui = "auto";
        };
        credential.helper = "osxkeychain";
        core.whitespace = "fix,-indent-with-non-tab,trailing-space,cr-at-eol";
        repack.usedeltabaseoffset = "true";
        column.ui = "auto";
        branch = {
          # sort = "auto";
          autosetupmerge = "true";
        };
        # Sort tags as version numbers whenever applicable, so 1.10.2 is AFTER 1.2.0.
        tag.sort = "version:refname";
        init.defaultBranch = "main";
        diff = {
          algorithm = "histogram";
          renames = "true";
          mnemonicprefix = "true";
          colorMoved = "plain";
        };
        push = {
          default = "current";
          autoSetupRemote = "true";
          followTags = "true";
        };
        fetch = {
          prune = "true";
          pruneTags = "true";
          all = "true";
        };
        help.autocorrect = "prompt";
        commit.verbose = "true";
        rebase = {
          autoSquash = "true";
          autoStash = "true";
          updateRefs = "true";
        };
        merge = {
          stat = "true";
          conflictstyle = "zdiff3";
        };
        pull = {
          ff = "only";
          rebase = "true";
        };
        rerere = {
          autoupdate = true;
          enabled = true;
        };
      };
      # Replaces ~/.gitignore
      ignores = [
        ".cache/"
        ".DS_Store"
        ".idea/"
        "*.swp"
        "*.elc"
        "auto-save-list"
        ".direnv/"
        # exclude nix-build result
        "result"
        "result-*"
      ];
      # see home.file.".gitaliases".source below
      includes = [
        { path = "~/.gitaliases"; }
      ];
    };
    home.file.".gitaliases".source = link ../../configs/gitaliases;
  };
}
