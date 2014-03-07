#!/bin/sh

FILES='
    gitconfig \
    gitattributes \
    gitignore \
    ackrc \
    hgrc \
    hgskel \
    hgignore \
    tmux.conf \
    slate \
    '

SKELDIR=`pwd`

cd ${HOME}
for fname in ${FILES}; do ln -sf ${SKELDIR}/${fname} .${fname}; done

# setup keyremap4macbook
mkdir -p ${HOME}/Library/Application\ Support/KeyRemap4MacBook/
ln -s ${SKELDIR}/keyremap4macbook/private.xml ${HOME}/Library/Application\ Support/KeyRemap4MacBook/

# setup quicksilver
mkdir -p ${HOME}/Library/Application\ Support/Quicksilver
ln -s ${SKELDIR}/quicksilver/Triggers.plist ${HOME}/Library/Application\ Support/Quicksilver/

sudo easy_install hg-git
sudo easy_install mercurial_keyring
sudo easy_install keyring
