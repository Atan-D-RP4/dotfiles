" [[ Setting Neovim default options ]]
" These are some of the options enabled by default in Neovim
" These are options believed by many Vim users to be essential.
" For more information, see `:h vim_diff.txt` in Neovim
" I will skip the 
filetype on
syntax on
set autoindent autoread background=dark
set backspace=indent,eol,start belloff=all
set display=lastline encoding=utf-8 hidden
set history=10000 incsearch
set nojoinspaces laststatus=2 ruler
set showcmd smarttab nostartofline showmatch
set switchbuf=uselast wildmenu 


" Line number defaults
set number relativenumber ruler

" Enable mouse support
set mouse=a
set mousehide

" Don't show mode in the last line since we put it in the statusline
set showmode

" Show tabline
set showtabline=2

" Sync clipboard between OS and Neovim.
"  Schedule the setting after `UiEnter` because it can increase startup-time.
"  Remove this option if you want your OS clipboard to remain independent.
"  See `:help 'clipboard'`
augroup neovim_clipboard
  autocmd!
  autocmd VimEnter * if has('clipboard') | set clipboard+=unnamedplus | endif
augroup END

" Enable break indent
set breakindent
set breakindentopt=shift:4,min:20
set showbreak=+++

" Set preffered font for graphical vim displays
set guifont=Meslo\ LG\ M\ DZ

" Fix bizarre eol behaviour in visual mode. See 
" [[https://vi.stackexchange.com/questions/12607/extend-visual-selection-til-the-last-character-on-the-line-excluding-the-new-li][here]]
set selection=old

" Make backup folders automatically if they don't already exist.
if !isdirectory(expand(&undodir))
	call mkdir(expand(&undodir), "p")
endif
if !isdirectory(expand(&backupdir))
	call mkdir(expand(&backupdir), "p")
endif
if !isdirectory(expand(&directory))
	call mkdir(expand(&directory), "p")
endif

" Do incremental searching when it's possible to timeout.
if has('reltime')
	set incsearch
endif

set nrformats-=octal				" Do not recognize octal numbers for Ctrl-A and Ctrl-X

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries.
if has('win32')
	set guioptions-=t
endif

if has('langmap') && exists('+langremap')
	" Prevent that the langmap option applies to characters that result from a
	" mapping.  If set (default), this may break plugins (but it's backward
	" compatible).
	set nolangremap
endif

if &t_Co > 2 || has("gui_running")
	" Switch on highlighting the last used search pattern.
	set hlsearch
endif


" Save undo history
set undofile 
set undolevels=1000
set undoreload=10000
set undodir='/tmp/.vim/undo'

" Enable swapfiles and backups
set swapfile
set backup

" Case-insensitive search unless \C or one or more capital letters are used
set ignorecase smartcase

" Tab and indent settings
set noexpandtab
set tabstop=4
set shiftwidth=4
set expandtab

" Wildmenu options
set wildmode=longest:full,full
set wildoptions=pum,tagfile,fuzzy
set wildignore+=*/tmp/*,*.so,*.swp,*.zip,*.pyc,*.pyo,*.exe,*.dll,*.obj,*.o,*.a,*.lib,*.so,*.dylib,*.class,*.jar,*.war
set pumheight=20
set display+=truncate

set updatetime=300

set timeout timeoutlen=300 ttimeoutlen=10

" Defaults for opening splits
set splitbelow splitright

" Set how vim will display whitespace
set list listchars=tab:▸\ ,trail:·,extends:»,precedes:«,nbsp:␣

" Preview substitutions live
"set inccommand=split

set cursorline

set scrolloff=10

set path=.,**
set autoread

if has('unnamedplus')
	set clipboard=unnamedplus,unnamed
else
	set clipboard+=unnamed
endif

" WSL yank support
let s:clip = '/mnt/c/Windows/System32/clip.exe'  " change this path according to your mount point
if executable(s:clip)
	augroup WSLYank
		autocmd!
		autocmd TextYankPost * if v:event.operator ==# 'y' | call system(s:clip, @0) | endif
	augroup END
endif

" Cscope settings
if has("cscope")
	set csprg=/usr/bin/cscope
	set csto=0
	set cst
	set nocsverb
	" add any database in current directory
	if filereadable("cscope.out")
		cs add cscope.out
	" else add database pointed to by environment
	elseif $CSCOPE_DB != ""
		cs add $CSCOPE_DB
	endif
	set csverb
endif

" Set the statusline
set lazyredraw

let g:netrw_banner=0                                                           " configure netrw to be more dired like
let g:netrw_fastbrowse=1                                                       " cache directory entries only when remote
let g:netrw_keepdir=1
let g:netrw_silent=1
let g:netrw_special_syntax=1
let g:netrw_bufsettings = "noma nomod nonu nowrap ro nobl relativenumber"      " Fix relativenumber being unset in netrw buffers
let g:EasyMotion_startofline=0                                                 " keep cursor column when JK motion
let g:EasyMotion_smartcase=1                                                   " makes EasyMotion work like smartcase for global searches


" vim: ts=2 sts=2 sw=2 et
