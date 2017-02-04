;;; init-local --- Minhas configurações
;;; Commentary:
;;; Code:

(require 'package)

(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/"))
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
(add-to-list 'package-archives '("melpa-stable" . "http://stable.melpa.org/packages/"))

(setq package-enable-at-startup nil)
(package-initialize)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes (quote (deeper-blue))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; Ensure packages
(defun ensure-package-installed (&rest packages)
  "Assure every package is installed, ask for installation if it’s not.
Return a list of installed packages or nil for every skipped package."
  (mapcar
   (lambda (package)
     (if (package-installed-p package)
         nil
       (if (y-or-n-p (format "Package %s is missing. Install it? " package))
           (package-install package)
         package)))
   packages))

;; Make sure to have downloaded archive description.
(or (file-exists-p package-user-dir)
    (package-refresh-contents))

;; Activate installed packages
(package-initialize)

;; Assuming you wish to install "iedit" and "magit"
(ensure-package-installed
 'iedit
 ;; 'magit # Requer o emacs 24.4+
 'evil
 'todotxt
 ;; 'elpy ;; Utilizando o anaconda-mode
 'neotree
 'cmake-ide
 'rtags
 'ggtags
 'irony
 'sr-speedbar ;; Para speedbar https://is.gd/frRIZO
 'company     ;; Para compleção de código https://is.gd/frRIZO
 'ggtags      ;; Para completar códigos (https://is.gd/frRIZO)
 'fill-column-indicator ;; Para indicar a coluna de quebra de linha
 ;; https://is.gd/ZNEz1v
 'arduino-mode
 'company-c-headers
 'org-journal
 'org-bullets
 'zenburn-theme
 )

;; (require 'elpy)
;; (elpy-enable)
(require 'evil)
(evil-mode 1)
(require 'todotxt)
(add-to-list 'auto-mode-alist '("\\todo.txt\\'" . todotxt-mode))
(require 'neotree)
(global-set-key [f8] 'neotree-toggle)

;; Auto fill mode será habilitado em modo texto (a quebra de linha será ativada automaticamente)
(add-hook 'text-mode-hook 'turn-on-auto-fill)

;; Para a completar código no minibuffer
(require 'ido)
(ido-mode t)

;; Todos os buffers com numeração de linha
(global-linum-mode 1)

;; Para o smerge
(setq smerge-command-prefix "\C-cv")

;; Para o cmake-ide
(require 'rtags) ;; optional, must have rtags installed
(cmake-ide-setup)

;; CONFIGURAÇÃO DO IRONY
(add-hook 'c++-mode-hook 'irony-mode)
(add-hook 'c-mode-hook 'irony-mode)
(add-hook 'objc-mode-hook 'irony-mode)

;; replace the `completion-at-point' and `complete-symbol' bindings in
;; irony-mode's buffers by irony-mode's function
(defun my-irony-mode-hook ()
  (define-key irony-mode-map [remap completion-at-point]
    'irony-completion-at-point-async)
  (define-key irony-mode-map [remap complete-symbol]
    'irony-completion-at-point-async))
(add-hook 'irony-mode-hook 'my-irony-mode-hook)
(add-hook 'irony-mode-hook 'irony-cdb-autosetup-compile-options)

;; Configuração do company mode (https://is.gd/frRIZO)
(require 'company)
(add-hook 'after-init-hook 'global-company-mode)
;; ---------------------------------------------------

;; Configuração do ggtags (https://is.gd/frRIZO)
(require 'ggtags)
(add-hook 'c-mode-common-hook
          (lambda ()
            (when (derived-mode-p 'c-mode 'c++-mode 'java-mode 'asm-mode)
              (ggtags-mode 1))))

(define-key ggtags-mode-map (kbd "C-c g s") 'ggtags-find-other-symbol)
(define-key ggtags-mode-map (kbd "C-c g h") 'ggtags-view-tag-history)
(define-key ggtags-mode-map (kbd "C-c g r") 'ggtags-find-reference)
(define-key ggtags-mode-map (kbd "C-c g f") 'ggtags-find-file)
(define-key ggtags-mode-map (kbd "C-c g c") 'ggtags-create-tags)
(define-key ggtags-mode-map (kbd "C-c g u") 'ggtags-update-tags)

(define-key ggtags-mode-map (kbd "M-,") 'pop-tag-marka)

(setq-local imenu-create-index-function #'ggtags-build-imenu-index)
;; ---------------------------------------------

;; Configuração do emacs intelhex https://is.gd/u7Ejms
(add-to-list 'load-path "~/.emacs.d/intelhex/")
(load-library "intel-hex-mode")
(require 'intel-hex-mode)
;; ------------------------------

;; Para a compilação do código https://is.gd/nymvUQ
(require 'ansi-color)
(defun colorize-compilation-buffer ()
  (toggle-read-only)
  (ansi-color-apply-on-region compilation-filter-start (point))
  (toggle-read-only))
(add-hook 'compilation-filter-hook 'colorize-compilation-buffer)
;; ------------------------------------------------


;; Source code completion using Clang (https://is.gd/QEF0AO)
(setq company-backends (delete 'company-semantic company-backends))
(define-key c-mode-map  [(tab)] 'company-complete)
(define-key c++-mode-map  [(tab)] 'company-complete)
;; ------------------------------------------------------

;; Fill column indicator config https://is.gd/ZNEz1v
(require 'fill-column-indicator)
(define-globalized-minor-mode
  global-fci-mode fci-mode (lambda () (fci-mode 1)))
(global-fci-mode t)
;; ------------------------------------------

;; Arduino support (https://is.gd/nQIe3V)
(require 'arduino-mode)
;; -------------------------------------

;; Google C style https://is.gd/2qFVTD
(require 'google-c-style)
;; ----------------------------

;; Ipython como padrão (https://is.gd/ZNEz1v)
;; use IPython
;;use IPython
(setq python-shell-interpreter "ipython"
      python-shell-interpreter-args "--simple-prompt -i")

;;(setq-default py-shell-name "ipython")
;;(setq-default py-which-bufname "IPython")
;;; use the wx backend, for both mayavi and matplotlib
;;(setq py-python-command-args
;;  '("--gui=wx" "--pylab=wx" "-colors" "Linux"))
;;(setq py-force-py-shell-name-p t)
;;
;;; switch to the interpreter after executing code
;;(setq py-shell-switch-buffers-on-execute-p t)
;;(setq py-switch-buffers-on-execute-p t)
;;; don't split windows
;;(setq py-split-windows-on-execute-p nil)
;;; try to automagically figure out indentation
;;(setq py-smart-indentation t)
;; -----------------------------------------------

;; Seta o default para ipython https://is.gd/UmHKa5
                                        ; (when (executable-find "ipython")
                                        ;  (setq python-shell-interpreter "ipython")
;; -----------------------------

;; Header file completion https://is.gd/MiNN7W
;;(add-to-list 'company-backends 'company-c-headers)
;;;; --------------------------------------------
;;
;;;; Semantic
;;(require 'cc-mode)
;;(require 'semantic)
;;
;;(global-semanticdb-minor-mode 1)
;;(global-semantic-idle-scheduler-mode 1)
;;
;;(semantic-mode 1)
;; -----------------------------------------------

;; Zenburn theme
;;(load-theme 'zenburn t)

;; Habilita o scroll bar
(scroll-bar-mode 1)

;; Deleta para a lixeira
(setq delete-by-moving-to-trash t)

;; Para journalling
(require 'org-journal)
(setq org-journal-dir "~/Documentos/journal/" )

;; Orgmode bullets mais organizados
(require 'org-bullets)
(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))

;; Syntax highlight dentro do source no org-mode
(setq org-src-fontify-natively t)

(provide 'init-local)
;;; init-local ends here

(defun my-org-archive-done-tasks ()
  (interactive)
  (org-map-entries 'org-archive-subtree "/DONE" 'file))

;; Randomize region
(defun my-randomize-region (beg end)
  "Randomize lines in region from BEG to END."
  (interactive "*r")
  (let ((lines (split-string
                (delete-and-extract-region beg end) "\n")))
    (when (string-equal "" (car (last lines 1)))
      (setq lines (butlast lines 1)))
    (apply 'insert
           (mapcar 'cdr
                   (sort (mapcar (lambda (x) (cons (random) (concat x "\n"))) lines)
                         (lambda (a b) (< (car a) (car b))))))))

;; http://stackoverflow.com/questions/6997387/how-to-archive-all-the-done-tasks-using-a-single-command

;; Configuraçoes para o auctex
(setq TeX-auto-save t)
(setq TeX-parse-self t)
(setq-default TeX-master nil)

(add-hook 'LaTeX-mode-hook 'visual-line-mode)
(add-hook 'LaTeX-mode-hook 'flyspell-mode)
(add-hook 'LaTeX-mode-hook 'LaTeX-math-mode)

(add-hook 'LaTeX-mode-hook 'turn-on-reftex)
(setq reftex-plug-into-AUCTeX t)
