;;; org-capture-mod.el --- modification of org-capture template function
;;
;; add additional template element headlinesearch
;;
;; Copyright (C) 2011  Taemin Cho
;; taemin.cho@gmail.com

(require 'org-capture)

(defun org-get-heading-from (file &optional default)
  (when (not default)
    (setq default "Unclassified"))
  (when (file-readable-p file)
   (with-temp-buffer
     (insert-file-contents file)
      (goto-char (point-min))
      (let ((headings '()) heading)
	(while (search-forward-regexp "^\* +.+" nil t)
	  (add-to-list 'headings
		       (buffer-substring
			(+ 2 (line-beginning-position)) (line-end-position))))

	(when (typep headings 'list)
	  (setq headings (sort headings 'string-lessp)))

	(setq heading (completing-read "Heading : " headings))
	(if (string= heading "") default heading)
))))

(defun org-capture-set-target-location (&optional target)
  "Find target buffer and position and store then in the property list."
  (let ((target-entry-p t))
    (setq target (or target (org-capture-get :target)))
    (save-excursion
      (cond
       ;; here added new element
       ((eq (car target) 'headlinesearch)
	(set-buffer (org-capture-target-buffer (nth 1 target)))
	(org-capture-put-target-region-and-position)
	(widen)
	(let ((hd (org-get-heading-from (nth 1 target) (nth 2 target))))
	  (goto-char (point-min))
	  (unless (org-mode-p)
	    (error
	     "Target buffer \"%s\" for headlinesearch should be in Org mode"
	     (current-buffer)))
	  (if (re-search-forward
	       (format org-complex-heading-regexp-format (regexp-quote hd))
	       nil t)
	      (goto-char (point-at-bol))
	    (goto-char (point-max))
	    (or (bolp) (insert "\n"))
	    (insert "* " hd "\n")
	    (beginning-of-line 0))))

       ((eq (car target) 'file)
	(set-buffer (org-capture-target-buffer (nth 1 target)))
	(org-capture-put-target-region-and-position)
	(widen)
	(setq target-entry-p nil))

       ((eq (car target) 'id)
	(let ((loc (org-id-find (nth 1 target))))
	  (if (not loc)
	      (error "Cannot find target ID \"%s\"" (nth 1 target))
	    (set-buffer (org-capture-target-buffer (car loc)))
	    (widen)
	    (org-capture-put-target-region-and-position)
	    (goto-char (cdr loc)))))

       ((eq (car target) 'file+headline)
	(set-buffer (org-capture-target-buffer (nth 1 target)))
	(org-capture-put-target-region-and-position)
	(widen)
	(let ((hd (nth 2 target)))
	  (goto-char (point-min))
	  (unless (org-mode-p)
	    (error
	     "Target buffer \"%s\" for file+headline should be in Org mode"
	     (current-buffer)))
	  (if (re-search-forward
	       (format org-complex-heading-regexp-format (regexp-quote hd))
	       nil t)
	      (goto-char (point-at-bol))
	    (goto-char (point-max))
	    (or (bolp) (insert "\n"))
	    (insert "* " hd "\n")
	    (beginning-of-line 0))))

       ((eq (car target) 'file+olp)
 	(let ((m (org-find-olp
		  (cons (org-capture-expand-file (nth 1 target))
			(cddr target)))))
	  (set-buffer (marker-buffer m))
	  (org-capture-put-target-region-and-position)
	  (widen)
	  (goto-char m)))

       ((eq (car target) 'file+regexp)
	(set-buffer (org-capture-target-buffer (nth 1 target)))
	(org-capture-put-target-region-and-position)
	(widen)
	(goto-char (point-min))
	(if (re-search-forward (nth 2 target) nil t)
	    (progn
	      (goto-char (if (org-capture-get :prepend)
			     (match-beginning 0) (match-end 0)))
	      (org-capture-put :exact-position (point))
	      (setq target-entry-p (and (org-mode-p) (org-at-heading-p))))
	  (error "No match for target regexp in file %s" (nth 1 target))))

       ((memq (car target) '(file+datetree file+datetree+prompt))
	(require 'org-datetree)
	(set-buffer (org-capture-target-buffer (nth 1 target)))
	(org-capture-put-target-region-and-position)
	(widen)
	;; Make a date tree entry, with the current date (or yesterday,
	;; if we are extending dates for a couple of hours)
	(org-datetree-find-date-create
	 (calendar-gregorian-from-absolute
	  (cond
	   (org-overriding-default-time
	    ;; use the overriding default time
	    (time-to-days org-overriding-default-time))

	   ((eq (car target) 'file+datetree+prompt)
	    ;; prompt for date
	    (let ((prompt-time (org-read-date
				nil t nil "Date for tree entry:"
				(current-time))))
	      (org-capture-put :prompt-time prompt-time)
	      (time-to-days prompt-time)))
	   (t
	    ;; current date, possible corrected for late night workers
	    (org-today))))))

       ((eq (car target) 'file+function)
	(set-buffer (org-capture-target-buffer (nth 1 target)))
	(org-capture-put-target-region-and-position)
	(widen)
	(funcall (nth 2 target))
	(org-capture-put :exact-position (point))
	(setq target-entry-p (and (org-mode-p) (org-at-heading-p))))

       ((eq (car target) 'function)
	(funcall (nth 1 target))
	(org-capture-put :exact-position (point))
	(setq target-entry-p (and (org-mode-p) (org-at-heading-p))))

       ((eq (car target) 'clock)
	(if (and (markerp org-clock-hd-marker)
		 (marker-buffer org-clock-hd-marker))
	    (progn (set-buffer (marker-buffer org-clock-hd-marker))
		   (org-capture-put-target-region-and-position)
		   (widen)
		   (goto-char org-clock-hd-marker))
	  (error "No running clock that could be used as capture target")))

       (t (error "Invalid capture target specification")))

      (org-capture-put :buffer (current-buffer) :pos (point)
		       :target-entry-p target-entry-p))))
