(global-set-key "\C-cbhg" 'brainleach-grab-export)

(defun brainleach-grab-one-declare (text)
 (if (or
      (string-match "^\\(declare -x \\([a-zA-Z0-9_-]+\\)=\"\\([^\"]+\\)\"\\)\ndeclare -x " text)
      (string-match "^\\(declare -x \\([a-zA-Z0-9_-]+\\)=\"\\([^\"]+\\)\"\\)" text))
  (progn
   (let ((subtext (match-string 1 text))
	 (var (match-string 2 text))
	 (value (match-string 3 text)))
    (add-to-list 'brainleach-current-environment-variables (cons var value))
    (substring text (length subtext))))))

(defun brainleach-process-export (text)
 (setq brainleach-current-environment-variables nil)
 (while text
  (setq text (brainleach-grab-one-declare text)))
 (message (prin1-to-string brainleach-current-environment-variables)))

(defun brainleach-grab-export ()
 ""
 (interactive)
 (setq brainleach-current-environment-variables (brainleach-process-process-environment process-environment))
 ;; (if (kmax-mode-is-derived-from 'shell-mode)
 ;;  (progn
 ;;   (end-of-buffer)
 ;;   (insert "export")
 ;;   (setq brainleach-task 'process-export)
 ;;   (comint-send-input)))
 )

(if 0
 (brainleach-process-export "declare -x CATALINA_HOME=\"/usr/share/tomcat5.5\"
declare -x CLASSPATH=\"/usr/lib/jvm/java-8-openjdk-amd64/jre/lib\"
declare -x COLUMNS=\"158\"
declare -x COMP_WORDBREAKS=\" 	
\\\"’><;|&(:\"
declare -x DBUS_SESSION_BUS_ADDRESS=\"unix:path=/run/user/1000/bus\"
declare -x DESKTOP_SESSION=\"lightdm-xsession\"
declare -x DISPLAY=\":0\"
declare -x DYLD_LIBRARY_PATH=\"/home/andrewdo/torch/install/lib:/home/andrewdo/torch/install/lib:/home/andrewdo/torch/install/lib:\"
declare -x EDITOR=\"emacsclient\"
"))

(defun brainleach-process-process-environment (process-environment)
 (mapcar (lambda (text)
	  (if
	   (string-match "^\\([-_a-zA-Z0-9]+\\)=\\(.+\\)$" text)
	   (cons (match-string 1 text) (match-string 2 text))
	   (error text)))
  (sort (cdr process-environment) 'string<)))

(provide 'brainleach-env-vars)
