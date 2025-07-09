packages pacman:networkmanager,network-manager-applet
packages pacman:ufw

sudo systemctl enable NetworkManager.service
sudo systemctl enable ufw.service
