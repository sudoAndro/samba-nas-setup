#!/bin/bash

echo "Installing Samba NAS..."

sudo apt update
sudo apt install samba -y

sudo mkdir -p /srv/nas

sudo chmod 777 /srv/nas

echo "Samba installation complete."