{ config, lib, pkgs, ... }:

let
  sources = import ../../npins/default.nix;

  # The `<tool> init zsh` outputs below are environment-independent (verified
  # by diffing runs across clean/changed environments), so generate them once
  # at build time and source the files, instead of forking the tool at every
  # shell startup.
  staticInit = name: cmd: pkgs.runCommand "zsh-${name}-init" { } "${cmd} > $out";
  zoxideInit = staticInit "zoxide" "${config.programs.zoxide.package}/bin/zoxide init zsh";
  fzfInit = staticInit "fzf" "${config.programs.fzf.package}/bin/fzf --zsh";
  # carapace reads $XDG_CONFIG_HOME/carapace/specs at init (unreadable in the
  # sandbox) and embeds the config path in its PATH bootstrap line, so point
  # it at an empty stand-in and fix the path up. `typeset -U path` dedups the
  # PATH prepend in nested shells. Only used while no user specs exist, see
  # carapaceHasSpecs.
  carapaceInit = pkgs.runCommand "zsh-carapace-init" { } ''
    export XDG_CONFIG_HOME=$TMPDIR/config
    mkdir -p $XDG_CONFIG_HOME/carapace/specs
    ${config.programs.carapace.package}/bin/carapace _carapace zsh \
      | sed "s|$XDG_CONFIG_HOME|${config.xdg.configHome}|g" > $out
  '';
  # The prebuilt init can never include user specs (the sandbox can't read
  # them), so detect them at eval time — impure, like the getEnv in home.nix —
  # and fall back to runtime init whenever any exist.
  carapaceSpecsDir = "${config.xdg.configHome}/carapace/specs";
  carapaceHasSpecs =
    builtins.pathExists carapaceSpecsDir
    && builtins.removeAttrs (builtins.readDir carapaceSpecsDir) [ ".DS_Store" ] != { };
  # rh embeds the invoking lua into its output; pkgs.lua is the same package
  # as the `lua` in home.packages.
  rhInit = staticInit "rh"
    "${pkgs.lua}/bin/lua ${sources.rh}/rh.lua --init zsh ${config.home.homeDirectory}/work";
in

