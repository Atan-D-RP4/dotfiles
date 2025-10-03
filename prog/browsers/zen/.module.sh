packages \
	paru:zen-browser-bin \
	yay:zen-browser-bin

info "To configure Tor proxying (if using Tor):"
info 'Open Network Settings: In the “Settings” menu, scroll down to “Network'
info 'Settings” and click “Settings…” on the right.'
info 'Set Up a Tor Proxy: In the connection settings, choose “Manual proxy'
info 'configuration.” Enter the following Tor settings:'
info '    SOCKS Host: 127.0.0.1 - Port: 9050'
info '    Save the Proxy Settings: Ensure the settings are saved to apply the Tor'
info '    connection for Konqueror.'
info 'Enable DNS over SOCKS: Check the box for “Proxy DNS when using SOCKS v5” to'
info 'ensure DNS queries go through Tor as wel.'
