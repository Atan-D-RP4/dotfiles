# Reference: https://wiki.archlinux.org/title/Uncomplicated_Firewall
packages pacman:ufw


sudo ufw default allow outgoing
sudo ufw default deny incoming
sudo ufw allow 22/tcp
sudo ufw app list
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https
sudo ufw allow 25/tcp  # smtp
sudo ufw allow 143/tcp # imap
sudo ufw allow 993/tcp # imaps
sudo ufw allow 110/tcp # pop3
sudo ufw allow 995/tcp # pop3s
sudo ufw enable
sudo ufw status verbose
