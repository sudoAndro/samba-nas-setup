#!/bin/bash

# ==============================================================
# Samba NAS Installation Script
# ==============================================================

set -e

echo "Updating system..."
sudo apt update

echo "Installing Samba..."
sudo apt install -y samba

echo "Creating NAS directory..."
sudo mkdir -p /srv/nas

echo "Setting permissions..."
sudo chmod 775 /srv/nas

echo "Samba NAS installation complete!"

# ==============================================================
# Samba Share Configuration
# ==============================================================

echo "Configuring Samba share..."

sudo bash -c 'cat >> /etc/samba/smb.conf <<EOF

[nas]
path = /srv/nas
browseable = yes
read only = no
guest ok = no
create mask = 0775
directory mask = 0775
EOF'

echo "Restarting Samba..."

sudo systemctl restart smbd