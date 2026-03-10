link "$XDG_CONFIG_HOME/kanata/config.kbd"

packages \
  paru:kanata-bin \
  yay:kanata-bin

sudo groupdel uinput || true
sudo groupadd --system uinput
sudo usermod -aG uinput $USER
sudo usermod -aG input $USER
# KERNEL=="uinput", GROUP="uinput", MODE="0660", OPTIONS+="static_node=uinput"
sudo tee /etc/udev/rules.d/99-uinput.rules >/dev/null <<EOF
KERNEL=="uinput", GROUP="uinput", MODE="0660", OPTIONS+="static_node=uinput"
EOF
sudo udevadm control --reload-rules
sudo udevadm trigger --name-match=uinput

info "Setting up Kanata service..."
link "$XDG_CONFIG_HOME/systemd/user/kanata.service"

sudo tee /usr/lib/systemd/system/kanata.service >/dev/null <<EOF
[Unit]
Description=Kanata keyboard remapper
Documentation=https://github.com/jtroo/kanata
After=dev-uinput.device

[Service]
Nice=-20
Type=simple
ExecStart=/usr/bin/sh -c 'exec $(which kanata) -p 7070 --cfg ${HOME}/.config/kanata/config.kbd'
ExecReload=/bin/kill -HUP $MAINPID
CapabilityBoundingSet=~CAP_SYS_* CAP_SET* CAP_NET_* CAP_DAC_* \
  CAP_CHOWN CAP_FSETID CAP_FOWNER CAP_IPC_OWNER CAP_LINUX_IMMUTABLE \
  CAP_IPC_LOCK CAP_BPF CAP_KILL CAP_BLOCK_SUSPEND CAP_LEASE
AmbientCapabilities=
NoNewPrivileges=yes
KeyringMode=private
PrivateTmp=yes
ProtectSystem=strict
ProtectClock=yes
ProtectHostname=yes
ProtectKernelModules=yes
ProtectKernelLogs=yes
ProtectKernelTunables=yes
ProtectControlGroups=yes
ProtectProc=invisible
RestrictAddressFamilies=AF_UNIX AF_INET
IPAddressDeny=any
IPAddressAllow=localhost
RestrictNamespaces=yes
RestrictSUIDSGID=yes
RestrictRealtime=yes
LockPersonality=yes
MemoryDenyWriteExecute=yes
SystemCallArchitectures=native
SystemCallFilter=@system-service

UMask=0077
Restart=always
RestartSec=3

[Install]
WantedBy=default.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now kanata.service
sudo systemctl status kanata.service
