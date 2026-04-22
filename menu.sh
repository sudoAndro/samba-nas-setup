#!/bin/bash

show_banner() {
    clear
    echo -e "\033[1;32m"
    cat <<'EOF'
 _     _       show_banner() {
    clear
    echo -e "\033[1;32m"
    cat <<'EOF'
 ____                        _                _   _    _    ____  
/ ___|  __ _ _ __ ___   __ _| |__   __ _     | \ | |  / \  / ___| 
\___ \ / _` | '_ ` _ \ / _` | '_ \ / _` |    |  \| | / _ \ \___ \ 
 ___) | (_| | | | | | | (_| | |_) | (_| |    | |\  |/ ___ \ ___) |
|____/ \__,_|_| |_| |_|\__,_|_.__/ \__,_|    |_| \_/_/   \_\____/ 

EOF
    echo -e "\033[0m"
}
EOF
    echo -e "\033[0m"
}

show_menu() {
    echo "1) Install Samba NAS"
    echo "2) Create Samba User"
    echo "3) Configure Share"
    echo "4) Restart Samba"
    echo "5) Show Status"
    echo "6) Exit"
    echo
    read -p "Choose an option: " choice
}

install_samba() {
    echo "Install function will be added here."
    read -p "Press Enter to continue..."
}

create_samba_user() {
    echo "Create user function will be added here."
    read -p "Press Enter to continue..."
}

configure_share() {
    echo "Configure share function will be added here."
    read -p "Press Enter to continue..."
}

restart_samba() {
    sudo systemctl restart smbd
    echo "Samba restarted."
    read -p "Press Enter to continue..."
}

show_status() {
    sudo systemctl status smbd --no-pager
    read -p "Press Enter to continue..."
}

while true; do
    show_banner
    show_menu

    case "$choice" in
        1) install_samba ;;
        2) create_samba_user ;;
        3) configure_share ;;
        4) restart_samba ;;
        5) show_status ;;
        6) echo "Goodbye!"; exit 0 ;;
        *) echo "Invalid option"; sleep 1 ;;
    esac
done