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


## Emacs keybindings cheat sheet

Notation: `C-` = Ctrl, `M-` = Alt, `S-` = Shift. `C-M-<up>` = Ctrl+Alt+Up.
Covers what is set in `init.el` plus built-ins worth knowing. Press a prefix
(e.g. `C-x p`) and wait: **which-key** shows the available continuations.

### Find your way around (inside Emacs)

| Keys | Action |
|---|---|
| `C-h k` then a key | What does this key do? |
| `C-h b` | List every binding active in this buffer |
| `C-h m` | Docs for the current modes |
| `C-h v` / `C-h f` | Describe a variable / function |
| `C-h D` | DevDocs lookup (offline docs) |
| `M-x` | Run any command by name |
| `C-g` | Cancel whatever you are doing |

### Folders, projects, workspaces: what is the difference?

Emacs has no single "opened folder" like VS Code. Three separate ideas:

| Concept | What it is | Used by |
|---|---|---|
| **Folder** (directory) | Any place on disk. Every buffer remembers its own folder (`default-directory`). | `C-x C-f`, dired, `M-x cd`, shells, compile |
| **Project** | A folder tree Emacs recognizes as a unit, normally a **git repo** (found automatically from the file you are in), or any folder containing an empty file named `.project`. | `C-x p ...` commands, magit, eglot (language server root), consult-ripgrep |
| **Treemacs workspace** | The list of folders shown in the `F8` sidebar. Independent from the project list, though it picks up the current project. | Sidebar only |

Rule of thumb:
- Browsing or opening files anywhere on disk: **folder tools** (`C-x C-f`, dired).
- Working inside a repo (find file, grep, run, git): **project tools** (`C-x p ...`).
- Want the VS Code feel of "this folder is my workspace": open the folder with `C-x p p`, then `F8`.

Emacs remembers known projects in `projects.eld` (in this folder).

### Changing folder

| Keys | Action |
|---|---|
| `C-x C-f` then type a path | Open a file/folder anywhere. Type `~/` to jump to home, `/` for root; `DEL` removes one path component |
| `C-x d` | Open dired (file manager) on any folder you type |
| `C-x C-j` | Open dired on the current file's folder |
| `^` (in dired) | Go to the parent folder |
| `M-x cd` | Change the current buffer's folder (affects the next `C-x C-f`, shells, compile) |
| `C-x p p` | Switch project. Choose `... (choose a dir)` to add any new folder as a project |
| `M-x project-remember-projects-under` | Register every repo found under a parent folder (e.g. `~/code`) |
| `M-x project-forget-project` | Remove a project from the list |
| `C-x r m` / `C-x r b` / `C-x r l` | Set / jump to / list bookmarks (works for files and folders) |
| `C-x b` then type | Switch to an open buffer or a recently opened file |
| `C-c C-p a` (in treemacs) | Add a folder to the sidebar (or `M-x treemacs-add-project-to-workspace`) |
| `C-x p s` | Open a shell in the project root |
| `emacs ~/some/folder` (terminal) | Start Emacs directly in dired on that folder |

### File management

#### Opening

| Keys | Action |
|---|---|
| `C-x C-f` | Open a file (a new name creates a new file on save) |
| `C-x C-v` | Replace the current buffer with another file |
| `C-x 4 f` | Open a file in the other window |
| `C-x 5 f` | Open a file in a new frame |
| `C-x C-r` | Open a file read-only |
| `C-x p f` | Find a file in the current project (Ctrl+P) |
| `C-x b` | Open recent files and buffers |
| `M-x consult-find` | Find files by name under the current folder |
| `M-x find-name-dired` | Find files by name and list them in dired |
| `C-x C-f` then `/sudo::/etc/hosts` | Open a file as root (TRAMP) |
| `C-x C-f` then `/ssh:user@host:/path` | Open a remote file over SSH |

#### Saving

| Keys | Action |
|---|---|
| `C-x C-s` | Save |
| `C-x s` | Save all modified buffers (asks about each) |
| `C-x C-w` | Save as (writes a copy under a new name) |
| `M-x revert-buffer` | Reload the file from disk (auto-revert already does this for unmodified buffers) |
| `C-x k` | Close (kill) the buffer |

Saving into a folder that does not exist prompts to create it.

#### Create, rename, copy, delete

| Command | Action |
|---|---|
| `M-x make-directory` | Create a folder |
| `M-x rename-visited-file` | Rename/move the file of the current buffer (Emacs 29+) |
| `M-x rename-file` | Rename/move any file (asks for source and destination) |
| `M-x copy-file` | Copy a file |
| `M-x delete-file` | Delete a file (goes to the trash, see config) |
| `M-x delete-directory` | Delete a folder |

Deletions go to the system trash because `delete-by-moving-to-trash` is on.

#### Dired (the built-in file manager)

Open with `C-x d` or `C-x C-j`. Navigating replaces the dired buffer instead of piling them up.

