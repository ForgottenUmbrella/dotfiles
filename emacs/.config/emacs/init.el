;;; Set up customisation.
;; Save custom.el in $XDG_CONFIG_HOME instead of cluttering $HOME.
;; NOTE: `setq' sets a buffer-local variable locally,
;; whereas `setq-default' sets a buffer-local variable globally.
;; Both forms may set ordinary (global) variables, but `setq' is terser.
(setq custom-file (concat user-emacs-directory "custom.el"))
(load custom-file t)

;;; Define helper functions.
(defun warn-missing (package purpose predicate)
  "Warn if PACKAGE is missing according to PREDICATE for given PURPOSE."
  (unless (funcall predicate)
    (warn "%s is not installed; install for %s" package purpose)))
(defun warn-missing-executable (package command purpose)
  "Warn if COMMAND from PACKAGE is not available for the given PURPOSE."
  (warn-missing package purpose (lambda ()
                                  "Check if COMMAND is present."
                                  (executable-find command))))
(defun warn-missing-hook-executable (package command purpose hook)
  "Warn on HOOK if COMMAND from PACKAGE is not available for the given PURPOSE."
  (add-hook hook
            (lambda ()
              "Warn missing executable."
              (warn-missing-executable package command purpose))))
(defun warn-missing-file (package file purpose)
  "Warn if system PACKAGE providing FILE is not available for PURPOSE."
  (warn-missing package purpose (lambda ()
                                  "Check if FILE is present."
                                  (file-exists-p file))))

;;; Set up packages.
;; Enable additional package repos.
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(add-to-list 'package-archives '("org" . "https://orgmode.org/elpa/") t)
;; Pre-compute autoloads to activate packages quickly.
(setq package-quickstart t)

;;;; Bootstrap package management with straight.
;; Must be before the bootstrap to have an effect.
(defvar straight-check-for-modifications nil "Avoid checking for local changes.")
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

;;;; Set up package management.
;; Provide key-binding commands and :g(f)hook options to use-package.
;; NOTE: Include `:demand t' if you use :general or :g(f)hook but still need the
;; external package or its :config to be loaded. Also, some (but not all)
;; built-in packages need :demand if you use :general-bind.
;; NOTE: :ghook adds the package mode to the given hook, whereas :gfhook adds
;; the given function to the package's own hook.
(use-package general :ensure t)
;; Provide `auto-package-update-now' to update packages.
(use-package auto-package-update :ensure t
  ;; Ensure `load-path' is updated.
  :gfhook
  ('auto-package-update-after-hook 'package-quickstart-refresh)
  :custom
  (auto-package-update-hide-results t "Don't show update results.")
  (auto-package-update-delete-old-versions t "Delete old package versions."))

