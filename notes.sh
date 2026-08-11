
# DO NOT RUN - NOTES ONLY

# Server Setup
    # Raspberry Pi OS Lite
    # Hostname: raspi
    # Capital City: Washington, D.C. (United States)
    # Time Zone: America/Los_Angeles
    # Keyboard Layout: us
    # No WiFi
    # Username: masonp
    # SSH w/ Pubkey Auth
        ssh-keygen -t ed25519 -C "[email]"
            # id_ed25519-raspi
            # passphrase
    # MAC IP Binded in Router to 192.168.50.20
    # ssh masonp@192.168.50.20 -i ~/.ssh/id_ed25519-raspi
        sudo apt update -y
        sudo apt full-upgrade -y
        sudo apt autoremove --purge -y
        sudo raspi-config
            # change locale to us
            # expand filesystem
            # update
        sudo reboot now
    # ssh masonp@192.168.50.20 -i ~/.ssh/id_ed25519-Raspi
        sudoedit /etc/ssh/sshd_config
            # change to "Port 7583"
            # change to "PermitRootLogin no"
            # change to "PubkeyAuthentication yes"
            # change to "AuthorizedKeysFile .ssh/authorized_keys"
            # change to "PasswordAuthentication no"
            # change to "X11Forwarding no"
            # add "AllowUsers masonp"
        # sudo systemctl list-units --type=service
        sudo systemctl disable --now {bluetooth,avahi-daemon}.service
        sudo systemctl disable --now avahi-daemon.socket
        sudo systemctl mask {bluetooth,avahi-daemon}.service
        sudo systemctl mask avahi-daemon.socket
        sudo rm /etc/motd         
        sudo reboot now
    # ssh raspi
        sudo apt install -y git neovim tree sane-utils nmap unattended-upgrades dnsutils imagemagick
        sudo dpkg-reconfigure unattended-upgrades
            # yes
        mkdir ~/.myconfig
        cd ~/.myconfig
        git clone https://github.com/masonperdue/raspi-config.git
        git clone https://github.com/masonperdue/neovim-config.git
        cd raspi-config
        ./setup.sh
        cd ..
        cd neovim-config
        ./setup.sh
        source ~/.bashrc
        sudo usermod -aG scanner masonp


# Set raspi dns to cloudflare (so software can update w/o servers running)
    nmcli connection show
    sudo nmcli con mod netplan-eth0 ipv4.dns 1.1.1.1
    sudo nmcli con mod netplan-eth0 ipv4.ignore-auto-dns yes
    sudo nmcli con up netplan-eth0
    # sudo nmcli radio wifi off
    nmcli dev show
    dig startpage.com

# Blocky & Unbound (Docker Compose)
    


# Unbound
    sudo apt install -y unbound unbound-anchor
    unbound -V
    sudo systemctl edit unbound.service
        # [Service]
        # ExecStartPre=timeout 60s sh -c 'until ping -c1 192.168.50.1; do sleep 1; done;'
    sudo systemctl cat unbound.service
    sudo systemctl daemon-reload
    sudo touch /var/log/unbound.log
    sudo chown unbound:unbound /var/log/unbound.log
    sudo touch /etc/unbound/unbound.conf.d/custom.conf
    sudoedit /etc/unbound/unboud.conf.d/custom.conf
    unbound-checkconf /etc/unbound/unbound.conf.d/custom.conf
    sudo systemctl restart unbound.service
    # unbound -d -vv -c /etc/unbound/unbound.conf
    sudo systemctl status unbound.service
    dig google.com @127.0.0.1 -p 5335
    dig fail01.dnssec.works @127.0.0.1 -p 5335
    dig +ad dnssec.works @127.0.0.1 -p 5335
    ss -tuln

# Firewalld
    sudo apt install -y firewalld
    sudo systemctl status firewalld.service
    sudo firewall-cmd --set-default-zone drop
    sudo firewall-cmd --zone=drop --add-port=7583/tcp --add-port=53/tcp --add-port=53/udp # --add-port=80/tcp --add-port-443/tcp
    sudo firewall-cmd --runtime-to-permanent
    sudo firewall-cmd --state
    sudo firewall-cmd --get-default-zone
    sudo firewall-cmd --get-active-zones
    sudo firewall-cmd --list-all
