# dotskel

A set of dotfiles and setup scripts to tune a system to my needs.

Based on chezmoi, prezto, and homebrew.

## Installation

To setup the system, run:

    ./setup.sh
    
The run the following code to setup the necessary values. Replace variables to
match the system:

    mkdir -p ~/.config/chezmoi/
    cat >~/.config/chezmoi/chezmoi.yaml <<EOF
    data:
      email: nikola@knezevic.ch
    EOF
    
Finally, apply chezmoi config:

    chezmoi apply
    
## Update

As simple as:

    chezmoi update --verbose
