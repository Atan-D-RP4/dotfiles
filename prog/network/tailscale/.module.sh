packages pacman:tailscale

# Enable tailscale service
sudo systemctl enable --now tailscaled
sudo tailscale set --operator=$USER

# Advertise as exit node (optional)
# sudo tailscale set --advertise-exit-node

# Set exit node IP
# sudo tailscale set --exit-node=$(tailscale status | head -n 1 | awk '{print $1}')

# Allow LAN access (optional)
# sudo tailscale set --accept-routes --accept-dns --exit-node-allow-lan-access

# Tailscale exit node (optional)
# Enable IP forwarding
# echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
# echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
# sudo sysctl -p /etc/sysctl.d/99-tailscale.conf

# Check if ufw is installed and enabled
if command -v ufw &>/dev/null && sudo ufw status | grep -q "Status: active"; then
	info "UFW is installed and enabled. Configuring for Tailscale exit node..."

	# Enable masquerading on UFW (for use with Tailscale exit node)
	echo '*nat' | sudo tee -a /etc/ufw/before.rules
	echo ':POSTROUTING ACCEPT [0:0]' | sudo tee -a /etc/ufw/before.rules
	echo '-A POSTROUTING -s 100.64.0.0/10 -o $(ip route | grep default | awk '{print $5}') -j MASQUERADE' | sudo tee -a /etc/ufw/before.rules
	# ---------------------------------------^------ Get active network interface -------^

	echo DEFAULT_FORWARD_POLICY="ACCEPT" | sudo tee -a /etc/ufw/ufw.conf
	sudo ufw reload
fi
