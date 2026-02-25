# Navigating Like a 10x Dev in Your LazyVim Setup

This isn't a keybinding reference -- you have which-key for that (press `<leader>` and wait).
This is a guide to **thinking differently** about navigation in Neovim.

---

## The Mental Shift: Forget Tabs, Think Jumps

In IntelliJ, you navigate by **arranging windows visually** -- dragging tabs, splitting panes, keeping things on screen. In Neovim, you navigate by **jumping** -- you teleport to exactly where you need to be, do your work, and teleport back. The screen is a viewport, not a workspace.

The single most important keybinding to internalize:

- **`Ctrl+o`** -- jump back to where you were (your "undo" for navigation)
- **`Ctrl+i`** -- jump forward again

Every `gd`, every search, every Flash jump gets recorded. You can dive 5 levels deep into a call chain, then `Ctrl+o` five times to get back. This replaces the IDE habit of "keep the file open in a tab so I can click back to it."

---

## Level 1: Moving Within a File -- "How Do I Get *There*?"

Flash enhances Neovim's built-in motions so they work across the entire visible screen with labeled jumps. Here's a decision tree for getting where you need to go:

### 1. Jump to a character you can see -- `f`/`t` (Flash-enhanced)

- **`f{char}`** -- jump **onto** the character. `f)` lands your cursor on `)`.
- **`t{char}`** -- jump **before** the character. `t)` lands your cursor one position before `)`.
- **`F`/`T`** -- same thing, but search backward.
- **`;`** repeats the last f/t, **`,`** reverses it.

