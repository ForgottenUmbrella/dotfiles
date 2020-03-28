;; Remind to commit changes in dotfiles.

((nil . ((eval . (add-hook 'after-save-hook
                           (lambda ()
                             "Remind to commit dotfile changes"
                             (message "Remember to commit changes!"))
                           nil t)))))

;; Some Emacs co-maintainer is stubborn and somehow equates separation of
;; concerns (elisp data vs elisp code/"data that can be evaluated as code" per
;; said maintainer's pedantry) with fragmentation, so disable Flycheck until a
;; proper elisp-data-mode gets added.
;; > but muh gut feeling
;; Local Variables:
;; flycheck-disabled-checkers: emacs-lisp
;; End:
