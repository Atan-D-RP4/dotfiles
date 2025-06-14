link "$XDG_CONFIG_HOME/kanata/config.kbd"

packages \
  paru:kanata-bin \
  yay:kanata-bin

set -euo pipefail

sudo tee /usr/lib/systemd/system/kanata.service > /dev/null << EOF
[Unit]
Description=Kanata keyboard remapper
Documentation=https://github.com/jtroo/kanata

[Service]
Nice=-20
Type=simple
ExecStart=/usr/bin/kanata --cfg ${HOME}/.config/kanata/config.kbd
Restart=always
RestartSec=3

[Install]
WantedBy=default.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable kanata.service
sudo systemctl start kanata.service
