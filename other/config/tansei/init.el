;;; キー操作を便利に。
(global-set-key "\C-h" 'backward-delete-char)
(global-set-key "\C-c\C-h" 'help-command)


;;no opening
(setq inhibit-startup-message t)

;;背景を黒にして透過
(if window-system (progn
    (set-background-color "Black")
    (set-foreground-color "LightGray")
    (set-cursor-color "Orange")
    (set-frame-parameter nil 'alpha 80) ;透明度
    ))

(column-number-mode 1)
(line-number-mode 1)
(display-time-mode 1)

;region color
(set-face-foreground 'region "black")
(set-face-background 'region "lightblue")

;;hilight

(show-paren-mode t)
(setq show-paren-delay 0)
(setq show-paren-style 'expression)
(set-face-background 'show-paren-match-face "pink")
(set-face-foreground 'show-paren-match-face "Black")
(set-face-foreground 'font-lock-comment-face "black")
(set-face-background 'font-lock-comment-face "gray")

;;; インデントを埋めるときにタブではなく空白を使う。
(setq-default indent-tabs-mode nil)
;;;melpaを読み込み
(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/") t)
(package-initialize)

;; line-number
(global-linum-mode t) ;; can be replaced with M-g M-g
(set-face-attribute 'linum nil
                    :height 0.8)

(add-hook 'c++-mode-hook
          '(lambda ()
             (hs-minor-mode 1)))
(add-hook 'c-mode-hook
          '(lambda ()
             (hs-minor-mode 1)))
(define-key global-map (kbd "C-\\") 'hs-toggle-hiding)

;;auto-complete
(global-auto-complete-mode t)
(setq ac-ignore-case nil)

;;prolog
(add-to-list 'auto-mode-alist '("\\.pl$" . prolog-mode))
(add-hook 'prolog-mode-hook 'auto-complete-mode)

;; for nvcc *.cu
(add-to-list 'auto-mode-alist '("\\.cu" . c-mode))

;; verilog-mode
(setq verilog-auto-newline nil)

;; verilog-function
(defalias 'verilog-auto-connect '(lambda () (interactive) (query-replace-regexp "\\([a-zA-Z0-9_]+\\)" ".\\1(\\1)" nil)))

;; why do not they work?

;; default text scale settings
(add-hook 'find-file-hook '(lambda () (text-scale-set 1)))
(add-hook 'emacs-startup-hook '(lambda () (text-scale-set 1)))


;; avy settings

(global-set-key (kbd "C-:") 'avy-goto-char)
(setq avy-keys (number-sequence ?a ?z))
;; guru-mode settings
(guru-global-mode)

;; smartparens settings
;; (smartparens-global-mode t)
(global-set-key (kbd "C-M-a") 'sp-beginning-of-sexp)
(global-set-key (kbd "C-M-e") 'sp-end-of-sexp)
(show-smartparens-global-mode t)
(setq sp-show-pair-delay 0)
(sp-local-pair 'verilog-mode "begin" "end")
(sp-local-pair 'verilog-mode "module" "endmodule")
(sp-local-pair 'verilog-mode "function" "endfunction")

;; yafolding mode
(add-hook 'verilog-mode-hook '(lambda () (yafolding-mode)))

;; volatile highlights mode
(volatile-highlights-mode)

;; auto highlight symbols
(global-auto-highlight-symbol-mode)

;; highlight symbols
(require 'highlight-symbol)
(global-set-key [(control f3)] 'highlight-symbol)
(global-set-key [f3] 'highlight-symbol-next)
(global-set-key [(shift f3)] 'highlight-symbol-prev)

;; change backup file directory
(setq backup-directory-alist
  (cons (cons ".*" (expand-file-name "~/.emacs.d/backup"))
        backup-directory-alist))
(setq auto-save-file-name-transforms
  `((".*", (expand-file-name "~/.emacs.d/backup/") t)))

;; cua-mode settings
(cua-mode t)
(setq cua-enable-cua-keys nil) 
