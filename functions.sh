#!/bin/bash

install_samba() {
    if ! whiptail --yesno "Start Samba installation?" 10 50; then
        return
    fi

    NAS_USER=$(whiptail --inputbox "Enter Samba username" 10 50 3>&1 1>&2 2>&3)
    [ -z "$NAS_USER" ] && return

    SHARE_NAME=$(whiptail --inputbox "Enter share name" 10 50 "nas" 3>&1 1>&2 2>&3)
    [ -z "$SHARE_NAME" ] && return

    SHARE_PATH=$(whiptail --inputbox "Enter share path" 10 60 "/srv/nas" 3>&1 1>&2 2>&3)
    [ -z "$SHARE_PATH" ] && return

    GUEST_ACCESS=$(whiptail --menu "Allow guest access?" 12 50 2 \
        "yes" "Guest access enabled" \
        "no" "Login required" 3>&1 1>&2 2>&3)
    [ -z "$GUEST_ACCESS" ] && return

    PASS=$(whiptail --passwordbox "Enter Samba password" 10 50 3>&1 1>&2 2>&3)
    [ -z "$PASS" ] && return

    PASS2=$(whiptail --passwordbox "Confirm Samba password" 10 50 3>&1 1>&2 2>&3)
    [ -z "$PASS2" ] && return

    if [ "$PASS" != "$PASS2" ]; then
        whiptail --msgbox "Passwords do not match." 10 50
        return
    fi

    if dpkg -l | grep -q '^ii  samba '; then
        whiptail --msgbox "Samba is already installed. Skipping package installation." 10 60
    else
        sudo apt update
        sudo apt install -y samba
    fi

    if id "$NAS_USER" >/dev/null 2>&1; then
        whiptail --msgbox "Linux user $NAS_USER already exists." 10 50
    else
        sudo useradd -m "$NAS_USER"
    fi

    echo -e "$PASS\n$PASS" | sudo smbpasswd -s -a "$NAS_USER" > /dev/null

    if [ ! -d "$SHARE_PATH" ]; then
        sudo mkdir -p "$SHARE_PATH"
    fi

    sudo chown -R "$NAS_USER:$NAS_USER" "$SHARE_PATH"
    sudo chmod -R 775 "$SHARE_PATH"

    if grep -q "^\[$SHARE_NAME\]$" /etc/samba/smb.conf; then
        whiptail --msgbox "Share [$SHARE_NAME] already exists in smb.conf. Skipping..." 10 60
    else
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
        sudo ufw allow samba
    fi

    testparm -s >/dev/null
    sudo systemctl restart smbd

    sudo bash -c "cat > /etc/samba-nas-setup.conf <<EOF
NAS_USER=\"$NAS_USER\"
SHARE_NAME=\"$SHARE_NAME\"
SHARE_PATH=\"$SHARE_PATH\"
EOF"

    IP=$(hostname -I | awk '{print $1}')

    whiptail --msgbox "Samba NAS setup complete!

Server IP:
$IP

Windows:
\\\\$IP\\$SHARE_NAME

Phone:
smb://$IP/$SHARE_NAME

Share name:
$SHARE_NAME

Username:
$NAS_USER

Password:
******" 20 70
}

restart_samba() {
    sudo systemctl restart smbd
    whiptail --msgbox "Samba restarted." 10 40
}

show_status() {
    TMP_FILE=$(mktemp)
    systemctl status smbd --no-pager > "$TMP_FILE" 2>&1
    whiptail --title "Samba Status" --textbox "$TMP_FILE" 25 90
    rm -f "$TMP_FILE"
}


check_config() {
    TMP_FILE=$(mktemp)
    testparm > "$TMP_FILE" 2>&1
    whiptail --title "Samba Config Check" --textbox "$TMP_FILE" 25 90
    rm -f "$TMP_FILE"
}

show_share_config() {
    TMP_FILE=$(mktemp)
    grep -A 10 "^\[.*\]" /etc/samba/smb.conf > "$TMP_FILE" 2>&1 || true
    whiptail --title "Current Samba Share Config" --textbox "$TMP_FILE" 25 90
    rm -f "$TMP_FILE"
}

show_connection_info() {
    IP=$(hostname -I | awk '{print $1}')

    if [ -f /etc/samba-nas-setup.conf ]; then
        source /etc/samba-nas-setup.conf
    fi

    if [ -z "$SHARE_NAME" ] || [ -z "$NAS_USER" ]; then
        whiptail --msgbox "No saved connection data found yet.

Please run the Samba installation first." 12 60
        return
    fi

    whiptail --title "Windows Connection Data" --msgbox "Windows Connection Data

Server IP:
$IP

Windows:
\\\\$IP\\$SHARE_NAME

Phone:
smb://$IP/$SHARE_NAME

Share name:
$SHARE_NAME

Username:
$NAS_USER

Password:
******" 20 70
}