;;; Install packages.
;;;; Make binding keys sane.
;; Definer for top-level keys prefixed by the leader key (SPC).
(general-create-definer leader-def
  :states '(motion normal insert emacs)
  :keymaps 'override
  :prefix "SPC"
  :non-normal-prefix "M-SPC"
  :prefix-command 'leader-map)
;; Definer for second-level prefix maps prefixed by the leader map.
(general-create-definer leader-prefix-def
  :keymaps 'leader-map
  :wk-full-keys nil)
;; Definer for things prefixed by the major leader key (,).
(general-create-definer major-prefix-def
  :states '(motion insert emacs)
  :prefix ","
  :non-normal-prefix "M-,"
  "" '(:ignore t :which-key "major"))
;; Make hydra bindings pretty.
(use-package pretty-hydra :ensure t)

;;;; Set up built-ins.
(use-package emacs :demand t
  :init
  (defvar my/transparency)  ;; Defined in early-init.el
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
  (defun unfill-region (beg end)
    "Unfill the region, joining text paragraphs into a single
    logical line.  This is useful, e.g., for use with
    `visual-line-mode'.

   From https://www.emacswiki.org/emacs/UnfillRegion"
    (interactive "*r")
    (let ((fill-column (point-max)))
      (fill-region beg end)))
  (defun yank-buffer-delete-frame ()
    "Copy contents of current buffer and close its frame."
    (interactive)
    (clipboard-kill-region (goto-char (point-min)) (goto-char (point-max)))
    (delete-file (buffer-file-name))
    (delete-frame))
  (defun yes-or-no-p->-y-or-n-p (orig-fun &rest r)
    "Advice around a function to replace `yes-or-no-p' with `y-or-n-p'.

From https://christiantietze.de/posts/2020/10/shorten-yes-or-no-emacs/"
    (cl-letf (((symbol-function 'yes-or-no-p) #'y-or-n-p))
      (apply orig-fun r)))
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
  (defun Fuco1/lisp-indent-function (indent-point state)
    "This function is the normal value of the variable `lisp-indent-function'.
The function `calculate-lisp-indent' calls this to determine
if the arguments of a Lisp function call should be indented specially.
INDENT-POINT is the position at which the line being indented begins.
Point is located at the point to indent under (for default indentation);
STATE is the `parse-partial-sexp' state for that position.
If the current line is in a call to a Lisp function that has a non-nil
property `lisp-indent-function' (or the deprecated `lisp-indent-hook'),
it specifies how to indent.  The property value can be:
* `defun', meaning indent `defun'-style
  \(this is also the case if there is no property and the function
  has a name that begins with \"def\", and three or more arguments);
* an integer N, meaning indent the first N arguments specially
  (like ordinary function arguments), and then indent any further
  arguments like a body;
* a function to call that returns the indentation (or nil).
  `lisp-indent-function' calls this function with the same two arguments
  that it itself received.
This function returns either the indentation to use, or nil if the
Lisp function does not specify a special indentation.

From https://github.com/Fuco1/.emacs.d/blob/master/site-lisp/my-redef.el"
    (let ((normal-indent (current-column))
          (orig-point (point)))
      (goto-char (1+ (elt state 1)))
      (parse-partial-sexp (point) calculate-lisp-indent-last-sexp 0 t)
      (cond
       ;; car of form doesn't seem to be a symbol, or is a keyword
       ((and (elt state 2)
             (or (not (looking-at "\\sw\\|\\s_"))
                 (looking-at ":")))
        (if (not (> (save-excursion (forward-line 1) (point))
                    calculate-lisp-indent-last-sexp))
            (progn (goto-char calculate-lisp-indent-last-sexp)
                   (beginning-of-line)
                   (parse-partial-sexp (point)
                                       calculate-lisp-indent-last-sexp 0 t)))
        ;; Indent under the list or under the first sexp on the same
        ;; line as calculate-lisp-indent-last-sexp.  Note that first
        ;; thing on that line has to be complete sexp since we are
        ;; inside the innermost containing sexp.
        (backward-prefix-chars)
        (current-column))
       ((and (save-excursion
               (goto-char indent-point)
               (skip-syntax-forward " ")
               (not (looking-at ":")))
             (save-excursion
               (goto-char orig-point)
               (looking-at ":")))
        (save-excursion
          (goto-char (+ 2 (elt state 1)))
          (current-column)))
       (t
        (let ((function (buffer-substring (point)
                                          (progn (forward-sexp 1) (point))))
              method)
          (setq method (or (function-get (intern-soft function)
                                         'lisp-indent-function)
                           (get (intern-soft function) 'lisp-indent-hook)))
          (cond ((or (eq method 'defun)
                     (and (null method)
                          (> (length function) 3)
                          (string-match "\\`def" function)))
                 (lisp-indent-defform state indent-point))
                ((integerp method)
                 (lisp-indent-specform method state
                                       indent-point normal-indent))
                (method
                 (funcall method indent-point state))))))))
  :general
  ;; Insert state.
  (:states 'insert
   "C-q" 'quoted-insert
   "C-S-q" 'insert-char)
  ;; Emacs Lisp mode.
  (major-prefix-def :prefix-command 'major-emacs-lisp-map
    :keymaps 'emacs-lisp-mode-map
    "c" 'emacs-lisp-byte-compile)
  (:prefix-command 'major-emacs-lisp-eval-map
   :keymaps 'major-emacs-lisp-map :prefix "e"
   :wk-full-keys nil
   "" '(:ignore t :which-key "eval")
   "b" 'eval-buffer
   "e" 'eval-last-sexp
   "r" 'eval-region
   "f" 'eval-defun)
  (:prefix-command 'major-emacs-lisp-help-map
   :keymaps 'major-emacs-lisp-map :prefix "h"
   :wk-full-keys nil
   "" '(:ignore t :which-key "help"))
  ;; Help mode.
  (:keymaps 'help-mode-map :states 'normal
   "[" 'help-go-back
   "]" 'help-go-forward)
  ;; Leader key.
  (leader-def "SPC" 'execute-extended-command
    "?" 'describe-bindings
    "<F1>" 'apropos-command
    "u" 'universal-argument)
  (leader-prefix-def :prefix-command 'leader-applications-map
    :prefix "a"
    "" '(:ignore t :which-key "applications")
    "p" 'list-processes)
  (:prefix-command 'leader-applications-shell-map
   :keymaps 'leader-applications-map :prefix "s"
   :wk-full-keys nil
   "" '(:ignore t :which-key "shell"))
  (leader-prefix-def :prefix-command 'leader-buffers-map :prefix "b"
    "" '(:ignore t :which-key "buffers")
    "C" 'clone-indirect-buffer
    "c" 'clone-buffer
    "d" 'kill-buffer
    "h" 'switch-to-help-buffer
    "m" 'switch-to-messages-buffer
    "n" 'next-buffer
    "p" 'previous-buffer
    "R" 'revert-buffer
    "r" 'read-only-mode
    "s" 'switch-to-scratch-buffer
    "w" 'switch-to-warnings-buffer
    "x" 'kill-buffer-and-window
    "y" 'copy-whole-buffer-to-clipboard)
  (leader-prefix-def :prefix-command 'leader-compile-map :prefix "c"
    "" '(:ignore t :which-key "compile"))
  (leader-prefix-def :prefix-command 'leader-errors-map :prefix "e"
    "" '(:ignore t :which-key "errors")
    "n" 'next-error
    "p" 'previous-error)
  (leader-prefix-def :prefix-command 'leader-files-map :prefix "f"
    "" '(:ignore t :which-key "files")
    "c" 'write-file
    "D" 'delete-current-buffer-file
    "f" 'find-file
    "o" 'open-file-or-directory-in-external-app
    "R" 'rename-current-buffer-file
    "s" 'save-buffer
    "w" 'write-file)
  (:prefix-command 'leader-files-convert-map
   :keymaps 'leader-files-map :prefix "C"
   :wk-full-keys nil
   "" '(:ignore t :which-key "convert")
   "d" 'unix2dos
   "u" 'dos2unix
   "s" 'untabify)
  (:prefix-command 'leader-files-emacs-map
   :keymaps 'leader-files-map :prefix "e"
   :wk-full-keys nil
   "" '(:ignore t :which-key "emacs")
   "d" 'find-init-file
   "r" 'reload-init-file)
  (leader-prefix-def :prefix-command 'leader-frames-map :prefix "F"
    "" '(:ignore t :which-key "frames")
    "d" 'delete-frame
    "o" 'other-frame
    "n" 'make-frame)
  (:prefix-command 'leader-frame-tabs-map
   :keymaps 'leader-frames-map :prefix "t"
   :wk-full-keys nil
   "" '(:ignore t :which-key "tabs"))
  (leader-prefix-def :prefix-command 'leader-git-map :prefix "g"
    "" '(:ignore t :which-key "git"))
  (leader-prefix-def :prefix-command 'leader-help-map :prefix "h"
    "" '(:ignore t :which-key "help"))
  (:prefix-command 'leader-help-describe-map
   :keymaps 'leader-help-map :prefix "d"
   :wk-full-keys nil
   "" '(:ignore t :which-key "describe")
   "B" 'general-describe-keybindings
   "F" 'describe-font
   "M" 'describe-minor-mode
   "T" 'describe-theme
   "C-F" 'describe-face)
  (leader-prefix-def :prefix-command 'leader-jumps-map :prefix "j"
    "" '(:ignore t :which-key "jumps"))
  (leader-prefix-def :prefix-command 'leader-narrow-map :prefix "n"
    "" '(:ignore t :which-key "narrow")
    "r" 'narrow-to-region
    "w" 'widen)
  (leader-prefix-def :prefix-command 'leader-projects-map :prefix "p"
    "" '(:ignore t :which-key "projects"))
  (:prefix-command 'leader-projects-sessions-map
   :keymaps 'leader-projects-map :prefix "s"
   :wk-full-keys nil
   "" '(:ignore t :which-key "sessions")
   "s" 'desktop-save
   "r" 'desktop-read)
  (leader-prefix-def :prefix-command 'leader-quit-map :prefix "q"
    "" '(:ignore t :which-key "quit")
    "q" 'save-buffers-kill-emacs
    "Q" 'kill-emacs
    "y" 'yank-buffer-delete-frame)
  (leader-prefix-def :prefix-command 'leader-search-map :prefix "s"
    "" '(:ignore t :which-key "search")
    "o" 'occur
    "P" 'check-parens)
  (leader-prefix-def :prefix-command 'leader-toggles-map :prefix "t"
    "" '(:ignore t :which-key "toggles")
    "D" 'toggle-debug-on-error
    "d" 'toggle-selective-display
    "F" 'auto-fill-mode
    "L" 'visual-line-mode
    "l" 'toggle-truncate-lines
    "P" 'prettify-symbols-mode
    "W" 'toggle-whitespace-cleanup)
  (:prefix-command 'leader-toggles-colours-map
   :keymaps 'leader-toggles-map :prefix "c"
   :wk-full-keys nil
   "" '(:ignore t :which-key "colours"))
  (leader-prefix-def :prefix-command 'leader-themes-map :prefix "T"
    "" '(:ignore t :which-key "themes")
    "T" 'hydra-transparency/body)
  (leader-prefix-def :prefix-command 'leader-windows-map :prefix "w"
    "" '(:ignore t :which-key "windows")
    "<tab>" 'alternate-window
    "T" 'undedicate-window)
  (leader-prefix-def :prefix-command 'leader-zoom-map :prefix "z"
    "" '(:ignore t :which-key "zoom"))
  :ghook
  ;; Automatically hard-wrap text.
  ('(text-mode-hook prog-mode-hook) 'auto-fill-mode)
  :gfhook
  ('find-file-not-found-functions
   (lambda ()
     "Create non-existent parent directories and return nil."
     (let ((parent-dir (file-name-directory buffer-file-name)))
       (when (not (file-exists-p parent-dir))
         (make-directory parent-dir t)))
     nil))
  ('emacs-lisp-mode-hook
   (lambda ()
     "Maybe fix sporadic elisp indentation."
     (setq-local lisp-indent-function 'Fuco1/lisp-indent-function)))
  ('kill-emacs-hook 'desktop-save-in-desktop-dir)
  :config
  (pixel-scroll-mode)
  (auto-save-visited-mode)
  :custom
  (scroll-conservatively 101 "Don't disruptively recentre point.")
  (scroll-margin 2 "Keep cursor away from very top or bottom.")
  (mouse-wheel-progressive-speed nil "Don't accelerate scrolling.")
  (mouse-wheel-scroll-amount '(1 ((shift) . 1) ((control)))
                             "Scroll one line at a time.")
  (prettify-symbols-unprettify-at-point t "Show original symbol at point.")
  (indicate-empty-lines t
                        "Differentiate EOF from empty lines.")
  (fill-column 80 "Wrap at 80th character.")
  (indent-tabs-mode nil "Never use tabs for indentation.")
  (read-quoted-char-radix 16
                          "Allow inserting characters by hex value.")
  (frame-resize-pixelwise t "Allow proper frame maximisation.")
  (initial-major-mode 'text-mode "Start scratch buffer in text mode.")
  (major-mode 'text-mode "Start file-less buffers in text mode.")
  (require-final-newline t "Ensure files terminate properly.")
  (help-window-select t "Focus help window on summon.")
  (delete-by-moving-to-trash t "Delete files safely by trashing.")
  (sentence-end-double-space nil "Don't use archaic double spaces.")
  (window-combination-resize t "Always succeed splitting.")
  (initial-scratch-message nil "Start with scratch buffer empty.")
  (open-paren-in-column-0-is-defun-start nil "Don't assume any open bracket on column 0 is a function definition.")
  (backup-directory-alist (list (cons "." (concat user-emacs-directory
                                                  "backups/")))
                          "Save backups in a central directory.")
  (delete-old-versions t "Automatically delete old backups.")
  (version-control t "Number backup files.")
  (ring-bell-function 'ignore "Don't sound the bell.")
  (initial-buffer-choice (lambda ()
                           "Get current buffer."
                           (window-buffer (selected-window)))
                         "Open current buffer in new frames.")
  (large-file-warning-threshold (* 1000 1000) "Warn of 1MB files.")
  (confirm-kill-processes nil "Silently kill processes.")
  (frame-title-format "%* %b"
                      "Show buffer name & status in frame title.")
  (mode-line-format nil "Don't show mode line.")
  (bidi-paragraph-direction 'left-to-right
                            "Avoid text direction detection.")
  (bidi-inhibit-bpa t "Don't bother rendering right-to-left text.")
  (display-buffer-alist
   '((".*" .
      ((display-buffer-reuse-window display-buffer-same-window) .
       ((reusable-frames . t)))))
   "Try to reuse existing windows, else use current window.")
  (even-window-sizes nil "Don't resize windows.")
  (isearch-regexp-lax-whitespace t "Search across lines")
  (search-whitespace-regexp "[ \t\r\n]+" "Ignore all whitespace when searching"))
(set-keymap-parent leader-help-describe-map help-map)

;;;; Join the dark side.
;; Vim keys.
(use-package evil :ensure t :demand t :after undo-tree
  :custom
  (evil-want-C-u-scroll t "Replace Emacs's C-u with Vim scrolling.")
  (evil-want-Y-yank-to-eol t "Differentiate Y and yy for yanking.")
  (evil-want-visual-char-semi-exclusive t
                                        "Make visual mode less confusing.")
  (evil-ex-substitute-global t "Substitute globally by default.")
  (evil-vsplit-window-right t "Vertically split to the right.")
  (evil-split-window-below t "Horizontally split below.")
  (evil-cross-lines t "Allow horizontal movement to other lines.")
  ;; XXX: Doesn't work: emacs-evil/evil#188
  (evil-respect-visual-line-mode t "Respect visual line mode.")
  (evil-auto-balance-windows nil
                             "Don't spontaneously resize windows.")
  (evil-symbol-word-search t
                           "Operate * and # on words instead of symbols.")
  (evil-search-module 'evil-search
                      "Use evil's search module instead of Emacs's.")
  (evil-want-keybinding nil
                        "Required to add evil-collection keybindings.")
  (evil-undo-system 'undo-tree "Use undo-tree for undo until Emacs 28.")
  (evil-ex-visual-char-range t "Default to substituting in actual selection.")
  :config
  (evil-mode)
  (set-keymap-parent leader-windows-map evil-window-map)
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
  (defun tiny-window ()
    "Resize current window to be as small as possible."
    (interactive)
    (evil-resize-window 1))
  (defun small-window ()
    "Resize current window to be fairly small."
    (interactive)
    (evil-resize-window 10))
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
      ("=" balance-windows "balance"))))
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
   "C-z" nil)  ;; Disable accidental Emacs state entry.
  (:keymaps 'evil-ex-search-keymap
   "C-w" 'backward-kill-word)
  (leader-def "<tab>" 'evil-switch-to-windows-last-buffer)
  (:keymaps 'leader-files-map
   "S" 'evil-write-all)
  (:keymaps 'leader-search-map
   "c" 'evil-ex-nohighlight)
  (:keymaps 'leader-windows-map
   "0" 'small-window
   "1" 'tiny-window
   "d" 'evil-quit
   "." 'hydra-window/body))
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
  (evil-move-beyond-eol t "Required to keep parentheses balanced (luxbock/evil-cleverparens#29).")
  :general
  (:keymaps 'evil-cleverparens-mode-map :states 'normal
   "C-(" 'evil-cp-<
   "C-)" 'evil-cp->)
  (:keymaps 'evil-cleverparens-mode-map
   :states '(normal visual operator)
   "_" nil
   "s" nil
   "x" nil
   "<" nil
   ">" nil))
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
(use-package evil-collection :ensure t :after evil
  :custom
  (evil-collection-magit-want-horizontal-movement t "Allow horizontal movement.")
  (evil-collection-magit-use-z-for-folds t "Don't hijack Vim z.")
  :init
  (evil-collection-init)
  :config
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
   "] c" 'next-comment
   "[ q" 'evil-collection-unimpaired-previous-error
   "] q" 'evil-collection-unimpaired-next-error)
  (:states 'visual
   "[ e" ":move'<--1"
   "] e" ":move'>+1")
  (:keymaps 'help-mode-map :states 'normal
   "C-o" nil
   "C-i" nil))
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
;; View contents of registers before using them with " (normal) or C-r (insert).
(use-package evil-owl :ensure t
  :init
  (setq-default evil-owl-idle-delay 0.4)
  :config
  (evil-owl-mode))
;; Preview ALL the ex mode commands.
(use-package evil-traces :ensure t
  :config
  (evil-traces-use-diff-faces)
  (evil-traces-mode))

;;;; Aesthetics.
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
   "t" 'hl-todo-mode))
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
  (advice-add 'git-gutter:stage-hunk :around 'yes-or-no-p->-y-or-n-p)
  (global-git-gutter-mode)
  :general
  (:keymaps 'leader-git-map
   "d" 'git-gutter:popup-hunk
   "h" 'git-gutter:stage-hunk
   "H" 'git-gutter:update-all-windows
   "n" 'git-gutter:next-hunk
   "p" 'git-gutter:previous-hunk
   "x" 'git-gutter:revert-hunk)
  (:states 'motion
   "[ h" 'git-gutter:previous-hunk
   "] h" 'git-gutter:next-hunk))
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
  :ghook 'prog-mode-hook
  :config
  (warn-missing-file "otf-fira-code-symbol"
                     "/usr/share/fonts/OTF/FiraCode-Regular-Symbol.otf"
                     "ligatures"))
;; Soft-wrap at fill-column when visual-line-mode is on.
(use-package visual-fill-column :ensure t
  :ghook 'visual-line-mode)
;; Icons for company mode.
(use-package company-box :ensure t
  :ghook 'company-mode)
;; Icons for ivy mode. Run `all-the-icons-install-fonts' once for installation.
(use-package all-the-icons-ivy-rich :ensure t :after counsel-projectile
  :config
  (all-the-icons-ivy-rich-mode t))
;; Google style guides.
(use-package google-c-style :ensure t
  :ghook ('c-mode-common-hook '(google-set-c-style gogle-make-newline-indent)))

;;;;; Themes.
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

;;;; Navigation.
;; Show available key bindings on wait.
(use-package which-key :ensure t :demand t
  :custom
  (which-key-idle-delay 0.4
                        "How long to wait before showing keybindings.")
  (which-key-sort-order 'which-key-key-order-alpha
                        "Sort keybindings alphabetically.")
  (which-key-allow-evil-operators t "Remind of custom Vim objects.")
  :config
  (which-key-mode)
  (advice-add 'which-key--show-popup
              :around (lambda (f &rest r)
                        "Add extra line to work around issue #231."
                        (apply f (list (cons (+ 1 (car (car r))) (cdr (car r)))))))
  :general
  (:keymaps 'leader-help-map
   "k" 'which-key-show-top-level
   "m" 'which-key-show-major-mode)
  (:keymaps 'leader-toggles-map
   "K" 'which-key))
;; Enable undoing window management with SPC-w-u.
(use-package winner :demand t
  :config
  (winner-mode)
  (defun toggle-fullscreen-window ()
    "Toggle between deleting other windows and undoing the deletion."
    (interactive)
    (if (eql (length (window-list)) 1)
        (winner-undo)
      (delete-other-windows)))
  (pretty-hydra-define+ hydra-window nil
    ("History"
     (("u" winner-undo "undo")
      ("U" winner-redo "redo"))))
  :general
  (:keymaps 'leader-windows-map
   "u" 'winner-undo
   "U" 'winner-redo))
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
  (display-line-numbers-type 'visual
                             "Show relative line numbers that work nicely with folds.")
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
(use-package undo-tree :ensure t :demand t
  :ghook ('evil-local-mode-hook 'turn-on-undo-tree-mode)
  :general
  (:keymaps 'leader-applications-map
   "u" 'undo-tree-visualize)
  :config
  (global-undo-tree-mode))
;; Navigate to recent files with SPC-f-r.
(use-package recentf
  :custom
  (recentf-max-saved-items 1024 "Save more recent file history.")
  (recentf-exclude (list (expand-file-name package-user-dir)
                         (lambda (path)
                           "Return whether the path is not in HOME."
                           (not (string-match-p abbreviated-home-dir path))))
                   "Exclude irrelevant files from recentf.")
  :config
  (recentf-mode)
  (run-at-time t 300 'recentf-save-list))
;; Clear old buffers with SPC-b-x.
(use-package midnight
  :general
  (:keymaps 'leader-buffers-map
   "X" 'clean-buffer-list))
;; Fold code blocks.
(use-package hideshow
  :ghook
  ('prog-mode-hook 'hs-minor-mode))
;; Fold comment headings.
(use-package outline
  :general
  (:keymaps 'outline-mode-map :states 'normal
   "z b" nil)
  (:keymaps 'outline-minor-mode-map :states 'normal
   "M-h" 'outline-promote
   "M-j" 'outline-move-subtree-down
   "M-k" 'outline-move-subtree-up
   "M-l" 'outline-demote
   "M-RET" 'outline-insert-heading)
  (:keymaps 'outline-minor-mode-map :states 'motion
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
;; Manage projects with SPC-p.
(use-package projectile :ensure t :demand t
  :custom
  (projectile-completion-system 'ivy "Use ivy for completion.")
  (projectile-sort-order 'recentf
                         "Sort projects by how recent they are.")
  (projectile-use-git-grep t "Only search indexed files.")
  :config
  (projectile-mode)
  (set-keymap-parent leader-projects-map projectile-command-map)
  :general
  (:keymaps 'major-cc-goto-map
   "a" 'projectile-find-other-file
   "A" 'projectile-find-other-file-other-window))
;; Integrate projectile with ivy.
(use-package counsel-projectile :ensure t :demand t
  :config
  (counsel-projectile-mode))
;; Follow symlinks when editing version-controlled files.
(use-package vc
  :custom
  (vc-handled-backends '(Git) "Don't load other version control systems.")
  (vc-follow-symlinks t "Follow symlinks when opening files."))
;; Group buffers into a frame using frame tabs.
(use-package tab-bar
  :general
  (:keymaps 'leader-toggles-map
   "t" 'toggle-tab-bar-mode-from-frame)
  (:keymaps 'leader-frame-tabs-map
   "<tab>" 'tab-bar-switch-to-recent-tab
   "j" 'tab-bar-switch-to-prev-tab
   "k" 'tab-bar-switch-to-next-tab
   "n" 'tab-bar-new-tab
   "t" 'tab-bar-switch-to-tab
   "x" 'tab-bar-close-tab
   "X" 'tab-bar-undo-close-tab))
;; Skip whitespace with M-h/k/j/l, like indentation-based navigation.
(use-package spatial-navigate :ensure t
  :general
  (:states 'motion
   "M-h" 'spatial-navigate-backward-horizontal-box
   "M-j" 'spatial-navigate-forward-vertical-box
   "M-k" 'spatial-navigate-backward-vertical-box
   "M-l" 'spatial-navigate-forward-horizontal-box))

;;;; Completion.
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
(use-package ivy-rich :ensure t :after all-the-icons-ivy-rich
  :config
  (ivy-rich-mode t))
;; Replace built-in commands with ivy.
(use-package counsel :ensure t :demand t
  :custom
  (counsel-grep-base-command "rg -i -M 120 --no-heading --line-number --color never '%s' %s"
                             "Use rg instead of grep.")
  :config
  (counsel-mode t)
  (warn-missing-executable "ripgrep" "rg" "Counsel searching")
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
  (company-idle-delay nil "Only auto-complete on request.")
  (company-minimum-prefix-length 1
                                 "Complete even a single character.")
  (company-format-margin-function 'company-detect-icons-margin
                                  "Iconify completion")
  :config
  (global-company-mode)
  :general
  (:states 'insert
   "C-SPC" 'company-complete)
  (:keymaps '(company-active-map company-search-map)
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
  (warn-missing-hook-executable "flow" "flow"
                                "JavaScript auto-completion"
                                'js-mode-hook))
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
  (cdlatex-paired-parens "$([{"
                         "Pair all the things.")
  (cdlatex-math-modify-prefix nil "Don't override apostrophe key.")
  (cdlatex-math-symbol-prefix nil "Don't override backtick key.")
  :ghook
  'LaTeX-mode-hook)

;;;; Correction.
;; Highlight errors.
(use-package flycheck :ensure t :demand t
  :custom
  (flycheck-disabled-checkers '(emacs-lisp-checkdoc)
                              "Don't complain about arcane ELisp conventions.")
  :config
  (global-flycheck-mode)
  (warn-missing-hook-executable "cppcheck" "cppcheck" "C++ linting"
                                'c++-mode-hook)
  (warn-missing-hook-executable "eslint" "eslint"
                                "JavaScript linting"
                                'js-mode-hook)
  (warn-missing-hook-executable "shellcheck" "shellcheck"
                                "shell script linting" 'sh-mode-hook)
  (warn-missing-hook-executable "python-pylint" "pylint"
                                "Python linting" 'python-mode-hook)
  (warn-missing-hook-executable "mypy" "mypy" "Python type-checking"
                                'python-mode-hook)
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
  (:keymaps 'leader-errors-map
   "b" 'flycheck-buffer
   "c" 'flycheck-clear
   "h" 'flycheck-describe-checker
   "L" 'goto-flycheck-error-list
   "l" 'toggle-flycheck-error-list
   "S" 'flycheck-set-checker-executable
   "s" 'flycheck-select-checker
   "v" 'flycheck-verify-setup
   "y" 'flycheck-copy-errors-as-kill)
  (:keymaps 'leader-toggles-map
   "s" 'flycheck-mode))
;; Show errors in a popup.
(use-package flycheck-pos-tip :ensure t
  :config
  (flycheck-pos-tip-mode))
;; Ensure indentation is correct.
(use-package aggressive-indent :ensure t :demand t
  :config
  (global-aggressive-indent-mode)
  (add-to-list 'aggressive-indent-excluded-modes 'kotlin-mode)
  :general
  (:keymaps 'leader-toggles-map
   "I" 'aggressive-indent-mode))
;; Ensure parentheses match.
(use-package smartparens :ensure t :demand t
  :ghook
  'eval-expression-minibuffer-setup-hook
  ;; XXX: Tag handling is broken: Fuco1/smartparens#397
  ('(nxml-mode-hook html-mode-hook) 'turn-off-smartparens-mode)
  :custom
  (sp-escape-quotes-after-insert nil "Don't escape quotes.")
  (sp-show-pair-from-inside t "Always highlight pairs.")
  :config
  (require 'smartparens-config)
  (smartparens-global-mode)
  (show-smartparens-global-mode)
  (sp-local-pair 'minibuffer-inactive-mode "'" nil :actions nil)
  (sp-local-pair 'conf-mode "Section" "EndSection")
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
   "S" 'flyspell-mode)
  (:keymaps 'flyspell-mode-map
   ;; Don't accidentally autocorrect words when trying to escape insert mode.
   "C-;" nil))
;; Correct typos with SPC-S.
(use-package flyspell-popup :ensure t
  :general
  (leader-def :keymaps 'flyspell-mode-map
    "S" 'flyspell-popup-correct))
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
;; Trim only your own trailing whitespace.
(use-package ws-butler :ensure t
  :config
  (ws-butler-global-mode))
;; Format all the code.
(use-package format-all :ensure t
  :ghook 'prog-mode-hook)
;; Show error at point.
(use-package help-at-pt :demand t
  :custom
  (help-at-pt-display-when-idle t "Show error at point.")
  :general
  (:keymaps 'leader-errors-map
   "d" 'display-local-help))

;;;; Major modes.
;; Org mode.
(use-package org :ensure org-plus-contrib
  :gfhook
  'toggle-truncate-lines
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
  (org-M-RET-may-split-line '((default . nil))
                            "Insert new lines instead of splitting with M-RET")
  :init
  (setq-default org-export-with-smart-quotes t
                org-latex-listings t)
  :config
  (org-babel-do-load-languages 'org-babel-load-languages
                               '((python . t)
                                 (emacs-lisp . t)
                                 (mathematica . t)))
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
   "e" 'counsel-org-entity
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
  (major-prefix-def :prefix-command 'major-kotlin-map
    :keymaps 'kotlin-mode-map)
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
   "" '(:ignore t :which-key "goto")
   "f" 'ff-find-other-file))
;; CMake mode.
(use-package cmake-mode :ensure t)
;; Bison/yacc/lex mode.
(use-package bison-mode :ensure t)
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
  (major-prefix-def :prefix-command 'major-latex-map
    :keymaps 'LaTeX-mode-map
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
  (:prefix-command 'major-latex-fonts-map :keymaps 'major-latex-map
   :prefix "x" :wk-full-keys nil
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
  (:prefix-command 'major-latex-fill-map :keymaps 'major-latex-map
   :prefix "f" :wk-full-keys nil
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
  (:prefix-command 'major-latex-reftex-map :keymaps 'major-latex-map
   :prefix "r" :wk-full-keys nil
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
  (major-prefix-def :prefix-command 'major-python-map
    :keymaps 'python-mode-map
    "'" 'run-python
    "d" 'pdb
    "q" 'fill-paragraph-72)
  (:prefix-command 'major-python-goto-map :keymaps 'major-python-map
   :prefix "g" :wk-full-keys nil
   "" '(:ignore t :which-key "goto"))
  (:prefix-command 'major-python-help-map :keymaps 'major-python-map
   :prefix "h" :wk-full-keys nil
   "" '(:ignore t :which-key "help"))
  (:prefix-command 'major-python-refactor-map
   :keymaps 'major-python-map :prefix "r"
   :wk-full-keys nil
   "" '(:ignore t :which-key "refactor")
   "i" 'python/remove-unused-imports)
  (:prefix-command 'major-python-repl-map :keymaps 'major-python-map
   :prefix "s" :wk-full-keys nil
   "" '(:ignore t :which-key "repl")
   "b" 'python-shell-send-buffer
   "f" 'python-shell-send-defun
   "i" 'run-python
   "r" 'python-shell-send-region)
  (:prefix-command 'major-python-virtualenv-map
   :keymaps 'major-python-map :prefix "V"
   :wk-full-keys nil
   "" '(:ignore t :which-key "virtualenv")))
;; JavaScript mode.
(use-package js2-mode :ensure t
  :general
  (major-prefix-def :prefix-command 'major-js-map
    :keymaps 'js2-mode-map))
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

;;;;; Major mode extensions.
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
;; Render/preview LaTeX maths in buffer.
(use-package xenops :ensure t :demand t
  :ghook 'LaTeX-mode-hook
  :gfhook
  (nil (lambda ()
         "Unbind )."
         (general-unbind xenops-mode-map ")")))
  :general
  (:keymaps 'major-latex-preview-map
   "x" 'xenops-mode
   "X" 'xenops-clear-latex-preamble-cache))
;; Insert LaTeX maths delimiters with $.
(use-package math-delimiters ;;:after cdlatex  ;; To override cdlatex binding.
  ;;cdlatex is PITA
  :straight (math-delimiters :host github
                             :repo "oantolin/math-delimiters")
  :general
  (:keymaps 'LaTeX-mode-map :states 'insert
   "$" 'math-delimiters-insert)
  (:keymaps 'org-mode-map :states 'insert
   "$" 'math-delimiters-insert)
  (:keymaps 'cdlatex-mode-map
   "$" nil))
;; IDE features in Emacs, which integrates with flycheck, company, imenu,
;; which-key. Provides linting, completion, code outlines, navigation,
;; formatting, semantic highlighting
(use-package lsp-mode :ensure t
  ;; XXX: Temporarily disabled because LSP prompts server
  ;; auto-install with no way to abort, soft-locking Emacs.
  ;;:ghook
  ;;('(c++-mode-hook
  ;;   js-mode-hook
  ;;   kotlin-mode-hook
  ;;   python-mode-hook
  ;;   rustic-mode-hook
  ;;   haskell-mode-hook)
  ;; 'lsp)
  :gfhook
  ('lsp-mode 'lsp-enable-which-key-integration)
  ;; NOTE: Install clang, javascript-typescript-langserver,
  ;; {python,kotlin,haskell}-language-server for language support.
  ;; See https://emacs-lsp.github.io/lsp-mode/page/languages
  :custom
  (lsp-auto-guess-root t "Don't prompt about project roots.")
  :general
  ;; TODO: Spacemacs bindings (https://develop.spacemacs.org/layers/+tools/lsp/README.html#core-key-bindings)
  (:keymaps 'leader-errors-map
   "P" 'lsp-ui-flycheck-list))
;; Provide a UI to LSP features.
(use-package lsp-ui :ensure t
  :custom
  (lsp-ui-doc-enable nil "Don't obscure code with documentation.")
  :general
  (:keymaps 'lsp-mode-map :states 'insert
   "<F1>" 'lsp-ui-doc-glance
   "C-?" 'lsp-ui-doc-glance))
;; Integrate LSP with ivy for searching symbols.
(use-package lsp-ivy :ensure t
  :general
  (:keymaps 'leader-search-map
   "S" 'lsp-ivy-workspace-symbol))
;; Sort Python imports.
(use-package py-isort :ensure t
  :general
  (:keymaps 'major-python-refactor-map
   "I" 'py-isort-buffer)
  :config
  (warn-missing-hook-executable "python-isort" "isort"
                                "sorting Python imports"
                                'python-mode-hook))
;; LSP support for Haskell.
(use-package lsp-haskell :ensure t
  :ghook ('haskell-mode-hook 'lsp))
;; Prettify Org mode bullets.
(use-package org-superstar :ensure t
  ;; XXX: If slowdown occurs, try setting inhibit-compacting-font-caches
  :ghook 'org-mode-hook)
;; TODO dap-mode with Spacemacs bindings (https://develop.spacemacs.org/layers/+tools/dap/README.html#startstop)

;;;; Applications.
;; Create and check regexes with SPC-a-r.
(use-package re-builder
  :general
  (:keymaps 'leader-applications-map
   "r" 're-builder))
;; The Git porcelain, with SPC-g.
(use-package magit :ensure t
  :custom
  (magit-diff-refine-hunk 'all "Show granular differences.")
  :general
  (:keymaps 'magit-mode-map
   "<tab>" 'magit-section-toggle)
  (:keymaps 'transient-map
   "<escape>" 'transient-quit-one)
  (:keymaps 'leader-git-map
   "b" 'magit-blame
   "c" 'magit-commit
   "f" 'magit-file-dispatch
   "i" 'magit-init
   "m" 'magit-dispatch
   "S" 'magit-stage-file
   "s" 'magit-status
   "U" 'magit-unstage-file)
  (major-prefix-def :prefix-command 'major-with-editor-map
    :keymaps 'with-editor-mode-map
    "," 'with-editor-finish
    "a" 'with-editor-cancel
    "c" 'with-editor-finish
    "k" 'with-editor-cancel))
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
;; Zone out with SPC-a-z.
(use-package zone
  :general
  (:keymaps 'leader-applications-map
   "z" 'zone))
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
;; Find out why Emacs is slow with SPC-a-t.
(use-package explain-pause-mode
  :straight (explain-pause-mode :host github
                                :repo "lastquestion/explain-pause-mode")
  :config
  (explain-pause-mode)
  :general
  (:keymaps 'leader-applications-map
   "t" 'explain-pause-top))
;; Set of debuggers in Emacs.
(use-package gud
  :general
  (:keymaps 'leader-applications-map
   "d" 'gud-gdb))

;;;; Other.
;; Run any command on current file (e.g. compile or interpret) with SPC-c-c.
(use-package compile
  :custom
  (compilation-scroll-output 'first-error "Stop scrolling at first error.")
  :general
  (:keymaps 'leader-compile-map
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
;; Provide `restart-emacs' to restart Emacs.
(use-package restart-emacs :ensure t
  :general
  (:keymaps 'leader-quit-map
   "r" 'restart-emacs))
;; Save buffers periodically and on exit in case of crash.
(use-package desktop :demand t
  :ghook
  ('emacs-startup-hook 'desktop-save-mode)
  :general
  (:keymaps 'leader-applications-map
   "d" 'desktop-read))
