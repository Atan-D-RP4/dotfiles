"        My Keybindings----

" Don't use Ex mode, use Q for formatting.
" Revert with ":unmap Q".
map Q gq

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
" Revert with ":iunmap <C-U>".
inoremap <C-U> <C-G>u<C-U>

" Better keybinding Esc in insert mode
inoremap <Esc> <Esc><Esc>
inoremap <C-c> <Esc><Esc>

" Deals with search highlighting for me
nnoremap <silent><Esc> :noh<CR><ESC>

" Keybinding for opening a new line in normal mode
nnoremap <leader><CR> i<CR><Esc>

" Keybinding for deleting a line in normal mode
nnoremap <leader><BS> dd

" Keybinding for opening terminal
nnoremap <leader>' :terminal<CR>

" Keybinding for Toggling Netrw
nnoremap <C-n> :ToggleNetrw<CR>

" Keybinding for Toggling UndoTree -- put in plugs/undotree.vim
nnoremap <leader>z :UndotreeToggle<CR>

" LSP navigation
nnoremap <leader>sl :LspDocumentSymbolSearch<CR>

" Keymaps for buffer-tabs
nnoremap <silent> <leader>] :bnext!<CR>
nnoremap <silent> <leader>[ :bprevious!<CR>
nnoremap <silent> <leader>d :bdelete! %<CR>
nnoremap <silent> <leader>u :edit! #<CR>

" Auto-expands braces
inoremap (; (<CR>);<Esc>O
inoremap (, (<CR>),<Esc>O
inoremap {; {<CR>};<Esc>O
inoremap {, {<CR>},<Esc>O
inoremap [; [<CR>];<Esc>O
inoremap [, [<CR>],<Esc>O

inoremap {<CR> {<CR>}<Esc>O

" Keybindings for navigation
nnoremap <silent> <S-w> b
vnoremap <silent> <S-w> b

" Keybinding for quicksaving
nnoremap <silent> <C-S> :update<CR>
inoremap <silent> <C-S> <Esc>:update <CR>
vnoremap <silent> <C-S> <Esc>:update <CR>

" Keybindings for alt line movement.
nnoremap <silent> <C-k> :call MoveLines(-2)<CR>
nnoremap <silent> <C-j> :call MoveLines(+1)<CR>
nnoremap <silent> <C-Up> :call MoveLines(-2)<CR>
nnoremap <silent> <C-Down> :call MoveLines(+1)<CR>

vnoremap <silent> <C-k> :call MoveVisualSelection(+1)<CR>
vnoremap <silent> <C-j> :call MoveVisualSelection(-2)<CR>
vnoremap <silent> <C-Up> :call MoveVisualSelection(-2)<CR>
vnoremap <silent> <C-Down> :call MoveVisualSelection(+1)<CR>

inoremap <silent> <C-k> <C-o>:m-2 .+<C-r>=v:count1<CR><CR>
inoremap <silent> <C-j> <C-o>:m+ .+<C-r>=v:count1<CR><CR>
inoremap <silent> <C-Up> <C-o>:m-2 .+<C-r>=v:count1<CR><CR>
inoremap <silent> <C-Down> <C-o>:m+ .+<C-r>=v:count1<CR><CR>

" Jump up the file lines
nnoremap <silent> <C-q> <C-u>
vnoremap <silent> <C-q> <C-u>

" Visual shifting (does not exit Visual mode)
vnoremap < <gv
vnoremap > >gv

" Treat long lines as break lines (useful when moving around in them)
nmap j gj
nmap k gk
vmap j gj
vmap k gk

nnoremap <silent> <leader>: :call SkyBison("")<CR>

" Keymap for repeating ':' commands
nnoremap <silent> <leader>; :<Up><CR>

" Remapping for vim-sneak -- put in plugs/sneak.vim
nmap gs <Plug>Sneak_s
nmap gS <Plug>Sneak_S
vmap gs <Plug>Sneak_s
vmap gS <Plug>Sneak_S
