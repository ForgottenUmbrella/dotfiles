;;; Packages that I ended up not using.
;; Number windows for quick navigation with SPC-NUM.
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
;; Refactor C/C++ code.
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
;; Expand selected region. (Vim text objects are more precise.)
(use-package expand-region :ensure t
             :general
             (leader-def "v" 'er/expand-region))
;; Run your Python script as you type it.
(use-package live-py-mode :ensure t
             :general
             (:keymaps 'major-python-map
                       "l" 'live-py-mode))
;; Interactive ELisp interpreter.
(use-package ielm
  :general
  (:keymaps 'major-emacs-lisp-map
            "'" 'ielm))
;; Run ELisp tests.
(use-package ert
  :general
  (:keymaps 'major-emacs-lisp-map
            "t" 'ert))
;; Show a nice menu on startup. Probably the reason recentf is fucked up.
(use-package dashboard :ensure t
             :init
             (setq-default dashboard-startup-banner 'logo
                           dashboard-center-content t
                           show-week-agenda-p t
                           initial-buffer-choice (lambda ()
                                                   "Open `*dashboard*' in new frames."
                                                   (get-buffer "*dashboard*")))
             :config
             (dashboard-setup-startup-hook)
             (add-to-list 'dashboard-items '(projects) t))
;; Centre the only window. Buggy.
(use-package centered-window :ensure t
             :general
             (:keymaps 'leader-windows-map
                       "c" 'centered-window-mode))
;; Let the window manager handle multiple buffers in frames instead of windows.
;; Removed because it doesn't play well with company-quickhelp.
(use-package frames-only-mode :ensure t
             :config
             (frames-only-mode))
;; Enable system package dependency management. (Annoying TRAMP stuff when
;; updating in a headless fashion.)
(use-package use-package-ensure-system-package :ensure t)

;;; Replaced packages.
;; Make isearch more vim-like. (Replaced with evil-search module.)
(use-package isearch+ :load-path "lisp/"
             :config
             (dolist (item '(backward-kill-word beginning-of-line end-of-line))
               (add-to-list 'isearchp-initiate-edit-commands item)))
(general-define-key :keymaps 'isearch-mode-map
                    "<escape>" 'isearch-cancel
                    "C-n" 'isearch-ring-advance
                    "<down>" 'isearch-ring-advance
                    "C-p" 'isearch-ring-retreat
                    "<up>" 'isearch-ring-retreat
                    "C-g" 'isearch-repeat-forward
                    "C-j" 'isearch-repeat-forward
                    "C-t" 'isearch-repeat-backward
                    "C-k" 'isearch-repeat-backward)
;; Provide an ivy interface to correct typos with SPC-S. (Replaced with flyspell-popup.)
(use-package flyspell-correct-ivy :ensure t
             :init
             (setq-default flyspell-correct-interface 'flyspell-correct-ivy)
             :general
             (leader-def :keymaps 'flyspell-mode-map
               "S" 'flyspell-correct-next))
;; Auto-format Python code. (Replaced by lsp with python-language-server.)
(use-package yapfify :ensure t
             :ensure-system-package yapf
             :ghook '(python-mode-hook yapf-mode)
             :general
             (:keymaps 'major-python-map
                       "=" 'yapfify-buffer))
;; Augment Python mode. (Replaced by lsp with python-language-server.)
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
;; Integrate anaconda with company.
(use-package company-anaconda :ensure t
             :config
             (add-to-list 'company-backends 'company-anaconda))
;; Keep text wrapped with SPC-t-r. Prevents inserting spaces.
(use-package refill
  :general
  (:keymaps 'leader-toggles-map
            "r" 'refill-mode))
;; Augment TypeScript mode. (Replaced by lsp with javascript-typescript-langserver.)
(use-package tide :ensure t
             :ghook
             ('typescript-mode-hook '(tide-setup tide-hl-identifier-mode))
             ('before-save-hook 'tide-format-before-save))
;; Fold code blocks. (Replaced by hideshow.)
(use-package origami :ensure t
             :config
             (global-origami-mode))
;; Format C++ code. (Replaced by format-all.)
(use-package clang-format :ensure t
             :ghook
             ('c++-mode-hook
              (lambda ()
                "Format buffer with clang-format before save."
                (add-hook 'before-save-hook 'clang-format-buffer nil t))))
;; Format JavaScript code. (Replaced by format-all.)
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
;; LSP replacement, depends on eldoc, flymake and project.el (flycheck and
;; projectile not supported...)
(use-package eglot :ensure t
             :ghook ('prog-mode-hook 'eglot-ensure))
;; [-KEY and ]-KEY bindings for various pairs. (Replaced by implementation in
;; evil-collection.)
(use-package evil-unimpaired :after move-text
             :straight (evil-unimpaired :host github
                                        :repo "zmaas/evil-unimpaired"))
;; Adjust font size of all frames. (Replaced with face-remap.)
(use-package default-text-scale :ensure t)

;; TODO: Determine whether the below semantic packages really are replaced by lsp.
;; Show current function/class's signature at the top of the frame.
(use-package semantic
  :ghook
  'c++-mode-hook
  'js-mode-hook
  'kotlin-mode-hook
  'rustic-mode-hook
  :config
  (dolist (mode '(global-semantic-stickyfunc-mode
                  global-semantic-idle-local-symbol-highlight-mode))
    (add-to-list 'semantic-default-submodes mode))
  :general
  (:keymaps 'leader-toggles-map
            "C-s" 'semantic-mode))
;; Patch semantic to work with multi-line signatures.
(use-package stickyfunc-enhance :ensure t)
;; Show function argument list in echo area. Depends on semantic.
(use-package eldoc
  :ghook
  'prog-mode-hook
  :init
  (setq-default eldoc-echo-area-use-multiline-p nil))

;; TODO try this package
;; Built-in replacement for projectile.
(use-package project
  :config
  (set-keymap-parent leader-projects-map project-prefix-map))

;;; Currently unmaintained packages.
;; Add auto-complete support for JavaScript. (Repo was deleted.)
(use-package company-tern :ensure t
             :config
             (if (executable-find "tern")
                 (add-to-list 'company-backends 'company-tern)
               (message "tern is not installed; install for JavaScript auto-completion")))
;; Find out why Emacs is slow with SPC-a-t.
(use-package explain-pause-mode
  :straight (explain-pause-mode :host github
                                :repo "lastquestion/explain-pause-mode")
  :config
  ;;(explain-pause-mode)  ; Disabled for now, due to weird bugs?
  :general
  (:keymaps 'leader-applications-map
   "t" 'explain-pause-top))
;; Navigate TODO items in a project.
(use-package doom-todo-ivy
  :ghook ('after-init-hook 'doom-todo-ivy)
  :general
  (:keymaps 'leader-jumps-map
   "T" 'doom/ivy-tasks))
