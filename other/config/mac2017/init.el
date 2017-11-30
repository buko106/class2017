;;; キー操作を便利に。
(global-set-key "\C-h" 'backward-delete-char)
(global-set-key "\C-c\C-h" 'help-command)
;; (when (eq system-type 'darwin)
;;   (setq ns-command-modifier (quote meta)))
;; (when (and (eq system-type 'darwin) (eq window-system 'ns))
;;   (setq ns-command-modifier (quote meta))
;;   (setq ns-alternate-modifier (quote super)))

;;no opening
(setq inhibit-startup-message t)

;;; インデントを埋めるときにタブではなく空白を使う。
(setq-default indent-tabs-mode nil)

;; backup directory
(setq backup-directory-alist
  (cons (cons ".*" (expand-file-name "~/.emacs.d/backup"))
        backup-directory-alist))
(setq auto-save-file-name-transforms
  `((".*", (expand-file-name "~/.emacs.d/backup/") t)))

;;背景を黒にして透過
(if window-system (progn
    (set-background-color "Black")
    (set-foreground-color "LightGray")
    (set-cursor-color "Orange")
    (set-frame-parameter nil 'alpha 75) ;透明度
    ))

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

;;; インデントを埋めるときにタブではなく空白を使う。
(setq-default indent-tabs-mode nil)

(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/") t)
(package-initialize)

;; line-number
(global-linum-mode t) ;; can be replaced with M-g M-g
(set-face-attribute 'linum nil
                    :height 0.8)

;; auto-complete
(global-auto-complete-mode t)
;; auto-complete ignore case
(setq ac-ignore-case nil)

;; default text scale settings
(add-hook 'find-file-hook '(lambda () (text-scale-set 1)))
(add-hook 'emacs-startup-hook '(lambda () (text-scale-set 1)))

;; avy settings
(global-set-key (kbd "C-:") 'avy-goto-char)
(setq avy-keys (number-sequence ?a ?z))

;; guru-mode settings
(guru-global-mode)

;; volatile highlights mode
(volatile-highlights-mode)

;; auto highlight symbols
(global-auto-highlight-symbol-mode)

;; highlight symbols
(global-set-key [(control f3)] 'highlight-symbol)
(global-set-key [f3] 'highlight-symbol-next)
(global-set-key [(shift f3)] 'highlight-symbol-prev)

;; css/js
(setq css-indent-offset 2)
(setq js-indent-level 2)

;; do not edit below
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (highlight-symbol auto-highlight-symbol volatile-highlights guru-mode avy auto-complete))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