{
  config = {
    programs.zsh = rec {
      enable = true;

      # This way, my functions could be stored under
      # .config/zsh/lib
      dotDir = "${config.xdg.configHome}/zsh";

      # zsh-autosuggestions is loaded via the plugins list below; enabling
      # this as well would source the nixpkgs copy on top of it.
      autosuggestion.enable = false;
      enableCompletion = true;
      # compinit -C skips the slow fpath security audit. The dump is keyed on
      # the nix store paths that feed fpath (the profiles plus this
      # generation's .zshrc), so any rebuild or profile change starts a fresh
      # dump automatically; unchanged generations reuse the zcompiled dump.
      completionInit = ''
        autoload -U compinit
        () {
          local p key=
          for p in ''${(z)NIX_PROFILES} $ZDOTDIR/.zshrc; do
            p=''${p:A}
            key+=''${''${''${p#/nix/store/}%%-*}//\//}
          done
          local dump=''${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-''${ZSH_VERSION}-''${key:-default}
          if [[ ! -e $dump ]]; then
            command mkdir -p -- ''${dump:h}
            command rm -f -- ''${dump:h}/zcompdump-*(N)
          fi
          compinit -C -d $dump
          if [[ ! -e $dump.zwc || $dump -nt $dump.zwc ]]; then
            zcompile $dump
          fi
        }
      '';
      history = {
        size = 50000;
        save = 500000;
        # Put the ZSH history into the same directory as the configuration.
        # Also, the path must be absolute, relative paths just make new directories
        # wherever you're working from.
        path = "${dotDir}/history";
        extended = true;
        ignoreDups = true;
        share = true;
      };

      sessionVariables = rec {
        LANG = "en_US.UTF-8";
        LC_ALL = "en_US.UTF-8";

        NVIM_TUI_ENABLE_TRUE_COLOR = "1";

        BROWSER = if pkgs.stdenv.isDarwin then "open" else "xdg-open";

        # use the same nixpkgs for the rest of the system as we use here
        NIX_PATH = "nixpkgs=${sources.nixpkgs}:home-manager=${sources."home-manager"}";

        EDITOR = "vim";
        VISUAL = EDITOR;
        GIT_EDITOR = EDITOR;

        XDG_CONFIG_HOME = config.xdg.configHome;
        XDG_CACHE_HOME = config.xdg.cacheHome;
        XDG_DATA_HOME = config.xdg.dataHome;

        GOPATH = "$HOME/go";
        PATH = "$HOME/bin:$HOME/.local/bin:$GOPATH/bin:$HOME/.emacs.d/bin:$PATH";
        TERM = "xterm-256color";

        LESS = "-F -g -i -M -R -S -w -X -z-4";

        _ZO_DATA_DIR = "$HOME/.local/zoxide";
      };

      localVariables = {
        # This way, C-w deletes words (path elements)
        WORDCHARS = "*?_-.[]~&;!#$%^(){}<>";

        ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE = "fg=8";
        # Bind the autosuggest widgets once at the first precmd instead of
        # re-binding on every prompt. (Async suggestion fetching needs no
        # setting: the plugin force-enables ZSH_AUTOSUGGEST_USE_ASYNC on
        # zsh >= 5.0.8.)
        ZSH_AUTOSUGGEST_MANUAL_REBIND = "1";
      };

      shellAliases = {
        l = "eza --color auto";
        ls = "eza -G --color auto -a -s type";
        ll = "eza -l --color always -a -s type";
        "]" = "open";
        dl = "\curl -O -L";
        p = "pushd";
        pd = "perldoc";
        mkdir = "nocorrect mkdir";
        cat = "bat";
        x = "unar";
        zb = "z -b";
        zh = "z -I -t .";
        # fd's default of not searching hidden files is annoying
        f = "fd -H --no-ignore";
        k = "kubectl";
        hm = "home-manager";
        d = "direnv";

        df = "duf";
        du = "dua";

        # commonly used git aliases (lifted from prezto)
        g = "git";
        ga = "git add";
        gai = "git add -i";
        gap = "git add --patch";
        gau = "git add --update";
        gb = "git branch";
        gbx = "git branch -d";
        gbX = "git branch -D";
        gba = "git branch -a";
        gbm = "git branch -m";
        gc = "git commit --verbose";
        gcm = "git commit --message";
        gcf = "git commit --amend --reuse-message HEAD";
        gco = "git checkout";
        gd = "git diff";
        gl = "git pull";
        gm = "git merge";
        gma = "git merge --abort";
        gcpa = "git cherry-pick --abort";
        gp = "git push -u";
        gpf = "git push -u --force-with-lease";
        gpa = "git push --all && git push --tags";
        gr = "git rebase";
        gri = "git rebase --interactive";
        gra = "git rebase --abort";
        grc = "git rebase --continue";
        grs = "git rebase --skip";
        gst = "git status";
        gt = "git tag";
        gup = ''git fetch -p && git rebase --autostash "''${$(git symbolic-ref refs/remotes/origin/HEAD)#refs/remotes/}"'';
        gfa = "git fetch --all -v";
        stash = "git stash";
        unstash = "git stash pop";
        staged = "git diff --no-ext-diff --cached";
      };

      initContent =
        let
          # Must stay the very first thing in .zshrc (mkBefore is order 500,
          # this is 400): paints the prompt immediately and lets the rest of
          # the init run behind it.
          instantPrompt = pkgs.lib.mkOrder 400 ''
            if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
              source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
            fi
          '';
          initExtraFirst = pkgs.lib.mkBefore ''
	    # Make sure we can get nix after macos upgrade (when /etc/zshrc gets overwritten)
	    if [[ ! $(command -v nix) && -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]]; then
	        source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
	    fi

            DIRSTACKSIZE=10

            setopt   emacs

            setopt   notify globdots correct cdablevars autolist
            setopt   correctall autocd recexact longlistjobs
            setopt   autoresume
            setopt   rcquotes mailwarning
            unsetopt bgnice
            setopt   autopushd pushdminus pushdsilent pushdtohome pushdignoredups

            setopt COMPLETE_IN_WORD    # Complete from both ends of a word.
            setopt ALWAYS_TO_END       # Move cursor to the end of a completed word.
            setopt AUTO_MENU           # Show completion menu on a successive tab press.
            setopt AUTO_LIST           # Automatically list choices on ambiguous completion.
            setopt EXTENDED_GLOB       # Needed for file modification glob modifiers with compinit
            unsetopt AUTO_PARAM_SLASH    # If completed parameter is a directory, do not add a trailing slash.
            unsetopt MENU_COMPLETE     # Do not autoselect the first completion entry.
            unsetopt FLOW_CONTROL      # Disable start/stop characters in shell editor.

            # compinit will be called after this block
          '';

          # Called whenever zsh is initialized
          initExtra = ''
            # Nix setup (environment variables, etc.)
            if [ -e ~/.nix-profile/etc/profile.d/nix.sh ]; then
              . ~/.nix-profile/etc/profile.d/nix.sh
            fi

            # expands .... to ../..
            function expand-dot-to-parent-directory-path {
              if [[ $LBUFFER = *.. ]]; then
                LBUFFER+='/..'
              else
                LBUFFER+='.'
              fi
            }
            zle -N expand-dot-to-parent-directory-path

            bindkey -M emacs '\e[1;5D' backward-word
            bindkey -M emacs '\e[1;5C' forward-word
            bindkey -M emacs '\e[3~' delete-char
            bindkey -M emacs "^P" history-substring-search-up
            bindkey -M emacs "^N" history-substring-search-down
            # also bind to keys up and down
            bindkey '^[[A' history-substring-search-up
            bindkey '^[[B' history-substring-search-down
            # expand .... to ../..
            bindkey -M emacs "." expand-dot-to-parent-directory-path
            # but not during incremental search
            bindkey -M isearch . self-insert 2> /dev/null

            # more flexible push-line, C-q kills the line and restores after new line is executed
            for key in "\C-Q" "\e"{q,Q}
              bindkey -M emacs "$key" push-line-or-edit
            # Expand history on space.
            bindkey -M emacs ' ' magic-space

            fpath=(${config.xdg.configHome}/zsh/functions(-/FN) $fpath)
            # functions must be autoloaded, do it in a function to isolate
            function {
              local pfunction_glob='^([_.]*|prompt_*_setup|README*|*~)(-.N:t)'

              local pfunction
              # Extended globbing is needed for listing autoloadable function directories.
              setopt LOCAL_OPTIONS EXTENDED_GLOB

              for pfunction in ${config.xdg.configHome}/zsh/functions/$~pfunction_glob; do
                autoload -Uz "$pfunction"
              done
            }

            source ${rhInit}

            # Theme config; powerlevel10k itself is loaded earlier, as a plugin
            source ${config.xdg.configHome}/zsh/p10k.zsh

            # zsh-histdb start
            # sqlite-history.zsh itself is sourced via the zsh-histdb plugin entry
            HISTDB_TABULATE_CMD=(sed -e $'s/\x1f/\t/g')

            _zsh_autosuggest_strategy_histdb_top() {
                local query="
                    select commands.argv from history
                    left join commands on history.command_id = commands.rowid
                    left join places on history.place_id = places.rowid
                    where commands.argv LIKE '$(sql_escape $1)%'
                    group by commands.argv, places.dir
                    order by places.dir != '$(sql_escape $PWD)', count(*) desc
                    limit 1
                "
                suggestion=$(_histdb_query "$query")
            }

            ZSH_AUTOSUGGEST_STRATEGY=histdb_top

            # need to rebind the key again, since plugins are sourced before sourcing fzf
            bindkey '^R' histdb-fzf-widget
            # zsh-histdb end

            # fzf goodies
            _fzf_complete_git() {
                _fzf_complete \
                    --preview='git show --color=always {1}' \
                    --preview-window=wrap,~6\
                    -- "$@" < <(
                        if [[ "$*" == *"--"* ]]; then
                            git ls-files
                        else
                            git log --oneline
                        fi
                    )
            }

            _fzf_complete_git_post() {
                cut -d ' ' -f1
            }

            # Tab/window title (OSC 2). Ghostty's own title integration is
            # disabled (no-title in configs/ghostty/config): it reports the
            # cwd head-first, and tab truncation eats the tail, leaving only
            # the uninformative leading components. Instead: the repo name
            # plus the abbreviated path below it when inside a git/jj
            # checkout (dotskel, dotskel/m/programs), fish-style abbreviated
            # ~-relative path otherwise (s/foo for ~/scratchpad/foo).
            _tab_title_precmd() {
              [[ $TERM == (dumb|linux) || -z $TTY ]] && return
              local root=$PWD pretty= first=1
              local -a parts
              while [[ -n $root && ! -e $root/.git && ! -e $root/.jj ]]; do
                root=''${root%/*}
              done
              if [[ -n $root && $root != $HOME ]]; then
                # Inside a checkout: repo name stays full, the rest shortens.
                parts=(''${root:t} ''${(s:/:)''${PWD#$root}})
                first=2
              else
                pretty=''${(%):-%~}
                parts=(''${(s:/:)pretty})
                (( $#parts > 1 )) && [[ $parts[1] == '~' ]] && parts[1]=()
              fi
              local i
              for (( i = first; i < $#parts; i++ )); do
                [[ $parts[i] == .* ]] && parts[i]=''${parts[i][1,2]} || parts[i]=''${parts[i][1]}
              done
              local title=''${(j:/:)parts}
              [[ $pretty == /* ]] && title=/$title
              print -rn -- $'\e]2;'$title$'\a' > $TTY
            }

            # While a command runs, show it in the title (what ghostty's
            # integration did); the next precmd switches back to the path.
            _tab_title_preexec() {
              [[ $TERM == (dumb|linux) || -z $TTY ]] && return
              local cmd=''${1//[[:cntrl:]]}
              print -rn -- $'\e]2;'$cmd$'\a' > $TTY
            }

            autoload -Uz add-zsh-hook
            add-zsh-hook precmd _tab_title_precmd
            add-zsh-hook preexec _tab_title_preexec
          '';
          # Static replacements for the disabled enableZshIntegration hooks,
          # at the orders the home-manager modules would have used: zoxide
          # 851, fzf 910 (with its zle guard), carapace at the end of the
          # order-1000 block.
          staticInits = pkgs.lib.mkMerge [
            (pkgs.lib.mkOrder 851 "source ${zoxideInit}")
            (pkgs.lib.mkOrder 910 ''
              if [[ $options[zle] = on ]]; then
                source ${fzfInit}
              fi
            '')
            (pkgs.lib.mkOrder 1001 (
              if carapaceHasSpecs then
                # Specs only work with runtime init; costs one fork per startup.
                "source <(${config.programs.carapace.package}/bin/carapace _carapace zsh)"
              else
                ''
                  source ${carapaceInit}
                  # Catch specs added since the last switch; rebuilding picks
                  # the runtime-init branch above as long as any spec exists.
                  () {
                    local -a specs=(${config.xdg.configHome}/carapace/specs/*(N))
                    specs=(''${specs:#*/.DS_Store})
                    (( $#specs )) && print -ru2 -- "carapace: new spec files detected; run 'hm switch' to include them in completions"
                  }
                ''
            ))
          ];
        in
        pkgs.lib.mkMerge [ instantPrompt initExtraFirst initExtra staticInits ];

      siteFunctions = {
        take = ''
          \mkdir -p "$1" && cd "$1"
	'';
	up = ''
          local n=''${1:-1}
          [[ "$n" =~ '^[0-9]+$' ]] || { echo "usage: up [number]"; return 1; }
          cd $(printf '../%.0s' {1..$n})
	'';
	running = ''
          set -euo pipefail
          
          process_list="$(ps -eo 'pid command')"
          if [[ $# != 0 ]]; then
            process_list="$(echo "$process_list" | grep -Fiw "$@")"
          fi
          
          echo "$process_list" |
            grep -Fv "''${BASH_SOURCE[0]}" |
            grep -Fv grep |
            GREP_COLORS='mt=00;35' grep -E --colour=auto '^\s*[[:digit:]]+'
        '';
        cpwd = ''
          set -euo pipefail
          pwd | tr -d '\n' | pbcopy
        '';
      };

      plugins = [
        {
          name = "zsh-autosuggestions";
          src = sources.zsh-autosuggestions;
        }
        {
          name = "fast-syntax-highlighting";
          src = sources.fast-syntax-highlighting;
        }
        {
          name = "zsh-history-substring-search";
          src = sources.zsh-history-substring-search;
        }
        {
          name = "async";
          src = sources.zsh-async;
        }
        {
          # upstream ships no powerlevel10k.plugin.zsh, so name the theme file
          # explicitly; the p10k.zsh config is sourced later, from initContent
          name = "powerlevel10k";
          src = sources.powerlevel10k;
          file = "powerlevel10k.zsh-theme";
        }
        {
          name = "zsh-you-should-use";
          src = sources.zsh-you-should-use;
        }
        {
          name = "zsh-histdb";
          src = sources.zsh-histdb;
        }
        {
          name = "zsh-histdb-fzf";
          src = sources.zsh-histdb-fzf;
        }
        {
          name = "zsh-autopair";
          src = sources.zsh-autopair;
        }
      ];
    };
    xdg.configFile."zsh/p10k.zsh".source = ../../zsh/p10k.zsh;
    xdg.configFile."zsh/p10k-jj.zsh".source = ../../zsh/p10k-jj.zsh;
    xdg.configFile."zsh/functions".source = ../../zsh/functions;
  };
}
