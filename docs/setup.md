# 📦 Samba NAS Setup Guide

This guide explains how to use the **Samba NAS Setup Tool** step by step.

---

## 1️⃣ Requirements

Make sure your system meets the following:

* Debian / Ubuntu / Raspberry Pi OS
* sudo privileges
* Internet connection

---

## 2️⃣ Install dependencies

```bash
sudo apt update
sudo apt install whiptail samba -y
```

---

## 3️⃣ Start the tool

```bash
bash menu.sh
```

---

## 4️⃣ Create your NAS share

In the menu, choose:

```text
1) Install Samba NAS
```

You will be asked for:

* **Samba username** → login user
* **Share name** → folder name (e.g. `nas`, `media`, `files`)
* **Share path** → folder location (default: `/srv/nas`)
* **Guest access** → yes/no
* **Password** → Samba password

---

## 5️⃣ What happens automatically

The tool will:

* install Samba (if not already installed)
* create a Linux user
* create a Samba user
* create the share directory
* set correct permissions
* update `/etc/samba/smb.conf`
* restart the Samba service

---

## 6️⃣ Connect from Windows

Open Explorer and enter:

```text
\\SERVER-IP\SHARENAME
```

Example:

```text
\\192.168.50.233\share
```

---

## 7️⃣ Connect from Phone

Use any file manager (e.g. Solid Explorer, CX File Explorer):

```text
smb://SERVER-IP/SHARENAME
```

Example:

```text
smb://192.168.50.233/share
```

---

## 8️⃣ Login

Use the credentials you created:

* Username: your Samba username
* Password: your Samba password

⚠️ Important:

* Share name is NOT the same as username
* Wrong login = no access

---

## 9️⃣ Troubleshooting

### Check Samba status

Menu:

```text
3) Show Samba Status
```

---

### Check configuration

Menu:

```text
4) Check Samba Config
```

---

### View current shares

Menu:

```text
5) Show Current Share Config
```

---

### Connection info

Menu:

```text
6) Windows / Phone connection data
```

---

## 🔟 Common issues

### Cannot connect from Windows

* Check firewall:

```bash
sudo ufw allow samba
```

* Check IP:

```bash
hostname -I
```

---

### Share not visible

Restart Samba:

```bash
sudo systemctl restart smbd
```

---

### Wrong permissions

Fix manually:

```bash
sudo chown -R USER:USER /srv/nas
sudo chmod -R 775 /srv/nas
```

---

## 📁 Config file

The tool stores last setup in:

```text
/etc/samba-nas-setup.conf
```

---

## ✅ Done

Your NAS is now ready to use.
