# Vim Cheatsheet & Tutorial

## Understanding Vim Modes

Vim has several modes, each serving a different purpose:

- **Normal Mode** (default): Navigate and manipulate text
- **Insert Mode**: Type text normally
- **Visual Mode**: Select text
- **Command Mode**: Execute commands (start with `:`)

### Mode Switching
- `i` - Enter Insert mode before cursor
- `a` - Enter Insert mode after cursor
- `I` - Enter Insert mode at beginning of line
- `A` - Enter Insert mode at end of line
- `o` - Open new line below and enter Insert mode
- `O` - Open new line above and enter Insert mode
- `ESC` or `Ctrl+[` - Return to Normal mode
- `v` - Enter Visual mode
- `V` - Enter Visual Line mode
- `Ctrl+v` - Enter Visual Block mode
- `:` - Enter Command mode

## Basic Navigation

### Character Movement
- `h` - Move left
- `j` - Move down
- `k` - Move up
- `l` - Move right
- `gj` - Move down visual line (useful for wrapped lines)
- `gk` - Move up visual line

### Word Movement
- `w` - Jump to start of next word
- `W` - Jump to start of next WORD (space-separated)
- `e` - Jump to end of word
- `E` - Jump to end of WORD
- `b` - Jump backward to start of word
- `B` - Jump backward to start of WORD

### Line Movement
- `0` - Jump to start of line
- `^` - Jump to first non-blank character of line
- `$` - Jump to end of line
- `g_` - Jump to last non-blank character of line

### Screen Movement
- `H` - Move to top of screen
- `M` - Move to middle of screen
- `L` - Move to bottom of screen
- `Ctrl+f` - Page down
- `Ctrl+b` - Page up
- `Ctrl+d` - Half page down
- `Ctrl+u` - Half page up

### File Movement
- `gg` - Go to first line
- `G` - Go to last line
- `5G` or `:5` - Go to line 5
- `%` - Jump to matching bracket/parenthesis

## Editing Commands

### Delete (also cuts to clipboard)
- `x` - Delete character under cursor
- `X` - Delete character before cursor
- `dw` - Delete word
- `dd` - Delete entire line
- `D` - Delete from cursor to end of line
- `d$` - Same as D
- `d0` - Delete from cursor to beginning of line
- `3dd` - Delete 3 lines

### Change (delete and enter Insert mode)
- `cw` - Change word
- `cc` or `S` - Change entire line
- `C` - Change from cursor to end of line
- `ci"` - Change inside quotes
- `ci(` - Change inside parentheses
- `cit` - Change inside HTML tags

### Copy (Yank)
- `yy` - Copy entire line
- `yw` - Copy word
- `y$` - Copy from cursor to end of line
- `3yy` - Copy 3 lines
- `yiw` - Copy word under cursor

### Paste
- `p` - Paste after cursor
- `P` - Paste before cursor
- `gp` - Paste after cursor and move cursor after pasted text

### Undo/Redo
- `u` - Undo
- `Ctrl+r` - Redo
- `U` - Undo all changes on current line

## Visual Mode Operations

1. Enter Visual mode with `v`, `V`, or `Ctrl+v`
2. Select text with movement commands
3. Apply operation:
   - `d` - Delete selection
   - `y` - Copy selection
   - `c` - Change selection
   - `>` - Indent selection
   - `<` - Unindent selection
   - `=` - Auto-indent selection
   - `~` - Toggle case

## Search and Replace

### Search
- `/pattern` - Search forward for pattern
- `?pattern` - Search backward for pattern
- `n` - Next search result
- `N` - Previous search result
- `*` - Search for word under cursor forward
- `#` - Search for word under cursor backward

### Replace
- `:s/old/new/` - Replace first occurrence in line
- `:s/old/new/g` - Replace all occurrences in line
- `:%s/old/new/g` - Replace all in file
- `:%s/old/new/gc` - Replace all with confirmation
- `:5,10s/old/new/g` - Replace in lines 5-10

## Working with Multiple Lines (Your Examples Extended)

### Indentation
```vim
:2,4>          " Indent lines 2-4
:2,4<          " Remove indent from lines 2-4
:2,4>>         " Indent lines 2-4 by 2 levels
>G             " Indent from current line to end of file
>5j            " Indent current line and 5 lines below
```

### Commenting
```vim
:2,3s/^/#/g    " Add # comment to lines 2-3
:2,3s/^#//g    " Remove # comment from lines 2-3
:2,3s/^/\/\//g " Add // comment to lines 2-3
:%s/^/#/g      " Comment entire file with #
```

### Line Operations on Ranges
```vim
:2,4d          " Delete lines 2-4
:2,4y          " Yank (copy) lines 2-4
:2,4m10        " Move lines 2-4 after line 10
:2,4t10        " Copy lines 2-4 after line 10
:2,4!sort      " Sort lines 2-4
```

## Text Objects (Power Feature!)

Text objects allow precise selection/operation:

### Inner/Around
- `iw` / `aw` - inner/around word
- `is` / `as` - inner/around sentence
- `ip` / `ap` - inner/around paragraph
- `i"` / `a"` - inner/around double quotes
- `i'` / `a'` - inner/around single quotes
- `i(` / `a(` - inner/around parentheses
- `i{` / `a{` - inner/around braces
- `i[` / `a[` - inner/around brackets
- `it` / `at` - inner/around HTML tags

### Examples
- `diw` - Delete inner word
- `ci"` - Change text inside quotes
- `ya{` - Yank around braces (including braces)
- `vi(` - Select inside parentheses

## Macros (Automation)

