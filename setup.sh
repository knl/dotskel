#!/bin/sh

FILES='\
    gitconfig \
    gitattributes \
    gitignore \
    ackrc \
    hgrc \
'

SKELDIR=`pwd`

cd ${HOME}
for fname in ${FILES}; do ln -sf ${SKELDIR}/${fname} .${fname}; done
