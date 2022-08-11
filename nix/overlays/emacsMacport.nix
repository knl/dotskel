self: super: rec {

  spacemacsIcon = super.fetchurl {
    url = "https://github.com/nashamri/spacemacs-logo/raw/917f2f2694019d534098f5e2e365b5f6e5ddbd37/spacemacs.icns";
    sha256 = "sha256:0049lkmc8pmb9schjk5mqy372b3m7gg1xp649gibriabz9y8pnxk";
  };

  emacsMacport = super.emacsMacport.overrideAttrs (old: rec {
    # patches = [
    #   (super.fetchpatch {
    #     name = "fix-window-role.patch";
    #     url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/f3c16d68bbf52c1779be279579d124d726f0d04a/patches/emacs-27/fix-window-role.patch";
    #     sha256 = "sha256:1hcfm6dxy2ji7q8fw502757920axffy32qlk9pcmpmk6q1zclgzv";
    #   })
    #   (super.fetchpatch {
    #     name = "system-appearance.patch";
    #     url = "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/f3c16d68bbf52c1779be279579d124d726f0d04a/patches/emacs-27/system-appearance.patch";
    #     sha256 = "sha256:09zw6an5dxy1bjl3wx7wlrxhw6fp3i2qvdav83kqxlj06lz31miw";
    #   })
    #   # (super.fetchpatch {
    #   #   name = "ligatures-freeze-fix.patch";
    #   #   url = "https://github.com/d12frosted/homebrew-emacs-plus/raw/f3c16d68bbf52c1779be279579d124d726f0d04a/patches/emacs-27/ligatures-freeze-fix.patch";
    #   #   sha256 = "sha256:0zldjs8nx26x7r8pwjc995lvpg06iv52rq4cy1w38hxhy7vp8lp3";
    #   # })
    # ];
    postPatch = old.postPatch + ''
      # copy the nice icon to it
      cp ${spacemacsIcon} mac/Emacs.app/Contents/Resources/Emacs.icns
    '';
  });

}
