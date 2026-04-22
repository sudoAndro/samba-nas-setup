## Datei `uninstall.sh`

```bash
#!/bin/bash

set -e

echo "=== Samba NAS Uninstall Tool ==="

read -p "Enter share name to remove: " SHARE_NAME

if [ -z "$SHARE_NAME" ]; then
    echo "Share name cannot be empty."
    exit 1
fi

if grep -q "^\[$SHARE_NAME\]$" /etc/samba/smb.conf; then
    echo "Removing share [$SHARE_NAME] from smb.conf..."
    sudo sed -i "/^\[$SHARE_NAME\]$/,/^$/d" /etc/samba/smb.conf
else
    echo "Share [$SHARE_NAME] not found in smb.conf."
fi

echo "Restarting Samba..."
sudo systemctl restart smbd

echo "Done."
echo "Note: Share directory and user were not deleted automatically."