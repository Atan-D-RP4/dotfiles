if executable('yazi')
    Plug 'chriszarate/yazi.vim', { 'on': ['YaziCurrentDirectory'] }
    nnoremap <silent> <leader>o :YaziCurrentDirectory<CR>
else
    echo "yazi not found"
endif

