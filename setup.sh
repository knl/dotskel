#!/bin/sh

FILES='\
    gitconfig \
    gitattributes \
    gitignore \
    ackrc \
    hgrc \
    hgskel \
    hgignore \
    tmux.conf \
    '

SKELDIR=`pwd`

cd ${HOME}
for fname in ${FILES}; do ln -sf ${SKELDIR}/${fname} .${fname}; done
