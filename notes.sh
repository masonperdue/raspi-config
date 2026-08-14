
# DO NOT RUN - NOTES ONLY

# DO: Make new unprivledged user for rootless podman, Victoria Metrics & Grafana & Prometheus Node Exporter, Uptime Kuma + Ntfy, IT-Tools, Tailscale
# DO: Add more block/allow lists & domains to Blocky
# DO: Change Immich DB Password
# DO: Backup Immich

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
        cd raspi-config
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

# Blocky & Unbound
    sudo apt install -y podman
    sudo touch /etc/containers/systemd/{{blocky,unbound}.container,Containerfile,unbound.build,unbound.conf}
    sudo touch /etc/blocky/{config.yml,allowlist.txt,blocklist.txt}
    # sudo ss -tuln
    sudo systemctl daemon-reload
    sudo systemctl start unbound-build.service
    # sudo journalctl -u unbound-build.service -f --no-pager -n 20
    # sudo podman image list --all
    sudo systemctl start unbound.service blocky.service
    sudo systemctl enable --now podman-auto-update.timer
    # sudo podman container list
    # dig @127.0.0.1 -p 5335 google.com +short
    # dig @127.0.0.1 -p 53 google.com +short
    # dig @127.0.0.1 -p 53 doubleclick.net +short
    # dig @127.0.0.1 -p 5335 cloudflare.com +dnssec
    # dig @127.0.0.1 -p 5335 dnssec-failed.org
    # dig @127.0.0.1 -p 5335 dnssec-failed.org +cd
    # dig @127.0.0.1 -p 53 cloudflare.com +dnssec
    # dig @127.0.0.1 -p 53 dnssec-failed.org
    # dig @127.0.0.1 -p 53 dnssec-failed.org +cd
    sudo reboot now

# Immich
    mkdir ~/.config/containers/systemd/immich
    cd 
    touch ~/.config/containers/systemd/immich/{immich-network.network,immich-db.container,immich-redis.container,immich-ml.container,immich-server.container}
    mkdir ~/.volumes/immich/{photos,immich-ml-cache,immich-db-data,immich-redis-data}
    systemctl --user daemon-reload
    loginctl enable-linger masonp
    systemctl --user start immich-server.service
    systemctl --user enable --now podman-auto-update.timer
    # systemctl --user status immich-server.service
    # http://192.168.50.20:2283
    # Install Immich TV (Unofficial) by GJ Compagner from Play Store on TV
    # Get API Key from Immich website to sign into to TV app
    # Turn on developer options and wireless debugging on Google TV
    sudo apt install -y adb
    adb connect YOUR_TV_IP_ADDRESS
    adb shell settings put secure screensaver_components nl.giejay.android.tv.immich/.screensaver.ScreenSaverService
    adb shell settings put secure screensaver_enabled 1
    adb shell settings put system screen_off_timeout 60000
    adb shell settings get secure screensaver_components
    # adb shell dumpsys deviceidle whitelist +nl.giejay.android.tv.immich
    # adb shell cmd appops set nl.giejay.android.tv.immich RUN_IN_BACKGROUND allow

# Caddy
    touch ~/.config/containers/systemd/{caddy/caddy.container,caddy/Containerfile,caddy/caddy.build,lan.network}
    mkdir ~/.volumes/caddy/{site,data,config}
    touch ~/.volumes/caddy/Caddyfile
    sudo sysctl -w net.ipv4.ip_unprivileged_port_start=80
    sudoedit /etc/sysctl.d/99-podman.conf
        # Add: net.ipv4.ip_unprivileged_port_start=80
    systemctl --user daemon-reload
    systemctl 
    systemctl --user start caddy.service
    # podman exec -it caddy caddy reload --config /etc/caddy/Caddyfile

# Owntone
    sudo touch /etc/containers/systemd/owntone.container
    sudo mkdir -p /etc/owntone/{etc,media,cache}
    sudo chmod -R 777 /etc/owntone/cache
    sudo systemctl daemon-reload
    sudo systemctl start owntone.service
    # sudo systemctl status owntone.service
    # sudo journalctl -u owntone -f
    # http://192.168.50.20:3689/#/

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

# Backup
    scp -r raspi:/etc/blocky etc-blocky
    scp -r raspi:/etc/containers/systemd etc-containers-systemd
    rm -rf etc-containers-systemd/users
    scp -r raspi:~/.config/containers/systemd dotconfig-containers-systemd
    # scp -r raspi:~/.volumes volumes
    scp -r raspi:~/.volumes/caddy/Caddyfile Caddyfile
    # Remove Cloudflare API Token from caddy.container
    # Remove Immich DB Password from immich-db.container and immich.container