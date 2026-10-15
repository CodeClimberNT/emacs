;;; init.el --- Minimal and Optimal Emacs Configuration ;;;-*- lexical-binding: t; -*-

;; Assumes Emacs 30+ (flymake end-of-line diagnostics, built-in which-key).

;; ==========================================
;; 1. SEPARATE CUSTOM FILE
;; ==========================================
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file))

;; Hide warning popups from compiling third-party packages (not problems in this file)
(setq native-comp-async-report-warnings-errors 'silent)
;; Hide the "Missing lexical-binding cookie" notice from old packages (gruber-darker).
;; Note: this hides every warning of type `files'.
(add-to-list 'warning-suppress-types '(files))

;; ==========================================
;; 2. PACKAGE MANAGEMENT SETUP
;; ==========================================
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(require 'use-package)
(setq use-package-always-ensure t)

;; GUI Emacs launched from KDE often misses ~/.cargo/bin, ~/.local/bin, etc.
;; This imports PATH from your login shell so rust-analyzer, ruff, rg... are found.
(use-package exec-path-from-shell
  :if (or (daemonp) (display-graphic-p))
  :config (exec-path-from-shell-initialize))

;; ==========================================
;; 3. SANER COMMUNITY DEFAULTS
;; ==========================================
(setq inhibit-startup-message t)
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

;; Line numbers only where they make sense (not in magit, treemacs, shells...)
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(add-hook 'text-mode-hook #'display-line-numbers-mode)
(column-number-mode t)
(electric-pair-mode t)
(show-paren-mode t)
(global-hl-line-mode t)
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)

(setq make-backup-files nil)
(setq create-lockfiles nil)

(cua-mode t)

;; Session niceties
(recentf-mode 1)                       ; recent files (consult-buffer shows them)
(savehist-mode 1)                      ; remember minibuffer history
(save-place-mode 1)                    ; reopen files at last cursor position
(global-auto-revert-mode 1)            ; reload files changed on disk (git checkout!)
(setq global-auto-revert-non-file-buffers t)
(pixel-scroll-precision-mode 1)        ; smooth scrolling
(setq use-short-answers t)             ; y/n instead of yes/no
(setq ring-bell-function 'ignore)
(which-key-mode 1)                     ; shows available keys after a prefix

;; --- VS Code-style editing keys ---
(global-set-key (kbd "C-S-d") #'duplicate-dwim) ; duplicate line/region

;; Alt+Shift+Up/Down = copy line(s) up/down, like VS Code on Windows.
;; Works on the current line or on all lines touched by the active region;
;; point (or the region) ends up on the copy.
(defun my/duplicate-lines (up)
  "Duplicate current line or region lines. Copy goes above if UP, else below."
  (let* ((region (use-region-p))
         (col (current-column))
         (beg (save-excursion
                (goto-char (if region (region-beginning) (point)))
                (line-beginning-position)))
         (end (save-excursion
                (goto-char (if region (region-end) (point)))
                (when (and region (bolp) (> (point) beg)) (backward-char))
                (line-end-position)))
         (text (buffer-substring beg end))
         (len (- end beg))
         (cbeg (if up beg (1+ end))))
    (if up
        (progn (goto-char beg) (insert text "\n"))
      (goto-char end) (insert "\n" text))
    (if region
        (progn (set-mark cbeg) (goto-char (+ cbeg len)) (setq deactivate-mark nil))
      (goto-char cbeg) (move-to-column col))))

(defun my/duplicate-lines-up ()
  "Copy the current line (or region lines) above."
  (interactive) (my/duplicate-lines t))

(defun my/duplicate-lines-down ()
  "Copy the current line (or region lines) below."
  (interactive) (my/duplicate-lines nil))

(global-set-key (kbd "M-S-<up>")   #'my/duplicate-lines-up)
(global-set-key (kbd "M-S-<down>") #'my/duplicate-lines-down)
(global-set-key (kbd "C-;")   #'comment-line)   ; toggle comment

(use-package move-text                 ; Alt+Up / Alt+Down moves line/region
  :config (move-text-default-bindings))

(use-package expand-region             ; grow selection semantically
  :bind ("C-=" . er/expand-region))

;; ==========================================
;; 4. THEME (Gruber Darker)
;; ==========================================
;; Local copy (already lexical-binding) in ~/.config/emacs/themes/gruber-darker-theme.el
(add-to-list 'custom-theme-load-path
             (expand-file-name "themes" user-emacs-directory))
(load-theme 'gruber-darker t)

(set-face-attribute 'default nil :font "JetBrainsMono Nerd Font" :height 140)

;; Icons (run M-x nerd-icons-install-fonts once if icons look broken)
(use-package nerd-icons)

(use-package nerd-icons-dired
  :hook (dired-mode . nerd-icons-dired-mode))

;; ==========================================
;; 5. NAVIGATION, SEARCH & DIRED
;; ==========================================
(use-package vertico
  :init (vertico-mode 1))

;; Backspace deletes a whole path component when finding files
(use-package vertico-directory
  :ensure nil
  :after vertico
  :bind (:map vertico-map ("DEL" . vertico-directory-delete-char)))

;; In the C-x C-f file prompt, list folders first, then files
(use-package vertico-multiform
  :ensure nil
  :after vertico
  :config
  (defun my/sort-directories-first (files)
    (setq files (vertico-sort-history-length-alpha files))
    (nconc (seq-filter (lambda (x) (string-suffix-p "/" x)) files)
           (seq-remove (lambda (x) (string-suffix-p "/" x)) files)))
  (setq vertico-multiform-categories
        '((file (vertico-sort-function . my/sort-directories-first))))
  (vertico-multiform-mode 1))

;; Fuzzy-ish matching: "usr lib" matches "/usr/local/lib"
;; :config only runs if orderless really loaded, so a failed install can't break M-x
(use-package orderless
  :config
  (setq completion-styles '(orderless basic)
        completion-category-overrides '((file (styles basic partial-completion)))))

;; Descriptions next to every candidate in the minibuffer
(use-package marginalia
  :init (marginalia-mode 1))

(use-package nerd-icons-completion
  :after marginalia
  :hook (marginalia-mode . nerd-icons-completion-marginalia-setup)
  :config (nerd-icons-completion-mode 1))

;; Consult: VS Code's Ctrl+Shift+F, Ctrl+Tab, Ctrl+G, Ctrl+Shift+O, Problems panel
(use-package consult
  :bind (("C-x b"   . consult-buffer)       ; buffers + recent files + bookmarks
         ("M-s r"   . consult-ripgrep)      ; search whole project (needs `rg`)
         ("M-s l"   . consult-line)         ; search in current file
         ("M-g g"   . consult-goto-line)
         ("M-g i"   . consult-imenu)        ; symbols in file
         ("M-g f"   . consult-flymake)))    ; list of errors/warnings

;; Dired
(use-package dired
  :ensure nil
  :bind (("C-x C-j" . dired-jump))
  :custom
  (dired-listing-switches "-agho --group-directories-first")
  (dired-dwim-target t)
  (dired-kill-when-opening-new-dired-buffer t) ; don't pile up dired buffers
  (dired-auto-revert-buffer t)
  (delete-by-moving-to-trash t))
;; Folders: listed first (--group-directories-first above), icon via nerd-icons-dired,
;; and a bold name. Uncomment the second line to force a specific color too.
(with-eval-after-load 'dired
  (set-face-attribute 'dired-directory nil :weight 'bold)
  ;; (set-face-attribute 'dired-directory nil :foreground "#96a6c8")
  )
;; Tip: in dired press C-x C-q to rename/edit files like a normal buffer (wdired).

;; --- Side file explorer (VS Code sidebar) ---
(use-package treemacs
  :bind (("<f8>"   . treemacs)               ; toggle sidebar
         ("C-<f8>" . treemacs-select-window))
  :custom
  (treemacs-width 32)
  :config
  (treemacs-follow-mode t)                   ; highlight the file you're editing
  (treemacs-filewatch-mode t)                ; auto-refresh on disk changes
  (treemacs-git-mode 'deferred))             ; git status colors (needs python3)

(use-package treemacs-nerd-icons
  :after treemacs
  :config (treemacs-load-theme "nerd-icons"))

(use-package treemacs-magit
  :after (treemacs magit))

;; ==========================================
;; 6. MULTIPLE CURSORS
;; ==========================================
(use-package multiple-cursors
  :bind (("C->"           . mc/mark-next-like-this)      ; ~ Ctrl+D in VS Code
         ("C-<"           . mc/mark-previous-like-this)
         ("C-c C-<"       . mc/mark-all-like-this)       ; ~ Ctrl+Shift+L
         ("C-S-c C-S-c"   . mc/edit-lines)               ; cursor on each selected line
         ("C-S-<mouse-1>" . mc/add-cursor-on-click)      ; ~ Alt+Click
         ("C-M-<up>"      . mc/mark-previous-lines)      ; add cursor above (Ctrl+Alt+Up)
         ("C-M-<down>"    . mc/mark-next-lines))         ; add cursor below (Ctrl+Alt+Down)
  :config
  ;; Never ask "do this command for all cursors?": run every command on all cursors.
  ;; (Commands in `mc/cmds-to-run-once' still run once, e.g. the ones that open prompts.)
  (setq mc/always-run-for-all t)
  ;; Run these on every cursor without the one-time "do for all cursors?" prompt
  (dolist (cmd '(my/duplicate-lines-up my/duplicate-lines-down duplicate-dwim
                 move-text-up move-text-down comment-line))
    (add-to-list 'mc/cmds-to-run-for-all cmd)))

;; ==========================================
;; 7. LANGUAGE DEVELOPMENT SETUP
;; ==========================================
(unless (package-installed-p 'simpc-mode)
  (package-vc-install "https://github.com/rexim/simpc-mode"))
(use-package simpc-mode
  :ensure nil
  :mode "\\.[ch]\\'")

(use-package rust-mode
  :mode "\\.rs\\'")

(use-package go-mode
  :mode "\\.go\\'")

;; NOTE: web-mode is weak for JS/TS. Later consider typescript-ts-mode/js-ts-mode
;; (tree-sitter) + typescript-language-server via eglot.
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

;; --- Chezmoi & Go Templates (.tmpl) ---
(use-package go-template-mode)

(use-package polymode
  :config
  (define-hostmode poly-chezmoi-hostmode :mode nil)

  (define-innermode poly-chezmoi-innermode
    :mode 'go-template-mode
    :head-matcher "{{"
    :tail-matcher "}}"
    :head-mode 'host
    :tail-mode 'host)

  (define-polymode poly-chezmoi-mode
    :hostmode 'poly-chezmoi-hostmode
    :innermodes '(poly-chezmoi-innermode))

  (add-to-list 'auto-mode-alist '("\\.tmpl\\'" . poly-chezmoi-mode)))

;; ------------------------------------------
;; 7b. LANGUAGE SERVERS (eglot)
;; ------------------------------------------
;; Eglot runs ONE server per buffer. Install the server binary, then eglot-ensure
;; starts it when you open a file. (Edit hooks here; the eglot setup is in section 8.)
;;   Rust:    rustup component add rust-analyzer
;;   Go:      go install golang.org/x/tools/gopls@latest
;;   C/C++:   pacman -S clangd  (project needs compile_commands.json or compile_flags.txt)
;;   Python:  ty + ruff: `uv tool install ty ruff', or add them as dev dependencies
;;            (ty falls back to `uvx ty server' when it is not installed)

;; simpc-mode derives from prog-mode (not c-mode), so eglot doesn't know it by default.
;; Map it to clangd; :language-id "c" avoids Eglot telling clangd the language is "simpc".
(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs '((simpc-mode :language-id "c") . ("clangd"))))

;; --- ENABLED: C, C++, Rust, Go ---
(dolist (hook '(simpc-mode-hook c-mode-hook c++-mode-hook c-ts-mode-hook c++-ts-mode-hook
                rust-mode-hook go-mode-hook))
  (add-hook hook #'eglot-ensure))

;; --- ENABLED: Python (uv + .venv, ty for types/completion, ruff for lint+format) ---
;; Emacs does NOT activate a .venv by itself. This puts <project>/.venv/bin first on PATH for
;; the buffer (before eglot starts), so the server's `python` is the venv's python and imports
;; resolve. The same PATH is used by M-x compile / python-shell / apheleia. If you create the
;; .venv after opening a file, run M-x eglot-reconnect.
(defun my/python-use-project-venv ()
  "Prepend the nearest .venv/bin to PATH for this buffer."
  (when-let* ((root (locate-dominating-file default-directory ".venv"))
              (venv (expand-file-name ".venv" root))
              (bin  (expand-file-name "bin" venv))
              ((file-directory-p bin)))
    (setq-local exec-path (cons bin exec-path))
    (setq-local process-environment
                (append (list (concat "VIRTUAL_ENV=" venv)
                              (concat "PATH=" bin path-separator (getenv "PATH")))
                        process-environment))))

;; ty is the Python language server. Use the `ty' found on PATH (this includes the
;; project's .venv/bin, e.g. when ty is a dev dependency, or `uv tool install ty');
;; if there is none, run it through uvx. (The lsp-mode variable
;; `lsp-python-ty-clients-server-command' does not apply to eglot.)
(defun my/ty-server-contact (&optional _interactive)
  "Return the command that starts the ty language server."
  (if (executable-find "ty")
      '("ty" "server")
    '("uvx" "ty" "server")))

(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               '((python-mode python-ts-mode) . my/ty-server-contact)))
(add-hook 'python-base-mode-hook #'my/python-use-project-venv -90) ; must run before eglot
(add-hook 'python-base-mode-hook #'eglot-ensure)

;; Eglot only allows one server, so ruff diagnostics come via flymake and formatting via apheleia.
(use-package flymake-ruff)
(defun my/flymake-ruff-enable ()
  (when (derived-mode-p 'python-base-mode)
    (flymake-ruff-load)))
(add-hook 'eglot-managed-mode-hook #'my/flymake-ruff-enable)

(with-eval-after-load 'apheleia
  (dolist (mode '(python-mode python-ts-mode))
    (setf (alist-get mode apheleia-mode-alist) '(ruff-isort ruff)))) ; sort imports, then format

;; --- COMMENTED OUT: enable what you need ---

;; JavaScript / TypeScript (typescript-language-server)
;;   npm i -g typescript typescript-language-server
;;   1. Remove "\\.js\\'" and "\\.ts\\'" from the web-mode :mode list above.
;;   2. M-x treesit-install-language-grammar for: javascript, typescript, tsx.
;;   3. Uncomment:
;; (add-to-list 'auto-mode-alist '("\\.[cm]?jsx?\\'" . js-ts-mode))
;; (add-to-list 'auto-mode-alist '("\\.[cm]?ts\\'"   . typescript-ts-mode))
;; (add-to-list 'auto-mode-alist '("\\.tsx\\'"       . tsx-ts-mode))
;; (dolist (hook '(js-ts-mode-hook typescript-ts-mode-hook tsx-ts-mode-hook))
;;   (add-hook hook #'eglot-ensure))

;; HTML / CSS / JSON  (npm i -g vscode-langservers-extracted)
;; web-mode isn't in eglot's defaults, so map it explicitly:
;; (with-eval-after-load 'eglot
;;   (add-to-list 'eglot-server-programs '(web-mode . ("vscode-html-language-server" "--stdio"))))
;; (dolist (hook '(web-mode-hook css-mode-hook json-mode-hook))
;;   (add-hook hook #'eglot-ensure))

;; Bash (npm i -g bash-language-server)   YAML (npm i -g yaml-language-server)
;; Markdown (pacman -S marksman)   -- eglot knows these modes already:
;; (dolist (hook '(sh-mode-hook yaml-mode-hook markdown-mode-hook))
;;   (add-hook hook #'eglot-ensure))

;; Jai -- UNVERIFIED, I haven't tested these. jai-mode + Jails (community LSP):
;;   https://github.com/krig/jai-mode   https://github.com/SogoCZE/Jails
;;   Build `jails` and put it on PATH.
;; (unless (package-installed-p 'jai-mode)
;;   (package-vc-install "https://github.com/krig/jai-mode"))
;; (use-package jai-mode :ensure nil :mode "\\.jai\\'")
;; (with-eval-after-load 'eglot
;;   (add-to-list 'eglot-server-programs '((jai-mode :language-id "jai") . ("jails"))))
;; (add-hook 'jai-mode-hook #'eglot-ensure)

;; Editor-wide niceties for code
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package hl-todo                    ; highlights TODO / FIXME / NOTE
  :hook (prog-mode . hl-todo-mode))

(use-package breadcrumb                 ; file > symbol path in the header line
  :hook (prog-mode . breadcrumb-local-mode))

;; Snippets. Also REQUIRED for eglot to expand LSP completions with arguments.
(use-package yasnippet
  :hook (prog-mode . yas-minor-mode))
(use-package yasnippet-snippets
  :after yasnippet)

;; ==========================================
;; 8. AUTOCOMPLETION, LSP & ERROR LENS
;; ==========================================
(use-package corfu
  :custom
  (corfu-auto t)
  (corfu-auto-delay 0.1)
  (corfu-auto-prefix 2)
  (corfu-quit-no-match t)
  :init
  (global-corfu-mode))

;; Flymake = the diagnostics engine (eglot feeds it). This is your Error Lens:
;; messages are drawn at the end of the line, like the VS Code extension.
(use-package flymake
  :ensure nil
  :hook (prog-mode . flymake-mode)
  :custom
  (flymake-show-diagnostics-at-end-of-line 'short) ; try 'fancy for multi-line
  (flymake-no-changes-timeout 0.5)
  :bind (:map flymake-mode-map
              ("M-n" . flymake-goto-next-error)
              ("M-p" . flymake-goto-prev-error)))

;; Eglot: built-in LSP client
;; Install servers: rust-analyzer (rustup), gopls, clangd,
;; and for Python: basedpyright (or pyright) + ruff.
(use-package eglot
  :ensure nil
  ;; Per-language eglot-ensure hooks live in section 7b
  :hook (toml-mode . my/eglot-cargo-toml)
  :bind (:map eglot-mode-map
              ("C-c r" . eglot-rename)
              ("C-c a" . eglot-code-actions)       ; quick fixes (Ctrl+.)
              ("C-c o" . eglot-code-action-organize-imports)
              ("C-c h" . eldoc))
  :custom
  (eglot-autoshutdown t)                           ; kill server with last buffer
  (eglot-events-buffer-config '(:size 0))          ; less overhead
  :config
  ;; Inline crate version hints/diagnostics in Cargo.toml via crates-lsp.
  ;; Install with: cargo install crates-lsp   (experimental - verify it works for you)
  (add-to-list 'eglot-server-programs '(toml-mode . ("crates-lsp")))
  (defun my/eglot-cargo-toml ()
    "Start eglot only for Cargo.toml files."
    (when (equal (file-name-nondirectory (or buffer-file-name "")) "Cargo.toml")
      (eglot-ensure))))

;; ==========================================
;; 9. FORMATTING (Apheleia)
;; ==========================================
(use-package apheleia
  :config
  (apheleia-global-mode +1)
  (add-to-list 'apheleia-mode-alist '(simpc-mode . clang-format)))

;; ==========================================
;; 10. DOCUMENTATION (DevDocs)
;; ==========================================
(use-package devdocs
  :bind
  ("C-h D" . devdocs-lookup))

;; ==========================================
;; 11. PROJECT MANAGEMENT (Built-in project.el)
;; ==========================================
;; C-x p f = quick open (Ctrl+P), C-x p g = grep, C-x p c = compile/run,
;; C-x p p = switch project, C-x p b = project buffers.
(use-package project
  :ensure nil
  :custom
  (project-switch-commands '((project-dired "Dired" ?d)
                             (project-find-file "Find file" ?f)
                             (project-find-regexp "Find regexp" ?g)
                             (magit-project-status "Magit" ?m))))

;; ==========================================
;; 12. GIT INTEGRATION
;; ==========================================
(use-package magit
  :bind (("C-x g" . magit-status))
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

;; Gutter markers for added/changed/removed lines, live as you type (also in dired)
(use-package diff-hl
  :hook ((prog-mode . diff-hl-mode)
         (text-mode . diff-hl-mode)
         (dired-mode . diff-hl-dired-mode)
         (magit-pre-refresh . diff-hl-magit-pre-refresh)
         (magit-post-refresh . diff-hl-magit-post-refresh))
  :config (diff-hl-flydiff-mode 1))
;; Tip: M-x magit-blame-addition = GitLens-style blame; M-x magit-log-buffer-file = file history.

;;; init.el ends here