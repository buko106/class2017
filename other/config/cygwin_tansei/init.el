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

(global-linum-mode t)
;;yatex
