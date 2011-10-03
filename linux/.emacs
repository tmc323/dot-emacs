;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                 BASIC                                      ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; (setq py-python-command "python2")
;; (setq pymacs-python-command py-python-command)

(set-face-attribute 'default nil :height 90)
;; (setq py-python-command "/usr/bin/python2")
;; (setq python-python-command "/usr/bin/python2")

(add-to-list 'load-path "~/.emacs.d")
;; (add-to-list 'load-path "/usr/share/emacs/site-lisp/dvc")
(require 'dvc-autoloads)

;; == 기본 색상 ==
(add-to-list 'initial-frame-alist '(foreground-color . "white"))
(add-to-list 'initial-frame-alist '(background-color . "black"))
(set-cursor-color "white")


;; == 한글설정  ==

;; * Shift-Space 로 한영전환,
(set-input-method "korean-hangul")
(toggle-input-method)
(global-set-key (kbd "S-SPC") 'toggle-input-method)
;; * 한글 폰트
(set-fontset-font "fontset-default" 'hangul '("NanumGothic" . "unicode-bmp"))

;; == welcome 화면 지우기 등등 ==
(setq inhibit-startup-message t)
(setq inhibit-startup-echo-area-message t)
(setq initial-scratch-message nil)
(scroll-bar-mode -1)
(tool-bar-mode -1)
(menu-bar-mode -1)

;; == yes 대신 y 만 입력 ==
(fset 'yes-or-no-p 'y-or-n-p)

;; == 윈도우를 "meta - 화살표키"로 돌아다니기 ==
(windmove-default-keybindings 'meta)

;; == 스크롤 한 줄씩 되게 하기 ==
(require 'smooth-scrolling)
;;(smooth-scroll-mode t)

;; == delete-selection-mode 활성화 ==
(delete-selection-mode 1)

;; == shell 모드에서 제어 문자 나오는 것 방지 ==
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)

;;;; == 단축키 설정 ==
;; * Clipboard 이용 Cut Copy Paste (1)
;; Caps Lock 과 Ctrl 을 바꾸었다면 clipboard-kill-region은 오른쪽 Shift를 눌러야 한다.
(global-set-key [(control X)] 'clipboard-kill-region)
(global-set-key [(control C)] 'clipboard-kill-ring-save)
(global-set-key [(control V)] 'clipboard-yank)

;; * Clipboard 이용 Cut Copy Paste (2) - Emacs 친화적 키 바인딩
(global-set-key [(control c)(control w)] 'clipboard-kill-region)
(global-set-key [(control c)(meta w)] 'clipboard-kill-ring-save)
(global-set-key [(control c)(control y)] 'clipboard-yank)

;; == 버퍼 메뉴보기 ==
;; list-buffers (C-x C-b) 보다 낫다.
(global-set-key [(control x)(meta b)] 'buffer-menu)
;; better 버퍼 스위치
(iswitchb-mode 1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                               Utilities                                    ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; This was installed by package-install.el.
;;; This provides support for the package system and
;;; interfacing with ELPA, the package archive.
;;; Move this code earlier if you want to reference
;;; packages in your .emacs.
(when
    (load
     (expand-file-name "~/.emacs.d/elpa/package.el"))
  (package-initialize))

;;;; == 괄호 매칭. == -- lisp mode 에서는 필수 나머지는 선택.
;; (defun hl-p-hook ()
;;   (highlight-parentheses-mode t))
;; (add-hook 'lisp-interaction-mode-hook 'hl-p-hook)
;; (add-hook 'lisp-mode-hook 'hl-p-hook)
;; (add-hook 'emacs-lisp-mode-hook 'hl-p-hook)

(define-globalized-minor-mode global-highlight-parentheses-mode
  highlight-parentheses-mode
  (lambda ()
    (highlight-parentheses-mode t)))
(global-highlight-parentheses-mode t)

;; == Using Aspell instead of ispell ==
(setq ispell-program-name "aspell")
;;(setq ispell-extra-args '("--sug-mode=ultra"))


;;;; == 창 투명하게 하기 ==
(modify-frame-parameters nil `((alpha . 90)))
(defun djcb-opacity-modify (&optional dec)
  "modify the transparency of the emacs frame; if DEC is t,
    decrease the transparency, otherwise increase it in 5%-steps"
  (let* ((alpha-or-nil (frame-parameter nil 'alpha)) ; nil before setting
(oldalpha (if alpha-or-nil alpha-or-nil 100))
(newalpha (if dec (- oldalpha 5) (+ oldalpha 5))))
    (when (and (>= newalpha frame-alpha-lower-limit) (<= newalpha 100))
      (modify-frame-parameters nil (list (cons 'alpha newalpha))))))

;; C-= will increase opacity (== decrease transparency)
;; C-- will decrease opacity (== increase transparency
;; C-0 will returns the state to normal
(global-set-key (kbd "C-=") '(lambda()(interactive)(djcb-opacity-modify)))
(global-set-key (kbd "C--") '(lambda()(interactive)(djcb-opacity-modify t)))
(global-set-key (kbd "C-0") '(lambda()(interactive)
                               (modify-frame-parameters nil `((alpha . 100)))))


;; == smart-compile , 컴파일 ==
(require 'smart-compile)
(global-set-key "\C-cc" 'smart-compile)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                 Auctex                                     ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(load "auctex.el" nil t t)
(load "preview-latex.el" nil t t)

;; == default Tex-PDF-mode
;;(add-hook 'LaTeX-mode-hook 'TeX-PDF-mode)

(setq TeX-PDF-mode t)

;; flymake pdf
(require 'flymake)
(defun flymake-get-tex-args (file-name)
  (list "pdflatex" (list "-file-line-error" "-draftmode" "-interaction=nonstopmode" file-name)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                 CEDET                                      ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Load CEDET.
;; See cedet/common/cedet.info for configuration details.
;; (load-file "/usr/share/emacs/site-lisp/cedet/common/cedet.el")

(require 'cedet)

;; load header files
(require 'semantic-gcc)

;; Enable EDE (Project Management) features
(global-ede-mode 1)

;; Enable EDE for a pre-existing C++ project
;; (ede-cpp-root-project "NAME" :file "~/myproject/Makefile")


;; Enabling Semantic (code-parsing, smart completion) features
;; Select one of the following:

;; * This enables the database and idle reparse engines
(semantic-load-enable-minimum-features)

;; * This enables some tools useful for coding, such as summary mode
;;   imenu support, and the semantic navigator
(semantic-load-enable-code-helpers)

;; * This enables even more coding tools such as intellisense mode
;;   decoration mode, and stickyfunc mode (plus regular code helpers)
;; (semantic-load-enable-gaudy-code-helpers)

;; * This enables the use of Exuberent ctags if you have it installed.
;;   If you use C++ templates or boost, you should NOT enable it.
;; (semantic-load-enable-all-exuberent-ctags-support)
;;   Or, use one of these two types of support.
;;   Add support for new languges only via ctags.
;; (semantic-load-enable-primary-exuberent-ctags-support)
;;   Add support for using ctags as a backup parser.
;; (semantic-load-enable-secondary-exuberent-ctags-support)

;; Enable SRecode (Template management) minor-mode.
;; (global-srecode-minor-mode 1)

;; GNU global 사용
(require 'semanticdb-global)
(semanticdb-enable-gnu-global-databases 'c-mode)
(semanticdb-enable-gnu-global-databases 'c++-mode)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                               Auto-Complete mode                           ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(add-to-list 'load-path "/usr/share/emacs/site-lisp/auto-complete")
(require 'auto-complete-config)
(add-to-list 'ac-dictionary-directories "/usr/share/emacs/site-lisp/auto-complete/ac-dict")
(ac-config-default)


;; redefine C mode setup
(defun ac-cc-mode-setup ()
  (setq ac-sources (append '(ac-source-semantic ac-source-gtags ac-source-yasnippet) ac-sources)))

;; (require 'pymacs)
;; (ac-ropemacs-initialize)
;;;; = redefine Python mode setup
;; (defun ac-ropemacs-setup ()
;;   (ac-ropemacs-require)
;;   (setq ac-sources (append '(ac-source-ropemacs ac-source-yasnippet) ac-sources)))


;; Auto Syntax Error Hightlight
(when (load "flymake" t)
  (defun flymake-pyflakes-init ()
    (let* ((temp-file (flymake-init-create-temp-buffer-copy
		       'flymake-create-temp-inplace))
	   (local-file (file-relative-name
			temp-file
			(file-name-directory buffer-file-name))))
      (list "pyflakes" (list local-file))))
  (add-to-list 'flymake-allowed-file-name-masks
	       '("\\.py\\'" flymake-pyflakes-init)))

;;(add-hook 'find-file-hook 'flymake-find-file-hook)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                        그외 잡다한것들                                        ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; == 파일 경로 보이기 ==
(defun show-file-name ()
  "Show the full path file name in the minibuffer."
  (interactive)
  (message (buffer-file-name)))

(global-set-key (kbd "C-c n") 'show-file-name) ; Or any other key you want

;; for line numbering 터미널 모드에서만 되도록 해보자 !!
;; (require 'linum+)
;; (setq linum+-smart-format "%%%dd| ")

;; window swap
(defun swap-buffers-in-windows ()
  "Put the buffer from the selected window in next window, and vice versa"
  (interactive)
  (let* ((this (selected-window))
     (other (next-window))
     (this-buffer (window-buffer this))
     (other-buffer (window-buffer other)))
    (set-window-buffer other this-buffer)
    (set-window-buffer this other-buffer)
    )
  )


;; == remove white space ==
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; == Haskell-mode ==
(require 'haskell-mode)
(setq auto-mode-alist (cons '("\\.hs$" . haskell-mode) auto-mode-alist))
(add-hook 'haskell-mode-hook 'turn-on-haskell-doc-mode)
(add-hook 'haskell-mode-hook 'turn-on-haskell-indentation)
(add-hook 'haskell-mode-hook 'turn-on-haskell-indent)
;;(add-hook 'haskell-mode-hook 'turn-on-haskell-simple-indent)

;; == lua-mode ==

(setq auto-mode-alist (cons '("\.lua$" . lua-mode) auto-mode-alist))
(autoload 'lua-mode "lua-mode" "Lua editing mode." t)

;;; MATLAB mode

;; (add-to-list 'load-path "~/.emacs.d/matlab-emacs")
;; (setq mlint-programs '("/Applications/MATLAB_R2009bSP1.app/bin/maci64/mlint"))

(setq semantic-matlab-system-paths-include '("toolbox")) ;; under matlab root
(load-library "matlab-load")
;; Enable CEDET feature support for MATLAB code. (Optional)
(matlab-cedet-setup)

;; for heavy buffer change, for no error, no warning
(setq warning-suppress-types nil)
(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(org-agenda-files (quote ("~/Dropbox/org/test.org")))
 '(warning-suppress-types (quote ((undo discard-info)))))




;; == ipython mode ==
;;(setq ipython-command "/usr/bin/ipython")
(require 'ipython)
;;(setq py-python-command-args '("-pylab"));; "-colors" "Linux"))


(require 'anything)
(require 'anything-ipython)
(when (require 'anything-show-completion nil t)
   (use-anything-show-completion 'anything-ipython-complete
                                 '(length initial-pattern)))


(setq py-python-command-args '("--colors=Linux"))

;;(require 'tramp)
(require 'python-pep8)
(require 'python-pylint)


(add-hook 'py-shell-hook 'comint-mode)

(add-hook 'py-shell-hook
          #'(lambda ()
	      (define-key comint-mode-map [tab] 'ipython-complete)
	      ;; Add this so that tab-completion works both in X11 frames and inside
	      ;; terminals (such as when emacs is called with -nw).
	      (define-key comint-mode-map "\t" 'ipython-complete)
	      ;;XXX this is really just a cheap hack, it only completes symbols in the
	      ;;interactive session -- useful nonetheless.
	      (define-key comint-mode-map [(meta tab)] 'ipython-complete)
	      ))

(define-key comint-mode-map (kbd "M-n") 'comint-next-matching-input-from-input)
(define-key comint-mode-map (kbd "M-p") 'comint-previous-matching-input-from-input)
(define-key comint-mode-map [(control meta n)] 'comint-next-input)
(define-key comint-mode-map [(control meta p)] 'comint-previous-input)



;; python 도큐먼트 보기
(require 'w3m-load)
(add-to-list 'load-path "~/.emacs.d/pylookup")
(autoload 'pylookup-lookup "pylookup")
(autoload 'pylookup-update "pylookup")
(setq pylookup-program "~/.emacs.d/pylookup/pylookup.py")
(setq pylookup-db-file "~/.emacs.d/pylookup/pylookup.db")
(setq browse-url-browser-function 'w3m-browse-url) ;; w3m
(global-set-key "\C-ch" 'pylookup-lookup)

;; 괄호나 따옴표 짝짓기
;; (autoload 'autopair-global-mode "autopair" nil t)
;; (autopair-global-mode)
;; (add-hook 'python-mode-hook
;;           #'(lambda ()
;;               (push '(?' . ?')
;;                     (getf autopair-extra-pairs :code))
;;               (setq autopair-handle-action-fns
;;                     (list #'autopair-default-handle-action
;;                           #'autopair-python-triple-quote-action))))

;; ORG-MODE

(require 'org-install)
;; capture modification
(load-file "~/.emacs.d/org-capture-mod.el")
;; 음력지원
(require 'cal-korea)

(global-set-key "\C-ca" 'org-agenda)

(add-to-list 'auto-mode-alist '("\\.org\\'" . org-mode))
(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-cc" 'org-capture)
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cb" 'org-iswitchb)

(define-key mode-specific-map [?a] 'org-agenda)

(eval-after-load "org"
  '(progn
     (define-prefix-command 'org-todo-state-map)

     (define-key org-mode-map "\C-cx" 'org-todo-state-map)

     (define-key org-todo-state-map "x"
       #'(lambda nil (interactive) (org-todo "CANCELLED")))
     (define-key org-todo-state-map "d"
       #'(lambda nil (interactive) (org-todo "DONE")))
     (define-key org-todo-state-map "f"
       #'(lambda nil (interactive) (org-todo "DEFERRED")))
     (define-key org-todo-state-map "l"
       #'(lambda nil (interactive) (org-todo "DELEGATED")))
     (define-key org-todo-state-map "s"
       #'(lambda nil (interactive) (org-todo "STARTED")))
     (define-key org-todo-state-map "w"
       #'(lambda nil (interactive) (org-todo "WAITING")))

     (add-hook 'org-agenda-mode-hook
	       (lambda ()
		 (define-key org-agenda-mode-map "\C-n" 'next-line)
		 (define-key org-agenda-keymap "\C-n" 'next-line)
		 (define-key org-agenda-mode-map "\C-p" 'previous-line)
		 (define-key org-agenda-keymap "\C-p" 'previous-line)))))

(custom-set-variables
 '(org-agenda-files (quote ("~/Dropbox/org/todo.org")))
 '(org-default-notes-file "~/Dropbox/org/notes.org")
 '(org-agenda-ndays 7)
 '(org-deadline-warning-days 14)
 '(org-agenda-show-all-dates t)
 '(org-agenda-skip-deadline-if-done t)
 '(org-agenda-skip-scheduled-if-done t)
 '(org-agenda-start-on-weekday nil)
 '(org-reverse-note-order t)
 '(org-fast-tag-selection-single-key (quote expert))
 '(org-agenda-custom-commands
   (quote (("d" todo "DELEGATED" nil)
       ("c" todo "DONE|DEFERRED|CANCELLED" nil)
       ("w" todo "WAITING" nil)
       ("W" agenda "" ((org-agenda-ndays 21)))
       ("A" agenda ""
        ((org-agenda-skip-function
          (lambda nil
        (org-agenda-skip-entry-if (quote notregexp) "\\=.*\\[#A\\]")))
         (org-agenda-ndays 1)
         (org-agenda-overriding-header "Today's Priority #A tasks: ")))
       ("u" alltodo ""
        ((org-agenda-skip-function
          (lambda nil
        (org-agenda-skip-entry-if (quote scheduled) (quote deadline)
                      (quote regexp) "\n]+>")))
         (org-agenda-overriding-header "Unscheduled TODO entries: ")))))))

 (setq org-capture-templates
      (quote (("t" "Todo" entry (file+headline "~/Dropbox/org/todo.org" "Tasks")
             "* TODO %?\n  %i\n")
	      ("n" "Note" entry (headlinesearch "~/Dropbox/org/notes.org" "Notes")
	       "* %?\nEntered on %U\n  %i\n")
	      ("j" "Journal" entry (file+datetree "~/Dropbox/org/journals.org")
	       "* %?\nEntered on %U\n  %i\n")
	      )))


;; Set to the location of your Org files on your local system
(setq org-directory "~/Dropbox/org")
;; Set to the name of the file where new notes will be stored
(setq org-mobile-inbox-for-pull "~/Dropbox/org/flagged.org")
;; Set to <your Dropbox root directory>/MobileOrg.
(setq org-mobile-directory "~/Dropbox/MobileOrg")
(add-hook 'org-mobile-post-push-hook
  (lambda () (shell-command "sitecopy -u org")))
(add-hook 'org-mobile-pre-pull-hook
  (lambda () (shell-command "sitecopy -f org;sitecopy -s org")))
