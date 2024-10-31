" [[ Setting Neovim default options ]]
" These are some of the options enabled by default in Neovim
" These are options believed by many Vim users to be essential.
" For more information, see `:h vim_diff.txt` in Neovim
" I will skip the 
set title titlestring=%t%(\ %M%)%(\ (%{substitute(getcwd(),\ $HOME,\ '~',\ '')})%)%(\ %a%) titleold=

" Editor Options (Set in tokyo-night.vim)
" --------------
" syntax on
" colorscheme mohkale

" Change the terminals title depending on the current buffer. Format: filename [modifiers ](dirname)

if has('nvim')
  set inccommand=nosplit
endif

filetype on

set autoindent 
set autoread 
set background=dark
set backspace=indent,eol,start belloff=all
set display=lastline 
set hidden
set history=10000 
set nojoinspaces
set showcmd 
set nostartofline 
set showmatch
set switchbuf=uselast 

" Line number defaults
set number 
set relativenumber 
set ruler

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

" Enable swapfiles and backups
set swapfile
set backup

" Case-insensitive search unless \C or one or more capital letters are used
set ignorecase 
set smartcase

" Tab and indent settings
set noexpandtab
set softtabstop=0
set tabstop=4
set shiftwidth=4
set expandtab
set smarttab 

" Enable Wildmenu and set its defaults
set wildmenu 
set wildmode=longest:full,full
set wildoptions=pum,tagfile,fuzzy
set wildignore+=*/tmp/*,*.so,*.swp,*.zip,*.pyc,*.pyo,*.exe,*.dll,*.obj,*.o,*.a,*.lib,*.so,*.dylib,*.class,*.jar,*.war
set pumheight=20
set display+=truncate

" Set the default timeout for keycodes
set updatetime=300          " Time in milliseconds to write swap file
set encoding=utf-8          " Internal encoding
set ttimeout                " Time out for key codes
set ttimeoutlen=10          " Wait up to 100ms after Esc for special key
set timeoutlen=1000         " Time out for key codes

" Defaults for opening splits
set splitbelow 
set splitright

" Set how vim will display whitespace
set list 
set listchars=tab:▸\ ,trail:·,extends:»,precedes:«,nbsp:␣

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
set laststatus=2 
set lazyredraw
set shortmess+=I                                                               " disable the default startup message

set whichwrap+=<,>,h,l,[,]                                                     " move to previous or next line when moving back at eol
set guifont=Meslo\ LG\ M\ DZ                                                   " set preffered font for graphical vim displays
set selection=old                                                              " Fix bizarre eol behaviour in visual mode. See [[https://vi.stackexchange.com/questions/12607/extend-visual-selection-til-the-last-character-on-the-line-excluding-the-new-li][here]]

set foldmethod=marker                                                          " Detect folding based on foldexpr

set wildcharm=<C-z>                                                            " Use <C-z> to enter wildcharm mode

" WARN: For some reason nvim and vim viminfo files are [[https://vi.stackexchange.com/q/9987][incompatible]].
if has('nvim')
  set viminfo='250,\"100,:20,%,n$XDG_DATA_HOME/nvim/viminfo
else
  set viminfo='250,\"100,:20,%,n$XDG_DATA_HOME/vim/viminfo
endif


" vim: ts=2 sts=2 sw=2 et
