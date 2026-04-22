#!/bin/bash

# ==============================================================
# Samba NAS Installation Script
# ==============================================================

set -e

echo "=== Samba NAS Installer ==="

# ==============================================================
# Samba Installation
# ==============================================================

if dpkg -l | grep -q '^ii  samba '; then
    echo "Samba is already installed. Skipping..."
else
    echo "Installing Samba..."
    sudo apt update
    sudo apt install -y samba
fi

# ==============================================================
# Samba User Setup
# ==============================================================

echo "Creating Samba user..."
read -p "Enter username for Samba access: " NAS_USER

if id "$NAS_USER" >/dev/null 2>&1; then
    echo "Linux user $NAS_USER already exists"
else
    sudo useradd -m "$NAS_USER"
fi

echo "Set Samba password for $NAS_USER"
sudo smbpasswd -a "$NAS_USER"

# ==============================================================
# NAS Directory
# ==============================================================

if [ ! -d /srv/nas ]; then
    echo "Creating NAS directory..."
    sudo mkdir -p /srv/nas
    sudo chmod 775 /srv/nas
    sudo chown "$NAS_USER:$NAS_USER" /srv/nas
else
    echo "Directory /srv/nas already exists"
    sudo chown "$NAS_USER:$NAS_USER" /srv/nas
    sudo chmod 775 /srv/nas
fi

# ==============================================================
# Samba Share Configuration
# ==============================================================

if ! grep -q "^\[nas\]$" /etc/samba/smb.conf; then
    echo "Adding Samba share..."

    sudo bash -c "cat >> /etc/samba/smb.conf <<EOF

[nas]
path = /srv/nas
browseable = yes
read only = no
guest ok = no
valid users = $NAS_USER
create mask = 0775
directory mask = 0775
EOF"
else
    echo "Samba share already exists"
fi

# ==============================================================
# Firewall
# ==============================================================

if command -v ufw >/dev/null 2>&1; then
    echo "Allowing Samba through firewall..."
    sudo ufw allow samba
fi

# ==============================================================
# Restart Service
# ==============================================================

echo "Restarting Samba..."
sudo systemctl restart smbd

# ==============================================================
# Done
# ==============================================================

echo ""
echo "✅ Samba NAS setup complete!"
echo "📁 Share: /srv/nas"
echo "👤 User: $NAS_USER"