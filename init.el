;;; init.el --- Minimal and Optimal Emacs Configuration ;;;-*- lexical-binding: t; -*-

;; ==========================================
;; 1. SEPARATE CUSTOM FILE
;; ==========================================
;; Keep init.el clean by moving Emacs-generated customization to a separate file
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file))

;; ==========================================
;; 2. PACKAGE MANAGEMENT SETUP
;; ==========================================
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; Ensure use-package is available (built-in in Emacs 29+)
(require 'use-package)
(setq use-package-always-ensure t) ; Automatically download packages

;; ==========================================
;; 3. SANER COMMUNITY DEFAULTS
;; ==========================================
;; Clean up the UI - Remove clutter immediately
(setq inhibit-startup-message t)
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

;; Editor behavior
(global-display-line-numbers-mode t)  ; Show line numbers
(column-number-mode t)                ; Show column number in mode line
(electric-pair-mode t)                ; Auto-close brackets/quotes
(setq-default indent-tabs-mode nil)   ; Use spaces instead of tabs
(setq-default tab-width 4)            ; Set default tab width to 4 spaces

;; Backup files management (Don't clutter source directories)
(setq make-backup-files nil)          ; Disable *~ backup files
(setq create-lockfiles nil)           ; Disable .# lock files

;; Enable modern Copy/Paste/Undo
(cua-mode t)

;; ==========================================
;; 4. THEME (Gruber Darker)
;; ==========================================
(use-package gruber-darker-theme
  :config
  (load-theme 'gruber-darker t))

;; Set Default Font & Font Size (140 = 14.0 pt)
(set-face-attribute 'default nil :font "JetBrainsMono Nerd Font" :height 140)

;; ==========================================
;; 5. INTUITIVE NAVIGATION & DIRED
;; ==========================================
;; Vertico provides a minimal and intuitive vertical completion UI
(use-package vertico
  :init
  (vertico-mode 1))

;; Dired (Built-in File Manager) configuration
(use-package dired
  :ensure nil ; It's built-in, no need to download
  :bind (("C-x C-j" . dired-jump)) ; Instantly open the directory of the current file
  :custom
  ;; -a: show all, -g: hide owner, -h: human readable, -o: hide group
  ;; --group-directories-first: lists folders before files
  (dired-listing-switches "-agho --group-directories-first")
  (dired-dwim-target t)) ; Predict target directory if two dired windows are open

;; ==========================================
;; 6. LANGUAGE DEVELOPMENT SETUP
;; ==========================================

(unless (package-installed-p 'simpc-mode)
  (package-vc-install "https://github.com/rexim/simpc-mode"))
(use-package simpc-mode
  :ensure nil ; Prevent use-package from searching for it on MELPA
  :mode "\\.[ch]\\'")

(use-package rust-mode
  :mode "\\.rs\\'")

(use-package go-mode
  :mode "\\.go\\'")

(use-package web-mode
  :mode ("\\.html?\\'" "\\.css\\'" "\\.js\\'" "\\.ts\\'")
  :custom
  (web-mode-markup-indent-offset 2)
  (web-mode-css-indent-offset 2)
  (web-mode-code-indent-offset 2))

(use-package git-modes)

(use-package dotenv-mode
  :mode ("\\.env\\'" "\\.env\\..*\\'"))

(use-package markdown-mode
  :mode ("\\.md\\'" "\\.markdown\\'")
  :custom
  (markdown-command "pandoc"))

(use-package json-mode
  :mode "\\.json\\'")

(use-package yaml-mode
  :mode "\\.ya?ml\\'")

(use-package toml-mode
  :mode "\\.toml\\'")

;; ==========================================
;; 7. AUTOCOMPLETION & LSP
;; ==========================================
;; Corfu: Minimal popup interface for auto-completion
(use-package corfu
  :custom
  (corfu-auto t)               ; Show popup automatically
  (corfu-quit-no-match t)      ; Close if there are no matches
  :init
  (global-corfu-mode))

;; Eglot: Built-in LSP client
(use-package eglot
  :ensure nil ; Built-in in Emacs 29+
  :hook ((simpc-mode . eglot-ensure)
         (rust-mode  . eglot-ensure)
         (go-mode    . eglot-ensure)))

;; ==========================================
;; 8. FORMATTING (Apheleia)
;; ==========================================
;; Asynchronous code formatting on save (doesn't move cursor)
(use-package apheleia
  :config
  (apheleia-global-mode +1)
  ;; Tell Apheleia to use clang-format for Tsoding's simpc-mode
  (add-to-list 'apheleia-mode-alist '(simpc-mode . clang-format)))

;; ==========================================
;; 9. DOCUMENTATION (DevDocs)
;; ==========================================
;; Fast, offline documentation browser (devdocs.io)
(use-package devdocs
  :bind
  ;; Bind to Emacs' standard help prefix (C-h)
  ("C-h D" . devdocs-lookup))

;; ==========================================
;; 10. PROJECT MANAGEMENT (Built-in project.el)
;; ==========================================
;; Emacs automatically treats any Git repository as a project.
;; Prefix: C-x p
(use-package project
  :ensure nil
  :custom
  ;; What to do when switching projects (C-x p p)
  ;; We set it to open the project root in Dired
  (project-switch-commands '((project-dired "Dired" ?d)
                             (project-find-file "Find file" ?f)
                             (project-find-regexp "Find regexp" ?g))))

;; ==========================================
;; 11. GIT INTEGRATION (Magit)
;; ==========================================
;; The magical Git interface for Emacs.
(use-package magit
  ;; Bind the main entry point to a global shortcut
  :bind (("C-x g" . magit-status)))

;;; init.el ends here