| Keys | Action |
|---|---|
| `RET` or `f` | Open file / enter folder |
| `o` | Open in the other window |
| `C-o` | Preview in the other window without moving there |
| `v` | View read-only |
| `^` | Parent folder |
| `j` | Jump to a file by name |
| `g` | Refresh |
| `s` | Toggle sort by name/date |
| `(` | Show/hide details (size, date, permissions) |
| `m` / `u` / `U` | Mark / unmark / unmark all |
| `t` | Invert marks |
| `% m` | Mark files matching a regex |
| `* .` | Mark by extension |
| `* /` | Mark all folders |
| `+` | Create a folder |
| `C-x C-f` | Create/open a file in this folder |
| `R` | Rename / move marked files (or file under cursor) |
| `C` | Copy |
| `D` | Delete (asks to confirm) |
| `d` then `x` | Flag for deletion, then execute |
| `% R` | Rename by regex |
| `Z` | Compress / decompress |
| `S` | Create a symbolic link |
| `M` | Change permissions (chmod) |
| `T` | Touch (update timestamp) |
| `w` | Copy file name; `0 w` copies the full path |
| `=` | Diff against another file |
| `F` | Open all marked files |
| `A` / `Q` | Regex search / search-and-replace across marked files |
| `!` | Run a shell command on marked files (e.g. `xdg-open` to open in the default app) |
| `&` | Same, but asynchronous |
| `C-x C-q` | Edit the listing like text to rename files; `C-c C-c` to apply, `C-c ESC` to abort |
| `q` | Close dired |

Copy/move between two folders: `C-x 3` to split, open each folder in a window, mark files, then `C` or `R`. The other window is suggested as the destination automatically.

#### Treemacs sidebar

Toggle with `F8`; `C-F8` jumps into it. It follows the file you are editing and shows git status. Press `?` inside it for the full key list.

| Keys | Action |
|---|---|
| `RET` | Open file (in the other window) |
| `TAB` | Expand / collapse folder |
| `u` | Go to parent |
| `c f` | Create file |
| `c d` | Create folder |
| `R` | Rename |
| `d` | Delete |
| `C-c C-p a` | Add a folder to the sidebar |
| `q` | Hide the sidebar |

### Search

| Keys | Action |
|---|---|
| `M-s r` | Search the whole project with ripgrep |
| `M-s l` | Search lines in the current file |
| `C-x p g` | Grep in project (built-in) |
| `M-g g` | Go to line |
| `M-g i` | Jump to a symbol in the file (imenu) |
| `M-g f` | List errors/warnings (Problems panel) |

### Editing (VS Code-style)

| Keys | Action |
|---|---|
| `M-<up>` / `M-<down>` | Move line / selection up / down |
| `M-S-<up>` / `M-S-<down>` | Copy line / selected lines above / below |
| `C-S-d` | Duplicate line / region |
| `C-;` | Toggle comment |
| `C-=` | Expand selection (repeat to grow) |
| `C-c` / `C-x` / `C-v` / `C-z` | Copy / cut / paste / undo (cua-mode; with no selection `C-c` and `C-x` stay normal prefixes) |

### Multiple cursors

| Keys | Action |
|---|---|
| `C->` | Add cursor on next match of selection (like Ctrl+D) |
| `C-<` | Add cursor on previous match |
| `C-c C-<` | Cursors on all matches |
| `C-M-<up>` / `C-M-<down>` | Add cursor on line above / below |
| `C-S-c C-S-c` | Cursor on every line of the selection |
| `C-S-<mouse-1>` | Add cursor at mouse click |
| `C-g` | Leave multiple-cursors mode |

KDE may grab `Ctrl+Alt+Arrow`. If it does nothing, check System Settings, Shortcuts.

### Projects (built-in project.el)

| Keys | Action |
|---|---|
| `C-x p f` | Find file in project |
| `C-x p g` | Grep in project |
| `C-x p c` | Compile / run command in project |
| `C-x p p` | Switch project (then `d` dired, `f` file, `g` grep, `m` magit) |
| `C-x p b` | Project buffers |
| `C-x p s` | Shell in project root |

### Git

| Keys | Action |
|---|---|
| `C-x g` | Magit status |
| In magit: `s` / `u` | Stage / unstage |
| In magit: `c c` | Commit |
| In magit: `P p` / `F p` | Push / pull |
| In magit: `b b` | Checkout branch |
| In magit: `q` | Quit |
| `M-x magit-blame-addition` | Blame (GitLens-style) |
| `M-x magit-log-buffer-file` | History of the current file |

Changed lines show in the gutter (diff-hl).

### Errors and LSP

| Keys | Action |
|---|---|
| `M-n` / `M-p` | Next / previous error (Flymake) |
| `C-c r` | Rename symbol |
| `C-c a` | Code actions / quick fix |
| `C-c o` | Organize imports |
| `C-c h` | Show docs for symbol at point |
| `M-.` / `M-,` | Go to definition / back |
| `M-?` | Find references |
| `M-x eglot-reconnect` | Restart the language server (e.g. after creating `.venv`) |

Completion popup (corfu): `C-n` / `C-p` select, `TAB` or `RET` accept.

### Useful one-off commands

| Command | Why |
|---|---|
| `M-x package-refresh-contents` | Fix "Not found" install errors |
| `M-x package-upgrade-all` | Update packages |
| `M-x nerd-icons-install-fonts` | Fix missing icons (run once) |
| `M-x treesit-install-language-grammar` | Install tree-sitter grammars (for TS/JS later) |