packages pacman:base-devel

if ! hash yay 2>/dev/null; then
  info 'Installing Paru (Blazingly Fast AUR Hepler Written in Rust)'
  run-cmds <<-'EOF'
if pushd "$(mktemp -d)" >/dev/null; then
  git clone 'https://aur.archlinux.org/paru-git.git' .
  makepkg -i --syncdeps --rmdeps --noconfirm
  popd >/dev/null || exit 1
else
  echo 'Failed to change to a temporary directory' >&2
fi
EOF
fi

if grep -q '\[chaotic-aur\]' /etc/pacman.conf; then
    print_log -sec "CHAOTIC-AUR" -stat "skipped" "Chaotic AUR entry found in pacman.conf..."
else
    prompt_timer 120 "Would you like to install Chaotic AUR? [y/n] | q to quit "
    is_chaotic_aur=false

    case "${PROMPT_INPUT}" in
    y | Y)
        is_chaotic_aur=true
        ;;
    n | N)
        is_chaotic_aur=false
        ;;
    q | Q)
        print_log -sec "Chaotic AUR" -crit "Quit" "Exiting..."
        exit 1
        ;;
    *)
        is_chaotic_aur=true
        ;;
    esac
    if [ "${is_chaotic_aur}" == true ]; then
        sudo pacman-key --init
        sudo "./chaotic_aur.sh" --install
    fi
fi

link-to /usr/bin/yay/ /usr/bin/paru
link-to "$XDG_CONFIG_HOME/autoloads/cmds/" ./auto/*
