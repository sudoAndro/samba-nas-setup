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

## Preview

![Samba NAS Setup Menu](images/common.png/menu.png)

## Installation

Clone the repository:

```bash
git clone git@github.com:sudoAndro/samba-nas-setup.git
cd samba-nas-setup

## Run the tool:

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

After installation you can access the NAS from Windows or Phone:

## Windows:
\\SERVER-IP\SHARENAME

## Phone:
smb://SERVER-IP/SHARENAME



## Project structure

samba-nas-setup
├─ menu.sh
├─ common.sh
├─ functions.sh
├─ install.sh
├─ uninstall.sh
├─ README.md
├─ docs
│  └─ setup.md
└─ examples
   └─ smb-share-example.conf


## Notes

- Share name is not the same as username
- The tool stores last setup data in:

/etc/samba-nas-setup.conf