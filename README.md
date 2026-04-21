# Samba NAS Setup

Simple automated Samba NAS installer for Debian and Raspberry Pi.

## Features

- installs Samba
- creates NAS directory
- configures share automatically

## Installation

```bash
bash install.sh

## Share location

After installation the Samba share will be available at:

/srv/nas

You can access it from Windows via:

\\SERVER-IP\nas

## Authentication

During installation you will be prompted to create a Samba user.

Use this user to access the NAS share.
