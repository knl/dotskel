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

sudo easy_install mercurial_keyring
sudo easy_install keyring
