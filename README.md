# Emacs Configuration

A minimal, performance-oriented Emacs configuration tailored for systems programming and a keyboard-driven workflow. Designed to provide a modern IDE experience without unnecessary bloat, heavily leveraging Emacs' built-in capabilities over third-party packages.

## Core Philosophy

* **Minimal Footprint:** A single, easily readable `init.el` file. Auto-generated GUI configurations are strictly isolated into a separate `custom.el` file to keep the main configuration clean.
* **Native First:** Relies on modern Emacs built-in features (like `project.el`, `dired`, and `eglot`) rather than relying on heavy, third-party alternatives.
* **Distraction-Free:** All GUI clutter (scrollbars, toolbars, menus) is disabled. The environment is visually quiet, utilizing the high-contrast, low-strain Gruber Darker theme.

## Technical Stack

### Languages & Development
* **C:** `simpc-mode` for a lightweight, fast C/C++ editing experience.
* **Rust & Go:** Native `rust-mode` and `go-mode`.
* **LSP Integration:** `eglot` (built-in) provides real-time error checking, go-to-definition, and intelligent refactoring.
* **Auto-completion:** `corfu` for a minimal, non-intrusive popup completion interface.
* **Formatting:** `apheleia` runs formatters (`clang-format`, `rustfmt`, `gofmt`) asynchronously on save without moving the cursor or locking the editor.
* **Documentation:** `devdocs` for instant, offline API lookups directly within the editor.

### Navigation & Workflow
* **File Management:** Built-in `dired` with writable mode (`wdired`) for mass-renaming files like standard text.
* **Project Management:** Built-in `project.el` automatically detects Git repositories and provides project-wide search and file jumping.
* **Completion System:** `vertico` provides a fast, vertical, and fuzzy-searchable interface for all Emacs commands and file lookups.
* **Source Control:** `magit` for a comprehensive, interactive Git workflow.
* **Keybindings:** Standard Emacs bindings supplemented with `cua-mode` for modern copy/paste/undo familiarity during the transition.

## Installation

Ensure you are running Emacs 29 or higher.

1. Clone this repository into your standard XDG config directory:
   ```bash
   git clone [https://github.com/YOUR-USERNAME/REPO-NAME.git](https://github.com/YOUR-USERNAME/REPO-NAME.git) ~/.config/emacs