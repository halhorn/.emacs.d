;;######################################################
;; Common Settings
;;######################################################

(add-to-list 'load-path "~/.emacs.d/elisp")
(load-theme 'wombat t)

(set-language-environment "Japanese")
(prefer-coding-system 'utf-8)

(global-set-key "\C-h" 'delete-backward-char)

(setq backup-inhibited nil)
(setq make-backup-files nil)

(global-font-lock-mode t)

(setq-default transient-mark-mode t)

(setq-default indent-tabs-mode nil)

(show-paren-mode t)

(setq inhibit-startup-message t)

;; バッファ・ファイルで大文字小文字を区別しない
(setq read-buffer-completion-ignore-case t)
(setq read-file-name-completion-ignore-case t)

(defun enable-minor-mode (my-pair)
  "Enable minor mode if filename match the regexp.  MY-PAIR is a cons cell (regexp . minor-mode)."
  (if (buffer-file-name)
      (if (string-match (car my-pair) buffer-file-name)
      (funcall (cdr my-pair)))))

;;######################################################
;; Package Install
;;######################################################
;; package.el
(require 'package)
(when (require 'package nil t)
  (add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/"))
  (add-to-list 'package-archives '("melpa"     . "https://melpa.org/packages/") t)
  (add-to-list 'package-archives '("ELPA"      . "http://tromey.com/elpa/"))
  (package-initialize))

(require 'cl)
(defvar installing-package-list
  '(
    ;; インストールするリスト
    use-package
    auto-complete
    web-mode
    cperl-mode
    js2-mode
    typescript-mode
    lsp-mode
    add-node-modules-path
    yaml-mode
    flymake-python-pyflakes
    helm
    find-file-in-project
    pyenv-mode
    elpy
    sphinx-doc
    terraform-mode
    vue-mode
    flycheck
    prettier-js
    ))

(let ((not-installed (loop for x in installing-package-list
			   when (not (package-installed-p x))
			   collect x)))
  (when not-installed
    (package-refresh-contents)
    (dolist (pkg not-installed)
      (package-install pkg))))

(eval-when-compile (require 'use-package))
(setq use-package-verbose t)


;;######################################################
;; Other Settings
;;######################################################

(require 'auto-complete)
(global-auto-complete-mode t)

(require 'linum)
(setq linum-format
      '(lambda (line)
	 (let ((fmt
		(let ((min-w 4)
		      (w (length (number-to-string
				  (count-lines (point-min) (point-max))))))
		  (concat "%"
			  (number-to-string (if (< min-w w) w min-w))
			  "d "))))
	   (propertize (format fmt line) 'face 'linum))))

;; helm
(require 'helm-config)
(when (require 'helm-config nil t)
  (helm-mode 1)
  (define-key global-map (kbd "M-x")     'helm-M-x)
  (define-key global-map (kbd "C-x C-f") 'helm-find-files)
  (define-key global-map (kbd "C-x C-r") 'helm-recentf)
  (define-key global-map (kbd "M-y")     'helm-show-kill-ring)
  (define-key global-map (kbd "C-c i")   'helm-imenu)
  (define-key global-map (kbd "C-x b")   'helm-buffers-list)
  (define-key helm-map (kbd "C-h") 'delete-backward-char)
  (define-key helm-find-files-map (kbd "C-h") 'delete-backward-char)
  (define-key helm-find-files-map (kbd "TAB") 'helm-execute-persistent-action)
  (define-key helm-read-file-map (kbd "TAB") 'helm-execute-persistent-action)
  ;; Disable helm in some functions
  (add-to-list 'helm-completing-read-handlers-alist '(find-alternate-file . nil))
  ;; Emulate `kill-line' in helm minibuffer
  (setq helm-delete-minibuffer-contents-from-point t)
  (defadvice helm-delete-minibuffer-contents (before helm-emulate-kill-line activate)
    "Emulate `kill-line' in helm minibuffer"
    (kill-new (buffer-substring (point) (field-end))))
  (defadvice helm-ff-kill-or-find-buffer-fname (around execute-only-if-exist activate)
    "Execute command only if CANDIDATE exists"
    (when (file-exists-p candidate)
      ad-do-it))
  (defadvice helm-ff-transform-fname-for-completion (around my-transform activate)
    "Transform the pattern to reflect my intention"
    (let* ((pattern (ad-get-arg 0))
	   (input-pattern (file-name-nondirectory pattern))
	   (dirname (file-name-directory pattern)))
      (setq input-pattern (replace-regexp-in-string "\\." "\\\\." input-pattern))
      (setq ad-return-value
	    (concat dirname
		    (if (string-match "^\\^" input-pattern)
			;; '^' is a pattern for basename
			;; and not required because the directory name is prepended
			(substring input-pattern 1)
		      (concat ".*" input-pattern)))))))
(setq helm-ff-transformer-show-only-basename nil)
(setq helm-buffer-max-length 50)
(setq ffip-prune-patterns `("*/.mypy_cache"))

;;######################################################
;; Language Settings
;;######################################################

;; web
(global-linum-mode)
(require 'web-mode)
(require 'prettier-js)
(add-to-list 'auto-mode-alist '("\\.phtml$"     . web-mode))
(add-to-list 'auto-mode-alist '("\\.tpl\\.php$" . web-mode))
(add-to-list 'auto-mode-alist '("\\.jsp$"       . web-mode))
(add-to-list 'auto-mode-alist '("\\.jsx$"       . web-mode))
(add-to-list 'auto-mode-alist '("\\.tsx$"       . web-mode))
(add-to-list 'auto-mode-alist '("\\.as[cp]x$"   . web-mode))
(add-to-list 'auto-mode-alist '("\\.erb$"       . web-mode))
(add-to-list 'auto-mode-alist '("\\.html?$"     . web-mode))
(add-to-list 'auto-mode-alist '("\\.tmpl?$"     . web-mode))
(defun web-mode-hook ()
  "Hooks for Web mode."
  (setq web-mode-html-offset   2)
  (setq web-mode-markup-indent-offset 2)
  (setq web-mode-code-indent-offset 2)
  (setq web-mode-css-offset    2)
  (setq web-mode-script-offset 2)
  (setq web-mode-php-offset    2)
  (setq web-mode-java-offset   2)
  (setq web-mode-asp-offset    2)
  )
(add-hook 'web-mode-hook 'web-mode-hook)
(add-hook 'web-mode-hook 'prettier-js-mode)
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(company-tooltip ((t (:background "#333333" :foreground "white"))))
 '(company-tooltip-annotation ((t (:inherit company-tooltip :foreground "white"))))
 '(company-tooltip-common ((t (:inherit company-tooltip :foreground "white"))))
 '(company-tooltip-common-selection ((t (:inherit company-tooltip-selection :foreground "white"))))
 '(company-tooltip-scrollbar-thumb ((t (:background "blue"))))
 '(company-tooltip-scrollbar-track ((t (:inherit company-tooltip :background "dim gray"))))
 '(company-tooltip-selection ((t (:inherit company-tooltip :background "#131388"))))
 '(mode-line ((t (:foreground "#F8F8F2" :background "#303030" :box (:line-width 1 :color "#000000" :style released-button)))))
 '(mode-line-buffer-id ((t (:foreground nil :background nil))))
 '(mode-line-inactive ((t (:foreground "#BCBCBC" :background "#101010" :box (:line-width 1 :color "#333333")))))
 '(web-mode-block-delimiter-face ((t :inherit font-lock-negation-char-face)))
 '(web-mode-comment-face ((t :inherit font-lock-comment-face)))
 '(web-mode-css-at-rule-face ((t :inherit font-lock-keyword-face)))
 '(web-mode-css-color-face ((t :inherit font-lock-reference-face)))
 '(web-mode-css-pseudo-class-face ((t :inherit font-lock-function-name-face)))
 '(web-mode-css-rule-face ((t :inherit font-lock-function-name-face)))
 '(web-mode-current-element-highlight-face ((t :inherit font-lock-builtin-face)))
 '(web-mode-doctype-face ((t :inherit font-lock-doc-face)))
 '(web-mode-error-face ((t :inherit font-lock-warning-face)))
 '(web-mode-function-call-face ((t :inherit font-lock-function-name-face)))
 '(web-mode-function-name-face ((t :inherit font-lock-function-name-face)))
 '(web-mode-html-attr-name-face ((t :inherit font-lock-variable-name-face)))
 '(web-mode-html-attr-value-face ((t :inherit font-lock-string-face)))
 '(web-mode-html-tag-bracket-face ((t :inherit font-lock-negation-char-face)))
 '(web-mode-html-tag-face ((t :inherit font-lock-function-name-face)))
 '(web-mode-javascript-comment-face ((t :inherit font-lock-comment-face)))
 '(web-mode-javascript-string-face ((t :inherit font-lock-string-face)))
 '(web-mode-json-comment-face ((t :inherit font-lock-comment-face)))
 '(web-mode-json-key-face ((t :inherit font-lock-keyword-face)))
 '(web-mode-json-string-face ((t :inherit font-lock-string-face)))
 '(web-mode-keyword-face ((t :inherit font-lock-keyword-face)))
 '(web-mode-param-name-face ((t :inherit font-lock-variable-name-face)))
 '(web-mode-preprocessor-face ((t :inherit font-lock-preprocessor-face)))
 '(web-mode-server-comment-face ((t :inherit font-lock-comment-face)))
 '(web-mode-string-face ((t :inherit font-lock-string-face)))
 '(web-mode-type-face ((t :inherit font-lock-type-face)))
 '(web-mode-variable-name-face ((t :inherit font-lock-variable-name-face)))
 '(web-mode-warning-face ((t :inherit font-lock-warning-face))))

(add-hook 'web-mode-hook #'(lambda ()
                            (enable-minor-mode
                             '("\\.[jt]sx?\\'" . prettier-js-mode))))


;; typescript
(use-package add-node-modules-path
  :hook (web-mode, typescript-mode))
(use-package flycheck
  :config
  (flycheck-add-mode 'javascript-eslint 'web-mode)
  (flycheck-add-mode 'javascript-eslint 'typescript-mode)
  (global-flycheck-mode t))

(require 'typescript-mode)
(add-hook 'typescript-mode-hook '(lambda () (setq typescript-indent-level 2)))
(add-to-list 'auto-mode-alist '("\.ts$" . typescript-mode))
(require 'ansi-color)
(defun colorize-compilation-buffer ()
  (ansi-color-apply-on-region compilation-filter-start (point-max)))
(add-hook 'compilation-filter-hook 'colorize-compilation-buffer)

(use-package lsp-mode
  :ensure t
  :commands (lsp lsp-deferred)
  :hook (typescript-mode . lsp-deferred))

(add-hook 'typescript-mode-hook 'prettier-js-mode)
(add-hook 'typescript-mode #'(lambda ()
                               (enable-minor-mode
                                '("\\.[jt]sx?\\'" . prettier-js-mode))))

;; yaml
(require 'yaml-mode)
(add-to-list 'auto-mode-alist '("\\.yml$" . yaml-mode))
(add-to-list 'auto-mode-alist '("\\.yaml$" . yaml-mode))
(require 'openapi-yaml-mode)
(add-to-list 'auto-mode-alist '("apispec/.*\\.ya?ml$" . openapi-yaml-mode))

;; js
(require 'js2-mode)
(add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))

;; json
(add-hook 'js-mode-hook
          (lambda ()
            (make-local-variable 'js-indent-level)
            (setq js-indent-level 2)))

;; vue
(require 'vue-mode)
(add-to-list 'auto-mode-alist '("\\.vue$" . vue-mode))

;; Perl
(require 'cperl-mode)
(defalias 'perl-mode 'cperl-mode)
(setq auto-mode-alist
      (append '(("\\.\\([pP][Llm]\\|t\\)$" . cperl-mode))  auto-mode-alist ))
(setq indent-tabs-mode nil)
(setq cperl-close-paren-offset -4)
(setq cperl-continued-statement-offset 4)
(setq cperl-indent-level 4)
(setq cperl-indent-parens-as-block t)
(setq cperl-label-offset -4)
(setq cperl-highlight-variables-indiscriminately t)
(setq cperl-tab-always-indent t)

;; python
(pyenv-mode)
(add-hook 'python-mode-hook 'flymake-python-pyflakes-load)
(setq flymake-python-pyflakes-executable "~/.pyenv/shims/flake8")
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(company-minimum-prefix-length 1)
 '(company-selection-wrap-around t)
 '(flymake-python-pyflakes-extra-arguments (quote ("--max-line-length=120" "--ignore=E128")))
 '(package-selected-packages
   (quote
    (sphinx-doc yaml-mode web-mode pyenv-mode js2-mode helm flymake-python-pyflakes elpy auto-complete))))
(defun flymake-show-help ()
  (when (get-char-property (point) 'flymake-overlay)
    (let ((help (get-char-property (point) 'help-echo)))
      (if help (message "%s" help)))))
(add-hook 'post-command-hook 'flymake-show-help)
(add-hook 'python-mode-hook (lambda ()
                              (require 'sphinx-doc)
                              (sphinx-doc-mode t)))

;; autopep8
(require 'py-autopep8)
(add-hook 'python-mode-hook '(lambda ()
                               (define-key python-mode-map (kbd "C-c f") 'py-autopep8-region)))

;; pyenv for elpy
(require 'set-pyenv-version-path)
(add-hook 'find-file-hook 'set-pyenv-version-path)
(add-to-list 'exec-path "~/.pyenv/shims")

;; python-elpy
(elpy-enable)

(setq elpy-rpc-backend "jedi")


(add-hook 'python-mode-hook '(lambda ()
                               (define-key python-mode-map (kbd "C-c C-g") 'elpy-goto-definition)))

;; aiml
(add-to-list 'auto-mode-alist '("\\.aiml$"     . xml-mode))

;; protobuf-mode
(require 'protobuf-mode)
(add-to-list 'auto-mode-alist '("\\.proto$" . protobuf-mode))


;;######################################################
;; Hooks
;;######################################################

;; test on save
(require 'save-hook)
 (add-hook 'before-save-hook 'delete-trailing-whitespace)
(add-hook 'after-save-hook 'save-hook)
(setq compilation-window-height 20)
(put 'upcase-region 'disabled nil)
