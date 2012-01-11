#!/bin/sh

FILES='gitconfig gitattributes gitignore'

SKELDIR=`pwd`

cd ${HOME}
for fname in ${FILES}; do ln -sf ${SKELDIR}/${fname} .; done