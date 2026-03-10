# Use lsusb (from usbutils) to find the vendor and product ID of your fingerprint reader, then check if it's supported by fprintd and libfprint. If it is, install the appropriate packages.
# Use appropriate libfprint driver packages for your fingerprint reader.
packages \
	pacman:fprintd,libfprint \
	paru:fprintd-git,libfprint-git

# Modifying the PAM configuration to enable fingerprint authentication.
sudo sed -i '/^auth\s\+include\s\+system-login/i \
  auth      sufficient  pam_unix.so try_first_pass nullok\
  auth      sufficient  pam_fprintd.so' /etc/pam.d/system-local-login

sudo sed -i '/^-auth\s\+\[success=2 default=ignore\]\s\+pam_systemd_home.so/i \
  auth      sufficient  pam_fprintd.so' /etc/pam.d/system-auth

# Adding polkit rules (should usually work, refer to arch wiki if fails)
sudo cp /usr/share/polkit-1/rules.d/50-default.rules /etc/polkit-1/rules.d/
