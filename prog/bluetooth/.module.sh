# Bluetooth
packages \
	pacman:bluez,bluez-utils

sudo rfkill unblock bluetooth
sudo systemctl enable --now bluetooth.service
