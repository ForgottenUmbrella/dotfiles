;;;; Customisation setup.
;; Save custom.el in $XDG_CONFIG_HOME instead of cluttering $HOME.
;; NOTE: `setq' sets a buffer-local variable locally,
;; whereas `setq-default' sets a buffer-local variable globally.
;; Both forms may set ordinary (global) variables, but `setq' is terser.
(setq custom-file (concat user-emacs-directory "custom.el"))
(load custom-file t)

;;;; Package management setup.
;; Enable additional package repos.
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
;; Pre-compute autoloads to activate packages quickly.
(setq package-quickstart t)
;;; Bootstrap straight for packages hosted elsewhere.
;; Don't bother checking. Must be before the bootstrap to have an effect.
(setq straight-check-for-modifications nil)
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el"
                         user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))
;; Install use-package via straight, for modular package configuration.
;; NOTE: Use :ensure with external (not buit-in) packages.
(straight-use-package 'use-package)
;; Ensure downloaded packages are the latest version.
(defun before-install-refresh-contents (&rest args)
  "Refresh package archive before installing to avoid outdated files."
  (package-refresh-contents)
  (advice-remove 'package-install 'before-install-refresh-contents))
(advice-add 'package-install :before 'before-install-refresh-contents)
;; Enable system package dependency management.
(use-package use-package-ensure-system-package :ensure t)
;; Provide `auto-package-update-now' to update packages.
(use-package auto-package-update :ensure t
             :custom
             (auto-package-update-hide-results t "Don't show update results.")
             (auto-package-delete-old-versions t
                                               "Delete old package versions."))

;;;; Install packages.
;;; Make binding keys sane.
;; NOTE: Include `:demand t' if you use :general or :g(f)hook but still need the
;; external package or its :config to be loaded. Also, some (but not all)
;; built-in packages need :demand if you use :general-bind.
;; NOTE: :ghook adds the package mode to the given hook, whereas :gfhook adds
;; the given function to the package's own hook.
(use-package general :ensure t)
;; Definer for things prefixed by the leader key (SPC).
(general-create-definer leader-def
  :states '(motion normal insert emacs)
  :keymaps 'override
  :prefix "SPC"
  :non-normal-prefix "M-SPC"
  :prefix-command 'leader-map)
;; Definer for things prefixed by the major leader key (,).
(general-create-definer major-prefix-def
  :states '(motion insert emacs)
  :prefix ","
  :non-normal-prefix "M-,"
  "" '(:ignore t :which-key "major"))
;; Make hydra bindings pretty.
(use-package pretty-hydra :ensure t)

;;; Join the dark side.
;; Vim keys.
(use-package evil :ensure t :demand t
             :custom
             (evil-want-C-u-scroll t "Replace Emacs's C-u with Vim scrolling.")
             (evil-want-Y-yank-to-eol t "Differentiate Y and yy for yanking.")
             (evil-want-visual-char-semi-exclusive t
                                                   "Make visual mode less confusing.")
             (evil-ex-substitute-global t "Substitute globally by default.")
             (evil-vsplit-window-right t "Vertically split to the right.")
             (evil-split-window-below t "Horizontally split below.")
             (evil-cross-lines t "Allow horizontal movement to other lines.")
             (evil-respect-visual-line-mode t "Respect visual line mode.")
             (evil-auto-balance-windows nil
                                        "Don't spontaneously resize windows.")
             (evil-symbol-word-search t
                                      "Operate * and # on words instead of symbols.")
             (evil-search-module 'evil-search
                                 "Use evil's search module instead of Emacs's.")
	     (evil-want-keybinding nil
                                   "Required to add evil-collection keybindings.")
             :config
             (evil-mode)
             (defun my/append-to-register ()
               "Append to instead of replacing the unnamed (default) register.
Actually appends to register z as a hack."
               (interactive)
               (evil-use-register "@Z"))
             (defun evil-smart-doc-lookup ()
               "Run documentation lookup command specific to the major mode.
Use command bound to `, h h' if defined, otherwise fall back
to `evil-lookup'. Based on Spacemacs."
               (interactive)
               (let ((binding (key-binding (kbd ",hh"))))
                 (if (commandp binding)
                     (call-interactively binding)
                   (evil-lookup))))
             :general
             ("C-l" 'evil-ex-nohighlight)
             ;; NOTE: 'motion is for non-editing commands.
             (:states 'motion
                      "_" (lambda ()
                            "Use black-hole register for deletion."
                            (interactive)
                            (evil-use-register ?_))
                      "C-_" 'my/append-to-register
                      "Q" (kbd "@q")
                      "K" 'evil-smart-doc-lookup
                      "M--" 'evil-window-decrease-height
                      "M-+" 'evil-window-increase-height
                      "M-<" 'evil-window-decrease-width
                      "M->" 'evil-window-increase-width
                      "<tab>" 'evil-toggle-fold)
             (:states 'insert
                      "C-i" 'evil-shift-right-line
                      "C-S-i" 'evil-shift-left-line
                      "<backtab>" 'evil-shift-left-line)
             (:keymaps 'evil-ex-search-keymap
                       "C-w" 'backward-kill-word)
             (leader-def "<tab>" 'evil-switch-to-windows-last-buffer)
             (:keymaps 'leader-files-map
                       "S" 'evil-write-all)
             (:keymaps 'leader-search-map
                       "c" 'evil-ex-nohighlight))
;; Escape all the things.
(use-package evil-escape :ensure t
             :custom
             (evil-escape-key-sequence "<escape>" "Escape everything with ESC.")
             :config
             (evil-escape-mode))
;; Increment/decrement numbers with C-a and C-x.
(use-package evil-numbers :ensure t
             :general
             (:states 'motion
                      "C-a" 'evil-numbers/inc-at-pt
                      "C-x" 'evil-numbers/dec-at-pt))
;; [-KEY and ]-KEY bindings for various pairs.
(use-package evil-unimpaired :after move-text
             :straight (evil-unimpaired :host github
                                        :repo "zmaas/evil-unimpaired")
             :config
             (general-unbind 'normal "] l" "[ l" "] q" "[ q" "] f" "[ f")
             (defun next-comment ()
               "Move point to next comment."
               (interactive)
               (search-forward comment-start nil t))
             (defun previous-comment ()
               "Move point to previous comment."
               (interactive)
               (search-backward comment-start nil t))
             :general
             (:states 'motion
                      "[ c" 'previous-comment
                      "] c" 'next-comment)
             (:states 'visual
                      "[ e" ":move'<--1"
                      "] e" ":move'>+1"))
;; Lisp navigation (brackets).
(use-package evil-cleverparens :ensure t :after evil-collection
             :ghook
             'lisp-mode-hook
             'emacs-lisp-mode-hook
             :init
             (add-to-list 'evil-collection-delete-operators 'evil-cp-delete-line)
             :custom
             (evil-cleverparens-use-regular-insert t
                                                   "Don't automatically insert spaces.")
             (evil-cleverparens-use-additional-movement-keys nil
                                                             "Don't override my keybindings.")
             (evil-move-beyond-eol t "Required to keep parentheses balanced.")
             :general
             (:keymaps 'evil-cleverparens-mode-map :states 'normal
                       "C-(" 'evil-cp-<
                       "C-)" 'evil-cp->)
             :config
             (general-unbind '(normal visual operator)
               evil-cleverparens-mode-map
               "_"
               "s"
               "x"
               "<"
               ">"))
;; Org-mode navigation (brackets).
(use-package evil-org :ensure t
             :ghook
             'org-mode-hook
             :config
             (evil-org-set-key-theme '(navigation
                                       return
                                       textobjects
                                       additional
                                       todo
                                       calendar))
             (require 'evil-org-agenda)
             (evil-org-agenda-set-keys))
;; Indentation-based text objects (ii/ai).
(use-package evil-indent-plus :ensure t
             :config
             (evil-indent-plus-default-bindings))
;; Comment command (gc).
(use-package evil-commentary :ensure t
             :config
             (evil-commentary-mode))
;; Comma-delimited text objects (ii/ai).
(use-package evil-args :ensure t
             :ghook
             ('(lisp-mode-hook emacs-lisp-mode-hook)
              (lambda ()
                "Don't pair single quotes."
                (setq evil-args-delimiters '(" "))))
             :general
             (:keymaps 'evil-inner-text-objects-map "a" 'evil-inner-arg)
             (:keymaps 'evil-outer-text-objects-map "a" 'evil-outer-arg))
;; Evil-ify various Emacs modes.
(use-package evil-collection :ensure t
             :config
             (evil-collection-init)
             (general-unbind 'normal evil-collection-unimpaired-mode-map
               "] l"
               "[ l")
             (general-unbind 'normal help-mode-map "C-o" "C-i"))
;; Evil-ify magit, the Emacs Git porcelain.
(use-package evil-magit :ensure t :after magit
             :custom
             (evil-magit-want-horizontal-movement t
                                                  "Allow horizontal movement.")
             (evil-magit-use-z-for-folds t "Don't hijack Vim z."))
;; Commands for manipulating surroundings.
(use-package evil-surround :ensure t
             :config
             (global-evil-surround-mode))
;; Augment % to match more than just brackets.
(use-package evil-matchit :ensure t
             :config
             (global-evil-matchit-mode))
;; Augment * and # to operate on visual selections.
(use-package evil-visualstar :ensure t
             :config
             (global-evil-visualstar-mode))
;; Show number of search matches.
(use-package evil-anzu :ensure t
             :custom
             (anzu-cons-mode-line-p nil
                                    "Integrate anzu with a custom mode line.")
             :config
             (global-anzu-mode))
;; Text objects and actions for LaTeX:
;; - c(ommand)
;; - e(nvironment)
;; - m(aths i.e. \(\))
;; - M(ATHS i.e. \[\])
;; - d(elimeters)
;; - s(ections)
;; - ; (CDLaTeX accents)
;; - ^ (superscript object)
;; - _ (subscript object)
;; - T(able cells i.e. &)
;; - mt ("magnificent toggle" action)
;; - M-n (move to next argument in CDLaTeX expansion, like TAB)
(use-package evil-tex :ensure t
             :ghook 'LaTeX-mode-hook)

;;; Aesthetics.
;; Modeline.
(use-package spaceline :ensure t
             :init
             (setq-default
              spaceline-buffer-size-p nil
              spaceline-minor-modes-p nil
              spaceline-buffer-encoding-p nil
              spaceline-buffer-encoding-abbrev-p nil
              spaceline-window-numbers-unicode t
              spaceline-workspace-numbers-unicode t
              ;; Use pywal colours for evil state instead of default.
              ;;spaceline-highlight-face-func 'spaceline-highlight-face-evil-state
              spaceline-highlight-face-func 'ewal-evil-cursors-highlight-face-evil-state
              ;; NOTE: Remember to call spaceline-compile after changing.
              powerline-default-separator nil)
             (defun toggle-mode-line ()
               "Toggle the mode line visibility."
               (interactive)
               (if mode-line-format
                   (setq-default mode-line-format nil)
                 (require 'spaceline-config)
                 (spaceline-spacemacs-theme)))
             :general
             (:keymaps 'leader-toggles-map
                       "m" 'toggle-mode-line))
;; Colourise colour codes with SPC-t-c-c.
(use-package rainbow-mode :ensure t
             :general
             (:keymaps 'leader-toggles-colours-map
                       "c" 'rainbow-mode))
;; Colourise nested delimiters.
(use-package rainbow-delimiters :ensure t
             :ghook
             'text-mode-hook
             'prog-mode-hook
             :general
             (:keymaps 'leader-toggles-colours-map
                       "d" 'rainbow-delimiters-mode))
;; Colourise different variable names.
(use-package rainbow-identifiers :ensure t
             :ghook
             'prog-mode-hook
             :general
             (:keymaps 'leader-toggles-colours-map
                       "i" 'rainbow-identifiers-mode))
;; Show a vertical margin at 80 characters.
(use-package display-fill-column-indicator :demand t
             :config
             (global-display-fill-column-indicator-mode)
             :general
             (:keymaps 'leader-toggles-map
                       "f" 'display-fill-column-indicator-mode))
;; Highlight the current line.
(use-package hl-line
  :config
  (global-hl-line-mode))
;; Highlight redundant whitespace.
(use-package whitespace :demand t
  :init
  (setq-default whitespace-style '(face trailing tabs empty))
  :config
  (global-whitespace-mode)
  :general
  (:keymaps 'leader-toggles-map
            "w" 'whitespace-mode))
;; Highlight TODO keywords.
(use-package hl-todo :ensure t :demand t
             :config
             (global-hl-todo-mode)
             :general
             (:keymaps 'hl-todo-mode-map :states 'motion
                       "[ T" 'hl-todo-previous
                       "] T" 'hl-todo-next)
             (:keymaps 'leader-jumps-map
                       "t" 'hl-todo-occur)
             (:keymaps 'leader-toggles-map
                       "h" 'hl-todo-mode))
;; Adjust font size of current frame with SPC-z-x or C-mouse scroll.
(use-package face-remap
  :general
  (:keymaps 'leader-zoom-map
            "x" 'text-scale-adjust))
;; Adjust font size of all frames with C-+ and C--.
(use-package default-text-scale :ensure t
             :init
             (pretty-hydra-define hydra-default-text (:title "Zoom" :quit-key "q")
               ("Increase"
                (("k" default-text-scale-increase)
                 ("+" default-text-scale-increase))
                "Decrease"
                (("j" default-text-scale-decrease)
                 ("-" default-text-scale-decrease))
                "Reset"
                (("0" default-text-scale-reset))))
             :general
             (:states 'motion
                      "C-+" 'default-text-scale-increase
                      "C-=" 'default-text-scale-increase
                      "C--" 'default-text-scale-decrease
                      "C-0" 'default-text-scale-reset)
             (:keymaps 'leader-zoom-map
                       "f" 'hydra-default-text/body))
;; Show indentation margins.
(use-package highlight-indent-guides :ensure t
             :after whitespace  ; Load whitespace first due to conflict.
             :ghook
             'prog-mode-hook
             :custom
             (highlight-indent-guides-method 'character
                                             "Highlight indentation with characters.")
             (highlight-indent-guides-responsive 'stack
                                                 "Colourise indentation.")
             :general
             (:keymaps 'leader-toggles-map
                       "i" 'highlight-indent-guides-mode))
;; Show diff status of lines.
(use-package git-gutter :ensure t :demand t
             :custom
             (git-gutter:hide-gutter t "Hide empty gutter.")
             :config
             (global-git-gutter-mode)
             :general
             (:keymaps 'leader-git-map
                       "d" 'git-gutter:popup-hunk
                       "h" 'git-gutter:stage-hunk
                       "n" 'git-gutter:next-hunk
                       "p" 'git-gutter:previous-hunk
                       "x" 'git-gutter:revert-hunk)
             (:states 'motion
                      "[ h" 'git-gutter:previous-hunk
                      "] h" 'git-gutter:next-hunk))
;; Zone out.
(use-package zone
  :general
  (:keymaps 'leader-applications-map
            "z" 'zone))
;; Give buffers short but unique names.
(use-package uniquify)
;; Interpret colour output in `compilation-mode'.
(use-package ansi-color :after compile
             :ghook
             ('compilation-filter-hook
              (lambda ()
                "Interpret ANSI colour escapes in `compilation-mode'."
                (ansi-color-apply-on-region compilation-filter-start
                                            (point-max)))))