**Why `t` matters:** `t` is for *operating up to* something. These are bread-and-butter edits:
- `ct)` -- change everything from cursor to (but not including) `)`. Essential for editing function args.
- `dt,` -- delete from cursor up to the comma. Clean up a list item.
- `df,` -- delete from cursor *through* the comma (f lands on it, so it's included).
- `vf}` -- visually select from cursor to the closing brace.

**Flash enhancement:** When you press `f`, Flash highlights ALL matches on screen. If there's only one, you jump immediately. If there are multiple, each gets a label -- press the label to jump. This means `f` works across the entire screen, not just the current line.

**When to use:** You can see the exact character you want. Single-char target. Fast for short and medium jumps. Great on punctuation (`f.`, `f## `, `f:`) which tends to have fewer matches.

### 2. Jump anywhere on screen -- `s` + 2 chars + label

Press **`s`**, type 2 characters of where you want to go, press the highlighted label. Three keystrokes, anywhere on screen.

**When to use:** Target is far away, or `f` would have too many matches (common chars like `e`, `t`, `a`). Two chars narrows it down fast. Example: jump to the word `return` -- type `sre` and pick the label.

**Pro tip:** `s` works in visual and operator-pending mode too. `ds{2chars}{label}` deletes to that spot. `vs{2chars}{label}` selects to it.

### 3. Select a code structure -- `S` (treesitter) / `Ctrl+Space` (incremental)

- **`S`** -- Flash labels treesitter nodes on screen. Pick one to select the entire node (a function, an argument, an if block).
- **`Ctrl+Space`** -- start incremental selection at cursor, press again to expand to the next larger node. **`Backspace`** shrinks it.

**When to use:** "Select this function", "select this argument", "select this if block". `S` is faster when you can see the node you want; `Ctrl+Space` is better when you're already inside it and want to grow outward.

### 4. Operate on something far away without moving -- `r` in operator-pending

**`yr{flash to target}{motion}`** -- yank from *there*, cursor stays put.

Example: you see a variable name 20 lines up that you want to copy. Type `yriw`, Flash activates, jump to the word, and it yanks that word -- your cursor never moves. Works with any operator: `dr`, `cr`, etc.

**When to use:** You see a value you want to copy/delete but don't want to lose your place.

### 5. Enhanced `/` search -- `Ctrl+s` in search mode

After typing **`/pattern`**, press **`Ctrl+s`** to add labels to all visible matches. Jump directly instead of pressing `n` repeatedly.

**When to use:** You're searching for something and there are many matches on screen.

### Symbols, not scrolling
- **`<leader>ss`** -- fuzzy search symbols in the current file (functions, classes, methods)
- **`<leader>cs`** -- toggle Aerial sidebar (persistent code outline on the side)
- **`<leader>ut`** -- toggle treesitter context (pins the parent function/class at the top of the screen)
- **`{`/`}`** -- jump between paragraphs (works great for jumping between functions)

### Searching within a file
- **`/pattern`** then `n`/`N` -- classic search, but with Flash's `Ctrl+s` for labeled jumping
- **`*`** on a word -- search for all occurrences of word under cursor
- **`<leader>sb`** -- fuzzy search lines in the current buffer

### Editing what you find

You've jumped to the right spot. Now what? These three systems handle the most common edits without leaving normal mode.

**Replace operator -- `gr` (mini.operators):**

`gr{motion}` replaces the text covered by the motion with whatever you last yanked (or any register contents). Think of it as "paste over" without selecting first.

- **`grw`** -- replace from cursor to end of word with register contents
- **`griw`** -- replace the entire inner word (more precise, doesn't depend on cursor position within the word)
- **`gr$`** -- replace from cursor to end of line
- **In visual mode:** select text, then `gr` to replace the selection

**Scenario:** Yank a variable name, then `griw` on each place you want to paste it -- no need to visually select each target first. Unlike `p` in visual mode, `gr` works with motions so you skip the selection step entirely.

**Surround operator -- `gsa`/`gsd`/`gsr` (mini.surround):**

Three operations: **a**dd, **d**elete, **r**eplace surrounding pairs.

- **`gsa{textobject}{pair}`** -- add surrounding (e.g., `gsaiw"` wraps word in quotes, `gsa2w(` wraps two words in parens)
- **`gsd{pair}`** -- delete surrounding (e.g., `gsd"` removes surrounding quotes, `gsd(` removes surrounding parens)
- **`gsr{old}{new}`** -- replace surrounding (e.g., `gsr"'` changes double to single quotes, `gsr({` changes parens to curlies)
- Works with `(`, `[`, `{`, `"`, `'`, `` ` ``, and `t` for HTML tags

**Scenario:** Wrapping a variable in a function call → `gsaiw)` then type the function name. Changing `"string"` to `'string'` → `gsr"'`.

**Pasting without overwriting your register:**

- **`p` in visual mode (yanky.nvim)** -- select text, press `p`, and your register keeps the original yank. Paste the same thing over multiple targets without re-yanking.
- **`"0p`** -- always paste from the yank register (ignores anything you deleted/changed). Useful when you `dd` a line then want to paste something you yanked earlier.
- **`<leader>p`** -- yanky's yank history picker. Browse everything you've copied and pick one.
- **`[y` / `]y`** -- after pasting, cycle through yank history to swap what you pasted for an older yank.
- **`]p` / `[p`** -- put indented (linewise). Pastes at the correct indent level for the destination -- no more re-indenting after pasting.

**Comment toggling -- `gcc` / `gc` (mini.comment):**

- **`gcc`** -- toggle comment on current line
- **`gc{motion}`** -- toggle comment over a motion (`gcip` comments a paragraph, `gc3j` comments 3 lines down)
- **Visual mode:** select lines, then `gc`
- Treesitter-aware: uses correct comment syntax in embedded languages (e.g., JS inside HTML)

**Smart increment/decrement -- `<C-a>` / `<C-x>` (dial.nvim):**

Vim's built-in `<C-a>`/`<C-x>` increment/decrement numbers. dial.nvim extends this to:
- **Booleans:** `true` ↔ `false`
- **JS/TS:** `let` ↔ `const`
- **Dates:** `2026/02/25` → `2026/02/26`
- **Logical operators:** `&&` ↔ `||`
- **Markdown:** `[ ]` ↔ `[x]` checkboxes, heading level cycling
- **CSS:** hex colors
- **JSON:** semver versions
- `g<C-a>` in visual: sequential increment (turns all selected `0`s into 1, 2, 3, 4...)

**Completion & snippets (blink.cmp):**

- **`<C-space>`** -- open completion menu (LSP completions, paths, buffer words)
- **`<C-y>`** -- accept the selected completion
- **Ghost text** shows inline preview automatically -- just keep typing if you don't want it
- **Snippets:** after expanding a snippet, `<Tab>` / `<S-Tab>` jump between placeholders, `<C-e>` finishes and exits the snippet

**Postfix snippets (JS/TS):**

IntelliJ-style postfix completions. Type an expression, then `.log`, `.const`, etc. and expand:
- `expr.log` → `console.log(expr)` (also `.warn`, `.error`)
- `expr.const` → `const name = expr` (also `.let`, `.constd` for destructuring)
- `expr.return` → `return expr` (also `.await`, `.throw`)
- `expr.if` → `if (expr) { }` (also `.not` → `!expr`)
- `expr.for` → `for (const item of expr) { }` (also `.foreach`)
- `expr.map` → `expr.map((item) => )` (also `.filter`, `.find`)

---

## Level 2: Jumping Between Files

### The Fuzzy Finder is Your Home Screen
These three keybindings replace IntelliJ's "Navigate to File/Class/Symbol":

| What you want | IntelliJ equivalent | Your keybinding |
|---|---|---|
| Open a file by name | Ctrl+Shift+N | **`<leader><space>`** or `<leader>ff` |
| Search text in all files | Ctrl+Shift+F | **`<leader>/`** or `<leader>sg` |
| Find a symbol across project | Ctrl+Shift+Alt+N | **`<leader>sS`** |
| Switch between open buffers | Ctrl+Tab | **`<leader>,`** or `[b`/`]b` |
| Recent files | Ctrl+E | **`<leader>fr`** |

**Pro tips inside the picker:**
- Type and it fuzzy-matches. No need for exact paths.
- `Alt+c` toggles between project root and current directory
- Results go to quickfix with `Alt+t` (Trouble)

### Harpoon: Your Pinned Files
This is the **biggest upgrade** over the fuzzy finder for daily work. Harpoon lets you pin 3-5 files and jump between them instantly -- no fuzzy finding, no thinking.

**Setup workflow:**
1. Open a file you'll keep returning to
2. **`<leader>H`** -- add it to Harpoon
3. Repeat for your 3-5 most important files
4. Now **`<leader>1`**, **`<leader>2`**, **`<leader>3`** teleport you instantly

**When to use it:** Any time you're bouncing between a component and its test, a controller and its service, a type definition and its implementation. Pin them, number them, forget about finding them.

**`<leader>h`** opens the Harpoon menu to reorder or remove entries.

### Following Code: LSP Navigation
This is where Neovim matches (and often beats) IntelliJ:

| Action | Keybinding | Notes |
|---|---|---|
| Go to definition | **`gd`** | The big one. Jump into any function/class/variable |
| Go to file under cursor | **`gf`** | Follow import paths, requires, file references |
| Go back | **`Ctrl+o`** | Return after any jump |
| Find references | **`<leader>r`** | Your custom binding (normally `gr`, but mini.operators took it) |
| Go to implementation | **`gI`** | Jump to impl of an interface/abstract |
| Go to type definition | **`gy`** | What type is this variable? |
| Incoming calls | **`gai`** | Who calls this function? |
| Outgoing calls | **`gao`** | What does this function call? |
| Rename symbol | **`<leader>cr`** | Rename across all files (inc-rename with preview) |

**The workflow:** `gd` into something, read it, `Ctrl+o` back. `gd` deeper, `Ctrl+o` `Ctrl+o` back two levels. Think of it like a browser's back button.

---

## Level 3: Managing Your Workspace

### Splits: Keep It Simple
Unlike IntelliJ where you drag tabs around, Neovim splits are quick and disposable:

- **`<leader>|`** -- split right (vertical)
- **`<leader>-`** -- split below (horizontal)
- **`Ctrl+h/j/k/l`** -- move between splits (also works across tmux/kitty panes)
- **`<leader>wd`** -- close a split
- **`<leader>wm`** or **`<leader>uZ`** -- zoom: temporarily maximize current split (press again to restore)

**The pattern:** Open a split when you need to see two things side-by-side (e.g., test + implementation), then close it when done. Don't accumulate splits.

### Buffers vs Tabs
- **Buffers** = open files (like hidden tabs). Use `<leader>,` to switch, `[b`/`]b` to cycle.
- **Tabs** = separate layouts/workspaces. Each tab has its own arrangement of splits.

**When to use tabs:** When you want completely separate contexts. E.g., Tab 1 = feature code, Tab 2 = config files, Tab 3 = documentation.

- **`<leader><tab><tab>`** -- new tab
- **`<leader><tab>]`** / **`<leader><tab>[`** -- next/prev tab
- **`<leader><tab>d`** -- close tab

**Realistically:** Most people use 0-2 tabs. Buffers + Harpoon handle 90% of file switching.

### Buffer Cleanup
Over a session, you accumulate dozens of open buffers. Clean up:
- **`<leader>bo`** -- close all buffers except the current one
- **`<leader>bd`** -- close current buffer
- **`<leader>bp`** -- pin a buffer (protected from bulk close)
- **`<leader>bP`** -- close all non-pinned buffers

---

## The File Explorer: Use It Right (or Use It Less)

Here's the uncomfortable truth: **if you're holding `<C-n>` to scroll to a file, the file explorer is the wrong tool for that moment.** The explorer is for spatial orientation and file operations -- not for opening files you can name. Use `<leader><space>` (fuzzy find) for that.

That said, the explorer is genuinely useful. Here's how to use it efficiently.

### Stop Scrolling, Start Searching

Your Snacks explorer is a picker in disguise. It has a search input:

- **`/`** or **`i`** -- focus the search input box. Type part of a filename and the tree filters to matches. Press `<CR>` to jump to the match in the tree.
- **`?`** -- show all keybindings (the in-explorer help overlay)

This is the #1 fix for the "holding `<C-n>`" problem. Instead of scrolling down 40 lines to find `UserService.ts`, press `/`, type `userser`, hit `<CR>`.

### Opening Files Without Closing the Explorer

The Snacks explorer **already stays open** when you open a file -- that's its default behavior. If yours is closing, something else is going on. Here's how opening works:

| Key | What it does |
|---|---|
| `l` or `<CR>` | Open file in the main window (explorer stays open) |
| `<C-v>` | Open file in a vertical split |
| `<C-s>` | Open file in a horizontal split |
| `<S-CR>` | Pick which window to open the file in |
| `o` | Open with system application (e.g., image viewer) |

**The workflow:** `<leader>e` to open explorer, navigate to file, `l` to open it. The explorer stays put. `<C-h>` to jump back to the explorer when you need it again (since it's the left split). `q` or `<Esc>` when you're done with it entirely.

### Navigating the Tree Efficiently

| Key | What it does |
|---|---|
| `l` | Expand directory / open file |
| `h` | Collapse directory (or go to parent if already collapsed) |
| `<BS>` | Go up one directory (change the tree root) |
| `.` | Focus into this directory (make it the new root) |
| `Z` | Collapse ALL directories at once |
| `H` | Toggle hidden files (dotfiles) |
| `I` | Toggle gitignored files |

**Jump to changes instead of scrolling:**

| Key | What it does |
|---|---|
| `]g` / `[g` | Jump to next/prev file with git changes |
| `]d` / `[d` | Jump to next/prev file with diagnostics |
| `]e` / `[e` | Jump to next/prev file with errors |
| `]w` / `[w` | Jump to next/prev file with warnings |

These are huge -- instead of scrolling through the tree looking for modified files, `]g` teleports you to them.

### File Operations

| Key | What it does |
|---|---|
| `a` | Create new file (end name with `/` for a directory) |
| `d` | Delete file (uses system trash when available) |
| `r` | Rename file (LSP-aware -- updates imports) |
| `<Tab>` | Select/deselect files (for bulk operations) |
| `m` | Move selected files to current directory |
| `c` | Copy selected files to current directory |
| `y` | Yank file path(s) |
| `p` | Paste yanked files |

**Bulk move/copy workflow:**
1. Navigate to files you want to move, `<Tab>` each one to select
2. Navigate to the target directory
3. Press `m` to move (or `c` to copy) all selected files there

### Power Features

| Key | What it does |
|---|---|
| `<leader>/` | Grep within the directory under cursor |
| `<C-t>` | Open terminal in the directory under cursor |
| `<C-c>` | Set tab working directory to this directory |
| `P` | Toggle file preview panel |
| `<Alt-m>` | Maximize/restore the explorer width |

### When to Use the Explorer vs Other Tools

| Situation | Best tool |
|---|---|
| "Open `UserService.ts`" | **`<leader><space>`** -- fuzzy find by name |
| "What files are in `src/api/`?" | **`<leader>e`** -- explorer for browsing structure |
| "Where did I make changes?" | **`<leader>gs`** -- git status picker (or `]g` in explorer) |
| "Create/rename/move files" | **`<leader>e`** then `a`/`r`/`m` in explorer |
| "Jump between my 3 active files" | **`<leader>1-5`** -- Harpoon |
| "Find the file containing `handleAuth`" | **`<leader>/`** -- grep across project |

### Should You Switch to Neo-tree?

**Probably not.** Neo-tree's `/` fuzzy finder within the tree is slightly more polished, but the Snacks explorer's search (`/` or `i`) does the same job. The real issue isn't which explorer you use -- it's building the habit of reaching for the fuzzy finder (`<leader><space>`) instead of scrolling the tree. Both explorers have the same fundamental limitation: trees are slow for navigation in large projects.

If you find yourself doing a lot of file creation/renaming/reorganization, consider **oil.nvim** as a complement (not replacement). It lets you edit a directory listing like a buffer -- delete a line to delete a file, change text to rename, yank+paste to copy. It's not a sidebar; it replaces the current buffer with a directory view. Press `-` to go up a directory. Very Vim-native.

---

## Level 4: Exploring an Unfamiliar Codebase

This is the scenario you described -- "how do I find my way around?" Here's the playbook:

### Step 1: Get the Lay of the Land
- **`<leader>e`** -- open file explorer to see project structure
- Browse directories, press `l` to expand, `h` to collapse
- Press `/` inside the explorer to filter/search file names

### Step 2: Find Entry Points
- **`<leader><space>`** -- search for key files (`main`, `index`, `app`, `server`)
- **`<leader>/`** -- grep for patterns: error messages, route definitions, config keys

### Step 3: Trace the Code
- Open an entry point, `gd` into functions to follow the call chain
- **`<leader>r`** on a function to see everywhere it's called
- **`gai`** -- incoming calls (who calls this?)
- **`gao`** -- outgoing calls (what does this call?)
- Use `Ctrl+o` to retrace your steps

### Step 4: Mark What You Find
As you discover important files:
- **`<leader>H`** -- Harpoon the key files
- **`mA`**, **`mB`**, etc. -- set global marks at important lines (uppercase marks work across files, jump back with `` `A ``, `` `B ``)

### Step 5: Build Understanding
- **`<leader>ss`** in any file -- see all symbols (functions, classes) at a glance
- **`<leader>cs`** -- keep the Aerial outline sidebar open while reading
- **`<leader>st`** -- find all TODO/FIXME comments in the project

---

## Level 5: Git Workflows Without Leaving Neovim

### Quick Operations
- **`]h`/`[h`** -- jump between changed hunks in the current file
- **`<leader>ghp`** -- preview what changed in this hunk (inline diff)
- **`<leader>ghs`** -- stage just this hunk (not the whole file)
- **`<leader>ghr`** -- revert just this hunk

### Full Git TUI
- **`<leader>gg`** -- opens LazyGit (full git client inside Neovim)
  - Stage files, write commits, manage branches, resolve conflicts
  - Press `?` inside LazyGit for its own keybinding help

### Investigation
- **`<leader>gb`** -- who wrote this line? (git blame)
- **`<leader>gf`** -- full git history of the current file
- **`<leader>ghd`** -- diff the current file against the git index

### Diffview: IntelliJ-Style Diff Navigation
- **`<leader>gd`** -- open diffview (uncommitted changes against index)
- **`<leader>gD`** -- PR review diff (auto-detects `main`/`master`, opens `origin/main...HEAD`)
- **`<leader>gc`** -- commit history for the current file
- **`<leader>gC`** -- all PR commits (commit history for the branch)
- **`<leader>gq`** -- close diffview

---

## Level 6: Power Moves

### Search and Replace Across Files
- **`<leader>sr`** -- opens grug-far (multi-file search & replace)
  - Type search pattern, see all matches across the project
  - Type replacement, preview changes inline
  - Apply selectively or all at once

### Diagnostics: Find All Problems
- **`]d`/`[d`** -- jump to next/prev diagnostic in the current file
- **`]e`/`[e`** -- jump to next/prev error specifically
- **`<leader>xx`** -- open Trouble panel with ALL diagnostics across the project
- **`<leader>cd`** -- see the full diagnostic message for the current line

### Quickfix List: Your Results Scratchpad
When you search references (`<leader>r`) or grep (`<leader>/`), you can send results to the quickfix list:
- **`]q`/`[q`** -- jump through quickfix items one by one
- **`<leader>xq`** -- view quickfix list in Trouble (filterable, persistent)

### Treesitter Selection
- **`Ctrl+Space`** -- start incremental selection (selects the smallest node)
- **`Ctrl+Space`** again -- expand to the next larger node
- **`Backspace`** -- shrink selection
- Great for selecting "this argument", "this function call", "this if block", "this whole function"

### Scratch Buffers
Need a quick place to paste something or write throwaway code?
- **`<leader>.`** -- toggle a scratch buffer
- **`<leader>S`** -- pick from existing scratch buffers

---

## Reviewing PRs in Neovim

PR review is the hardest thing to replicate from IntelliJ. The honest answer: you can get ~90% there with the right setup, but complex threaded discussions and CI log diving are still easier in a browser. Here's how to maximize the 90%.

### The Setup You Need

You have octo.nvim already. You're missing the other critical piece: **diffview.nvim**.

**diffview.nvim** gives you IntelliJ-style file-by-file diff navigation with a file panel on the left and side-by-side diff on the right. Add it as a plugin. Octo handles the GitHub interaction (comments, approvals); diffview handles the actual code reading.

Also configure octo with `use_local_fs = true` -- this is the single most impactful tweak. It makes the right side of diffs use your local files, so **LSP, go-to-definition, and diagnostics all work** during review. Without it, review buffers are dumb GitHub API content with no editor intelligence.

### The PR Review Workflow

#### Step 1: Check out the PR

**From Neovim (fastest):**
1. **`<leader>gp`** to open the PR list
2. **`<C-o>`** on a PR to check it out directly

**From the terminal:**
```bash
gh pr checkout 123
```

#### Step 2: Read the code with diffview

**`<leader>gD`** opens the full PR diff (auto-detects `main`/`master`). This is your one-key "review this PR" binding -- no need to type the `:DiffviewOpen origin/main...HEAD` command.

For uncommitted changes only, use **`<leader>gd`** instead.

This opens the IntelliJ-style view:
- **File panel on the left** -- all changed files listed
- **Side-by-side diff on the right** -- with full LSP support on the right side

| Key (in diffview) | What it does |
|---|---|
| `<Tab>` | Jump to next file |
| `<S-Tab>` | Jump to previous file |
| `]x` / `[x` | Jump to next/prev conflict |
| `gf` | Open file in editor (leave diff view) |
| `L` | Open commit log |
| `<leader>e` | Toggle the file panel |
| `g<C-x>` | Cycle diff layout (side-by-side vs inline) |
| `<leader>b` | Toggle file panel list style |
| `q` or **`<leader>gq`** | Close diffview |

For **commit-by-commit review** (like IntelliJ's commit list), press **`<leader>gC`** to see all PR commits. For a single file's history, use **`<leader>gc`**.

#### Step 3: Add comments and submit review with octo
```
:Octo review start
```

Inside octo's review mode:

| Key | What it does |
|---|---|
| `]q` / `[q` | Next/prev changed file |
| `]u` | Jump to next unreviewed file |
| `<localleader>ca` | Add comment on current line |
| `<localleader>sa` | Add code suggestion (GitHub suggestion block) |
| `<localleader>cr` | Reply to existing thread |
| `<C-a>` | Approve the PR |
| `<C-r>` | Request changes |

**The pattern:** Use diffview first to understand the changes thoroughly (with LSP, grep, `gd`, etc.). Then switch to octo review mode to add comments and approve. diffview is for reading; octo is for talking.

#### Step 4: Quick approvals (skip the ceremony)
For simple PRs that just need a thumbs-up:
```bash
gh pr review 123 --approve --body "LGTM"
```

### Octo Quick Reference

These work from normal mode (not inside a review):

| Key | What it does |
|---|---|
| `<leader>gp` | List open PRs |
| `<C-o>` | Check out PR (from PR list picker) |
| `<leader>gP` | Search PRs |
| `<leader>gi` | List open issues |
| `<leader>gI` | Search issues |

From inside a PR buffer (`:Octo pr 123`):

| Command | What it does |
|---|---|
| `:Octo review start` | Start a new review |
| `:Octo review resume` | Resume a pending review |
| `:Octo review submit` | Submit the review |
| `:Octo pr checks` | View CI check status |
| `:Octo pr merge squash` | Squash and merge |
| `:Octo comment add` | Add a PR-level comment |
| `:Octo label add` | Add labels |
| `:Octo assignee add` | Assign reviewers |

### What Still Needs the Browser

Be honest with yourself -- don't fight these:
- **Complex threaded discussions** -- long back-and-forth is painful in terminal buffers
- **PR descriptions with images/diagrams** -- can't render those in Neovim
- **Clicking through linked issues/PRs** -- cross-referencing is a browser strength
- **Detailed CI logs** -- `gh pr checks` shows pass/fail but not the actual logs
- **"Resolve conversation"** -- octo can't do this yet

### gh-dash: Optional but Nice

[gh-dash](https://github.com/dlvhdr/gh-dash) is a standalone terminal dashboard for GitHub. It shows all PRs needing your review, your own PRs, and issues -- in a TUI you can bind to a tmux hotkey. Think of it as your PR inbox. Press Enter on a PR to open it, then switch to Neovim for the actual review.

---

## The Daily Workflow Cheat Sheet

```
Opening the project:
  nvim .                          Open Neovim in project root
  <leader>qs                      Restore last session (picks up where you left off)

Finding things:
  <leader><space>                 Find file by name
  <leader>/                       Grep across the whole project
  <leader>,                       Switch between open buffers
  <leader>fr                      Recent files
  <leader>ss                      Symbols in this file
  <leader>sS                      Symbols across the project

Reading code:
  gd                              Go to definition
  Ctrl+o                          Come back
  <leader>r                       Find all references
  K                               Hover docs
  <leader>cs                      Toggle code outline sidebar

Quick switching:
  <leader>H                       Pin current file to Harpoon
  <leader>1-5                     Jump to pinned file
  <leader>bb                      Toggle between last two files
  [b / ]b                         Cycle buffers

Editing:
  <leader>cr                      Rename symbol (all files)
  <leader>ca                      Code action (quick fixes, imports)
  <leader>cf                      Format
  <leader>sr                      Search & replace across files
  griw                            Replace word with register (paste over it)
  gsaiw"                          Wrap word in quotes
  gsd(                            Delete surrounding parens
  gsr"'                           Change double quotes to single
  gcc                             Toggle comment on line
  gc{motion}                      Comment over a motion (gcip, gc3j)
  <C-a> / <C-x>                  Smart increment/decrement (bools, dates, etc.)
  <C-space>                       Open completion menu
  <C-y>                           Accept completion
  p (visual)                      Paste over selection (register preserved)
  <leader>p                       Browse yank history

Git:
  <leader>gg                      LazyGit
  ]h / [h                         Jump between changed hunks
  <leader>ghs                     Stage this hunk
  <leader>gb                      Blame this line

PR Review:
  <leader>gD                      Open PR diff (vs main/master)
  <leader>gd                      Open diff (uncommitted changes)
  <leader>gc                      File commit history
  <leader>gC                      PR commit history (all branch commits)
  <leader>gq                      Close diffview
  <leader>gp                      List open PRs (octo)

AI:
  <leader>ac                      Toggle Claude Code panel
  <leader>as                      Send selection to Claude (visual)
  <leader>ab                      Add current buffer to Claude context
  <leader>aa / <leader>ad         Accept / deny diff

Windows:
  <leader>|                       Split right
  <leader>-                       Split below
  Ctrl+h/j/k/l                   Move between splits
  <leader>wm                      Zoom current split

When lost:
  <leader> (then wait)            Which-key shows all options
  <leader>sk                      Search all keybindings
  <leader>sh                      Search help pages
  <leader>sR                      Resume last picker search
```

---

## What You Already Have (That You Might Not Know About)

Your config is actually really well set up for navigation. Here's what's already there:

1. **Harpoon2** -- instant file bookmarks (`<leader>1-5`)
2. **Aerial** -- code outline sidebar (`<leader>cs`)
3. **Flash** -- teleport anywhere on screen (`s`)
4. **Snacks picker** -- fuzzy find everything (`<leader><space>`, `<leader>/`, `<leader>ss`)
5. **Trouble** -- persistent diagnostics/references panels (`<leader>xx`)
6. **LazyGit** -- full git TUI (`<leader>gg`)
7. **Gitsigns** -- hunk-level git operations (`]h`, `<leader>ghs`)
8. **tmux/kitty navigator** -- seamless split navigation (`Ctrl+h/j/k/l`)
9. **Session restore** -- pick up where you left off (`<leader>qs`)
10. **Search & Replace** -- multi-file with preview (`<leader>sr`)
11. **Inc-rename** -- live rename preview (`<leader>cr`)
12. **Yanky** -- yank history and paste-without-overwrite (`<leader>p`, `[y`/`]y`)
13. **mini.operators** -- replace text with register contents using motions (`griw`, `gr$`)
14. **mini.surround** -- add/delete/change surrounding pairs (`gsa`, `gsd`, `gsr`)
15. **Diffview** -- IntelliJ-style file-by-file PR diffs (`<leader>gD`)
16. **Octo** -- GitHub PR/issue management with LSP in review diffs (`:Octo`)
17. **mini.comment** -- toggle comments with treesitter awareness (`gcc`, `gc{motion}`)
18. **dial.nvim** -- smart increment/decrement for booleans, dates, operators (`<C-a>`/`<C-x>`)
19. **Claude Code** -- AI assistant with diff management (`<leader>ac`, `<leader>as`)
20. **Postfix snippets** -- IntelliJ-style JS/TS postfix completions (`.log`, `.const`, `.for`)
21. **Treesitter context** -- sticky function/class header at top of screen (`<leader>ut`)

The tools are all there. The gap is building the muscle memory for the jump-based workflow instead of the arrange-windows workflow.

---

## Practice Progression

**Week 1:** Master `<leader><space>`, `<leader>/`, `gd`, `Ctrl+o`, `<leader>,`, and `gcc`. These cover 70% of navigation and editing.

**Week 2:** Start using Harpoon. Pin your 3 most-used files each session. Use `<leader>1-3` instead of fuzzy finding.

**Week 3:** Replace scrolling with `s` (Flash). Use `<leader>ss` to jump to functions instead of scrolling to find them. Also start using `griw` to paste over words, `gsa`/`gsd`/`gsr` to manipulate surrounding pairs, and `<C-a>`/`<C-x>` for smart increment/decrement -- these are the editing companions to Flash navigation.

**Week 4:** Integrate git into your flow. `]h`/`[h` to review changes, `<leader>ghs` to stage hunks, `<leader>gg` for everything else.

**Ongoing:** Use `<leader>` + wait whenever you forget. Which-key is your training wheels -- it shows every available binding. Over time, the bindings become automatic.
