#!/bin/bash

# ==============================================================
# Samba NAS Installation Script
# ==============================================================

set -e

echo "=== Samba NAS Installer ==="
echo ""

# ==============================================================
# User Input
# ==============================================================

while true; do
    read -p "Enter Samba username: " NAS_USER
    if [ -n "$NAS_USER" ]; then
        break
    else
        echo "Username cannot be empty."
    fi
done

read -p "Enter share name [nas]: " SHARE_NAME
SHARE_NAME=${SHARE_NAME:-nas}

read -p "Enter share path [/srv/nas]: " SHARE_PATH
SHARE_PATH=${SHARE_PATH:-/srv/nas}

while true; do
    read -p "Allow guest access? (yes/no) [no]: " GUEST_ACCESS
    GUEST_ACCESS=${GUEST_ACCESS:-no}
    case "$GUEST_ACCESS" in
        yes|no) break ;;
        *) echo "Please enter yes or no." ;;
    esac
done

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
# Linux User
# ==============================================================

if id "$NAS_USER" >/dev/null 2>&1; then
    echo "Linux user $NAS_USER already exists."
else
    echo "Creating Linux user $NAS_USER..."
    sudo useradd -m "$NAS_USER"
fi

echo "Set Samba password for $NAS_USER"
sudo smbpasswd -a "$NAS_USER"

# ==============================================================
# Share Directory
# ==============================================================

if [ ! -d "$SHARE_PATH" ]; then
    echo "Creating share directory..."
    sudo mkdir -p "$SHARE_PATH"
else
    echo "Directory $SHARE_PATH already exists."
fi

sudo chown -R "$NAS_USER:$NAS_USER" "$SHARE_PATH"
sudo chmod -R 775 "$SHARE_PATH"

# ==============================================================
# Samba Share Configuration
# ==============================================================

if grep -q "^\[$SHARE_NAME\]$" /etc/samba/smb.conf; then
    echo "Share [$SHARE_NAME] already exists in smb.conf. Skipping..."
else
    echo "Adding Samba share [$SHARE_NAME]..."

    sudo bash -c "cat >> /etc/samba/smb.conf <<EOF

[$SHARE_NAME]
path = $SHARE_PATH
browseable = yes
read only = no
guest ok = $GUEST_ACCESS
valid users = $NAS_USER
create mask = 0775
directory mask = 0775
EOF"
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
# Output
# ==============================================================

IP=$(hostname -I | awk '{print $1}')

echo ""
echo "✅ Samba NAS setup complete!"
echo "👤 User: $NAS_USER"
echo "📁 Share name: $SHARE_NAME"
echo "📂 Share path: $SHARE_PATH"
echo "🌐 Access from Windows: \\\\$IP\\$SHARE_NAME"