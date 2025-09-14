link "$XDG_CONFIG_HOME/kanata/config.kbd"

packages \
  paru:kanata-bin \
  yay:kanata-bin

info "Setting up Kanata service..."
sudo tee /usr/lib/systemd/system/kanata.service > /dev/null << EOF
[Unit]
Description=Kanata keyboard remapper
Documentation=https://github.com/jtroo/kanata
After=dev-uinput.device

[Service]
Nice=-20
Type=simple
ExecStart=/usr/bin/kanata --cfg ${HOME}/.config/kanata/config.kbd
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
RestrictAddressFamilies=AF_UNIX
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
sudo systemctl enable kanata.service
sudo systemctl start kanata.service
sudo systemctl status kanata.service
