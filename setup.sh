#!/bin/sh

FILES='
    gitconfig \
    gitattributes \
    gitignore \
    ackrc \
    tmux.conf \
    hammerspoon \
    '

SKELDIR=`pwd`

# setup Karabiner
mkdir -p ${HOME}/Library/Application\ Support/Karabiner/
# ... remove files first
rm -f ${HOME}/Library/Application\ Support/Karabiner/private.xml ${HOME}/Library/Preferences/org.pqrs.Karabiner.plist
ln -sf ${SKELDIR}/karabiner/private.xml ${HOME}/Library/Application\ Support/Karabiner/
ln -sf ${SKELDIR}/karabiner/org.pqrs.Karabiner.plist ${HOME}/Library/Preferences/

# setup quicksilver
mkdir -p ${HOME}/Library/Application\ Support/Quicksilver
# .. remove files first
rm -f ${HOME}/Library/Application\ Support/Quicksilver/Triggers.plist
ln -sf ${SKELDIR}/quicksilver/Triggers.plist ${HOME}/Library/Application\ Support/Quicksilver/

# spacemacs!
# brew tap railwaycat/emacsmacport
# brew install emacs-mac
git clone --recursive http://github.com/syl20bnr/spacemacs $HOME/.emacs.d

# add config files at their right locations
cd ${HOME}
for fname in ${FILES}; do ln -sf ${SKELDIR}/${fname} .${fname}; done
