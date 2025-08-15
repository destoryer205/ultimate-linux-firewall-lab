#!/bin/bash

# ===========================
#  Ultimate Linux Firewall Lab Setup
# ===========================
# This script sets up a privacy-focused, USB-bootable firewall and monitoring lab.
# Tools included: iptables, fail2ban, Tor, GUFW, log monitor

# ---------------------------
#  Update & Install Tools
# ---------------------------
echo "[+] Updating system and installing packages..."
sudo apt update && sudo apt install -y \
    iptables \
    iptables-persistent \
    fail2ban \
    gufw \
    tor \
    net-tools \
    curl

# ---------------------------
#  Create user 'cooper' with password 'dexter&baby'
# ---------------------------
echo "[+] Creating user 'cooper' with sudo privileges..."
sudo adduser --gecos "" cooper
echo "cooper:dexter&baby" | sudo chpasswd
sudo usermod -aG sudo cooper

# ---------------------------
# Configure iptables Firewall
# ---------------------------
echo "[+] Configuring iptables firewall..."
sudo iptables -F
sudo iptables -P INPUT DROP
sudo iptables -P FORWARD DROP
sudo iptables -P OUTPUT ACCEPT

# Allow loopback
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A OUTPUT -o lo -j ACCEPT

# Allow established connections
sudo iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow SSH (optional)
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Save rules
sudo netfilter-persistent save

# ---------------------------
#  Enable fail2ban for SSH
# ---------------------------
echo "[+] Enabling fail2ban for brute-force protection..."
echo "[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600
findtime = 600" | sudo tee /etc/fail2ban/jail.local > /dev/null

sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# ---------------------------
#  Start TOR for Privacy
# ---------------------------
echo "[+] Starting Tor service for anonymized traffic..."
sudo systemctl enable tor
sudo systemctl start tor

# ---------------------------
#  Log Monitor Script
# ---------------------------
echo "[+] Creating firewall_monitor.sh script..."
echo '#!/bin/bash
echo "[+] Monitoring dropped packets..."
dmesg --ctime | grep "DROP" | tail -n 20' > ~/firewall_monitor.sh
chmod +x ~/firewall_monitor.sh

# ---------------------------
#  Launch GUFW (GUI Firewall)
# ---------------------------
echo "[+] You can launch GUFW by running: sudo gufw"

# ---------------------------
#  Summary
# ---------------------------
echo "\n SETUP COMPLETE: Your bootable USB firewall lab is ready!"
echo "- Firewall: iptables default-deny with SSH allowed"
echo "- Brute-force protection: fail2ban active"
echo "- Anonymized browsing: Tor ready (use 127.0.0.1:9050 SOCKS5)"
echo "- GUI management: gufw"
echo "- Monitor script: ~/firewall_monitor.sh"
echo "\n Reboot system for full effect."

exit 0