1. `qa` - Start recording macro in register 'a'
2. Perform your actions
3. `q` - Stop recording
4. `@a` - Play macro from register 'a'
5. `@@` - Repeat last macro
6. `5@a` - Play macro 5 times

### Macro Example: Add semicolon to end of lines
1. `qa` - Start recording
2. `A;` - Append semicolon
3. `j` - Move down
4. `q` - Stop recording
5. `10@a` - Apply to next 10 lines

## Marks and Jumps

### Setting Marks
- `ma` - Set mark 'a' at current position
- `mA` - Set global mark 'A' (works across files)

### Jumping to Marks
- `` `a `` - Jump to mark 'a'
- `'a` - Jump to line of mark 'a'
- `` `` `` - Jump to position before last jump
- `''` - Jump to line before last jump
- `Ctrl+o` - Jump to previous location
- `Ctrl+i` - Jump to next location

## Window Management

### Splitting
- `:split` or `:sp` - Horizontal split
- `:vsplit` or `:vsp` - Vertical split
- `Ctrl+w s` - Horizontal split
- `Ctrl+w v` - Vertical split

### Navigation
- `Ctrl+w h/j/k/l` - Move between windows
- `Ctrl+w w` - Cycle through windows

### Window Operations
- `Ctrl+w =` - Make all windows equal size
- `Ctrl+w _` - Maximize height
- `Ctrl+w |` - Maximize width
- `Ctrl+w +/-` - Increase/decrease height
- `Ctrl+w >/<` - Increase/decrease width
- `Ctrl+w c` - Close current window
- `Ctrl+w o` - Close all other windows

## Buffers and Tabs

### Buffers
- `:e filename` - Open file in new buffer
- `:bnext` or `:bn` - Next buffer
- `:bprev` or `:bp` - Previous buffer
- `:bd` - Delete (close) buffer
- `:ls` - List buffers
- `:b3` - Go to buffer 3

### Tabs
- `:tabnew` - New tab
- `:tabnext` or `gt` - Next tab
- `:tabprev` or `gT` - Previous tab
- `:tabclose` - Close tab
- `:tabonly` - Close all other tabs

## Useful Commands

### File Operations
- `:w` - Save file
- `:q` - Quit
- `:wq` or `:x` or `ZZ` - Save and quit
- `:q!` - Quit without saving
- `:w filename` - Save as filename
- `:r filename` - Read file and insert at cursor

### Settings
- `:set number` or `:set nu` - Show line numbers
- `:set relativenumber` or `:set rnu` - Relative line numbers
- `:set hlsearch` - Highlight search results
- `:set ignorecase` - Case insensitive search
- `:set smartcase` - Smart case search
- `:set wrap` - Enable line wrapping
- `:set paste` - Paste mode (preserves formatting)

### Other Useful Commands
- `.` - Repeat last change
- `==` - Auto-indent current line
- `ggVG=` - Auto-indent entire file
- `:!command` - Execute shell command
- `:%!command` - Filter entire file through command
- `:help keyword` - Get help on keyword

## Advanced Tips

### Combining Commands with Numbers
Most commands can be prefixed with numbers:
- `5j` - Move down 5 lines
- `3w` - Move forward 3 words
- `2dd` - Delete 2 lines
- `4x` - Delete 4 characters

### The Dot Formula
One of Vim's most powerful features:
1. Make a change
2. Move to next location
3. Press `.` to repeat the change

### Common Workflows

**Delete all blank lines:**
```vim
:g/^$/d
```

**Convert tabs to spaces:**
```vim
:%s/\t/    /g
```

**Remove trailing whitespace:**
```vim
:%s/\s\+$//g
```

**Sort unique lines:**
```vim
:%!sort -u
```

**Format JSON:**
```vim
:%!python -m json.tool
```

## Quick Reference Card

### Most Essential Commands
| Command | Action |
|---------|--------|
| `i` | Insert mode |
| `ESC` | Normal mode |
| `:w` | Save |
| `:q` | Quit |
| `/` | Search |
| `u` | Undo |
| `dd` | Delete line |
| `yy` | Copy line |
| `p` | Paste |
| `v` | Visual select |

### Movement Shortcuts
| Command | Action |
|---------|--------|
| `w` | Next word |
| `b` | Previous word |
| `0` | Start of line |
| `$` | End of line |
| `gg` | First line |
| `G` | Last line |

## Practice Exercises

1. **Basic Navigation**: Open a file and navigate using only hjkl
2. **Word Operations**: Delete every other word in a paragraph using `dw`
3. **Visual Mode**: Select a paragraph and indent it
4. **Search/Replace**: Replace all occurrences of 'foo' with 'bar'
5. **Macros**: Record a macro to surround words with quotes
6. **Text Objects**: Change text inside various brackets and quotes

## Configuration Tip

Create a `.vimrc` file in your home directory to save your preferred settings:

```vim
" ~/.vimrc
set number          " Show line numbers
set relativenumber  " Relative line numbers
set tabstop=4       " Tab width
set shiftwidth=4    " Indent width
set expandtab       " Use spaces instead of tabs
set hlsearch        " Highlight search
set ignorecase      " Case insensitive search
set smartcase       " Smart case search
set incsearch       " Incremental search
syntax on           " Syntax highlighting
```

## Learning Path

1. **Week 1**: Master basic navigation (hjkl) and modes
2. **Week 2**: Learn basic editing (dd, yy, p) and searching
3. **Week 3**: Practice text objects and visual mode
4. **Week 4**: Learn windows, buffers, and marks
5. **Week 5**: Start using macros and advanced commands

Remember: Vim has a steep learning curve, but the investment pays off in editing speed and efficiency!
