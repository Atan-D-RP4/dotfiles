# Display
import ../login/
import ../../kanata/
import ../../waybar/
# import ../../rofi/ # launcher
import ../../fastfetch/
import ../../wget/
import ../../editors/nvim/
import ../../git
import ../../fzf/
import ../../ripgrep/
import ../../terminal/kitty/
import ../../shells/fish/
import ../../media/mpv/

# Hyprland packages
packages \
	pacman:hyprland,hyprlock,hyprpicker,hyprsunset,hypridle,uswm,xdg-desktop-portal-hyprland,xdg-used-dirs \
	paru:hyprland-git,hyprlock-git,hyprpicker-git,hyprsunset-git,hypridle-git,uwsm,xdg-desktop-portal-hyprland,xdg-used-dirs

packages pacman:swww             # wallpaper engine
packages pacman:grim,slurp,satty # screenshot tool, region select for screenshot/screenshare, and annotator
import ../wayland/               # wl-paste, wl-comp clipboard manager and logout tool

# System
import ../../browsers/zen/    # browser
import ../../thunar/          # file manager and archive tool
import ../../network-manager/ # networkmanager and it's systray util

packages pacman:auto-cpufreq,thermald
packages pacman:polkit-gnome    # authentication agent
packages pacman:libnotify,dunst # notifications library, and  daemon
packages pacman:btop            # system monitor

# Audio
packages pacman:pipewire            # audio/video server
packages pacman:pipewire-alsa       # pipewire alsa client
packages pacman:pipewire-audio      # pipewire audio client
packages pacman:pipewire-jack       # pipewire jack client
packages pacman:pipewire-pulse      # pipewire pulseaudio client
packages pacman:gst-plugin-pipewire # pipewire gstreamer client
packages pacman:wireplumber         # pipewire session manager
packages pacman:pavucontrol         # pulseaudio volume control
packages pacman:pamixer             # pulseaudio cli mixer

import ../../bluetooth/ # bluetooth

# Themeing
# --------------------------------------------------- // Theming
packages pacman:nwg-look   # gtk configuration tool
packages pacman:t5ct       # qt5 configuration tool
packages pacman:t6ct       # qt6 configuration tool
packages pacman:vantum     # svg based qt6 theme engine
packages pacman:vantum-qt5 # svg based qt5 theme engine
packages pacman:t5-wayland # wayland support in qt5
packages pacman:t6-wayland # wayland support in qt6

# General
packages pacman:pacman-contrib   # for system update check
packages pacman:parallel         # for parallel processing
packages pacman:jq               # for json processing
packages pacman:imagemagick      # for image processing
packages pacman:brightnessctl    # screen brightness control
packages pacman:playerctl        # media controls
packages pacman:udiskie          # manage removable media
packages pacman:noto-fonts-emoji # emoji font

link -f \
	win-ctrl/win-ctrl.plasma:"$XDG_CONFIG_HOME/win-ctrl/win-ctrl.hypr"
