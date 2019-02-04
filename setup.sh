#!/bin/sh

FILES='gitconfig \
    gitattributes \
    gitignore \
    tmux.conf \
    hammerspoon \
    spacemacs'

SKELDIR=`pwd`

# setup quicksilver
mkdir -p ${HOME}/Library/Application\ Support/Quicksilver
# .. remove files first
rm -f ${HOME}/Library/Application\ Support/Quicksilver/Triggers.plist
ln -sf ${SKELDIR}/quicksilver/Triggers.plist ${HOME}/Library/Application\ Support/Quicksilver/

# spacemacs!
# brew tap railwaycat/emacsmacport
# brew install --with-spacemacs-icon --with-imagemagick --with-gnutls --with-ctags emacs-mac
git clone --recursive http://github.com/syl20bnr/spacemacs $HOME/.emacs.d

# copy preferences
for pref in preferences/*.plist; do
    ln -sf ${SKELDIR}/${pref} ${HOME}/Library/Preferences/
done

# add config files at their right locations
cd ${HOME}
for fname in ${FILES}; do ln -sf ${SKELDIR}/${fname} .${fname}; done
