" Quick-scope.vim plugin
Plug 'unblevable/quick-scope'

let g:qs_highlight_on_keys = ['f', 'F', 't', 'T']
let g:qs_max_chars = 80

" Highlight groups Red and Blue
autocmd ColorScheme * highlight QuickScopeSecondary guifg=#00ff00 gui=underline ctermfg=21 cterm=underline
autocmd ColorScheme * highlight QuickScopePrimary guifg=#ff3ede gui=underline ctermfg=196 cterm=underline
