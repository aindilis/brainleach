
;;; brainleach.el --- Record what user is working on and generate templates.

;; Copyright (C) 2019  Andrew J. Dougherty

;; Author: andrewdo <adougher9@gmail.com>
;; Keywords: 

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:

;;

;;; Code:

(global-set-key "\C-cbht" 'brainleach-toggle-tracking)
(global-set-key "\C-cbhr" 'brainleach-replay-session)
(global-set-key "\C-cbha" 'brainleach-restart-agent)

;; Write one that uses command log mode, to log to a file.  should
;; have intelligence on what is going on in the shell.  advise or hook
;; comint-send-input, etc.

(defvar brainleach-session 1 "")
(defvar brainleach-no-ack t "")

(defvar brainleach-task nil "")
(defvar brainleach-tracking nil "")
(defvar brainleach-current-directory nil "")
(defvar brainleach-current-environment-variables nil "")
(defvar brainleach-last-output nil "")

(defun brainleach-restart-agent ()
 ""
 (interactive)
 (uea-disconnect)
 (uea-connect-emacs-client)
 (uea-send-contents "exit" "BrainLeach" nil)
 (sit-for 0.5)
 (uea-send-contents "echo Connection established to BrainLeach" "BrainLeach" nil))

(defun brainleach-toggle-tracking ()
 "toggle debug-on-error value"
 (interactive)
 (if brainleach-tracking
  (brainleach-stop-session)
  (brainleach-start-new-session))
 )

(defun brainleach-stop-session ()
 ""
 (setq brainleach-tracking nil)
 (message "Stopped BrainLeach tracking."))

(defun brainleach-start-new-session ()
 ""
 (brainleach-restart-agent)
 (sit-for 0.5)
 (brainleach-set-session-id)
 (setq brainleach-tracking t)
 (brainleach-grab-export)
 (brainleach-log
  (list
   (cons "session" brainleach-session)
   (cons "env_vars" brainleach-current-environment-variables))))

;; (brainleach-set-session-id)

(defun brainleach-set-session-id ()
 ""
 (interactive)
 (let* ((message (uea-query-agent-raw
		  "get-next-session-id"
		  "BrainLeach"
		  (brainleach-util-data-dumper
		   (list
		    (cons "_DoNotLog" 1)
		    ))))
	(result (freekbs2-get-result message))
	(next-session-id (if result
			  (read result)
			  (error "BrainLeach Agent not acknowledging, cannot set next session id."))))
  (if (numberp next-session-id)
   (progn
    (setq brainleach-session next-session-id)
    (message (concat "Set session id to " (prin1-to-string brainleach-session)))
    )
   (error "BrainLeach Agent not acknowledging, cannot set next session id."))))

(defun brainleach-get-current-directory (text)
 ""
 (brainleach-get-current-directory-method-1 text))

(defun brainleach-get-current-directory-method-1 (text)
 ;; modified from https://www.emacswiki.org/emacs/ShellMode#toc8
 (if (string-match "\\w+@\\w+\\[01;34m:\\([^\n]+\\)\\$\\[00m " text)
  (progn
   (setq brainleach-current-directory (comint-directory (substring text (match-beginning 1) (match-end 1))))
   ;; (cd brainleach-current-directory)
   ;; (message brainleach-current-directory)
   )))

(defun brainleach-get-current-directory-method-2 (text)
 ;; modified from https://www.emacswiki.org/emacs/ShellMode#toc8
 (setq brainleach-current-directory (chomp (shell-command-to-string "pwd"))))

(defun brainleach-input-filter (string)
 ""
 (if brainleach-tracking
  ;; send it to prolog agent
  (progn
   ;; (see (concat brainleach-current-directory " " (chomp (substring-no-properties string))) 0.1)
   (brainleach-log
    (list
     (cons "session" brainleach-session)
     (cons "cwd" brainleach-current-directory)
     (cons "shell-command" (chomp (substring-no-properties string)))
     )
    )
   )
  )
 )

(defun brainleach-output-filter (string)
 ""
 (if brainleach-tracking
  ;; send it to prolog agent
  (progn
   (brainleach-get-current-directory string)
   (setq brainleach-last-output string)
   (if (equal brainleach-task 'process-export)
    (brainleach-process-export brainleach-last-output))
   ;; (brainleach-log
   ;;  (list
   ;;   (cons "session" brainleach-session)
   ;;   (cons "output" brainleach-last-output)
   ;;   )
   ;;  )
   )
  )
 )

;; see /var/lib/myfrdcsa/codebases/internal/kmax/frdcsa/emacs/kmax-command-log-mode/kmax-command-log-mode.el

(defun brainleach-pre-command (&optional cmd)
 ""
 t)

(defadvice command-execute (before who-said-that activate)
 "Find out who said that thing. and say so."
 (let ((trace nil) (n 1) (frame nil))
  (while (setq frame (backtrace-frame n))
   (setq n     (1+ n)
    trace (cons (cadr frame) trace)) )
  (see frame 0.0)
  (ad-set-arg 0 (see (ad-get-arg 0) 0.0))
  (ad-set-args 1 (see (ad-get-args 1) 0.0))))

(ad-disable-advice 'command-execute 'before 'who-said-that)
(ad-update 'command-execute)

(defvar brainleach-call nil "")

(defadvice funcall-interactively (before who-said-that activate)
 "Find out who said that thing. and say so."
 (let ((arg (ad-get-arg 0))
       (args (ad-get-args 1)))
  (ad-set-arg 0 arg)
  (ad-set-args 1 args)
  (setq brainleach-call (append (list arg) args))))

;; (ad-disable-advice 'funcall-interactively 'before 'who-said-that)
;; (ad-update 'funcall-interactively)

(defun brainleach-pre-command (&optional cmd)
 ""
 nil)

;; (see
;;  (brainleach-util-data-dumper
;;   (list
;;    (cons "test1" 1)
;;    (cons "test2" nil))))

;; (brainleach-cdr (list 4))

(defun brainleach-cdr (possible-list)
 (if (listp possible-list)
  (cdr possible-list)
  (list possible-list)))

(defun brainleach-post-command (&optional cmd)
 ""
 (if brainleach-tracking
  (progn
   (let* ((log-args (list
		     (cons "session" brainleach-session)
		     (cons "emacs-command" (car brainleach-call))
		     )))
    (if (cdr brainleach-call)
     (push (cons "emacs-command-args" (cdr brainleach-call)) log-args))
    (if (equal (car brainleach-call) 'self-insert-command)
     (push (cons "self-insert-char" (save-excursion (backward-char 1) (char-at-point))) log-args))
    (brainleach-log log-args)))))
;; (add-hook 'post-command-hook 'brainleach-post-command)oo

(defun brainleach-log (args)
 ""
 (if brainleach-no-ack
  (brainleach-log-send-contents args)
  (brainleach-log-query-agent args)))

(defun brainleach-util-data-dumper (item)
 "Generates a perl Data::Dumper result for an emacs data structure"
 (concat "$VAR1 = " (brainleach-util-convert-from-emacs-to-perl-data-structures item) ";")
 )

(defun brainleach-util-convert-from-emacs-to-perl-data-structures (item)
 "Convert this emacs data structure into a perl equivalent"
 ;; (message "%s" (prin1-to-string item))
 (if (listp item)
  (if (or (alistp item) (consp item))
   (concat				; this is an alist i.e. hash
    "{"
    (join ", " (mapcar 'freekbs2-util-make-hash-pair item))
    "}"
    )
   (concat 				; this is a regular list
    "[" 
    (join ", " (mapcar 'brainleach-util-convert-from-emacs-to-perl-data-structures item))
    "]")					
   )
  (if (stringp item)
   (concat "\"" 
    (join "" 
     (mapcar (lambda (char) 
	      (if (or (string= char "$")
		   (string= char "\\")
		   (string= char "\"")
		   (string= char "'")
		   (string= char "@")
		   (string= char "%")
		   (string= char "@")
		   )
	       (concat (prin1-to-string "\\" t) char) char)
	      ) (split-string item ""))) "\"")
   (if nil
    (concat "\"" (prin1-to-string item) "\"")
    (let* ((result (prin1-to-string item))
	   (match (progn (string-match "^var-\\(.+\\)$" result) (match-string 1 result))))
     (if (non-nil match)
      (concat "\\*{'::?" match "'}")
      (concat "\"" result "\"")))))))

(defun brainleach-log-send-contents (args)
 ""
 (uea-send-contents nil "BrainLeach"
  (brainleach-util-data-dumper
   (list
    (cons "_DoNotLog" 1)
    (cons "Log" args)
    (cons "Flags" nil)
    ))))

(defun brainleach-log-query-agent (args)
 ""
 (let* ((message (uea-query-agent-raw nil "BrainLeach"
		  (brainleach-util-data-dumper
		   (list
		    (cons "_DoNotLog" 1)
		    (cons "Log" args)
		    (cons "Flags" nil)
		    (cons "QueryAgent" 1)
		    )))))
  (if (string= (freekbs2-get-result message) "Ack")
   t
   (error "BrainLeach Agent not acknowledging."))))

(defun brainleach-replay-session ()
 ""
 (interactive)
 (let ((session-id (read-from-minibuffer "Session ID: ")))
  (uea-send-contents nil "BrainLeach"
   (brainleach-util-data-dumper
    (list
     (cons "_DoNotLog" 1)
     (cons "ReplaySession" session-id)
     (cons "EmacsPID" (emacs-pid))
     )))))

;; see /var/lib/myfrdcsa/codebases/internal/brainleach/frdcsa/emacs/brainleach-smartedit.el

(add-hook 'comint-input-filter-functions 'brainleach-input-filter)
;; (setq comint-input-filter-functions (delete 'brainleach-input-filter comint-input-filter-functions))

(add-hook 'comint-output-filter-functions 'brainleach-output-filter)
;; (setq comint-output-filter-functions (delete 'brainleach-output-filter comint-output-filter-functions))

(add-hook 'pre-command-hook 'brainleach-pre-command)
;; (setq pre-command-hook (delete 'brainleach-pre-command pre-command-hook))

(add-hook 'post-command-hook 'brainleach-post-command)
;; (setq post-command-hook (delete 'brainleach-pre-command post-command-hook))


(add-to-list 'load-path "/var/lib/myfrdcsa/codebases/internal/brainleach/frdcsa/emacs")
(require 'brainleach-todo)
(require 'brainleach-env-vars)
(require 'brainleach-smartedit)
;; (require 'brainleach-querying)
;; (require 'brainleach-backtrace)

(provide 'brainleach)
;;; brainleach.el ends here
