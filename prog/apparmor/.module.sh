packages \
	pacman:apparmor apparmor.d.enforced

sudo systemctl enable --now apparmor
sudo systemctl status apparmor
info 'AppArmor status:'
info "enabled: $(sudo aa-enabled)"
# Show warning to user about enabling AppArmor by default
# Apparmor reuires kernel parameter to be set to be enabled by default on boot
info 'AppArmor requires the following kernel parameters to be set in your bootloader configuration to be enabled by default on boot.'
info 'lsm=landlock,lockdown,yama,integrity,apparmor,bpf'
info 'Please refer to your bootloader documentation on how to set kernel parameters.'
info 'This is needed to set AppArmor as the default LSM (Linux Security Module) on your system.'
