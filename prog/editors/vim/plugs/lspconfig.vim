" LSP and LanguageClient Plugins
Plug 'prabirshrestha/vim-lsp'
Plug 'mattn/vim-lsp-settings'
let g:lsp_semantic_enabled = 1
let g:lsp_diagnostics_virtual_text_align = "after"
let g:lsp_use_event_queue = 1
let g:lsp_log_verbose = 1
let g:lsp_log_file = expand('$XDG_DATA_HOME/vim/lsp.log')
let g:lsp_inlay_hints_enabled = 1

Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
let g:async_complete_min_chars = 3
let g:asyncomplete_auto_completeopt = 1

Plug 'sheerun/vim-polyglot'

" ALE
Plug 'dense-analysis/ale'
Plug 'rhysd/vim-lsp-ale'

" LSP settings
function! s:on_lsp_buffer_enabled() abort
    setlocal omnifunc=lsp#complete
    setlocal tagfunc=lsp#tagfunc
    setlocal signcolumn=yes
    nmap <buffer> gd <plug>(lsp-definition)
    nmap <buffer> gr <plug>(lsp-references)
    nmap <buffer> gi <plug>(lsp-implementation)
    nmap <buffer> gt <plug>(lsp-type-definition)
    nmap <buffer> <leader>rn <plug>(lsp-rename)
    nmap <buffer> [g <plug>(lsp-previous-diagnostic)
    nmap <buffer> ]g <plug>(lsp-next-diagnostic)
    nmap <buffer> K <plug>(lsp-hover)
endfunction

augroup lsp_install
    au!
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END
