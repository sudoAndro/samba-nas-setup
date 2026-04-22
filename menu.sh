#!/bin/bash

# ==============================================================
# Samba NAS Setup Tool
# ==============================================================

set -e

show_banner() {
    clear
    echo -e "\033[1;32m"
    cat <<'EOF'
 ____                        _                _   _    _    ____  
              ,---------------------------,
              |  /---------------------\  |
              | |                       | |
              | |       SAMBA NAS       | |
              | |         Setup         | |
              | |                       | |
              | |     bash menu.sh      | |
              |  \_____________________/  |
              |___________________________|
            ,---\_____     []     _______/------,
          /         /______________\           /|
        /___________________________________ /  | ___
        |    created by: sudoAndro          |   |    )
        |  _ _ _                 [-------]  |   |   (
        |  o o o                 [-------]  |  /    _)_
        |__________________________________ |/     /  /
    /-------------------------------------/|      ( )/
  /-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/ /
/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/ /
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


EOF
    echo -e "\033[0m"
}

pause_screen() {
    echo
    read -p "Press Enter to continue..." dummy
}

install_samba() {
    echo "=== Install Samba NAS ==="
    echo

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

    if dpkg -l | grep -q '^ii  samba '; then
        echo "Samba is already installed. Skipping..."
    else
        echo "Installing Samba..."
        sudo apt update
        sudo apt install -y samba
    fi

    if id "$NAS_USER" >/dev/null 2>&1; then
        echo "Linux user $NAS_USER already exists."
    else
        echo "Creating Linux user $NAS_USER..."
        sudo useradd -m "$NAS_USER"
    fi

    echo "Set Samba password for $NAS_USER"
    sudo smbpasswd -a "$NAS_USER"

    if [ ! -d "$SHARE_PATH" ]; then
        echo "Creating share directory..."
        sudo mkdir -p "$SHARE_PATH"
    else
        echo "Directory $SHARE_PATH already exists."
    fi

    sudo chown -R "$NAS_USER:$NAS_USER" "$SHARE_PATH"
    sudo chmod -R 775 "$SHARE_PATH"

    if grep -q "^\[$SHARE_NAME\]$" /etc/samba/smb.conf; then
        echo "Share [$SHARE_NAME] already exists in smb.conf. Skipping..."
    else
        echo "Adding Samba share [$SHARE_NAME]..."

        if [ "$GUEST_ACCESS" = "yes" ]; then
            sudo bash -c "cat >> /etc/samba/smb.conf <<EOF

[$SHARE_NAME]
path = $SHARE_PATH
browseable = yes
read only = no
guest ok = yes
create mask = 0775
directory mask = 0775
EOF"
        else
            sudo bash -c "cat >> /etc/samba/smb.conf <<EOF

[$SHARE_NAME]
path = $SHARE_PATH
browseable = yes
read only = no
guest ok = no
valid users = $NAS_USER
create mask = 0775
directory mask = 0775
EOF"
        fi
    fi

    if command -v ufw >/dev/null 2>&1; then
        echo "Allowing Samba through firewall..."
        sudo ufw allow samba
    fi

    echo "Checking Samba configuration..."
    testparm -s >/dev/null

    echo "Restarting Samba..."
    sudo systemctl restart smbd

    IP=$(hostname -I | awk '{print $1}')

    echo
    echo "✅ Samba NAS setup complete!"
    echo "👤 User: $NAS_USER"
    echo "📁 Share name: $SHARE_NAME"
    echo "📂 Share path: $SHARE_PATH"
    echo "🌐 Access from Windows: \\\\$IP\\$SHARE_NAME"

    pause_screen
}

restart_samba() {
    echo "Restarting Samba..."
    sudo systemctl restart smbd
    echo "Samba restarted."
    pause_screen
}

show_status() {
    echo "=== Samba Status ==="
    sudo systemctl status smbd --no-pager
    pause_screen
}

check_config() {
    echo "=== Samba Config Check ==="
    testparm
    pause_screen
}

show_share_config() {
    echo "=== Current Samba Share Config ==="
    grep -A 10 "^\[.*\]" /etc/samba/smb.conf || true
    pause_screen
}

show_connection_info() {
    echo "=== Windows Connection Data ==="
    echo

    IP=$(hostname -I | awk '{print $1}')

    echo "Server IP: $IP"
    echo "Access from Windows:"
    echo "\\\\$IP"
    echo

    echo "Available shares:"
    grep "^\[" /etc/samba/smb.conf | sed 's/\[//;s/\]//'

    echo
    echo "Example:"
    echo "\\\\$IP\\nas"
    
    pause_screen
}

while true; do
    show_banner
    echo "1) Install Samba NAS"
    echo "2) Restart Samba"
    echo "3) Show Samba Status"
    echo "4) Check Samba Config"
    echo "5) Show Current Share Config"
    echo "6) Windows connection data"
    echo "7) Exit"
    read -p "Choose an option: " choice

case "$choice" in
    1) install_samba ;;
    2) restart_samba ;;
    3) show_status ;;
    4) check_config ;;
    5) show_share_config ;;
    6) show_connection_info ;;
    7) echo "Goodbye!"; exit 0 ;;
    *) echo "Invalid option."; sleep 1 ;;
esac

done