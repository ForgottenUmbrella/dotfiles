(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(haskell-mode flyspell-popup company-flow explain-pause-mode tide restart-emacs rustic annalist exec-path-from-shell company-lsp lsp-ui lsp-mode multi-line cdlatex ivy-prescient prescient precient tagedit pipenv ivy-hydra outshine doom-themes fill-column-indicator auto-package-update ewal-evil-cursors origami yasnippet-snippets yapfify winum which-key web-beautify use-package-ensure-system-package terminal-here systemd stickyfunc-enhance srefactor spaceline rainbow-mode rainbow-identifiers rainbow-delimiters py-isort pretty-hydra move-text live-py-mode kotlin-mode insert-shebang hl-todo highlight-indent-guides git-gutter-fringe general flyspell-correct-ivy flycheck-pos-tip flycheck-checkbashisms fish-mode expand-region ewal-spacemacs-themes evil-visualstar evil-surround evil-snipe evil-org evil-numbers evil-matchit evil-magit evil-indent-plus evil-escape evil-commentary evil-collection evil-cleverparens evil-args dumb-jump counsel-projectile company-tern company-statistics company-shell company-quickhelp company-c-headers company-auctex company-anaconda cmake-project cmake-mode clang-format anzu aggressive-indent))
 '(safe-local-variable-values
   '((flycheck-disabled-checkers quote
                                 (c/c++-clang))
     (flycheck-disabled-checkers . emacs-lisp)
     (eval add-hook 'after-save-hook
           (lambda nil "Remind to commit dotfile changes"
             (message "Remember to commit changes!"))
           nil t)
     (flycheck-disabled-checkers quote
                                 (emacs-lisp-checkdoc))))
 '(show-paren-mode t)
 '(warning-suppress-log-types '((comp)))
 '(which-key-mode t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(evil-ex-substitute-matches ((t (:inherit diff-removed :foreground unspecified :background unspecified))))
 '(evil-ex-substitute-replacement ((t (:inherit diff-added :foreground unspecified :background unspecified))))
 '(evil-traces-change ((t (:inherit diff-removed))))
 '(evil-traces-copy-preview ((t (:inherit diff-added))))
 '(evil-traces-copy-range ((t (:inherit diff-changed))))
 '(evil-traces-delete ((t (:inherit diff-removed))))
 '(evil-traces-global-match ((t (:inherit diff-added))))
 '(evil-traces-global-range ((t (:inherit diff-changed))))
 '(evil-traces-join-indicator ((t (:inherit diff-added))) t)
 '(evil-traces-join-range ((t (:inherit diff-changed))))
 '(evil-traces-move-preview ((t (:inherit diff-added))))
 '(evil-traces-move-range ((t (:inherit diff-removed))))
 '(evil-traces-normal ((t (:inherit diff-changed))))
 '(evil-traces-shell-command ((t (:inherit diff-changed))))
 '(evil-traces-substitute-range ((t (:inherit diff-changed))))
 '(evil-traces-yank ((t (:inherit diff-changed))))
 '(highlight ((t (:background unspecified))))
 '(ivy-highlight-face ((t (:inherit unspecified))))
 '(org-todo ((t (:background unspecified))))
 '(window-divider-first-pixel ((t (:inherit window-divider))))
 '(window-divider-last-pixel ((t (:inherit window-divider)))))
