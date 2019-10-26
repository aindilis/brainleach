(global-set-key "\C-cbhd" 'brainleach-todo)

(defun brainleach-todo ()
 ""
 (interactive)
 (kmax-not-yet-implemented))

(define-derived-mode brainleach-todo-mode
 do-todo-list-mode "BrainLeach Todo"
 "Major mode for managing BrainLeach todo.
\\{do-todo-list-mode-map}"
 (setq case-fold-search nil)

 (define-key brainleach-todo-mode-map "\C-cdin" 'brainleach-item-new)
 (define-key brainleach-todo-mode-map "\C-cdia" 'brainleach-item-activate)
 (define-key brainleach-todo-mode-map "\C-cdtc" 'brainleach-item-mark-complete)

 (make-local-variable 'font-lock-defaults)
 (setq font-lock-defaults '(subl-font-lock-keywords nil nil))
 (re-font-lock))

(defun brainleach-todo ()
 ""
 (interactive)
 (kmax-not-yet-implemented))

(defun brainleach-item-new ()
 ""
 (interactive)
 (kmax-not-yet-implemented))

(defun brainleach-item-activate ()
 ""
 (interactive)
 (kmax-not-yet-implemented))

(defun brainleach-item-mark-complete ()
 ""
 (interactive)
 (kmax-not-yet-implemented))

(provide 'brainleach-todo)
