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
    (set-frame-parameter nil 'alpha 75) ;透明度
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
(set-face-foreground 'show-paren-match-face "black")
(set-face-foreground 'font-lock-comment-face "black")
(set-face-background 'font-lock-comment-face "gray")
;; (set-face-foreground 'font-lock-comment-delimiter-face "black")
;; (set-face-background 'font-lock-comment-delimiter-face "white")


;;; インデントを埋めるときにタブではなく空白を使う。
(setq-default indent-tabs-mode nil)

(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/") t)
(package-initialize)


;; line-number
(global-linum-mode t) ;; can be replaced with M-g M-g
(set-face-attribute 'linum nil
                    :height 0.8)

;; M-p for scroll down
(define-key esc-map "p" 'scroll-down)

;; M-n for scroll up
(define-key esc-map "n" 'scroll-up)

; hs-minor-mode
(add-hook 'c++-mode-hook '(lambda () (hs-minor-mode 1)))
(add-hook 'c++-mode-hook '(lambda () (setq flycheck-gcc-language-standard "c++11")))
(add-hook   'c-mode-hook '(lambda () (hs-minor-mode 1)))
(define-key global-map (kbd "C-\\") 'hs-toggle-hiding)

(global-auto-complete-mode t)

;; Prolog
(add-to-list 'auto-mode-alist '("\\.pl$" . prolog-mode))
(add-hook   'prolog-mode-hook '(lambda () (auto-complete-mode 1)))

;; for verilog-mode

(setq verilog-auto-newline nil)

;; default text scale settings
(add-hook 'find-file-hook '(lambda () (text-scale-set 1)))
(add-hook 'emacs-startup-hook '(lambda () (text-scale-set 1)))
(defalias 'verilog-auto-connect '(lambda () (interactive)(query-replace-regexp "\\([a-zA-Z0-9_]+\\)" ".\\1(\\1)" nil)))

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
(require 'auto-highlight-symbol)
(global-auto-highlight-symbol-mode)

;; highlight symbols
(require 'highlight-symbol)
(global-set-key [(control f3)] 'highlight-symbol)
(global-set-key [f3] 'highlight-symbol-next)
(global-set-key [(shift f3)] 'highlight-symbol-prev)

;; backup directory
(setq backup-directory-alist
  (cons (cons ".*" (expand-file-name "~/.emacs.d/backup"))
        backup-directory-alist))
(setq auto-save-file-name-transforms
  `((".*", (expand-file-name "~/.emacs.d/backup/") t)))

(add-to-list 'load-path "~/.emacs.d/extern")

;; cua-mode settings
;; (cua-mode t)
;; (setq cua-enable-cua-keys nil)

;; prototxt
;; (require 'caffe-mode)
;; (add-to-list 'auto-mode-alist '("\\.prototxt$" . caffe-mode))

;; flycheck
(global-flycheck-mode t)
(flycheck-pos-tip-mode t)

;; typescript
(add-hook 'typescript-mode-hook
          (lambda ()
            (tide-setup)
            (eldoc-mode t)
            (setq typescript-indent-level 2)
            (auto-complete-mode t)
;;            (company-mode-on)
            ))

;; magit( emacs + git )
(global-set-key (kbd "C-x g") 'magit-status)
;; yatex mode
(autoload 'yatex-mode "yatex" "Yet Another LaTeX mode" t)
(add-to-list 'auto-mode-alist '("\\.tex$" . yatex-mode))
(setq YaTeX-kanji-code 4)
