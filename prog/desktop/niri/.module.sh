# Niri and related packages
packages \
	pacman:niri,xwayland-satellite,xdg-desktop-portal-gnome,xdg-desktop-portal-gtk \
	paru:niri,xwayland-satellite,xdg-desktop-portal-gnome,xdg-desktop-portal-gtk \
	yay:niri,xwayland-satellite,xdg-desktop-portal-gnome,xdg-desktop-portal-gtk

# DMS Shell
packages \
	pacman:dms-shell-git,qt6-multimedia,matugen \
	paru:dms-shell-bin,quickshell-git,qt6-multimedia,matugen \
	yay:dms-shell-bin,quickshell-git,qt6-multimedia,matugen

# Lua for Niri IPC event handlers
packages \
	pacman:luajit,lua52-dkjson,libluv

# Link config files
link -f \
	config.kdl:"$XDG_CONFIG_HOME/niri/config.kdl" \
	binds.kdl:"$XDG_CONFIG_HOME/niri/binds.kdl" \
	rules.kdl:"$XDG_CONFIG_HOME/niri/rules.kdl" \
	dms:"$XDG_CONFIG_HOME/niri/dms" \
	init.lua:"$XDG_CONFIG_HOME/niri/init.lua" \
	lua:"$XDG_CONFIG_HOME/niri/lua" \
	niri-portals.conf:"$XDG_CONFIG_HOME/xdg-desktop-portal/niri-portals.conf" \
	wl-copy:"$XDG_BIN_DIR/wl-copy" \
	wl-paste:"$XDG_BIN_DIR/wl-paste"

# Power and Thermal Management
packages \
	pacman:tlp,thermald

# Audio
packages \
	pacman:pipewire,pipewire-alsa,pipewire-jack,pipewire-audio,pipewire-pulse,wireplumber,gst-plugin-pipewire

# File Manager
packages \
	pacman:thunar,thunar-archive-plugin,thunar-volman,thunar-media-tags-plugin,engrampa

# Misc
packages \
	pacman:udiskie,libinput-tools,smartmontools

# Security
import ../../apparmor/

# Essentials
import ../wayland/
import ../../browsers/zen/
import ../../kanata/
import ../../terminal/kitty/
import ../../shells/fish/
import ../../editors/nvim/
import ../../git/
import ../../wget/
import ../../fzf/
import ../../ripgrep/

# Utilities
import ../../fastfetch/
import ../../ffmpeg/
import ../../network/
import ../../zathura/
import ../../media/mpv/
# import ../../media/mpd/
