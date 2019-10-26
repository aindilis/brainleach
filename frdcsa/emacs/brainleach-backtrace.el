(defun brainleach-get-frames ()
 ""
 (let* ((n 1)
	(frames nil))
  (while (non-nil (backtrace-frame n))
   (push frames (backtrace-frame n))
   (see n 1)
   (setq n (1+ n)))
  frames))

(defvar brainleach-calls nil "")

(defvar brainleach-self-insert nil "")

;; (add-hook 'post-self-insert-hook 'see)
;; (setq post-self-insert-hook (delete 'see post-self-insert-hook))

;; (defadvice self-insert-command (before who-said-that activate)
;;  "Find out who said that thing. and say so."
;;  (let ((arg (ad-get-arg 0))
;;        (args (ad-get-args 1)))
;;   (ad-set-arg 0 arg)
;;   (ad-set-args 1 args)
;;   (setq brainleach-self-insert args)))

;; (ad-disable-advice 'self-insert-command 'before 'who-said-that)
;; (ad-update 'self-insert-command)

(provide 'brainleach-backtrace)
