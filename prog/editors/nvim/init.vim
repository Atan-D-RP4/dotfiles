" Check $NVIM_APPNAME, default to 'nvim' if not set
if !exists('$NVIM_APPNAME')
  let $NVIM_APPNAME = 'nvim'
endif
luafile $XDG_CONFIG_HOME/$NVIM_APPNAME/init.lua
