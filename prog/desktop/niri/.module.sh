packages \
	paru:niri,xwayland-satellite,xdg-desktop-portal-hyprland \
	pacman:niri,xwayland-satellite,xdg-desktop-portal-hyprland \
	yay:niri,xwayland-satellite,xdg-desktop-portal-hyprland

packages \
	paru:dms-shell-bin,quickshell-git \
	yay:dms-shell-bin,quickshell-git

link -f \
	config.kdl:"$XDG_CONFIG_HOME/niri/config.kdl" \
	init.lua:"$XDG_CONFIG_HOME/niri/init.lua" \
	lua:"$XDG_CONFIG_HOME/niri/lua" \
	niri-portals.conf:"$XDG_CONFIG_HOME/xdg-desktop-portal/niri-portals.conf"

cp -r ./dms/ "$XDG_CONFIG_HOME/niri/"