;; Use ligatures.
(use-package fira-code-mode :ensure t
	     :ensure-system-package
	     ("/usr/share/fonts/FiraCode-Regular-Symbol.otf" . otf-fira-code-symbol)
	     :ghook 'prog-mode-hook)

;;; Themes.
;; NOTE: Defer all but the selected for faster startup.
(use-package doom-themes :ensure t :defer t)
(use-package nord-theme :ensure t :defer t)
(use-package monokai-theme :ensure t :defer t)
(use-package dracula-theme :ensure t :defer t)
(use-package atom-dark-theme :ensure t :defer t)
(use-package atom-one-dark-theme :ensure t :defer t)
(use-package solarized-theme :ensure t :defer t)
(use-package gruvbox-theme :ensure t :defer t)
(use-package oceanic-theme :ensure t :defer t)
(use-package afternoon-theme :ensure t :defer t)
;; A dynamically generated theme using wal colours.
(use-package ewal :ensure t
             :custom
             (ewal-use-built-in-on-failure-p t "Fail gracefully."))
(use-package ewal-spacemacs-themes :ensure t
             :config
             (load-theme 'ewal-spacemacs-modern t)
             (enable-theme 'ewal-spacemacs-modern)
             :custom-face
             (highlight ((t (:background unspecified))))
             (org-todo ((t (:background unspecified)))))
(use-package ewal-evil-cursors :ensure t
             :init
             (setq-default ewal-evil-cursors-obey-evil-p t))

;;; Navigation.
;; Show available key bindings on wait.
(use-package which-key :ensure t :demand t
             :custom
             (which-key-idle-delay 0.4
                                   "How long to wait before showing keybindings.")
             (which-key-sort-order 'which-key-key-order-alpha
                                   "Sort keybindings alphabetically.")
             :config
             (which-key-mode)
             :general
             (:keymaps 'leader-help-map
                       "k" 'which-key-show-top-level
                       "m" 'which-key-show-major-mode)
             (:keymaps 'leader-toggles-map
                       "K" 'which-key))
;; Enable undoing window management with SPC-w-u.
(use-package winner
  :config
  (winner-mode)
  :general
  (:keymaps 'leader-windows-map
            "u" 'winner-undo
            "U" 'winner-redo))
;; Open a terminal in the current directory with SPC-a-s-t.
(use-package terminal-here :ensure t
             :custom
             (terminal-here-terminal-command
                           (lambda (dir)
                             "Use $TERMINAL to open terminals."
                             (append (split-string (getenv "TERMINAL"))
                                     (list "-d" dir)))
                           "Command to use to open real terminals.")
             :general
             (:keymaps 'leader-applications-shell-map
                       "t" 'terminal-here-launch
                       "p" 'terminal-here-project-launch))
;; Jump to definition without building a database, with C-].
(use-package dumb-jump :ensure t
             :custom
             (dumb-jump-selector 'ivy "Use ivy to select jump choice.")
             (dumb-jump-prefer-searcher 'rg "Use rg to search for definitions.")
             :config
             (add-hook 'xref-backend-functions 'dumb-jump-xref-activate))
;; Display relative line numbers.
(use-package display-line-numbers :demand t
             :custom
             (display-line-numbers-type 'relative "Show relative line numbers.")
             :config
             (global-display-line-numbers-mode)
             :general
             (:keymaps 'leader-toggles-map
                       "n" 'display-line-numbers-mode))
;; Go to file at point with gf.
(use-package ffap
  :custom
  (ffap-machine-p-known 'reject "Don't waste time pinging random URLs.")
  :general
  (:states 'motion
           "g f" 'find-file-at-point))
;; Scroll window to position cursor at top with zf.
(use-package reposition
  :general
  (:states 'motion
           "z f" 'reposition-window))
;; Enable sane undo history that can be visualised as a tree with SPC-a-u.
(use-package undo-tree :ensure t
             :general
             (:keymaps 'leader-applications-map
                       "u" 'undo-tree-visualize))
;; Navigate to recent files with SPC-f-r.
(use-package recentf
  :custom
  (recentf-max-saved-items 1024 "Save more recent file history.")
  :config
  (add-to-list 'recentf-exclude (expand-file-name package-user-dir))
  (recentf-mode)
  (run-at-time t 300 'recentf-save-list))
;; Clear old buffers with SPC-b-x.
(use-package midnight
  :general
  (:keymaps 'leader-buffers-map
            "X" 'clean-buffer-list))
;; Fold code blocks.
(use-package hideshow
  :config
  (hs-minor-mode))
;; Fold comment headings.
(use-package outline
  :config
  (general-unbind 'normal outline-mode-map "z b")
  :general
  (:states 'normal :keymaps 'outline-minor-mode-map
           "M-h" 'outline-promote
           "M-j" 'outline-move-subtree-down
           "M-k" 'outline-move-subtree-up
           "M-l" 'outline-demote
           "M-RET" 'outline-insert-heading)
  (:states 'motion :keymaps 'outline-minor-mode-map
           "C-<tab>" 'outline-toggle-children
           "g h" 'outline-up-heading
           "g j" 'outline-forward-same-level
           "g k" 'outline-backward-same-level
           "g l" 'outline-next-visible-heading
           "g y" 'outline-previous-visible-heading))
;; Navigate to and focus on comment headings with SPC-j-o and SPC-n-n.
(use-package outshine :ensure t
             :ghook
             ('prog-mode-hook 'outshine-mode)
             :general
             (:keymaps 'leader-jumps-map
                       "o" 'outshine-imenu)
             (:keymaps 'leader-narrow-map
                       "n" 'outshine-narrow-to-subtree))
;; Start where you last left off.
(use-package saveplace
  :config
  (save-place-mode))
;; Don't hang on files with long lines.
(use-package so-long
            :config
            (global-so-long-mode))
;; Navigate TODO items in a project.
(use-package doom-todo-ivy
  :straight (doom-todo-ivy :host github :repo "jsmestad/doom-todo-ivy")
  :general
  (:keymaps 'leader-jumps-map
            "T" 'doom/ivy-tasks))

;;; Completion.
;; Completion framework.
(use-package ivy :ensure t :demand t
             :custom
             (ivy-use-selectable-prompt t "Allow literal entry as a choice.")
             (ivy-use-virtual-buffers t "Show recent files in buffer list.")
             (ivy-initial-inputs-alist nil
                                       "Don't assume search must start with input.")
             :config
             (add-to-list 'ivy-format-functions-alist
                          '(t . ivy-format-function-line))
             (ivy-mode t)
             :general
             (:keymaps '(ivy-minibuffer-map
                         ivy-occur-grep-mode-map
                         ivy-occur-mode-map
                         ivy-reverse-i-search-map
                         ivy-switch-buffer-map)
                       "C-w" 'ivy-backward-kill-word
                       "C-j" 'ivy-next-line
                       "C-k" 'ivy-previous-line
                       "C-l" 'ivy-alt-done
                       "<tab>" 'ivy-alt-done
                       "C-d" 'ivy-scroll-down-command
                       "C-u" 'ivy-scroll-up-command)
             (:keymaps 'ivy-switch-buffer-map
                       "C-x" 'ivy-switch-buffer-kill)
             (:keymaps 'ivy-minibuffer-map
                       "C-h" 'ivy-backward-delete-char))
;; Better interface for ivy.
(use-package ivy-rich :ensure t
             :config
             (ivy-rich-mode t))
;; Replace built-in commands with ivy.
(use-package counsel :ensure t :demand t
             :ensure-system-package (rg . ripgrep)
             :custom
             (counsel-grep-base-command "rg -i -M 120 --no-heading --line-number --color never '%s' %s"
                                        "Use rg instead of grep.")
             :config
             (counsel-mode t)
             :general
             (:keymaps 'counsel-find-file-map
                       "C-h" 'counsel-up-directory)
             (:keymaps 'leader-buffers-map
                       "b" 'counsel-switch-buffer)
             (:keymaps 'leader-files-map
                       "l" 'counsel-locate
                       "r" 'counsel-recentf
                       "F" 'counsel-file-jump)
             (:keymaps 'leader-help-map
                       "RET" 'counsel-minor)
             (:keymaps 'leader-jumps-map
                       "i" 'counsel-semantic-or-imenu)
             (:keymaps 'leader-search-map
                       "d" 'counsel-rg
                       "s" 'counsel-grep-or-swiper)
             (:keymaps 'leader-themes-map
                       "t" 'counsel-load-theme))
;; Sort ivy completion candidates by use.
(use-package ivy-prescient :ensure t :after counsel
             :config
             (push '(read-file-name-internal . ivy-sort-file-function-default)
                   ivy-sort-functions-alist)
             (push '(t . ivy--regex-fuzzy) ivy-re-builders-alist)
             (ivy-prescient-mode))
;; Snippet framework.
(use-package yasnippet :ensure t :demand t
             :config
             (yas-global-mode)
             :general
             (:keymaps 'leader-toggles-map
                       "y" 'yas-minor-mode))
;; A collection of snippets for yasnippet.
(use-package yasnippet-snippets :ensure t)
;; Auto-complete.
(use-package company :ensure t :demand t
             :custom
             (company-minimum-prefix-length 1
                                            "Complete even a single character.")
             :config
             (global-company-mode)
             :general
             (:states 'insert
                     "C-SPC" 'company-complete)
             (:keymaps 'company-active-map
                       "C-w" 'evil-delete-backward-word
                       "C-l" 'company-complete-selection
                       ;; XXX: Still doesn't unbind <tab> when yasnippet is on?
                       nil 'company-complete-common))
;; Show documentation for auto-complete candidates.
(use-package company-quickhelp :ensure t
             :ghook
             'company-mode-hook)
;; Sort auto-complete candidates by use.
(use-package company-statistics :ensure t
             :config
             (company-statistics-mode))
;; Add auto-complete support to LaTeX.
(use-package company-auctex :ensure t
             :config
             (company-auctex-init))
;; Add auto-complete support to shell scripts.
(use-package company-shell :ensure t
             :config
             (add-to-list 'company-backends
                          '(company-shell company-shell-env)))
;; Add auto-complete support for C headers.
(use-package company-c-headers :ensure t
             :config
             (add-to-list 'company-backends 'company-c-headers))
;; Add auto-complete support for JavaScript.
(use-package company-flow :ensure t
             :config
             (add-to-list 'company-backends 'company-flow)
             (add-hook 'js-mode-hook
                       (lambda ()
                         "Warn missing JavaScript auto-completion tool."
                         (warn-missing-executable "flow"
                                                  "JavaScript auto-completion"))))
;; Icons for company mode.
(use-package company-box :ensure t
             :ghook 'company-mode)
;; Automatically insert shebang.
(use-package insert-shebang :ensure t
             :ghook
             ('find-file-not-found-functions (lambda ()
                                               "Insert shebang and return nil."
                                               (insert-shebang)
                                               nil))
             :custom
             (insert-shebang-track-ignored-filename nil
                                                    "Don't track ignored files.")
             (insert-shebang-custom-headers '(("sh" . "#!/bin/sh"))
                                            "Use a saner sh shebang.")
             :config
             (add-to-list 'insert-shebang-file-types '("py" . "python3"))
             (remove-hook 'find-file-hook 'insert-shebang))
;; LaTeX abbreviations (see `cdlatex-command-help').
(use-package cdlatex :ensure t
             :custom
             (cdlatex-paired-parens "$([{" "Pair all the things.")
             :ghook
             ('LaTeX-mode-hook 'turn-on-cdlatex)
             :gfhook
             ('org-mode-hook 'org-cdlatex-mode))

;;; Correction.
;; Highlight errors.
(use-package flycheck :ensure t :demand t
             :ensure-system-package (shellcheck
                                     (pylint . python-pylint)
                                     mypy)
             :custom
             (flycheck-disabled-checkers '(emacs-lisp-checkdoc)
                                         "Don't complain about arcane ELisp conventions.")
             :config
             (global-flycheck-mode)
             (add-hook 'c++-mode-hook
                       (lambda ()
                         "Warn missing C++ linters."
                         (warn-missing-executable "cppcheck" "C++ linting")))
             (add-hook 'js-mode-hook
                       (lambda ()
                         "Warn missing JavaScript linters."
                         (warn-missing-executable "eslint"
                                                  "JavaScript linting")))
             (flycheck-add-next-checker 'python-pylint 'python-mypy)
             (defun toggle-flycheck-error-list ()
               "Toggle flycheck's error list window.
If the error list is visible, hide it. Otherwise, show it. From Spacemacs."
               (interactive)
               (-if-let (window (flycheck-get-error-list-window))
                   (quit-window nil window)
                 (flycheck-list-errors)))
             (defun goto-flycheck-error-list ()
               "Open and go to the error list buffer. From Spacemacs."
               (interactive)
               (unless (get-buffer-window
                        (get-buffer flycheck-error-list-buffer))
                 (flycheck-list-errors)
                 (switch-to-buffer-other-window flycheck-error-list-buffer)))
             :general
             (:states 'motion
                      "[ l" 'flycheck-previous-error
                      "] l" 'flycheck-next-error
                      "[ q" 'flycheck-previous-error
                      "] q" 'flycheck-next-error)
             (:keymaps 'leader-errors-map
                       "b" 'flycheck-buffer
                       "c" 'flycheck-clear
                       "d" 'flycheck-display-error-at-point
                       "h" 'flycheck-describe-checker
                       "L" 'goto-flycheck-error-list
                       "l" 'toggle-flycheck-error-list
                       "S" 'flycheck-set-checker-executable
                       "s" 'flycheck-select-checker
                       "v" 'flycheck-verify-setup
                       "x" 'flycheck-explain-error-at-point
                       "y" 'flycheck-copy-errors-as-kill)
             (:keymaps 'leader-toggles-map
                       "s" 'flycheck-mode))
;; Show errors in a popup.
(use-package flycheck-pos-tip :ensure t
             :config
             (flycheck-pos-tip-mode))
;; Ensure indentation is correct.
;; XXX: Seems to mess up Emacs package updates (aggressive-indent--indent-if-changed)
(use-package aggressive-indent :ensure t :demand t
             :config
             (global-aggressive-indent-mode)
             :general
             (:keymaps 'leader-toggles-map
                       "I" 'aggressive-indent-mode))
;; Ensure parentheses match.
(use-package smartparens :ensure t :demand t
             :ghook
             'eval-expression-minibuffer-setup-hook
             ;; XXX: Tag handling is broken?
             ;;('(nxml-mode-hook html-mode-hook) 'turn-off-smartparens-mode)
             :custom
             (sp-escape-quotes-after-insert nil "Don't escape quotes.")
             (sp-show-pair-from-inside t "Always highlight pairs.")
             ;; XXX: I can't remember if I hated the aesthetics or what.
             ;;(sp-highlight-pair-overlay nil)
             ;;(sp-highlight-wrap-overlay nil)
             ;;(sp-highlight-wrap-tag-overlay nil)
             :config
             (require 'smartparens-config)
             (smartparens-global-mode)
             (show-smartparens-global-mode)
             (sp-local-pair 'minibuffer-inactive-mode "'" nil :actions nil)
             (sp-local-pair 'conf-mode "Section" "EndSection")
             (sp-local-pair 'sh-mode "if" "fi")
             :general
             (:keymaps 'leader-toggles-map
                       "p" 'smartparens-mode))
;; Highlight typos.
(use-package flyspell
  :ghook
  'text-mode-hook
  ('prog-mode-hook 'flyspell-prog-mode)
  :custom
  (flyspell-issue-message-flag nil "Be less obnoxious about typos.")
  :general
  (:keymaps 'leader-toggles-map
            "S" 'flyspell-mode))
;; Correct typos with SPC-S.
(use-package flyspell-popup :ensure t
             :general
             (leader-def :keymaps 'flyspell-mode-map
               "S" 'flyspell-popup-correct))
;; Sort Python imports.
(use-package py-isort :ensure t
             :ensure-system-package (isort . python-isort)
             :general
             (:keymaps 'major-python-refactor-map
                       "I" 'py-isort-buffer))
;; Format C++ code.
(use-package clang-format :ensure t
             :ghook
             ('c++-mode-hook
              (lambda ()
                "Format buffer with clang-format before save."
                (add-hook 'before-save-hook 'clang-format-buffer nil t))))
;; Format JavaScript code.
(use-package web-beautify :ensure t
             :config
             (if (executable-find "js-beautify")
                 (add-hook 'js-mode-hook
                           (lambda ()
                             "Format buffer with js-beautify before save."
                             (add-hook 'before-save-hook
                                       'web-beautify-js-buffer t t)))
               (message "js-beautify is not installed; install for JavaScript formatting"))
             :general
             (:keymaps 'major-js-map
                       "=" 'web-beautify-js))
;; Reload files that have changed outside of Emacs.
(use-package autorevert
  :custom
  (auto-revert-avoid-polling t "Detect file changes efficiently.")
  :config
  (global-auto-revert-mode))
;; Automatically insert and update closing tags.
(use-package tagedit :ensure t
             :ghook
             'nxml-mode
             'html-mode
             :config
             (tagedit-add-experimental-features))
;; Manually wrap long lines of code with C-q.
(use-package multi-line :ensure t
             :general
             (:keymaps 'prog-mode-map
                       "C-q" 'multi-line))
;; Move a line up or down.
(use-package move-text :ensure t
             :general
             (:states 'normal
                      "[ e" 'move-text-up
                      "] e" 'move-text-down))
;; trim only your own trailing whitespace.
(use-package ws-butler :ensure t
             :config
             (ws-butler-global-mode))
(add-hook 'text-mode-hook 'auto-fill-mode)
(add-hook 'prog-mode-hook 'auto-fill-mode)

;;; Major modes.
;; Org mode.
(use-package org
  :custom
  (org-startup-indented t "Indent levels.")
  (org-startup-folded nil "Don't hide content by default.")
  (org-startup-truncated nil "Don't truncate lines.")
  (org-agenda-files '("~/Dropbox/Wiki/uni/"))
  (org-src-tab-acts-natively t "Allow normal TAB behaviour in src blocks.")
  (org-confirm-babel-evaluate (lambda (lang body)
                                "Don't confirm Python evaluation."
                                (not (string= lang "python")))
                              "Don't confirm src block evaluation.")
  :init
  (setq-default org-export-with-smart-quotes t
                org-latex-listings t)
  :config
  (org-babel-do-load-languages 'org-babel-load-languages
                               '((python . t) (emacs-lisp . t)))
  (add-to-list 'org-latex-packages-alist '("" "listingsutf8"))
  :general
  (:prefix-command 'leader-applications-org-map
                   :keymaps 'leader-applications-map :prefix "o"
                   :wk-full-keys nil
                   "" '(:ignore t :which-key "org")
                   "#" 'org-agenda-list-stuck-projects
                   "/" 'org-occur-in-agenda-files
                   "a" 'org-agenda-list
                   "c" 'org-capture
                   "l" 'org-store-link
                   "o" 'org-agenda
                   "s" 'org-search-view
                   "t" 'org-todo-list)
  (:prefix-command 'leader-applications-org-clock-map
                   :keymaps 'leader-applications-org-map :prefix "C"
                   :wk-full-keys nil
                   "" '(:ignore t :which-key "clock")
                   "c" 'org-clock-cancel
                   "g" 'org-clock-goto
                   "I" 'org-clock-in-last
                   "i" 'org-clock-in
                   "j" 'org-clock-jump-to-current-clock
                   "o" 'org-clock-out
                   "r" 'org-resolve-clocks)
  (major-prefix-def :prefix-command 'major-org-map :keymaps 'org-mode-map
    "'" 'org-edit-special
    ":" 'org-set-tags
    "." 'org-time-stamp
    "!" 'org-time-stamp-inactive
    "," 'org-ctrl-c-ctrl-c
    "*" 'org-ctrl-c-star
    "RET" 'ogr-ctrl-c-ret
    "SPC" 'org-toggle-checkbox
    "-" 'org-ctrl-c-minus
    "^" 'org-sort
    "/" 'org-sparse-tree
    "A" 'org-archive-subtree
    "a" 'org-agenda
    "b" 'org-tree-to-indirect-buffer
    "c" 'org-capture
    "D" 'org-insert-drawer
    "d" 'org-deadline
    "f" 'org-set-effort
    "H" 'org-shiftleft
    "C-H" 'org-shiftcontrolleft
    "I" 'org-clock-in
    "J" 'org-shiftdown
    "C-J" 'org-shiftcontroldown
    "K" 'org-shiftup
    "C-K" 'org-shiftcontrolup
    "L" 'org-shiftright
    "l" 'org-open-at-point
    "C-L" 'org-shiftcontrolleft
    "n" 'org-narrow-to-subtree
    "N" 'widen
    "O" 'org-clock-out
    "P" 'org-set-property
    "p" 'org-latex-preview
    "q" 'org-clock-cancel
    "R" 'org-refile
    "s" 'org-schedule
    "T" 'org-show-todo-tree)
  (:prefix-command 'major-org-export-map :keymaps 'major-org-map :prefix "e"
                   :wk-full-keys nil
                   "" '(:ignore t :which-key "export")
                   "e" 'org-export-dispatch)
  (:prefix-command 'major-org-headings-map :keymaps 'major-org-map :prefix "h"
                   :wk-full-keys nil
                   "" '(:ignore t :which-key "headings")
                   "I" 'org-insert-heading
                   "i" 'org-insert-heading-after-current
                   "s" 'org-insert-subheading)
  (:prefix-command 'major-org-insert-map :keymaps 'major-org-map :prefix "i"
                   :wk-full-keys nil
                   "" '(:ignore t :which-key "insert")
                   "a" 'org-attach
                   "l" 'org-insert-link
                   "f" 'org-footnote-new
                   "s" 'org-insert-structure-template)
  (:prefix-command 'major-org-subheadings-map :keymaps 'major-org-map
                   :prefix "S" :wk-full-keys nil
                   "" '(:ignore t :which-key "subheadings")
                   "h" 'org-promote-subtree
                   "j" 'org-move-subtree-down
                   "k" 'org-move-subtree-up
                   "l" 'org-demote-subtree)
  (:prefix-command 'major-org-tables-map :keymaps 'major-org-map :prefix "t"
                   :wk-full-keys nil
                   "" '(:ignore t :which-key "tables")
                   "a" 'org-table-align
                   "b" 'org-table-blank-field
                   "c" 'org-table-convert
                   "e" 'org-table-eval-formula
                   "E" 'org-table-export
                   "h" 'org-table-previous-field
                   "H" 'org-table-move-column-left
                   "I" 'org-table-import
                   "j" 'org-table-next-row
                   "J" 'org-table-move-row-down
                   "K" 'org-table-move-row-up
                   "l" 'org-table-next-field
                   "L" 'org-table-move-column-right
                   "n" 'org-table-create
                   "N" 'org-table-create-with-table.el
                   "r" 'org-table-recalculate
                   "s" 'org-table-sort-lines
                   "w" 'org-table-wrap-region)
  (:prefix-command 'major-org-tables-delete-map :keymaps 'major-org-tables-map
                   :prefix "d" :wk-full-keys nil
                   "" '(:ignore t :which-key "delete")
                   "c" 'org-table-delete-column
                   "r" 'org-table-kill-row)
  (:prefix-command 'major-org-tables-insert-map :keymaps 'major-org-tables-map
                   :prefix "i" :wk-full-keys nil
                   "" '(:ignore t :which-key "insert")
                   "c" 'org-table-insert-column
                   "h" 'org-table-insert-hline
                   "H" 'org-table-hline-and-move
                   "r" 'org-table-insert-row)
  (:prefix-command 'major-org-tables-toggle-map :keymaps 'major-org-tables-map
                   :prefix "t" :wk-full-keys nil
                   "" '(:ignore t :whick-key "toggle")
                   "f" 'org-table-toggle-formula-debugger
                   "o" 'org-table-toggle-coordinate-overlays))
;; Kotlin mode.
(use-package kotlin-mode :ensure t :demand t
             :gfhook
             (nil (lambda ()
                    "Set Kotlin mode `fill-column' to 120."
                    (setq fill-column 120)))
             :custom
             (kotlin-tab-width 4 "Use four spaces for indentation.")
             :general
             (major-prefix-def :prefix-command 'major-kotlin-map :keymaps 'kotlin-mode-map)
             (:prefix-command 'major-kotlin-repl-map :keymaps 'major-kotlin-map
                              :prefix "s" :wk-full-keys nil
                              "" '(:ignore t :which-key "repl")
                              "B" 'kotlin-send-block
                              "b" 'kotlin-send-buffer
                              "i" 'kotlin-repl
                              "l" 'kotlin-send-line
                              "r" 'kotlin-send-region))
;; C/C++ mode.
(use-package cc-mode
  :config
  (add-to-list 'c-default-style '(other . "stroustrup"))
  :mode ("\\.h\\'" . c++-mode)
  :general
  (major-prefix-def :prefix-command 'major-cc-map :keymaps 'c-mode-base-map
    "d" 'gud-gdb)
  (:prefix-command 'major-cc-goto-map :keymaps 'major-cc-map :prefix "g"
                   :wk-full-keys nil
                   "" '(:ignore t :which-key "goto")))
;; CMake mode.
(use-package cmake-mode :ensure t)
;; LaTeX mode.
(use-package auctex :ensure t
             :gfhook
             ('LaTeX-mode-hook 'latex-electric-env-pair-mode)
             ('LaTeX-mode-hook 'auto-fill-mode)
             :mode ("\\.tex\\'" . LaTeX-mode)
             :custom
             (TeX-view-program-list '(("Evince" "xdg-open"))
                                    "Open PDFs outside of Emacs.")
             (TeX-insert-macro-default-style 'mandatory-args-only
                                             "Don't expand with optional arguments.")
             (TeX-parse-self t "Parse file on load for AUCTeX to work.")
             (TeX-auto-save t "Parse file on save to keep AUCTeX up to date.")
             :init
             (defun latex/build ()
               "Save and build the current LaTeX file. Based on Spacemacs."
               (interactive)
               (let ((TeX-save-query nil))
                 (TeX-save-document (TeX-master-file)))
               (TeX-command "LaTeX" 'TeX-master-file -1))
             (defun latex/font-bold () (interactive) (TeX-font nil ?\C-b))
             (defun latex/font-medium () (interactive) (TeX-font nil ?\C-m))
             (defun latex/font-code () (interactive) (TeX-font nil ?\C-t))
             (defun latex/font-emphasis () (interactive) (TeX-font nil ?\C-e))
             (defun latex/font-italic () (interactive) (TeX-font nil ?\C-i))
             (defun latex/font-clear () (interactive) (TeX-font nil ?\C-d))
             (defun latex/font-calligraphic () (interactive) (TeX-font nil ?\C-a))
             (defun latex/font-small-caps () (interactive) (TeX-font nil ?\C-c))
             (defun latex/font-sans-serif () (interactive) (TeX-font nil ?\C-f))
             (defun latex/font-normal () (interactive) (TeX-font nil ?\C-n))
             (defun latex/font-serif () (interactive) (TeX-font nil ?\C-r))
             (defun latex/font-oblique () (interactive) (TeX-font nil ?\C-s))
             (defun latex/font-upright () (interactive) (TeX-font nil ?\C-u))
             :general
             (major-prefix-def :prefix-command 'major-latex-map :keymaps 'LaTeX-mode-map
               "\\" 'TeX-insert-macro
               "," 'TeX-command-master
               "a" 'TeX-command-run-all
               "b" 'latex/build
               "c" 'LaTeX-close-environment
               "e" 'LaTeX-environment
               "i" 'LaTeX-insert-item
               "k" 'TeX-kill-job
               "m" 'TeX-insert-macro
               "v" 'TeX-view
               "s" 'LaTeX-section
               "z" 'TeX-fold-dwim)
             (:prefix-command 'major-latex-fonts-map :keymaps 'major-latex-map :prefix "x"
                              :wk-full-keys nil
                              "" '(:ignore t :which-key "fonts")
                              "a" 'latex/font-calligraphic
                              "B" 'latex/font-medium
                              "b" 'latex/font-bold
                              "C" 'latex/font-small-caps
                              "c"  'latex/font-code
                              "e"  'latex/font-emphasis
                              "f" 'latex/font-sans-serif
                              "i"  'latex/font-italic
                              "n" 'latex/font-normal
                              "o"  'latex/font-oblique
                              "R" 'latex/font-serif
                              "r"  'latex/font-clear
                              "u" 'latex/font-upright)
             (:prefix-command 'major-latex-fill-map :keymaps 'major-latex-map :prefix "f"
                              :wk-full-keys nil
                              "" '(:ignore t :which-key "fill")
                              "e" 'LaTeX-fill-environment
                              "p" 'LaTeX-fill-paragraph
                              "r" 'LaTeX-fill-region
                              "s" 'LaTeX-fill-section)
             (:prefix-command 'major-latex-preview-map :keymaps 'major-latex-map
                              :prefix "p" :wk-full-keys nil
                              "" '(:ignore t :which-key "preview")
                              "b" 'preview-buffer
                              "c" 'preview-clearout
                              "d" 'preview-document
                              "e" 'preview-environment
                              "p" 'preview-at-point
                              "r" 'preview-region
                              "s" 'preview-section)
             (:prefix-command 'major-latex-reftex-map :keymaps 'major-latex-map :prefix "r"
                              :wk-full-keys nil
                              "" '(:ignore t :which-key "reftex")
                              "c" 'reftex-citation
                              "g" 'reftex-grep-document
                              "I" 'reftex-display-index
                              "i" 'reftex-index-selection-or-word
                              "<tab>" 'reftex-index
                              "l" 'reftex-label
                              "P" 'reftex-index-visit-phrases-buffer
                              "p" 'reftex-index-phrase-selection-or-word
                              "r" 'reftex-reference
                              "s" 'reftex-search-document
                              "T" 'reftex-toc-recenter
                              "t" 'reftex-toc
                              "v" 'reftex-view-crossref))
;; Render LaTeX maths in buffer.
(use-package xenops :ensure t
             :ghook 'LaTeX-mode-hook
             :general
             (:keymaps 'major-latex-preview-map
                       "x" 'xenops-mode))
;; Insert LaTeX maths delimiters with $.
(use-package math-delimiters :after cdlatex  ;; To override cdlatex binding.
             :straight (math-delimiters :host github
                                        :repo "oantolin/math-delimiters")
             :general
             (:keymaps LaTeX-mode-map
                       "$" 'math-delimiters-insert)
             (:keymaps cdlatex-mode-map
                       "$" nil))
;; Python mode.
(use-package python :demand t
             :init
             ;; Need to declare so it can be used by the pipenv package.
             (defvar major-python-virtualenv-map (make-sparse-keymap)
               "Nested keymap for virtualenv-related commands in Python major mode.")
             :custom
             (python-fill-docstring-style 'pep-257-nn
                                          "Format docstrings properly.")
             :config
             (defun fill-paragraph-72 ()
               "Fill paragraph at column 72."
               (interactive)
               (let ((fill-column 72))
                 (fill-paragraph)))
             (defun python/remove-unused-imports ()
               "Use autoflake to remove unused functions. From Spacemacs."
               (interactive)
               (if (executable-find "autoflake")
                   (progn
                     (shell-command (format "autoflake --remove-all-unused-imports -i %s"
                                            (shell-quote-argument (buffer-file-name))))
                     (revert-buffer t t t))
                 (message "Error: Cannot find autoflake executable.")))
             :general
             (:keymaps 'python-mode-map "RET" 'newline-and-indent)
             (major-prefix-def :prefix-command 'major-python-map :keymaps 'python-mode-map
               "'" 'run-python
               "d" 'pdb
               "q" 'fill-paragraph-72)
             (:prefix-command 'major-python-goto-map :keymaps 'major-python-map :prefix "g"
                              :wk-full-keys nil
                              "" '(:ignore t :which-key "goto"))
             (:prefix-command 'major-python-help-map :keymaps 'major-python-map :prefix "h"
                              :wk-full-keys nil
                              "" '(:ignore t :which-key "help"))
             (:prefix-command 'major-python-refactor-map :keymaps 'major-python-map
                              :prefix "r" :wk-full-keys nil
                              "" '(:ignore t :which-key "refactor")
                              "i" 'python/remove-unused-imports)
             (:prefix-command 'major-python-repl-map :keymaps 'major-python-map :prefix "s"
                              :wk-full-keys nil
                              "" '(:ignore t :which-key "repl")
                              "b" 'python-shell-send-buffer
                              "f" 'python-shell-send-defun
                              "i" 'run-python
                              "r" 'python-shell-send-region)
             (:prefix-command 'major-python-virtualenv-map :keymaps 'major-python-map
                              :prefix "V" :wk-full-keys nil
                              "" '(:ignore t :which-key "virtualenv")))
;; JavaScript mode.
(use-package js2-mode :ensure t
             :general
             (major-prefix-def :prefix-command 'major-js-map :keymaps 'js2-mode-map))
;; Systemd unit mode.
(use-package systemd :ensure t)
;; XML mode.
(use-package nxml-mode
  :custom
  (nxml-slash-auto-complete-flag t "Auto-complete closing tags."))
;; Document viewer.
(use-package doc-view
  :custom
  (doc-view-continuous t "View pages continuously."))
;; Rust mode.
(use-package rustic :ensure t)
;; TypeScript mode.
(use-package typescript-mode :ensure t)
;; Shell script mode.
(use-package sh-script
  :mode ("PKGBUILD" . sh-mode))
;; Haskell mode.
(use-package haskell-mode :ensure t)
;; Emacs Lisp.
(major-prefix-def :prefix-command 'major-emacs-lisp-map
  :keymaps 'emacs-lisp-mode-map
  "c" 'emacs-lisp-byte-compile)
(general-define-key :prefix-command 'major-emacs-lisp-eval-map
                    :keymaps 'major-emacs-lisp-map :prefix "e" :wk-full-keys nil
                    "" '(:ignore t :which-key "eval")
                    "b" 'eval-buffer
                    "e" 'eval-last-sexp
                    "r" 'eval-region
                    "f" 'eval-defun)
(general-define-key :prefix-command 'major-emacs-lisp-help-map
                    :keymaps 'major-emacs-lisp-map :prefix "h" :wk-full-keys nil
                    "" '(:ignore t :which-key "help"))
;; Help.
(general-define-key :keymaps 'help-mode-map :states 'normal
                    "[" 'help-go-back
                    "]" 'help-go-forward)
;; Evaluate expression.
(add-hook 'eval-expression-minibuffer-setup-hook
          (lambda ()
            "Set up key bindings for `eval-expression'."
            (general-define-key :keymaps 'local
                                "C-w" 'backward-kill-word
                                "C-p" 'previous-history-element
                                "C-n" 'next-history-element)))
;; Apropos.
(general-define-key :keymaps 'apropos-mode-map :states 'normal
                    "<tab>" 'forward-button
                    "<backtab>" 'backward-button)

;;; Other.
;; The Git porcelain, with SPC-g.
(use-package magit :ensure t
             :general
             (:prefix-command 'leader-git-map :keymaps 'leader-map :prefix "g"
                              :wk-full-keys nil
                              "" '(:ignore t :which-key "git")
                              "b" 'magit-blame
                              "c" 'magit-commit
                              "i" 'magit-init
                              "m" 'magit-dispatch
                              "S" 'magit-stage-file
                              "s" 'magit-status
                              "C-s" 'magit-stage
                              "U" 'magit-unstage-file)
             (major-prefix-def :prefix-command 'major-with-editor-map
               :keymaps 'with-editor-mode-map
               "," 'with-editor-finish
               "a" 'with-editor-cancel
               "c" 'with-editor-finish
               "k" 'with-editor-cancel))
;; Project management, with SPC-p.
(use-package projectile :ensure t :demand t
             :custom
             (projectile-completion-system 'ivy "Use ivy for completion.")
             (projectile-sort-order 'recentf
                                    "Sort projects by how recent they are.")
             (projectile-use-git-grep t "Only search indexed files.")
             :config
             (projectile-mode)
             :general
             (:keymaps 'major-cc-goto-map
                       "a" 'projectile-find-other-file
                       "A" 'projectile-find-other-file-other-window
                       "f" 'ff-find-other-file))
;; Integrate projectile with ivy.
(use-package counsel-projectile :ensure t :demand t
             :config
             (counsel-projectile-mode))
;; Run any command on current file (e.g. compile or interpret) with SPC-c-c.
(use-package compile
  :custom
  (compilation-scroll-output 'first-error "Stop scrolling at first error.")
  :general
  (:prefix-command 'leader-compile-map :keymaps 'leader-map :prefix "c"
                   :wk-full-keys nil
                   "" '(:ignore t :which-key "compile")
                   "c" 'compile
                   "k" 'kill-compilation
                   "r" 'recompile))
;; Name character under point with SPC-h-d-c.
(use-package descr-text
  :general
  (:keymaps 'leader-help-describe-map
            "c" 'describe-char))
;; Integrate CMake with `compile'.
(use-package cmake-project :ensure t
             :ghook
             'c++-mode-hook)
;; Provide documentation lookup with K in Elisp.
(use-package elisp-slime-nav :ensure t
             :general
             (:keymaps 'major-emacs-lisp-help-map
                       "h" 'elisp-slime-nav-describe-elisp-thing-at-point))
;; Make Emacs aware of Python virtual environments.
(use-package pipenv :ensure t :after python
             :ghook
             'python-mode-hook
             :config
             (set-keymap-parent major-python-virtualenv-map pipenv-command-map))
;; Summon a native Elisp shell with SPC-a-s-e.
(use-package eshell
  :gfhook
  (nil (lambda ()
         "Workaround to define custom key-bindings for `eshell'."
         (general-define-key :keymaps 'eshell-mode-map :states 'insert
                             "C-j" 'eshell-next-prompt
                             "C-k" 'eshell-previous-prompt
                             "C-n" 'eshell-next-matching-input-from-input
                             "C-p" 'eshell-previous-matching-input-from-input)))
  :general
  (:keymaps 'leader-applications-shell-map
            "e" 'eshell))
;; Follow symlinks when editing version-controlled files.
(use-package vc
  :custom
  (vc-handled-backends '(Git) "Don't load other version control systems.")
  (vc-follow-symlinks t "Follow symlinks when opening files."))
;; IDE features in Emacs, which integrates with flycheck, company, imenu,
;; which-key. Provides linting, completion, code outlines, navigation,
;; formatting, semantic highlighting
(use-package lsp-mode :ensure t
             :ghook
             ('(c++-mode-hook
                js-mode-hook
                kotlin-mode-hook
                python-mode-hook
                rustic-mode-hook)
              'lsp)
             :gfhook
             ('lsp-mode 'lsp-enable-which-key-integration)
             ;; NOTE: Install clang, javascript-typescript-langserver,
             ;; {python,kotlin}-language-server for language support.
             ;; See https://emacs-lsp.github.io/lsp-mode/page/languages
             :custom
             (lsp-auto-guess-root t "Don't prompt about project roots.")
             :general
             (:keymaps 'leader-errors-map
                       "P" 'lsp-ui-flycheck-list))
;; Provide a UI to LSP features.
(use-package lsp-ui :ensure t
             :custom
             (lsp-ui-doc-enable nil "Don't obscure code with documentation.")
             :general
             (:keymaps 'lsp-mode-map :states 'insert
                       "<F1>" 'lsp-ui-doc-show
                       "C-?" 'lsp-ui-doc-show))
(use-package lsp-ivy :ensure t
             :general
             (:keymaps 'leader-search-map
                       "S" 'lsp-ivy-workspace-symbol))
;; Provide `restart-emacs' to restart Emacs.
(use-package restart-emacs :ensure t
             :general
             (:keymaps 'leader-quit-map
                       "r" 'restart-emacs))
;; Find out why Emacs is slow with SPC-a-t.
(use-package explain-pause-mode
  :straight (explain-pause-mode :host github
                                :repo "lastquestion/explain-pause-mode")
  :config
  (explain-pause-mode)
  :general
  (:keymaps 'leader-applications-map
            "t" 'explain-pause-top))
;; Save buffers periodically and on exit in case of crash.
(use-package desktop :demand t
  :config
  (desktop-save-mode)
  :general
  (:keymaps 'leader-applications-map
            "d" 'desktop-read))
;; Set of debuggers in Emacs.
(use-package gud
  :general
  (:keymaps 'leader-applications-map
            "d" 'gud-gdb))

;;;; Define overriding key bindings.
(general-define-key :states 'insert
                    "C-q" 'quoted-insert
                    "C-S-q" 'insert-char)
(general-define-key :keymaps 'transient-map "<escape>" 'transient-quit-one)
;;; Leader key.
(leader-def "SPC" 'execute-extended-command
  "?" 'describe-bindings
  "<F1>" 'apropos-command
  "u" 'universal-argument)
(general-define-key :prefix-command 'leader-applications-map
                    :keymaps 'leader-map :prefix "a" :wk-full-keys nil
                    "" '(:ignore t :which-key "applications")
                    "r" 're-builder)
(general-define-key :prefix-command 'leader-applications-shell-map
                    :keymaps 'leader-applications-map :prefix "s"
                    :wk-full-keys nil
                    "" '(:ignore t :which-key "shell"))
(general-define-key :prefix-command 'leader-buffers-map :keymaps 'leader-map
                    :prefix "b" :wk-full-keys nil
                    "" '(:ignore t :which-key "buffers")
                    "C" 'clone-indirect-buffer
                    "c" 'clone-buffer
                    "d" 'kill-buffer
                    "h" 'switch-to-help-buffer
                    "m" 'switch-to-messages-buffer
                    "n" 'next-buffer
                    "p" 'previous-buffer
                    "r" 'read-only-mode
                    "s" 'switch-to-scratch-buffer
                    "w" 'switch-to-warnings-buffer
                    "x" 'kill-buffer-and-window
                    "y" 'copy-whole-buffer-to-clipboard)
(general-define-key :prefix-command 'leader-errors-map :keymaps 'leader-map
                    :prefix "e" :wk-full-keys nil
                    "" '(:ignore t :which-key "errors")
                    "n" 'next-error
                    "p" 'previous-error)
(general-define-key :prefix-command 'leader-files-map :keymaps 'leader-map
                    :prefix "f" :wk-full-keys nil
                    "" '(:ignore t :which-key "files")
                    "c" 'write-file
                    "D" 'delete-current-buffer-file
                    "f" 'find-file
                    "o" 'open-file-or-directory-in-external-app
                    "R" 'rename-current-buffer-file
                    "s" 'save-buffer)
(general-define-key :prefix-command 'leader-files-convert-map
                    :keymaps 'leader-files-map :prefix "C" :wk-full-keys nil
                    "" '(:ignore t :which-key "convert")
                    "d" 'unix2dos
                    "u" 'dos2unix
                    "s" 'untabify)
(general-define-key :prefix-command 'leader-files-emacs-map
                    :keymaps 'leader-files-map :prefix "e" :wk-full-keys nil
                    "" '(:ignore t :which-key "emacs")
                    "d" 'find-init-file
                    "r" 'reload-init-file)
(general-define-key :prefix-command 'leader-frames-map :keymaps 'leader-map
                    :prefix "F" :wk-full-keys nil
                    "" '(:ignore t :which-key "frames")
                    "d" 'delete-frame
                    "o" 'other-frame
                    "n" 'make-frame)
(general-define-key :prefix-command 'leader-help-map :keymaps 'leader-map
                    :prefix "h" :wk-full-keys nil
                    "" '(:ignore t :which-key "help"))
(general-define-key :prefix-command 'leader-help-describe-map
                    :keymaps 'leader-help-map :prefix "d" :wk-full-keys nil
                    "" '(:ignore t :which-key "describe")
                    "B" 'general-describe-keybindings
                    "F" 'describe-font
                    "M" 'describe-minor-mode
                    "T" 'describe-theme
                    "C-F" 'describe-face)
(set-keymap-parent leader-help-describe-map help-map)
(general-define-key :prefix-command 'leader-jumps-map :keymaps 'leader-map
                    :prefix "j" :wk-full-keys nil
                    "" '(:ignore t :which-key "jumps"))
(general-define-key :prefix-command 'leader-narrow-map :keymaps 'leader-map
                    :prefix "n" :wk-full-keys nil
                    "" '(:ignore t :which-key "narrow")
                    "r" 'narrow-to-region
                    "w" 'widen)
(general-define-key :prefix-command 'leader-projects-map :keymaps 'leader-map
                    :prefix "p" :wk-full-keys nil
                    "" '(:ignore t :which-key "projects"))
(set-keymap-parent leader-projects-map projectile-command-map)
(general-define-key :prefix-command 'leader-projects-sessions-map
                    :keymaps 'leader-projects-map :prefix "s"
                    :wk-full-keys nil
                    "" '(:ignore t :which-key "sessions")
                    "s" 'desktop-save
                    "r" 'desktop-read)
(general-define-key :prefix-command 'leader-quit-map :keymaps 'leader-map
                    :prefix "q" :wk-full-keys nil
                    "" '(:ignore t :which-key "quit")
                    "q" 'save-buffers-kill-emacs
                    "Q" 'kill-emacs
                    "y" 'yank-buffer-delete-frame)
(general-define-key :prefix-command 'leader-search-map :keymaps 'leader-map
                    :prefix "s" :wk-full-keys nil
                    "" '(:ignore t :which-key "search")
                    "o" 'occur
                    "P" 'check-parens)
(general-define-key :prefix-command 'leader-toggles-map :keymaps 'leader-map
                    :prefix "t" :wk-full-keys nil
                    "" '(:ignore t :which-key "toggles")
                    "D" 'toggle-debug-on-error
                    "d" 'toggle-selective-display
                    "F" 'auto-fill-mode
                    "L" 'visual-line-mode
                    "l" 'toggle-truncate-lines
                    "P" 'prettify-symbols-mode
                    "W" 'toggle-whitespace-cleanup)
(general-define-key :prefix-command 'leader-toggles-colours-map
                    :keymaps 'leader-toggles-map :prefix "c" :wk-full-keys nil
                    "" '(:ignore t :which-key "colours"))
(general-define-key :prefix-command 'leader-themes-map :keymaps 'leader-map
                    :prefix "T" :wk-full-keys nil
                    "" '(:ignore t :which-key "themes")
                    "T" 'hydra-transparency/body)
(pretty-hydra-define hydra-transparency
  (:title "Set Transparency" :quit-key "q")
  ("Active frames"
   (("k" increase-active-transparency "increase")
    ("j" decrease-active-transparency "decrease"))
   "Inactive frames"
   (("l" increase-inactive-transparency "increase")
    ("h" decrease-inactive-transparency "decrease"))
   "Toggle"
   (("T" toggle-transparency))))
(general-define-key :prefix-command 'leader-windows-map :keymaps 'leader-map
                    :prefix "w" :wk-full-keys nil
                    "" '(:ignore t :which-key "windows")
                    "<tab>" 'alternate-window
                    "." 'hydra-window/body
                    "1" 'tiny-window
                    "0" 'small-window
                    "d" 'delete-window-or-frame
                    "T" 'undedicate-window)
(set-keymap-parent leader-windows-map evil-window-map)
(pretty-hydra-define hydra-window (:title "Window Manipulation" :quit-key "q")
  ("Select"
   (("h" evil-window-left "←")
    ("j" evil-window-down "↓")
    ("k" evil-window-up "↑")
    ("l" evil-window-right "→"))
   "Move"
   (("H" evil-window-move-far-left "←")
    ("J" evil-window-move-very-bottom "↓")
    ("K" evil-window-move-very-top "↑")
    ("L" evil-window-move-far-right "→")
    ("r" evil-window-rotate-downwards "forward")
    ("R" evil-window-rotate-upwards "backward"))
   "Split"
   (("S" split-window-below "horizontal")
    ("s" evil-window-split "horizontal & focus")
    ("V" split-window-right "vertical")
    ("v" evil-window-vsplit "vertical & focus"))
   "Resize"
   (("+" evil-window-increase-height "+height")
    ("-" evil-window-decrease-height "-height")
    ("_" evil-window-set-height "max height")
    (">" evil-window-increase-width "+width")
    ("<" evil-window-decrease-width "-width")
    ("|" evil-window-set-width "max width")
    ("=" balance-windows "balance"))
   "History"
   (("u" winner-undo "undo")
    ("U" winner-redo "redo"))))
(general-define-key :prefix-command 'leader-zoom-map :keymaps 'leader-map
                    :prefix "z" :wk-full-keys nil
                    "" '(:ignore t :which-key "zoom"))

;;; Functions.
;; Default value for use by functions.
(defun delete-window-or-frame (&optional window frame force)
  "Delete WINDOW, or delete FRAME if there is only one window in FRAME.
If WINDOW is nil, it defaults to the selected window.
If FRAME is nil, it defaults to the selected frame."
  (interactive)
  (if (= 1 (length (window-list frame)))
      (delete-frame frame force)
    (delete-window window)))
(defun enable-transparency (&optional frame)
  "Set active/inactive transparency of FRAME to predetermined values.
If FRAME is nil, it defaults to the selected frame. Does not work on Wayland."
  (interactive)
  (set-frame-parameter frame 'alpha my/transparency))
(defun disable-transparency (&optional frame)
  "Make FRAME opaque.
If FRAME is nil, it defaults to the selected frame."
  (interactive)
  (set-frame-parameter frame 'alpha 100))
(defun toggle-transparency (&optional frame)
  "Toggle transparency of FRAME.
If FRAME is nil, it defaults to the selected frame. Based on
https://www.emacswiki.org/emacs/TransparentEmacs."
  (interactive)
  (let ((alpha (frame-parameter frame 'alpha)))
    (if (or (eql alpha 100) (equal alpha '(100 . 100)))
        (disable-transparency frame)
      (enable-transparency frame))))
(defun increase-transparency (fun &optional frame)
  "Decrease FUN ('car or 'cdr) of FRAME's alpha by 5%.
If FRAME is nil, it defaults to the selected frame."
  (let* ((alpha (frame-parameter frame 'alpha))
         (increased-alpha (- (if (consp alpha)
                                 (funcall fun alpha)
                               alpha) 5)))
    (when (>= increased-alpha frame-alpha-lower-limit)
      (set-frame-parameter frame 'alpha (if (eq fun 'car)
                                            (cons increased-alpha
                                                  (or (cdr-safe alpha) alpha))
                                          (cons (or (car-safe alpha) alpha)
                                                increased-alpha))))))
(defun increase-active-transparency (&optional frame)
  "Increase active transparency of FRAME by 5%.
If FRAME is nil, it defaults to the selected frame."
  (interactive)
  (increase-transparency 'car frame))
(defun increase-inactive-transparency (&optional frame)
  "Increase inactive transparency of FRAME by 5%.
If FRAME is nil, it defaults to the selected frame."
  (interactive)
  (increase-transparency 'cdr frame))
(defun decrease-transparency (fun &optional frame)
  "Decrease FUN ('car or 'cdr) of FRAME's transparency by 5%.
If FRAME is nil, it defaults to the selected frame."
  (let* ((alpha (frame-parameter frame 'alpha))
         (decreased-alpha (+ (if (consp alpha)
                                 (funcall fun alpha)
                               alpha) 5)))
    (when (<= decreased-alpha 100)
      (set-frame-parameter frame 'alpha (if (eq fun 'car)
                                            (cons decreased-alpha
                                                  (or (cdr-safe alpha) alpha))
                                          (cons (or (car-safe alpha) alpha)
                                                decreased-alpha))))))
(defun decrease-active-transparency (&optional frame)
  "Decrease active transparency of FRAME by 5%.
If FRAME is nil, it defaults to the selected frame."
  (interactive)
  (decrease-transparency 'car frame))
(defun decrease-inactive-transparency (&optional frame)
  "Decrease inactive transparency of FRAME by 5%.
If FRAME is nil, it defaults to the selected frame."
  (interactive)
  (decrease-transparency 'cdr frame))
(defun find-init-file ()
  "Open the Emacs init file."
  (interactive)
  (find-file user-init-file))
(defun reload-init-file ()
  "Reload the Emacs init file."
  (interactive)
  (load-file user-init-file))
(defun undedicate-window (window)
  "Set WINDOW dedication to nil.
If WINDOW is nil, it defaults to the selected window."
  (interactive (list (frame-selected-window)))
  (set-window-dedicated-p window nil))
(defun toggle-fullscreen-window ()
  "Toggle between deleting other windows and undoing the deletion."
  (interactive)
  (if (eql (length (window-list)) 1)
      (winner-undo)
    (delete-other-windows)))
(defun switch-to-messages-buffer (&optional arg)
  "Switch to the `*Messages*' buffer.
If prefix argument ARG is given, switch to it in another, possibly new window.
From Spacemacs."
  (interactive "P")
  (with-current-buffer (messages-buffer)
    (goto-char (point-max))
    (if arg
        (switch-to-buffer-other-window (current-buffer))
      (switch-to-buffer (current-buffer)))))
(defun switch-to-scratch-buffer (&optional arg)
  "Switch to the `*scratch*' buffer, creating it first if needed.
If prefix argument ARG is given, switch to it in another, possibly new window.
Based on Spacemacs."
  (interactive "P")
  (if arg
      (switch-to-buffer-other-window (get-buffer-create "*scratch*"))
    (switch-to-buffer (get-buffer-create "*scratch*"))))
(defun switch-to-help-buffer (&optional arg)
  "Switch to the `*Help*' buffer.
If prefix argument ARG is given, switch to it in another, possibly new window."
  (interactive "P")
  (funcall (if arg
               'switch-to-buffer-other-window
             'switch-to-buffer) (help-buffer)))
(defun switch-to-warnings-buffer (&optional arg)
  "Switch to the `*Warnings*' buffer.
If prefix argument ARG is given, switch to it in another, possibly new window."
  (interactive "P")
  (funcall (if arg
               'switch-to-buffer-other-window
             'switch-to-buffer) (get-buffer "*Warnings*")))
(defun copy-whole-buffer-to-clipboard ()
  "Copy entire buffer to clipboard. From Spacemacs."
  (interactive)
  (clipboard-kill-ring-save (point-min) (point-max)))
(defun dos2unix ()
  "Convert the current buffer to UNIX file format. From Spacemacs."
  (interactive)
  (set-buffer-file-coding-system 'undecided-unix nil))
(defun unix2dos ()
  "Convert the current buffer to DOS file format. From Spacemacs."
  (interactive)
  (set-buffer-file-coding-system 'undecided-dos nil))
(defun open-file-or-directory-in-external-app (arg)
  "Open current file in external application.
If the universal prefix argument is used then open the folder containing the
current file by the default explorer. Based on Spacemacs."
  (interactive "P")
  (let ((file-path (cond (arg (expand-file-name default-directory))
                         ((derived-mode-p 'dired-mode) (dired-get-file-for-visit))
                         (t buffer-file-name))))
    (if file-path
        (start-process "" nil "xdg-open" file-path)
      (message "No file associated with this buffer."))))
(defun rename-current-buffer-file ()
  "Rename current buffer and associated file (if it exists).
Based on Spacemacs."
  (interactive)
  (let* ((name (buffer-name))
         (filename (buffer-file-name))
         (dir (file-name-directory filename))
         (new-name (read-file-name "New name: " dir)))
    (cond ((get-buffer new-name)
           (error "A buffer named '%s' already exists!" new-name))
          ((not filename)  ; Non-file buffer
           (rename-buffer new-name))
          ((not (file-exists-p filename))  ; New (non-existent) file
           (set-visited-file-name new-name))
          (t  ; Existing file
           (let ((dir (file-name-directory new-name)))
             (when (and (not (file-exists-p dir))
                        (yes-or-no-p (format "Create directory '%s'?" dir)))
               (make-directory dir t)))
           (rename-file filename new-name 1)
           (rename-buffer new-name)
           (set-visited-file-name new-name)
           (set-buffer-modified-p nil)
           (when (fboundp 'recentf-add-file)
             (recentf-add-file new-name)
             (recentf-remove-if-non-kept filename))
           (message "File '%s' successfully renamed to '%s'"
                    name (file-name-nondirectory new-name))))))
(defun toggle-whitespace-cleanup ()
  "Toggle deleting trailing whitespace on save."
  (interactive)
  (funcall (if (memq 'delete-trailing-whitespace before-save-hook)
               'remove-hook
             'add-hook)
           'before-save-hook 'delete-trailing-whitespace))
(defun set-selective-display-at-point ()
  "Fold anything indented further than point's column."
  (interactive)
  (set-selective-display (1+ (current-column))))
(defun toggle-selective-display ()
  "Toggle selective display at point."
  (interactive)
  (if selective-display
      (set-selective-display nil)
    (set-selective-display-at-point)))
(defun alternate-window ()
  "Switch back and forth between current and last window in the
current frame. From Spacemacs."
  (interactive)
  (let (;; switch to first window previously shown in this frame
        (prev-window (get-mru-window nil t t)))
    ;; Check window was not found successfully
    (unless prev-window (user-error "Last window not found."))
    (select-window prev-window)))
(defun tiny-window ()
  "Resize current window to be as small as possible."
  (interactive)
  (evil-resize-window 1))
(defun small-window ()
  "Resize current window to be fairly small."
  (interactive)
  (evil-resize-window 10))
(defun delete-current-buffer-file ()
  "Remove file connected to current buffer and kill buffer. From Spacemacs."
  (interactive)
  (let ((filename (buffer-file-name))
        (buffer (current-buffer))
        (name (buffer-name)))
    (if (not (and filename (file-exists-p filename)))
        (ido-kill-buffer)
      (if (yes-or-no-p
           (format "Are you sure you want to delete this file: '%s'?" name))
          (progn
            (delete-file filename t)
            (kill-buffer buffer)
            (message "File deleted: '%s'" filename))
        (message "Canceled: File deletion")))))
(defun sudo-edit (&optional arg)
  "Edit a file as sudo. From Spacemacs."
  (interactive "P")
  (let ((fname (if (or arg (not buffer-file-name))
                   (read-file-name "File: ")
                 buffer-file-name)))
    (find-file
     (cond ((string-match-p "^/ssh:" fname)
            (with-temp-buffer
              (insert fname)
              (search-backward ":")
              (let ((last-match-end nil)
                    (last-ssh-hostname nil))
                (while (string-match "@\\\([^:|]+\\\)" fname last-match-end)
                  (setq last-ssh-hostname (or (match-string 1 fname)
                                              last-ssh-hostname))
                  (setq last-match-end (match-end 0)))
                (insert (format "|sudo:%s" (or last-ssh-hostname "localhost"))))
              (buffer-string)))
           (t (concat "/sudo:root@localhost:" fname))))))
(defun fix-key (key)
  "Bind KEY to `self-insert-command'."
  (general-define-key key 'self-insert-command))
(defun kill-emacs-no-prompt ()
  "Kill Emacs and automatically reply 'no' to any prompts."
  (dolist (prompt-p '(yes-or-no-p y-or-n-p))
    (defalias prompt-p (lambda (prompt) nil)))
  (kill-emacs))
(defun unfill-region (beg end)
  "Unfill the region, joining text paragraphs into a single
    logical line.  This is useful, e.g., for use with
    `visual-line-mode'.

   From https://www.emacswiki.org/emacs/UnfillRegion"
  (interactive "*r")
  (let ((fill-column (point-max)))
    (fill-region beg end)))
(defun yank-buffer-delete-frame ()
  (interactive)
  (clipboard-kill-region (goto-char (point-min)) (goto-char (point-max)))
  (delete-file (buffer-file-name))
  (delete-frame))
(defun warn-missing-executable (name purpose)
  "Warn if executable `name' is not available for the given `purpose'."
  (unless (executable-find name)
    (warn "%s is not installed; install for %s" name purpose)))

;;; Generic settings.
(add-hook 'find-file-not-found-functions
          (lambda ()
            "Create non-existent parent directories and return nil."
            (let ((parent-dir (file-name-directory buffer-file-name)))
              (when (not (file-exists-p parent-dir))
                (make-directory parent-dir t)))
            nil))
(add-to-list 'completion-styles 'flex)
(setq-default scroll-conservatively 101
              scroll-margin 5
              mouse-wheel-progressive-speed nil
              mouse-wheel-scroll-amount '(1 ((shift) . 1) ((control)))
              prettify-symbols-unprettify-at-point t
              indicate-empty-lines t
              fill-column 80
              indent-tabs-mode nil
              read-quoted-char-radix 16
              frame-resize-pixelwise t
              initial-major-mode 'text-mode
              require-final-newline t
              help-window-select t
              delete-by-moving-to-trash t
              sentence-end-double-space nil
              window-combination-resize t
              initial-scratch-message nil
              open-paren-in-column-0-is-defun-start nil
              default-frame-scroll-bars 'right
              backup-directory-alist (list (cons "." (concat user-emacs-directory
                                                             "backups/")))
              delete-old-versions t
              version-control t
              comment-auto-fill-only-comments t
              use-dialog-box nil
              ring-bell-function 'ignore
              display-buffer-alist '(("\\*help" (display-buffer-same-window)))
              read-process-output-max (* 1024 1024)
              initial-buffer-choice (lambda ()
                                      "Get current buffer."
                                      (window-buffer (selected-window)))
              large-file-warning-threshold (* 1000 1000)
              confirm-kill-processes nil
              frame-title-format "%* %b"
              mode-line-format nil)