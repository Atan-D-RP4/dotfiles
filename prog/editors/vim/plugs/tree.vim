Plug 'mbbill/undotree'

nnoremap <geader>u :UndotreeToggle<CR>

let g:netrw_banner=0                                                           " configure netrw to be more dired like
let g:netrw_fastbrowse=1                                                       " cache directory entries only when remote
let g:netrw_keepdir=1
let g:netrw_silent=1
let g:netrw_special_syntax=1
let g:netrw_bufsettings = "noma nomod nonu nowrap ro nobl relativenumber"      " Fix relativenumber being unset in netrw buffers
let g:EasyMotion_startofline=0                                                 " keep cursor column when JK motion
let g:EasyMotion_smartcase=1                                                   " makes EasyMotion work like smartcase for global searches

