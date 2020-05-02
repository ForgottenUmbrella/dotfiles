;;;; Customisation setup.
(setq custom-file (concat user-emacs-directory "custom.el"))
(load custom-file t)

;;;; Package setup.
;; Enable additional package repos.
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(package-initialize)
;; Bootstrap, load and configure use-package.
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(eval-when-compile
  (require 'use-package))
(defun before-install-refresh-contents (&rest args)
  "Refresh package archive before installing to avoid outdated files."
  (package-refresh-contents)
  (advice-remove 'package-install 'before-install-refresh-contents))
(advice-add 'package-install :before 'before-install-refresh-contents)
(use-package use-package-ensure-system-package :ensure t)
;; Auto-update packages (disabled, run auto-package-update-now when you feel
;; like it.)
;;(use-package auto-package-update :ensure t
;;   :init
;;   (setq-default auto-package-update-hide-results t
;;                 auto-package-update-delete-old-version t)
;;   :config
;;   (auto-package-update-maybe))

;;;; Install packages.
;;; Make binding keys sane.
(use-package general :ensure t)
(general-create-definer leader-def
  :states '(motion normal insert emacs)
  :keymaps 'override
  :prefix "SPC"
  :non-normal-prefix "M-SPC"
  :prefix-command 'leader-map)
(general-create-definer major-prefix-def
  :states '(motion insert emacs)
  :prefix ","
  :non-normal-prefix "M-,"
  "" '(:ignore t :which-key "major"))
(use-package pretty-hydra :ensure t)
;; NOTE: :ensure is for external (not built-in) packages, and
;; :demand is needed if you :general-bind keys or
;; :g(f)hook but still need the external package to be loaded.
;; Also, some built-in packages also need :demand when :general-binding.
;; NOTE: :ghook enables the package mode;
;; :gfhook calls function when the package mode is enabled

;;; Join the dark side.
(use-package evil :ensure t :demand t
  :init
  (setq-default evil-want-C-u-scroll t
                evil-want-Y-yank-to-eol t
                evil-want-visual-char-semi-exclusive t
                evil-want-keybinding nil ; For evil-collection.
                evil-ex-substitute-global t
                evil-vsplit-window-right t
                evil-split-window-below t
                evil-cross-lines t
                evil-respect-visual-line-mode t
                evil-auto-balance-windows nil
                evil-symbol-word-search t)
  :config
  (evil-mode)
  (defun my-append-to-register ()
    "Append to register z instead of unnamed register as a hack."
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
  ;; NOTE: 'motion is for commands useful even when not modifying text
  (:states 'motion
           "_" (lambda ()
                 "Use black-hole register for deletion."
                 (interactive)
                 (evil-use-register ?_))
           "C-_" 'my-append-to-register
           "Q" (kbd "@q")
           "K" 'evil-smart-doc-lookup
           "M--" 'evil-window-decrease-height
           "M-+" 'evil-window-increase-height
           "M-<" 'evil-window-decrease-width
           "M->" 'evil-window-increase-width)
  (:states 'normal
           "j" 'evil-next-visual-line
           "k" 'evil-previous-visual-line)
  (:states 'visual
           "<" "<gv"
           ">" ">gv")
  (leader-def "TAB" 'evil-switch-to-windows-last-buffer)

  (:keymaps 'leader-files-map
            "S" 'evil-write-all)
  (:keymaps 'leader-search-map
            "c" 'evil-ex-nohighlight))
(use-package evil-escape :ensure t
  :init
  (setq-default evil-escape-key-sequence "<escape>")
  :config
  (evil-escape-mode))
(use-package evil-numbers :ensure t
  :general
  (:states 'motion
           "C-a" 'evil-numbers/inc-at-pt
           "C-x" 'evil-numbers/dec-at-pt))
(use-package evil-unimpaired :load-path "lisp/" :demand t
  :config
  (general-unbind 'normal "] l" "[ l" "] q" "[ q")
  :general
  (:states 'motion
           "[ c" 'previous-comment
           "] c" 'next-comment))
(use-package evil-cleverparens :ensure t
  :ghook
  'lisp-mode-hook
  'emacs-lisp-mode-hook
  :init
  (setq-default evil-cleverparens-use-regular-insert t
                evil-cleverparens-use-additional-movement-keys nil)
  :config
  (general-unbind '(normal visual operator) evil-cleverparens-mode-map
    "_" "s" "x"))
;; (use-package evil-snipe :ensure t
;;   :init
;;   (setq-default evil-snipe-repeat-keys nil
;;                 evil-snipe-smart-case nil
;;                 evil-snipe-show-prompt nil)
;;   :config
;;   (evil-snipe-mode t))
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
(use-package evil-indent-plus :ensure t
  :config
  (evil-indent-plus-default-bindings))
(use-package evil-commentary :ensure t
  :config
  (evil-commentary-mode))
(use-package evil-args :ensure t
  :ghook
  ('(lisp-mode-hook emacs-lisp-mode-hook) (lambda ()
                                            "Don't pair single quotes."
                                            (setq evil-args-delimiters '(" "))))
  :general
  (:keymaps 'evil-inner-text-objects-map "a" 'evil-inner-arg)
  (:keymaps 'evil-outer-text-objects-map "a" 'evil-outer-arg))
(use-package evil-collection :ensure t
  :config
  (evil-collection-init)
  (general-unbind 'normal evil-collection-unimpaired-mode-map "] l" "[ l")
  (general-unbind 'normal help-mode-map "C-o" "C-i"))
(use-package evil-magit :ensure t
  :init
  (setq-default evil-magit-want-horizontal-movement t))
(use-package evil-surround :ensure t
  :config
  (global-evil-surround-mode))
(use-package evil-matchit :ensure t
  :config
  (global-evil-matchit-mode))
(use-package evil-visualstar :ensure t
  :config
  (global-evil-visualstar-mode))

;;; Aesthetics.
(use-package spaceline :ensure t
  :init
  (setq-default spaceline-buffer-size-p nil
                spaceline-minor-modes-p nil
                spaceline-buffer-encoding-p nil
                spaceline-buffer-encoding-abbrev-p nil
                spaceline-window-numbers-unicode t
                spaceline-workspace-numbers-unicode t
                ;; Use pywal colours for evil state instead of default.
                ;;spaceline-highlight-face-func 'spaceline-highlight-face-evil-state
                spaceline-highlight-face-func 'ewal-evil-cursors-highlight-face-evil-state
                ;; Remember to call spaceline-compile after changing.
                powerline-default-separator nil)
  :config
  (require 'spaceline-config)
  (spaceline-spacemacs-theme))
(use-package rainbow-mode :ensure t
  :general
  (:keymaps 'leader-toggles-colours-map
            "c" 'rainbow-mode))
(use-package rainbow-delimiters :ensure t
  :ghook
  'text-mode-hook
  'prog-mode-hook
  :general
  (:keymaps 'leader-toggles-colours-map
            "d" 'rainbow-delimiters-mode))
(use-package rainbow-identifiers :ensure t
  :general
  (:keymaps 'leader-toggles-colours-map
            "i" 'rainbow-identifiers-mode))
(use-package fill-column-indicator :ensure t :demand t
  :config
  (define-globalized-minor-mode global-fci-mode fci-mode turn-on-fci-mode)
  (global-fci-mode)
  :general
  (:keymaps 'leader-toggles-map
            "f" 'fci-mode))
(use-package hl-line
  :config
  (global-hl-line-mode))
(use-package whitespace
  :init
  (setq-default whitespace-style '(face trailing tabs empty))
  :config
  (global-whitespace-mode)
  :general
  (:keymaps 'leader-toggles-map
            "w" 'whitespace-mode))
(use-package hl-todo :ensure t :demand t
  :config
  (global-hl-todo-mode)
  :general
  (:keymaps 'hl-todo-mode-map :states 'motion
            "[ T" 'hl-todo-previous
            "] T" 'hl-todo-next)
  (:keymaps 'leader-toggles-map
            "h" 'hl-todo-mode))
(use-package semantic
  :ghook
  'prog-mode-hook
  :config
  (dolist (mode '(global-semantic-stickyfunc-mode
                  global-semantic-idle-local-symbol-highlight-mode))
    (add-to-list 'semantic-default-submodes mode))
  :general
  (:keymaps 'leader-toggles-map
            "C-s" 'semantic-mode))
(use-package stickyfunc-enhance :ensure t)
(use-package default-text-scale :ensure t
  :init
  (pretty-hydra-define hydra-default-text (:title "Zoom" :quit-key "q")
    ("Increase"
     (("k" default-text-scale-increase)
      ("+" default-scale-increase))
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
(use-package highlight-indent-guides :ensure t
  :after whitespace ; Load whitespace first due to conflict.
  :ghook
  'prog-mode-hook
  :init
  (setq-default highlight-indent-guides-method 'character
                highlight-indent-guides-responsive 'stack)
  :general
  (:keymaps 'leader-toggles-map
            "i" 'highlight-indent-guides-mode))
(use-package git-gutter :ensure t :demand t
  :init
  (setq-default git-gutter:hide-gutter t)
  :config
  (global-git-gutter-mode)
  :general
  (:keymaps 'leader-git-map
            "h" 'git-gutter:stage-hunk
            "n" 'git-gutter:next-hunk
            "p" 'git-gutter:previous-hunk
            "x" 'git-gutter:revert-hunk)
  (:states 'motion
           "[ h" 'git-gutter:previous-hunk
           "] h" 'git-gutter:next-hunk))
(use-package face-remap
  :general
  (:keymaps 'leader-zoom-map
            "x" 'text-scale-adjust))
;;(use-package dashboard :ensure t
;;  :init
;;  (setq-default dashboard-startup-banner 'logo
;;                dashboard-center-content t
;;                show-week-agenda-p t
;;                initial-buffer-choice (lambda ()
;;                                        "Open `*dashboard*' in new frames."
;;                                        (get-buffer "*dashboard*")))
;;  :config
;;  (dashboard-setup-startup-hook)
;;  (add-to-list 'dashboard-items '(projects) t))
;; Themes. Defer all but the selected.
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
(use-package ewal :ensure t
  :init
  (setq-default ewal-use-built-in-on-failure-p t
                ewal-high-contrast-p t))
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
(use-package zone
  :general
  (:keymaps 'leader-applications-map
            "z" 'zone))
(use-package multi-line :ensure t
  :general
  (:keymaps 'prog-mode-map
            "C-q" 'multi-line))

;;; Navigation.
(use-package which-key :ensure t :demand t
  :init
  (setq-default which-key-idle-delay 0.4
                which-key-sort-order 'which-key-key-order-alpha)
  :config
  (which-key-mode)
  :general
  (:keymaps 'leader-help-map
            "k" 'which-key-show-top-level
            "m" 'which-key-show-major-mode)
  (:keymaps 'leader-toggles-map
            "K" 'which-key))
(use-package evil-anzu :ensure t
  :init
  (setq-default anzu-cons-mode-line-p nil)
  :config
  (global-anzu-mode))
(use-package winum :ensure t :demand t
  :init
  (setq-default winum-auto-setup-mode-line nil)
  :config
  (winum-mode)
  :general
  (leader-def :keymaps 'winum-keymap
    "1" '(winum-select-window-1 :which-key t)
    "2" '(winum-select-window-2 :which-key t)
    "3" '(winum-select-window-3 :which-key t)
    "4" '(winum-select-window-4 :which-key t)
    "5" '(winum-select-window-5 :which-key t)
    "6" '(winum-select-window-6 :which-key t)
    "7" '(winum-select-window-7 :which-key t)
    "8" '(winum-select-window-8 :which-key t)
    "9" '(winum-select-window-9 :which-key t)
    "0" '(winum-select-window-0-or-10 :which-key t)))
(use-package winner
  :config
  (winner-mode)
  :general
  (:keymaps 'leader-windows-map
            "u" 'winner-undo
            "U" 'winner-redo))
(use-package terminal-here :ensure t
  :init
  (setq-default terminal-here-terminal-command
                (lambda (dir)
                  "Use i3-sensible-terminal to open terminals."
                  (list "i3-sensible-terminal" "-d" dir)))
  :general
  (:keymaps 'leader-applications-shell-map
            "t" 'terminal-here-launch
            "p" 'terminal-here-project-launch))
(use-package dumb-jump :ensure t
  :init
  (setq-default dumb-jump-selectory 'ivy
                dumb-jump-prefer-searcher 'rg)
  :config
  (dumb-jump-mode)
  :general
  (:states 'motion
           "C-]" 'dumb-jump-go))
(use-package display-line-numbers :demand t
  :init
  (setq-default display-line-numbers-type 'visual)
  :config
  (global-display-line-numbers-mode)
  :general
  (:keymaps 'leader-toggles-map
            "n" 'display-line-numbers-mode))
(use-package ffap
  :init
  (setq-default ffap-machine-p-known 'reject)
  :general
  (:states 'motion
           "g f" 'find-file-at-point))
(use-package uniquify)
(use-package reposition
  :general
  (:states 'motion
           "z f" 'reposition-window))
(use-package undo-tree :ensure t
  :general
  (:keymaps 'leader-applications-map
            "u" 'undo-tree-visualize))
(use-package recentf
  :init
  (setq-default recentf-max-saved-items 1024)
  :config
  (add-to-list 'recentf-exclude (expand-file-name package-user-dir))
  (recentf-mode)
  (run-with-idle-timer 600 t 'recentf-save-list))
(use-package midnight
  :general
  (:keymaps 'leader-buffers-map
            "X" 'clean-buffer-list))
(use-package origami :ensure t
  :config
  (global-origami-mode))
(use-package hideshow
  :ghook
  ('prog-mode-hook 'hs-minor-mode))
(use-package outline
  :ghook
  ('prog-mode-hook 'outline-minor-mode)
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
           "TAB" 'outline-toggle-children
           "<backtab>" 'outline-show-all
           "g h" 'outline-up-heading
           "g j" 'outline-forward-same-level
           "g k" 'outline-backward-same-level
           "g l" 'outline-next-visible-heading
           "g y" 'outline-previous-visible-heading))
(use-package outshine :ensure t
  :general
  (:keymaps 'leader-jumps-map
            "o" 'outshine-imenu)
  (:keymaps 'leader-narrow-map
            "n" 'outshine-narrow-to-subtree))
(use-package saveplace
  :config
  (save-place-mode))

;;; Completion.
(use-package ivy :ensure t :demand t
  :init
  (setq-default ivy-use-selectable-prompt t
                ivy-use-virtual-buffers t
                ivy-initial-inputs-alist nil)
  :config
  (ivy-mode t)
  (add-to-list 'ivy-format-functions-alist '(t . ivy-format-function-line))
  (add-to-list 'ivy-re-builders-alist '(t . ivy--regex-fuzzy))
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
            "C-d" 'ivy-scroll-down-command
            "C-u" 'ivy-scroll-up-command)
  (:keymaps 'ivy-switch-buffer-map
            "C-x" 'ivy-switch-buffer-kill))
(use-package ivy-hydra :ensure t)
(use-package ivy-rich :ensure t
  :config
  (ivy-rich-mode t))
(use-package counsel :ensure t :demand t
  :ensure-system-package (rg . ripgrep)
  :init
  (setq-default counsel-grep-base-command "rg -i -M 120 --no-heading --line-number --color never '%s' %s")
  :config
  (counsel-mode t)
  (defun todo-list ()
    "Navigate to a TODO item."
    (interactive)
    (let ((imenu-case-fold-search nil)
          (imenu-generic-expression (mapcar
                                     (lambda (keyword-face)
                                       (let* ((keyword (car keyword-face))
                                              (regexp (concat keyword
                                                              ":? ?\\(.*\\)$")))
                                         (list keyword regexp 1)))
                                     hl-todo-keyword-faces)))
      (imenu (imenu-choose-buffer-index))))
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
            "i" 'counsel-semantic-or-imenu
            "t" 'todo-list)
  (:keymaps 'leader-search-map
            "d" 'counsel-rg
            "s" 'counsel-grep-or-swiper)
  (:keymaps 'leader-themes-map
            "t" 'counsel-load-theme))
(use-package ivy-prescient :ensure t
  :config
  (ivy-prescient-mode)
  (add-to-list 'ivy-sort-functions-alist
               '(read-file-name-internal . ivy-sort-file-function-default)))
(use-package yasnippet :ensure t :demand t
  :config
  (yas-global-mode)
  (general-unbind 'normal yas-minor-mode-map "TAB")
  :general
  (:keymaps 'leader-toggles-map
            "y" 'yas-minor-mode))
(use-package yasnippet-snippets :ensure t)
(use-package company :ensure t :demand t
  :init
  (setq-default company-minimum-prefix-length 1)
  :config
  (global-company-mode)
  ;; (general-unbind company-active-map "TAB" "C-i" [tab])
  ;; ;; TODO bind to default command instead of being hijacked
  ;; (general-unbind company-mode-map "TAB")
  :general
  (:keymaps 'company-active-map
            "C-l" 'company-complete-selection
            "TAB" nil
            "C-i" nil
            [tab] nil
            ;; 'company-complete-common nil ;; XXX
            )
  (:keymaps 'company-mode-map
            "TAB" nil))
(use-package company-quickhelp :ensure t
  :ghook
  'company-mode-hook)
(use-package company-statistics :ensure t
  :config
  (company-statistics-mode))
(use-package company-auctex :ensure t
  :config
  (company-auctex-init))
(use-package company-shell :ensure t
  :config
  (add-to-list 'company-backends
               '(company-shell company-shell-env company-fish-shell)))
(use-package company-c-headers :ensure t
  :config
  (add-to-list 'company-backends 'company-c-headers))
(use-package company-tern :ensure t
  :config
  (if (executable-find "tern")
      (add-to-list 'company-backends 'company-tern)
    (message "tern is not installed; install for JavaScript auto-completion")))
(use-package anaconda-mode :ensure t
  :ghook
  'python-mode-hook
  ('python-mode-hook 'anaconda-eldoc-mode)
  :general
  (:keymaps 'major-python-help-map
            "h" 'anaconda-mode-show-doc)
  (:keymaps 'major-python-goto-map
            "a" 'anaconda-mode-find-assignments
            "u" 'anaconda-mode-find-references))
(use-package company-anaconda :ensure t
  :config
  (add-to-list 'company-backends 'company-anaconda))
(use-package eldoc
  :ghook
  'prog-mode-hook
  :init
  (setq-default eldoc-echo-area-use-multiline-p nil))
(use-package insert-shebang :ensure t
  :ghook
  ('find-file-not-found-functions (lambda ()
                                    "Insert shebang and return nil."
                                    (insert-shebang)
                                    nil))
  :init
  (setq-default insert-shebang-track-ignored-filename nil
                insert-shebang-custom-headers '(("sh" . "#!/bin/sh")))
  :config
  (add-to-list 'insert-shebang-file-types '("py" . "python3"))
  (remove-hook 'find-file-hook 'insert-shebang))
(use-package cdlatex :ensure t)

;;; Correction.
(use-package flycheck :ensure t :demand t
  :init
  (setq-default flycheck-disabled-checkers '(emacs-lisp-checkdoc))
  :config
  (global-flycheck-mode)
  (add-hook 'sh-mode-hook
            (lambda ()
              "Warn missing shell script linters."
              (unless (executable-find "shellcheck")
                (message
                 "shellcheck is not installed; install for sh linting"))))
  (add-hook 'c++-mode-hook
            (lambda ()
              "Warn missing C++ linters."
              (unless (executable-find "cppcheck")
                (message
                 "cppcheck is not installed; install for C++ linting"))))
  (add-hook 'js-mode-hook
            (lambda ()
              "Warn missing JavaScript linters."
              (unless (executable-find "eslint")
                (message
                 "eslint is not installed; install for JavaScript linting"))))
  (add-hook 'python-mode-hook
            (lambda ()
              "Warn missing Python linters."
              (unless (executable-find "pylint")
                (message "pylint is not installed; install for Python linting"))
              (unless (executable-find "mypy")
                (message
                 "mypy is not installed; install for Python type checking"))))
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
    (unless (get-buffer-window (get-buffer flycheck-error-list-buffer))
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
(use-package flycheck-checkbashisms :ensure t
  :config
  (flycheck-checkbashisms-setup)
  (add-hook 'sh-mode-hook
            (lambda ()
              "Warn missing POSIX shell linters."
              (unless (executable-find "checkbashisms")
                (message "checkbashisms is not installed; install for POSIX compatibility checking")))))
(use-package flycheck-pos-tip :ensure t
  :config
  (flycheck-pos-tip-mode))
(use-package aggressive-indent :ensure t :demand t
  :config
  (global-aggressive-indent-mode)
  :general
  (:keymaps 'leader-toggles-map
            "I" 'aggressive-indent-mode))
(use-package smartparens :ensure t :demand t
  :ghook
  'eval-expression-minibuffer-setup-hook
  ;; XXX: Tag handling is broken.
  ('nxml-mode-hook 'turn-off-smartparens-mode)
  :init
  (setq-default sp-escape-quotes-after-insert nil
                sp-show-pair-from-inside t
                sp-highlight-pair-overlay nil
                sp-highlight-wrap-overlay nil
                sp-highlight-wrap-tag-overlay nil)
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
(use-package flyspell
  :ghook
  'text-mode-hook
  ('prog-mode-hook 'flyspell-prog-mode)
  :init
  (setq-default flyspell-issue-message-flag nil
                enable-flyspell-auto-completion t)
  :general
  (:keymaps 'leader-toggles-map
            "S" 'flyspell-mode))
(use-package flyspell-correct-ivy :ensure t
  :init
  (setq-default flyspell-correct-interface 'flyspell-correct-ivy)
  :general
  (leader-def :keymaps 'flyspell-mode-map
    "S" 'flyspell-correct-next))
(use-package yapfify :ensure t
  :config
  (if (executable-find "yapf")
      (add-hook 'python-mode-hook 'yapf-mode)
    (message "yapf is not installed; install for Python formatting"))
  :general
  (:keymaps 'major-python-map
            "=" 'yapfify-buffer))
(use-package py-isort :ensure t
  :ghook
  ('python-mode-hook
   (lambda ()
     "Warn missing Python isort import-sorter."
     (unless (executable-find "isort")
       (message "isort is not installed; install for automatic Python import sorting"))))
  :general
  (:keymaps 'major-python-refactor-map
            "I" 'py-isort-buffer))
(use-package srefactor :ensure t
  :general
  (:prefix-command 'major-emacs-lisp-srefactor-map
                   :keymaps 'major-emacs-lisp-map
                   :prefix "=" :wk-full-keys nil
                   "" '(:ignore t :which-key "srefactor")
                   "b" 'srefactor-lisp-format-buffer
                   "d" 'srefactor-lisp-format-defun
                   "o" 'srefactor-lisp-one-line
                   "s" 'srefactor-lisp-format-sexp)
  (:keymaps 'major-cc-map
            "r" 'srefactor-refactor-at-point))
(use-package clang-format :ensure t
  :ghook
  ('c++-mode-hook
   (lambda ()
     "Format buffer with clang-format before save."
     (add-hook 'before-save-hook 'clang-format-buffer nil t))))
(use-package web-beautify :ensure t
  :config
  (if (executable-find "js-beautify")
      (add-hook 'js-mode-hook
                (lambda ()
                  "Format buffer with js-beautify before save."
                  (add-hook 'before-save-hook 'web-beautify-js-buffer t t)))
    (message "js-beautify is not installed; install for JavaScript formatting"))
  :general
  (:keymaps 'major-js-map
            "=" 'web-beautify-js))
(use-package autorevert
  :config
  (global-auto-revert-mode))
(use-package electric
  :ghook
  ('python-mode-hook
   (lambda ()
     "Always indent, including in docstrings."
     (add-hook 'electric-indent-functions (lambda (_) 'do-indent) nil t))))
(use-package refill
  :general
  (:keymaps 'leader-toggles-map
            "r" 'refill-mode))
(use-package tagedit :ensure t
  :ghook
  'nxml-mode
  :config
  (tagedit-add-experimental-features))
(add-hook 'text-mode-hook 'auto-fill-mode)
(add-hook 'prog-mode-hook 'auto-fill-mode)
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;;; Major modes.
(use-package org
  :gfhook
  'turn-off-fci-mode
  'turn-on-org-cdlatex
  :init
  (setq-default org-startup-indented t
                org-startup-folded nil
                org-startup-truncated nil
                org-agenda-files '("~/Dropbox/Wiki/uni/")
                org-src-tab-acts-natively t
                org-confirm-babel-evaluate (lambda (lang body)
                                             "Don't confirm Python evaluation."
                                             (not (string= lang "python")))
                org-export-with-smart-quotes t
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
    "p" 'org-toggle-latex-fragment
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
                   "f" 'org-footnote-new)
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
(use-package kotlin-mode :ensure t :demand t
  :gfhook
  (nil (lambda ()
         "Set Kotlin mode `fill-column' to 120."
         (setq fill-column 120)))
  :init
  (setq-default kotlin-tab-width 4)
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
(use-package cc-mode
  :config
  (add-to-list 'c-default-style '(other . "stroustrup"))
  :mode ("\\.h\\'" . c++-mode)
  :general
  (major-prefix-def :prefix-command 'major-cc-map :keymaps 'c-mode-base-map)
  (:prefix-command 'major-cc-goto-map :keymaps 'major-cc-map :prefix "g"
                   :wk-full-keys nil
                   "" '(:ignore t :which-key "goto")))
(use-package cmake-mode :ensure t)
(use-package fish-mode :ensure t)
(use-package auctex :ensure t
  :gfhook
  ('LaTeX-mode-hook 'latex-electric-env-pair-mode)
  ('LaTeX-mode-hook 'turn-on-org-cdlatex)
  ;;('LaTeX-mode-hook 'turn-on-auto-fill) ; XXX: Shouldn't be necessary
  :mode ("\\.tex\\'" . LaTeX-mode)
  :init
  (setq-default TeX-view-program-list '(("Evince" "xdg-open"))
                TeX-insert-macro-default-style 'mandatory-args-only)
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
                   "TAB" 'reftex-index
                   "l" 'reftex-label
                   "P" 'reftex-index-visit-phrases-buffer
                   "p" 'reftex-index-phrase-selection-or-word
                   "r" 'reftex-reference
                   "s" 'reftex-search-document
                   "T" 'reftex-toc-recenter
                   "t" 'reftex-toc
                   "v" 'reftex-view-crossref))
(use-package python :demand t
  :init
  (setq-default major-python-virtualenv-map (make-sparse-keymap)
                python-fill-docstring-style 'pep-257-nn)
  :config
  (defun fill-paragraph-72 ()
    "Fill paragraph at column 72."
    (interactive)
    (let ((fill-column 72))
      (fill-paragraph)))
  :general
  (:keymaps 'python-mode-map "RET" 'newline-and-indent)
  (major-prefix-def :prefix-command 'major-python-map :keymaps 'python-mode-map
    "'" 'run-python
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
(use-package js
  :general
  (major-prefix-def :prefix-command 'major-js-map :keymaps 'js-mode-map))
(use-package systemd :ensure t)
(use-package nxml-mode
  :init
  (setq-default nxml-slash-auto-complete-flag t))
(use-package doc-view
  :init
  (setq-default doc-view-continuous t))
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
;; Evaluate expression,
(add-hook 'eval-expression-minibuffer-setup-hook
          (lambda ()
            "Set up key bindings for `eval-expression'."
            (general-define-key :keymaps 'local
                                "C-w" 'backward-kill-word
                                "C-p" 'previous-history-element
                                "C-n" 'next-history-element)))
;; Apropos.
(general-define-key :keymaps 'apropos-mode-map :states 'normal
                    "TAB" 'forward-button
                    "<backtab>" 'backward-button)

;;; Other.
(use-package magit :ensure t
  :general
  (:prefix-command 'leader-git-map :keymaps 'leader-map :prefix "g"
                   :wk-full-keys nil
                   "" '(:ignore t :which-key "git")
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
(use-package projectile :ensure t :demand t
  :init
  (setq-default projectile-completion-system 'ivy
                projectile-sort-order 'recentf)
  :config
  (projectile-mode)
  :general
  (:keymaps 'major-cc-goto-map
            "a" 'projectile-find-other-file
            "A" 'projectile-find-other-file-other-window
            "f" 'ff-find-other-file))
(use-package counsel-projectile :ensure t :demand t
  :config
  (counsel-projectile-mode)
  (defun project-smart-search ()
    "Search project with (rip)grep."
    (interactive)
    (if (executable-find "rg")
        (counsel-projectile-rg)
      (counsel-projectile-grep)))
  :general
  (leader-def :keymaps 'counsel-mode-map
    "/" 'project-smart-search)
  (:keymaps 'leader-search-map
            "p" 'project-smart-search))
(use-package expand-region :ensure t
  :general
  (leader-def "v" 'er/expand-region))
(use-package live-py-mode :ensure t
  :general
  (:keymaps 'major-python-map
            "l" 'live-py-mode))
(use-package ielm
  :general
  (:keymaps 'major-emacs-lisp-map
            "'" 'ielm))
(use-package ert
  :general
  (:keymaps 'major-emacs-lisp-map
            "t" 'ert))
(use-package move-text :ensure t)
(use-package compile
  :init
  (setq-default compilation-scroll-output 'first-error)
  :general
  (:prefix-command 'leader-compile-map :keymaps 'leader-map :prefix "c"
                   :wk-full-keys nil
                   "" '(:ignore t :which-key "compile")
                   "c" 'compile
                   "k" 'kill-compilation
                   "r" 'recompile))
(use-package descr-text
  :general
  (:keymaps 'leader-help-describe-map
            "c" 'describe-char))
(use-package cmake-project :ensure t
  :ghook
  'c++-mode-hook)
(use-package elisp-slime-nav :ensure t
  :general
  (:keymaps 'major-emacs-lisp-help-map
            "h" 'elisp-slime-nav-describe-elisp-thing-at-point))
(use-package pipenv :ensure t
  :ghook
  'python-mode-hook
  :config
  (set-keymap-parent major-python-virtualenv-map pipenv-command-map))
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
(use-package vc
  :init
  (setq-default vc-handled-backends '(Git)
                vc-follow-symlinks t))
(use-package lsp-mode :ensure t
  :ghook
  ('(kotlin-mode-hook c++-mode-hook) 'lsp)
  :gfhook
  ('lsp-mode 'lsp-enable-which-key-integration)
  ;; NOTE: Install {kotlin,python}-language-server, clang for language support
  ;; See https://github.com/emacs-lsp/lsp-mode#supported-languages.
  )
(use-package lsp-ui :ensure t)
(use-package company-lsp :ensure t
  :gfhook
  ('lsp (lambda ()
          "Reduce company delay"
          (setq company-idle-delay 0)))
  :config
  (add-to-list 'company-backends 'company-lsp))
(use-package exec-path-from-shell :ensure t
  :config
  (exec-path-from-shell-initialize))

;;;; Define overriding key bindings.
(general-define-key :states 'insert
                    "C-q" 'quoted-insert
                    "C-S-q" 'insert-char
                    ;;"C-i" 'evil-shift-right-line ;; XXX perhaps overrides TAB
                    ;;"C-S-i" 'evil-shift-left-line
                    "<backtab>" 'evil-shift-left-line)
(general-define-key :keymaps 'isearch-mode-map
                    "<escape>" 'isearch-cancel
                    "C-w" 'backward-kill-word
                    "C-n" 'isearch-ring-advance
                    "C-p" 'isearch-ring-retreat
                    "C-g" 'isearch-repeat-forward
                    "C-j" 'isearch-repeat-forward
                    "C-t" 'isearch-repeat-backward
                    "C-k" 'isearch-repeat-backward)
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
                    "Q" 'kill-emacs)
(general-define-key :prefix-command 'leader-search-map :keymaps 'leader-map
                    :prefix "s" :wk-full-keys nil
                    "" '(:ignore t :which-key "search")
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
                    "t" 'toggle-truncate-lines
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
                    "TAB" 'alternate-window
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

;;;; Functions.
;; Default value for use by functions.
(defvar my-transparency '(90 . 80)
  "Cons of active and inactive frame alpha values, where 0 is fully transparent
and 100 is fully opaque.")
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
If FRAME is nil, it defaults to the selected frame."
  (interactive)
  (set-frame-parameter frame 'alpha my-transparency))
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
(defun next-comment ()
  "Move point to next comment."
  (interactive)
  (search-forward comment-start nil t))
(defun previous-comment ()
  "Move point to previous comment."
  (interactive)
  (search-backward comment-start nil t))
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
(defun python/remove-unused-imports ()
  "Use autoflake to remove unused functions. From Spacemacs."
  (interactive)
  (if (executable-find "autoflake")
      (progn
        (shell-command (format "autoflake --remove-all-unused-imports -i %s"
                               (shell-quote-argument (buffer-file-name))))
        (revert-buffer t t t))
    (message "Error: Cannot find autoflake executable.")))
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
  "Rename current buffer and associated file (if it exists). Based on Spacemacs."
  (interactive)
  (let* ((name (buffer-name))
         (filename (buffer-file-name))
         (dir (file-name-directory filename))
         (new-name (read-file-name "New name: " dir)))
    (cond ((get-buffer new-name)
           (error "A buffer named '%s' already exists!" new-name))
          ((not (and filename (file-exists-p filename)))
           (rename-buffer new-name))
          (t
           (let ((dir (file-name-directory new-name)))
             (when (and (not (file-exists-p dir)) (yes-or-no-p (format "Create directory '%s'?" dir)))
               (make-directory dir t)))
           (rename-file filename new-name 1)
           (rename-buffer new-name)
           (set-visited-file-name new-name)
           (set-buffer-modified-p nil)
           (when (fboundp 'recentf-add-file)
             (recentf-add-file new-name)
             (recentf-remove-if-non-kept filename))
           (message "File '%s' successfully renamed to '%s'" name (file-name-nondirectory new-name))))))
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

;;;; Generic settings.
;; Enable transparency.
(add-to-list 'default-frame-alist (cons 'alpha my-transparency))
;; Use custom bitmap font set in fontconfig.
(add-to-list 'default-frame-alist
             (cons 'font
                   (concat (substring
                            (shell-command-to-string "fc-match bitmap family")
                            0 -1) " 13")))
;; Use Symbola for all other symbols.
(set-fontset-font t nil (font-spec :name "Symbola" :size 13))
(set-scroll-bar-mode nil)
(menu-bar-mode -1)
(tool-bar-mode -1)
(add-hook 'find-file-not-found-functions
          (lambda ()
            "Create non-existent parent directories and return nil."
            (let ((parent-dir (file-name-directory buffer-file-name)))
              (when (not (file-exists-p parent-dir))
                (make-directory parent-dir t)))
            nil))
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
              backup-directory-alist (list (cons "." (concat user-emacs-directory "backups/")))
              delete-old-versions t
              version-control t
              comment-auto-fill-only-comments t
              use-dialog-box nil
              ring-bell-function 'ignore
              display-buffer-alist '(("\\*help" (display-buffer-same-window)))
              ;; NOTE: Increase the power of two until performance no longer improves.
              gc-cons-threshold (* (expt 2 1) 800000)
              read-process-output-max (* 1024 1024)
              initial-buffer-choice (lambda ()
                                      "Get current buffer."
                                      (window-buffer (selected-window))))
