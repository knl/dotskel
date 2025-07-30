{ config, lib, pkgs, ... }:

let
  sources = import ../../nix/sources.nix;
in

{
  config = {
    programs.zsh = rec {
      enable = true;

      # This way, my functions could be stored under
      # .config/zsh/lib
      dotDir = ".config/zsh";

      autosuggestion.enable = true;
      enableCompletion = true;
      history = {
        size = 50000;
        save = 500000;
        # Put the ZSH history into the same directory as the configuration.
        # Also, the path must be absolute, relative paths just make new directories
        # wherever you're working from.
        path =
          let
            inherit (config.home) homeDirectory;
          in
          "${homeDirectory}/${dotDir}/history";
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
        PATH = "$HOME/bin:$GOPATH/bin:$HOME/.emacs.d/bin:$PATH";
        TERM = "xterm-256color";

        LESS = "-F -g -i -M -R -S -w -X -z-4";

        # This is to make `z my-dir` work with z.lua
        _ZL_HYPHEN = "1";
      };

      localVariables = {
        # This way, C-w deletes words (path elements)
        WORDCHARS = "*?_-.[]~&;!#$%^(){}<>";

        ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE = "fg=8";
      };

      shellAliases = {
        l = "eza --color auto";
        ls = "eza -G --color auto -a -s type";
        ll = "eza -l --color always -a -s type";
        "]" = "open";
        dl = "\curl -O -L";
        up = "\cd ..";
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

        jjw = "viddy --skip-empty-diffs --unfold 'jjx 2>&1'";

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
          initExtraFirst = pkgs.lib.mkBefore ''
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

            if [[ -n $GHOSTTY_RESOURCES_DIR ]]; then
              source "$GHOSTTY_RESOURCES_DIR"/shell-integration/zsh/ghostty-integration
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

            eval "$(lua ${sources.rh}/rh.lua --init zsh ~/work)"

            # Theme (custom built on powerlevel10k)
            # First load all variables
            source ${config.xdg.configHome}/zsh/p10k.zsh
            # Then source the theme
            source ${sources.powerlevel10k}/powerlevel10k.zsh-theme

            # zsh-histdb start
            HISTDB_TABULATE_CMD=(sed -e $'s/\x1f/\t/g')

            source ''${ZDOTDIR}/plugins/zsh-histdb/sqlite-history.zsh

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
          '';
        in
        pkgs.lib.mkMerge [ initExtraFirst initExtra ];

      loginExtra = ''
        # Execute code only if STDERR is bound to a TTY.
        if [[ -o INTERACTIVE && -t 2 ]]; then
          # Print a random, hopefully interesting, adage.
          if (( $+commands[fortune] )); then
            fortune -s
            print
          fi
        fi >&2
      '';

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
          # look at home.file.".p10k.zsh".source for config
          name = "powerlevel10k";
          src = sources.powerlevel10k;
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
    xdg.configFile."zsh/functions".source = ../../zsh/functions;
  };
}
