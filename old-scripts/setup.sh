#!/bin/sh

FILES='gitconfig \
    gitattributes \
    gitignore \
    hammerspoon \
    spacemacs'

SKELDIR=`pwd`

# setup quicksilver
mkdir -p ${HOME}/Library/Application\ Support/Quicksilver
# .. remove files first
rm -f ${HOME}/Library/Application\ Support/Quicksilver/Triggers.plist
ln -sf ${SKELDIR}/quicksilver/Triggers.plist ${HOME}/Library/Application\ Support/Quicksilver/

# spacemacs!
brew tap d12frosted/emacs-plus
brew install emacs-plus
brew linkapps emacs-plus
git clone http://github.com/syl20bnr/spacemacs $HOME/.emacs.d

# copy preferences
for pref in preferences/*.plist; do
    ln -sf ${SKELDIR}/${pref} ${HOME}/Library/Preferences/
done

# add config files at their right locations
cd ${HOME}
for fname in ${FILES}; do ln -sf ${SKELDIR}/${fname} .${fname}; done
