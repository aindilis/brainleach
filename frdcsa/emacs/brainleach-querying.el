(defun brainleach-start-querying ()
 "Start querying the user every half hour what they are working on"
 (interactive)
 (setq brainleach-querying-timer
  (run-at-time "10 min" (* 10 60) 'brainleach-query-task)))

(defun brainleach-stop-querying ()
 (interactive)
 (cancel-timer brainleach-querying-timer))

(defun brainleach-query-task ()
 "Ask the user what they are currently working on, record it to SQL
db.  This is a stop-gap measure before the entire brainleach system is
complete, so that I can go back and review messages and fill out
timesheet properly with what was getting done during the day."
 (interactive)
 (uea-send-contents
  (concat "BrainLeach reports: "
   (read-from-minibuffer "What are you working on? "))))

;; (brainleach-start-querying)

(provide 'brainleach-querying)
