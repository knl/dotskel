#!/bin/sh

sudo xcode-select --install

/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

brew tap d12frosted/emacs-plus
brew install emacs-plus
brew linkapps emacs-plus

brew install zsh fzf direnv fd ripgrep fasd

brew tap twpayne/taps
brew install twpayne/taps/chezmoi

# install the dependencies
git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d

# zprezto goes in zsh
zsh << EOF
git clone --recursive https://github.com/knl/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"

setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
    ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done
EOF

chezmoi init https://github.com/knl/dotskel.git
