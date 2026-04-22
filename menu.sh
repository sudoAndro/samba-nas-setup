#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/common.sh"
source "$SCRIPT_DIR/functions.sh"

show_banner

while true; do
    OPTION=$(whiptail --title "Samba NAS Setup Tool" --menu "Choose an option" 22 65 12 \
"1" "Install Samba NAS" \
"2" "Restart Samba" \
"3" "Show Samba Status" \
"4" "Check Samba Config" \
"5" "Show Current Share Config" \
"6" "Windows / Phone connection data" \
"7" "About / Help" \
"8" "Exit" 3>&1 1>&2 2>&3)

    case "$OPTION" in
    1) install_samba ;;
    2) restart_samba ;;
    3) show_status ;;
    4) check_config ;;
    5) show_share_config ;;
    6) show_connection_info ;;
    7) show_about ;;
    8) clear; exit 0 ;;
    *) clear; exit 0 ;;
esac
done