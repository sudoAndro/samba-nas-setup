# Setup Guide

## 1. Install dependencies

```bash
sudo apt update
sudo apt install whiptail samba -y

## 2. Start the menu
bash menu.sh

## 3. Create your share

Use menu option:

Install Samba NAS

Then enter:

Samba username
share name
share path
guest access
Samba password

## 4. Connect from Windows
\\SERVER-IP\SHARENAME

## 5. Connect from phone
smb://SERVER-IP/SHARENAME

## 6. Check configuration

Use menu options:

Show Samba Status
Check Samba Config
Windows / Phone connection data

## Datei `examples/smb-share-example.conf`

```ini
[share]
path = /srv/nas
browseable = yes
read only = no
guest ok = no
valid users = myuser
create mask = 0775
directory mask = 0775
