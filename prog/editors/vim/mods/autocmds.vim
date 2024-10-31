" Position Restore
" ----------------
" Automatically restore the previous cursor position when entering a
" new buffer.
" ResCur silently jumps to the previous cursor position saved in mark "
" without updating the jumplist.
function! ResCur()
  if line("'\"") <= line("$")
    silent! normal! g`"zz
    return 1
  endif
endfunction

function! SynStack ()
  for i1 in synstack(line("."), col("."))
    let i2 = synIDtrans(i1)
    let n1 = synIDattr(i1, "name")
    let n2 = synIDattr(i2, "name")
    echo n1 "->" n2
  endfor
endfunction

" Automatically create missing directories when writing a file.
map gm :call SynStack()<CR>

augroup resCur
  autocmd!
  autocmd BufWinEnter * call ResCur()
augroup END

augroup fileTypeDetect
  autocmd!
  autocmd BufNewFile,BufRead .config   set syntax=clojure
augroup END

augroup help_splits
  autocmd!
  autocmd! BufEnter * if &ft ==# 'help' | wincmd L | endif
augroup END

augroup Mkdir
  autocmd!
  autocmd BufWritePre * call mkdir(expand("<afile>:p:h"), "p")
augroup END

" WSL yank support
let s:clip = '/mnt/c/Windows/System32/clip.exe'  " change this path according to your mount point
if executable(s:clip)
	augroup WSLYank
		autocmd!
		autocmd TextYankPost * if v:event.operator ==# 'y' | call system(s:clip, @0) | endif
	augroup END
endif
