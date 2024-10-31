
"        _
" __   _(_)_ __ ___  _ __ ___
" \ \ / | | '_ ` _ \| '__/ __|
"  \ V /| | | | | | | | | (__
"   \_/ |_|_| |_| |_|_|  \___|
"

set nocompatible

" XDG Compatibility Stuff
" -----------------------

" Assign the defaults when the environment doesn't provide them.
if empty($XDG_CACHE_HOME)
  let $XDG_CACHE_HOME = $HOME.'/.cache'
endif
if empty($XDG_CONFIG_HOME)
  let $XDG_CONFIG_HOME = $HOME.'/.config'
endif

" Make sure any configuration directories/paths exist.
if !isdirectory($XDG_CACHE_HOME."/vim/swap")
  call mkdir($XDG_CACHE_HOME."/vim/swap", "p")
endif
if !isdirectory($XDG_CACHE_HOME."/vim/backup")
  call mkdir($XDG_CACHE_HOME."/vim/backup", "p")
endif
if !isdirectory($XDG_CACHE_HOME."/vim/undo")
  call mkdir($XDG_CACHE_HOME."/vim/undo", "p")
endif
if !isdirectory($XDG_CACHE_HOME."/vim/view")
  call mkdir($XDG_CACHE_HOME."/vim/view", "p")
endif

let &undodir=$XDG_CACHE_HOME.'/vim/undo'
let &directory=$XDG_CACHE_HOME.'/vim/swap'
let &backupdir=$XDG_CACHE_HOME.'/vim/backup'
let &viewdir=$XDG_CACHE_HOME.'/vim/view'
let &runtimepath=expand('$XDG_CONFIG_HOME/vim,$VIMRUNTIME,$XDG_CONFIG_HOME/vim/after')
let g:netrw_home=$XDG_CACHE_HOME.'/vim'

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

let mapleader = "\r"
let localleader = "\r"
let g:mapleader = "\r"
let g:localleader = "\r"

autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o " suppress automatic comment insertion

autocmd BufEnter    * silent! lcd %:p:h                                        " like autochdir except for any buffer, not just files
silent! au TermOpen * setlocal listchars= nonumber norelativenumber            " disable line numbers in vims builtin terminal emulator

if $TERM == "cygwin"
  let &t_ti.="\e[1 q" &t_SI.="\e[5 q" &t_EI.="\e[1 q" &t_te.="\e[0 q"          " use a block cursor on windows cygwin
endif

runtime! mods/*

source $XDG_CONFIG_HOME/vim/plugins.vim                                        " Load vim plugin configuration
