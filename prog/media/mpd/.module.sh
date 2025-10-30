makedir "$XDG_CACHE_HOME/mpd"
makedir "$XDG_STATE_HOME/mpd/"

link                                            \
  "$XDG_CONFIG_HOME/mpd/mpd.conf"               \
  "$XDG_CONFIG_HOME/mpDris2/mpDris2.conf"
link-to "$XDG_BIN_DIR" ./cmds/*
link-to "$XDG_CONFIG_HOME/tmuxp/" ./tmux/*

packages                                        \
  choco:mpd                                     \
  paru:mpd,rmpc,mpdris2                          \
  yay:mpd,rmpc,mpdris2

systemctl --user enable --now mpd mpDris2
rmpc update

# if ! bots ncmpc ncmpcpp; then
#   import clients/ncmpcpp
# else
#   import -b                                     \
#     clients/ncmpc                               \
#     clients/ncmpcpp
# fi
