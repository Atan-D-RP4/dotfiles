# see: http://zsh.sourceforge.net/Guide/zshguide02.html

# Only run zshrc if being run interactively
case $- in
    *i*) ;;
    *) return ;;
esac

. ~/.zprofile
