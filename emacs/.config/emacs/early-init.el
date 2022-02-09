;;; Startup optimisations.
(defvar old-file-name-handler-alist file-name-handler-alist
  "Original value of `file-name-handler-alist'.")
(defvar old-gc-cons-threshold gc-cons-threshold
  "Original value of `gc-cons-threshold'.")
(defvar old-gc-cons-percentage gc-cons-percentage
  "Original value of `gc-cons-percentage'.")
(setq file-name-handler-alist nil
      gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 1.0)
(add-hook 'emacs-startup-hook
          (lambda ()
            "Reset variables tampered by startup optimisations."
            (setq file-name-handler-alist old-file-name-handler-alist
                  ;; NOTE: Increase the power of two until performance no
                  ;; longer improves.
                  gc-cons-threshold (* (expt 2 2) old-gc-cons-threshold)
                  gc-cons-percentage old-gc-cons-percentage)
            (garbage-collect)) t)

;;; Frame customisations.
;; Disable menu bar.
(menu-bar-mode -1)
;; Disable scroll bar.
(scroll-bar-mode -1)
;; Disable tool bar.
(tool-bar-mode -1)
;; Enable transparency.
(defvar my/transparency '(90 . 80)
  "Cons of active and inactive frame alpha values, where 0 is fully transparent
and 100 is fully opaque.")
(add-to-list 'default-frame-alist (cons 'alpha my/transparency))
;; Set font in a daemon-compatible way.
(add-to-list 'default-frame-alist (cons 'font "Misc Tamsyn-12"))
             ;; XXX: Emacs' font lookup ignores OTB fonts despite supporting them,
             ;; so do the lookup yourself.
             ;; XXX: Unreliable if shell-command-to-string produces errors.
             ;; https://emacs.stackexchange.com/questions/21422/how-to-discard-stderr-when-running-a-shell-function
             ;(cons 'font (shell-command-to-string
                          ;"fc-match monospace -f %{family}-12")))
;; Fallback fonts. XXX: How many are absolutely necessary?
(dolist (font '(;;"Tamzen"
                ;;"Symbola"
                "Font Awesome 5 Free"
                ;;"FuraMono Nerd Font"
                )
              (set-fontset-font t nil font)))
