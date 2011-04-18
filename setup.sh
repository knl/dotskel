#!/bin/sh

FILES='gitconfig gitattributes gitignore'

PWD=`pwd`

cd ${HOME}
for fname in ${FILES}; do ln -sf ${PWD}/${fname} .; done