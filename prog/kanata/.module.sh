link "$XDG_CONFIG_HOME/kanata/config.kbd"

# packages \
#   paru:kanata-bin \
#   yay:kanata-bin

set -euo pipefail

info "Setting up Kanata service..."
sudo tee /usr/lib/systemd/system/kanata.service > /dev/null << EOF
[Unit]
Description=Kanata keyboard remapper
Documentation=https://github.com/jtroo/kanata

[Service]
Nice=-20
Type=simple
ExecStart=/usr/bin/kanata --cfg ${HOME}/.config/kanata/config.kbd

# Security enhancements
AmbientCapabilities=CAP_SYS_ADMIN
CapabilityBoundingSet=CAP_SYS_ADMIN
NoNewPrivileges=yes
ProtectHome=yes
ProtectClock=yes
ProtectSystem=strict
ProtectKernelModules=yes
ProtectControlGroups=yes
ProtectKernelTunables=yes
ProtectHostname=yes
ProtectProc=invisible
ProcSubset=pid
PrivateTmp=yes
PrivateDevices=yes
PrivateUsers=yes
PrivateNetwork=yes
RestrictAddressFamilies=AF_INET AF_INET6 AF_UNIX
RestrictNamespaces=yes
RestrictRealtime=yes
LockPersonality=yes
MemoryDenyWriteExecute=yes
ReadOnlyPaths=/etc /usr
ReadWritePaths=/var /run
UMask=0077
Restart=always
RestartSec=3

[Install]
WantedBy=default.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable kanata.service
sudo systemctl start kanata.service
