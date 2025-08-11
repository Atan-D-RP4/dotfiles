makedir "$XDG_STATE_HOME/fzf/history"
touch "$XDG_STATE_HOME/fzf/history/default"

# From ubuntu 20.04 this is no longer necessary.
# run-cmd sudo add-apt-repository ppa:x4121/ripgrep
# run-cmd sudo apt update

packagex fzf
