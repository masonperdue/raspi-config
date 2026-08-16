
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
    # MAC IP Binded in Router to 192.168.50.20
    # ssh masonp@192.168.50.20
        sudo apt update
        sudo apt full-upgrade -y
        sudo apt autoremove --purge -y
        sudo raspi-config
            # enable sudo password
            # change locale to us
            # expand filesystem
            # update
        sudo reboot now
    # ssh masonp@192.168.50.20
        sudoedit /etc/ssh/sshd_config
            # change to "Port 7583"
            # change to "PermitRootLogin no"
            # change to "PubkeyAuthentication yes"
            # change to "AuthorizedKeysFile .ssh/authorized_keys"
            # change to "PasswordAuthentication no"
            # change to "X11Forwarding no"
            # add "AllowUsers masonp"
        sudo systemctl disable --now {{avahi-daemon,bluetooth}.service,avahi-daemon.socket}
        sudo systemctl mask {{avahi-daemon,bluetooth}.service,avahi-daemon.socket}
        sudo rm /etc/motd         
        sudo reboot now
    # ssh -A raspi
        sudo apt install -y git neovim tree sane-utils nmap unattended-upgrades dnsutils imagemagick
        sudo dpkg-reconfigure unattended-upgrades
            # yes
        git clone git@github.com:masonperdue/raspi-config.git
        cd raspi-config
        echo "" >> /home/masonp/.bashrc
        echo ". /home/masonp/raspi-config/mybashrc" >> /home/masonp/.bashrc
        cd
        git clone git@github.com:masonperdue/neovim-config.git
        cd neovim-config
        ./setup.sh
        cd
        source ~/.bashrc
        sudo usermod -aG scanner masonp

# Set raspi dns to cloudflare (so server can update w/o servers running)
    nmcli connection show
    sudo nmcli con mod netplan-eth0 ipv4.dns 1.1.1.1
    sudo nmcli con mod netplan-eth0 ipv4.ignore-auto-dns yes
    sudo nmcli con up netplan-eth0
    sudo nmcli radio wifi off
    nmcli dev show
    dig startpage.com

# Blocky & Unbound
    sudo ss -tuln
    sudo apt install -y podman
    sudo cp -R ~/raspi-config/etc-containers-systemd/* /etc/containers/systemd/
    sudo cp -R ~/raspi-config/etc-blocky/* /etc/blocky/
    sudo systemctl daemon-reload
    sudo systemctl enable --now podman-auto-update.timer
    sudo systemctl start blocky.service
    # Testing
        sudo systemctl status unbound.service
        sudo systemctl status blocky.service
        sudo podman container list
        dig @127.0.0.1 -p 5335 google.com +short
        dig @127.0.0.1 -p 53 google.com +short
        dig @127.0.0.1 -p 53 doubleclick.net +short
        dig @127.0.0.1 -p 5335 cloudflare.com +dnssec
        dig @127.0.0.1 -p 5335 dnssec-failed.org
        dig @127.0.0.1 -p 5335 dnssec-failed.org +cd
        dig @127.0.0.1 -p 53 cloudflare.com +dnssec
        dig @127.0.0.1 -p 53 dnssec-failed.org
        dig @127.0.0.1 -p 53 dnssec-failed.org +cd
    sudo reboot now

# Firewalld
    sudo apt install -y firewalld
    sudo systemctl status firewalld.service
    sudo firewall-cmd --set-default-zone drop
    sudo firewall-cmd --zone=drop --add-port=7583/tcp --add-port=53/tcp --add-port=53/udp
    sudo firewall-cmd --runtime-to-permanent
    # Testing
        sudo firewall-cmd --state
        sudo firewall-cmd --get-default-zone
        sudo firewall-cmd --get-active-zones
        sudo firewall-cmd --list-all
