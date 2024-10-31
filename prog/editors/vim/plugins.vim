" Global variables
let g:vim_home = expand('$XDG_CONFIG_HOME/vim')
let g:plug_path = g:vim_home . '/autoload/plug.vim'
let g:plug_url = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
let g:configured_plugins = []
let g:plugins_state_file = g:vim_home . '/.plugins_state'

" Function to install vim-plug if not present
function! s:InstallVimPlug() abort
  if !filereadable(g:plug_path)
    echo "Installing vim-plug..."
    silent execute '!curl -fLo ' . g:plug_path . ' --create-dirs ' . g:plug_url
    
    if filereadable(g:plug_path)
      echo "vim-plug installed successfully. Please restart vim."
      let g:plug_just_installed = 1
      return 1
    else
      echoerr "Failed to install vim-plug. Please install manually."
      return 0
    endif
  endif
  return 1
endfunction

" Function to source plugin configuration files
function! s:LoadPluginConfig(plug_file) abort
  let l:full_path = g:vim_home . '/plugs/' . a:plug_file
  
  if filereadable(l:full_path)
    let l:prev_plugins = exists('g:plugs') ? len(g:plugs) : 0
    execute 'source ' . l:full_path
    
    " Track newly added plugins
    if exists('g:plugs')
      let l:curr_plugins = len(g:plugs)
      if l:curr_plugins > l:prev_plugins
        let l:new_plugins = keys(g:plugs)[l:prev_plugins : l:curr_plugins-1]
        call extend(g:configured_plugins, l:new_plugins)
      endif
    endif
  else
    echom "Plugin config not found: " . l:full_path
  endif
endfunction

" Function to read cached plugin state
function! s:ReadPluginState() abort
  if filereadable(g:plugins_state_file)
    let l:content = readfile(g:plugins_state_file)
    return l:content
  endif
  return []
endfunction

" Function to write current plugin state
function! s:WritePluginState() abort
  if exists('g:plugs')
    call writefile(sort(keys(g:plugs)), g:plugins_state_file)
  endif
endfunction

" Function to check if plugins list has changed
function! s:PluginsChanged() abort
  " Always install if vim-plug was just installed
  if exists('g:plug_just_installed')
    return 1
  endif
  
  " Skip if g:plugs doesn't exist (no plugins configured)
  if !exists('g:plugs')
    return 0
  endif
  
  " Get previous state
  let l:previous_plugins = s:ReadPluginState()
  let l:current_plugins = sort(keys(g:plugs))
  
  " If no previous state exists, consider it changed
  if empty(l:previous_plugins)
    return 1
  endif
  
  " Compare current and previous states
  return string(l:previous_plugins) !=# string(l:current_plugins)
endfunction

" Function to check if plugins need installation
function! s:PluginsNeedInstall() abort
  " Check if plugins list has changed
  if s:PluginsChanged()
    return 1
  endif
  
  " Check for any missing plugins
  if exists('g:plugs')
    for [name, spec] in items(g:plugs)
      if !isdirectory(spec.dir)
        return 1
      endif
    endfor
  endif
  
  return 0
endfunction

" Main initialization
if s:InstallVimPlug()
  " Begin plugin declarations
  call plug#begin(g:vim_home . '/plugins')
  
  " Load plugin configurations
  call s:LoadPluginConfig('sneak.vim')
  call s:LoadPluginConfig('yazi.vim')
  call s:LoadPluginConfig('fzf.vim')
  call s:LoadPluginConfig('git.vim')
  call s:LoadPluginConfig('copilot.vim')
  call s:LoadPluginConfig('lspconfig.vim')
  call s:LoadPluginConfig('quickscope.vim')
  call s:LoadPluginConfig('tokyo-night.vim')
  call s:LoadPluginConfig('tree.vim')
  
  " End plugin declarations
  call plug#end()
  
  " Auto-install plugins if needed
  if s:PluginsNeedInstall()
    augroup PlugInstallGroup
      autocmd!
      autocmd VimEnter * PlugInstall --sync | call s:WritePluginState() | source $MYVIMRC
    augroup END
  endif
endif
