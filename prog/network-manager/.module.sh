packages pacman:networkmanager,network-manager-applet,tailscale

# Enable tailscale service
sudo systemctl enable --now tailscaled
sudo tailscale set --operator=$USER
