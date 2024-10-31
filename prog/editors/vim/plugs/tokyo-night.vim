Plug 'ghifarit53/tokyonight-vim'

" set termguicolors if not already set(only if supported)
if (has("termguicolors"))
  set termguicolors
endif

let g:tokyonight_style = 'night'
let g:tokyonight_disable_italic_comment = 1
let g:tokyonight_menu_selection_background = 'blue'
let g:tokyonight_transparent_background = 0

" Autocmd to set colorscheme and syntax on after Plugin is loaded
autocmd VimEnter * colorscheme tokyonight
autocmd VimEnter * syntax on
