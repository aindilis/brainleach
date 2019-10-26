(if (kmax-file-exists-p "/var/lib/myfrdcsa/sandbox/smartedit-1.1/smartedit-1.1/emacs/smloader.el")
 (load "/var/lib/myfrdcsa/sandbox/smartedit-1.1/smartedit-1.1/emacs/smloader.el"))

;; /var/lib/myfrdcsa/sandbox/smartedit-1.1/smartedit-1.1/emacs/sedit.el

(global-set-key "\C-cbhso" 'brainleach-open-sample-file)
(global-set-key "\C-cbhsr" 'brainleach-start-recording)
(global-set-key "\C-cbhss" 'brainleach-step-through)
(global-set-key "\C-cbhsR" 'brainleach-end-recording)
(global-set-key "\C-cbhsu" 'brainleach-start-up)

(defun brainleach-open-sample-file (arg)
 ""
 (interactive "P")
 (if arg
  (ffap "/var/lib/myfrdcsa/sandbox/smartedit-1.1/smartedit-1.1/emacs/index.html")
  (ffap "/var/lib/myfrdcsa/sandbox/smartedit-1.1/smartedit-1.1/emacs/sample.txt")))

(defun brainleach-start-up ()
 ""
 (interactive)
 (kmax-toggle-debug-on-error)
 (brainleach-open-sample-file 4)
 (smedit-start-up))

(defun brainleach-start-recording ()
 ""
 (interactive)
 (smedit-start-recording))

(defun brainleach-step-through ()
 ""
 (interactive)
 (smedit-step-through))

(defun brainleach-end-recording ()
 ""
 (interactive)
 (smedit-end-recording))

(provide 'brainleach-smartedit)
