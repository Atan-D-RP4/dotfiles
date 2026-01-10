packages \
	paru:niri,xwayland-satellite \
	pacman:niri,xwayland-satellite \
	yay:niri,xwayland-satellite

packages \
	paru:dms-shell-bin,quickshell-git \
	yay:dms-shell-bin,quickshell-git

link -f \
	config.kdl:"$XDG_CONFIG_HOME/niri/config.kdl" \
	events.lua:"$XDG_CONFIG_HOME/niri/events.lua"

cp -r ./dms/ "$XDG_CONFIG_HOME/niri/"
