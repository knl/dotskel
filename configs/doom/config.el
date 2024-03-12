;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "Nikola Knezevic"
      user-mail-address "nikola.knezevic@imc.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-unicode-font' -- for unicode glyphs
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
(setq doom-font (font-spec :family "Iosevka Term SS08" :size 16))
;;      doom-unicode-font (font-spec :family "FiraCode Nerd Font Mono" :size 15))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one-light)
;; (setq doom-theme 'ujelly)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type "relative")

;; workaround for large title bar on macOS Sonoma
;; see https://github.com/doomemacs/doomemacs/issues/7532
(add-hook 'doom-after-init-hook (lambda () (tool-bar-mode 1) (tool-bar-mode 0)))

(map! (:after evil-org
       :map evil-org-mode-map
       :n "gk" (cmd! (if (org-at-heading-p)
                         (org-backward-element)
                       (evil-previous-visual-line)))
       :n "gj" (cmd! (if (org-at-heading-p)
                         (org-forward-element)
                       (evil-next-visual-line))))

      :o "o" #'evil-inner-symbol

      :leader
      "0" #'+treemacs/toggle
      "h L" #'global-keycast-mode
      (:prefix "f"
               "t" #'find-in-dotfiles
               "T" #'browse-dotfiles)
      (:prefix "w"
               "-" #'+evil/window-split-and-follow
               "/" #'+evil/window-vsplit-and-follow)
      (:prefix "n"
               "b" #'org-roam-buffer-toggle
               "d" #'org-roam-dailies-goto-today
               "D" #'org-roam-dailies-goto-date
               "i" #'org-roam-node-insert
               "r" #'org-roam-node-find
               "R" #'org-roam-capture))

;;; :tools lsp
;; Disable invasive lsp-mode features
(after! lsp-mode
  (setq lsp-enable-symbol-highlighting nil
        ;; If an LSP server isn't present when I start a prog-mode buffer, you
        ;; don't need to tell me. I know. On some machines I don't care to have
        ;; a whole development environment for some ecosystems.
        lsp-enable-suggest-server-download nil))
(after! lsp-ui
  (setq lsp-ui-sideline-enable nil  ; no more useful than flycheck
        lsp-ui-doc-enable nil))     ; redundant with K
                                    ;

;;; :lang org
(setq +org-roam-auto-backlinks-buffer nil
      org-directory "~/notes/"
      org-roam-directory (concat org-directory "roam/")
      org-roam-db-location (concat org-roam-directory ".org-roam.db")
      org-roam-dailies-directory "daily/"
      org-archive-location (concat org-directory ".archive/%s::")
      org-agenda-files org-directory)

(after! org-roam
  (setq org-roam-capture-templates
        `(("n" "note" plain
           ,(format "#+title: ${title}\n%%[%s/template/note.org]" org-roam-directory)
           :target (file "%<%F%T>-${slug}.org")
           :unnarrowed t)
          ("r" "thought" plain
           ,(format "#+title: ${title}\n%%[%s/template/thought.org]" org-roam-directory)
           :target (file "thought/%<%F%T>-${slug}.org")
           :unnarrowed t)
          ("p" "project" plain
           ,(format "#+title: ${title}\n%%[%s/template/project.org]" org-roam-directory)
           :target (file "project/%<%F>-${slug}.org")
           :unnarrowed t)
          ("f" "ref" plain
           ,(format "#+title: ${title}\n%%[%s/template/ref.org]" org-roam-directory)
           :target (file "ref/%<%F%T>-${slug}.org")
           :unnarrowed t))
        ;; Use human readable dates for dailies titles
        org-roam-dailies-capture-templates
        '(("d" "default" entry
           "** %?"
           :target (file+head+olp "%<%Y-%m-W%W>.org" "#+title: Week %<%W, %B %Y>\n\n\n" ("%<%F>"))
           :unnarrowed t
           :jump-to-captured t)))
  ;; '(("d" "default" entry "* %?"
  ;;    :target (file+head "%<%Y-%m-%d>.org" "#+title: %<%B %d, %Y>\n\n")))))

  ;; Offer completion for #tags and @areas separately from notes.
  (add-to-list 'org-roam-completion-functions #'org-roam-complete-tag-at-point)

  ;; Automatically update the slug in the filename when #+title: has changed.
  (add-hook 'org-roam-find-file-hook #'org-roam-update-slug-on-save-h)

  ;; Make the backlinks buffer easier to peruse by folding leaves by default.
  (add-hook 'org-roam-buffer-postrender-functions #'magit-section-show-level-2)

  ;; List dailies and zettels separately in the backlinks buffer.
  (advice-add #'org-roam-backlinks-section :override #'org-roam-grouped-backlinks-section)

  ;; Open in focused buffer, despite popups
  (advice-add #'org-roam-node-visit :around #'+popup-save-a)

  ;; Make sure tags in vertico are sorted by insertion order, instead of
  ;; arbitrarily (due to the use of group_concat in the underlying SQL query).
  ;; (advice-add #'org-roam-node-list :filter-return #'org-roam-restore-insertion-order-for-tags-a)

  ;; Add ID, Type, Tags, and Aliases to top of backlinks buffer.
  ;; (advice-add #'org-roam-buffer-set-header-line-format :after #'org-roam-add-preamble-a)
  )

(after! org-tree-slide
  ;; I use g{h,j,k} to traverse headings and TAB to toggle their visibility, and
  ;; leave C-left/C-right to .  I'll do a lot of movement because my
  ;; presentations tend not to be very linear.
  (setq org-tree-slide-skip-outline-level 2))

                                        ;(require 'treemacs-all-the-icons)
(setq doom-themes-treemacs-enable-variable-pitch nil)
(setq doom-themes-treemacs-theme "doom-colors")
                                        ;(treemacs-load-theme "all-the-icons")

;; Until the related PR merged, I neeed to configure colemak binding manually
;; https://github.com/hlissner/doom-emacs/issues/783
(use-package! evil-colemak-basics
  :after evil
  :init
  (setq evil-colemak-basics-layout-mod `mod-dh) ; Swap "h" and "m"
  ;; I frequently use "t" and "f", while end-of-word ("e", on Colemak "j") not so much
  (setq evil-colemak-basics-rotate-t-f-j nil)
  :config
  (global-evil-colemak-basics-mode) ; Enable colemak rebinds
)

(use-package! atomic-chrome
  :defer 5                              ; since the entry of this
                                        ; package is from Chrome
  :config
  (setq atomic-chrome-url-major-mode-alist
        '(("github\\.com"        . gfm-mode)
          ("emacs-china\\.org"   . gfm-mode)
          ("stackexchange\\.com" . gfm-mode)
          ("stackoverflow\\.com" . gfm-mode)))

  (defun +my/atomic-chrome-mode-setup ()
    (setq header-line-format
          (substitute-command-keys
           "Edit Chrome text area.  Finish \
`\\[atomic-chrome-close-current-buffer]'.")))

  (add-hook 'atomic-chrome-edit-mode-hook #'+my/atomic-chrome-mode-setup)

  (atomic-chrome-start-server))

(advice-add '+emacs-lisp-truncate-pin :override (lambda () ()) )

(setq emojify-display-style 'unicode)

;; Weeks should start on Monday
(setq calendar-week-start-day 1)

;; (setq explicit-shell-file-name "/bin/zsh")
;; (setq shell-file-name "zsh")

;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
