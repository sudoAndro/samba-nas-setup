# Samba NAS Setup

Simple automated Samba NAS installer for Debian and Raspberry Pi.

```md
## Features

- interactive setup menu
- Samba installation
- Linux + Samba user creation
- automatic share creation
- firewall rule for Samba
- config validation
- service restart and status check

## Installation

Run the setup tool with:

```bash
bash menu.sh

## Share location

After installation the Samba share will be available at:

/srv/nas

You can access it from Windows via:

\\SERVER-IP\nas

## Authentication

During installation you will be prompted to create a Samba user.

Use this user to access the NAS share.

## Access

After installation you can access the NAS from Windows:

\\SERVER-IP\nas
