
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
	# Remove-Item C:\\Users\\perdu/.ssh/known_hosts*
    # ssh -A raspi
		sudo apt remove --purge -y vim-common vim-tiny
		sudo apt autoremove --purge -y
        sudo apt install -y git tree sane-utils nmap unattended-upgrades dnsutils imagemagick neovim
        sudo dpkg-reconfigure unattended-upgrades
            # yes
		vi ~/.ssh/id_ed25519-GitHub.pub
        chmod 600 ~/.ssh/id_ed25519-GitHub.pub
	    git config --global user.name masonperdue
        git config --global user.email 220426478+masonperdue@users.noreply.github.com
        git config --global core.editor nvim
        git config --global init.defaultBranch main
        git config --global commit.gpgSign true
        git config --global tag.gpgSign true
        git config --global gpg.format ssh
        git config --global user.signingkey ~/.ssh/id_ed25519-GitHub.pub
        echo "" >> ~/.bashrc
        echo ". /home/masonp/raspi-config/mybashrc" >> ~/.bashrc
		cd
        git clone git@github.com:masonperdue/raspi-config.git
        source ~/.bashrc
        gitClone neovim-config
		mkdir ~/.config/nvim/lua/
		ln -sf /home/masonp/neovim-config/nvim/init.lua /home/masonp/.config/nvim/init.lua
		ln -sf /home/masonp/neovim-config/nvim/lua/* /home/masonp/.config/nvim/lua/
        sudo usermod -aG scanner masonp

# Set raspi dns to cloudflare (so server can update w/o servers running)
    nmcli con show
    sudo nmcli con mod [UUID] ipv4.dns 1.1.1.3
    sudo nmcli con mod [UUID] ipv4.ignore-auto-dns yes
    sudo nmcli con up [UUID]
    sudo nmcli radio wifi off
    nmcli dev show
    dig startpage.com

# Blocky & Unbound
	sudo ss -tuln
	sudo apt install -y podman
	echo "net.ipv4.ip_unprivileged_port_start=53" | sudo tee /etc/sysctl.d/99-rootless-dns.conf
	sudo sysctl --system
	sudo loginctl enable-linger masonp
	mkdir ~/.config/{containers/systemd,blocky/cache,unbound/lib}
    ln -sf /home/masonp/raspi-config/blocky/* /home/masonp/.config/blocky/
    ln -sf /home/masonp/raspi-config/containers-systemd/* /home/masonp/.config/containers/systemd/
    ln -sf /home/masonp/raspi-config/containers-systemd/unbound/* /home/masonp/.config/containers/systemd/unbound/
	chmod 777 ~/.config/unbound/lib
	systemctl --user daemon-reload
	systemctl --user enable --now podman-auto-update.timer
	systemctl --user enable --now unbound.service blocky.service
    # Testing
        systemctl status unbound.service
        systemctl status blocky.service
        podman container list
        ss -tuln
        journalctl --user -exfu blocky.service
        dig @127.0.0.1 -p 5335 google.com +short
        dig @127.0.0.1 google.com +short
        dig @127.0.0.1 -p 5335 doubleclick.net +short
        dig @127.0.0.1 doubleclick.net +short
        dig @127.0.0.1 -p 5335 cloudflare.com +dnssec
        dig @127.0.0.1 cloudflare.com +dnssec
        dig @127.0.0.1 -p 5335 dnssec-failed.org
        dig @127.0.0.1 dnssec-failed.org
        dig @127.0.0.1 -p 5335 dnssec-failed.org +cd
        dig @127.0.0.1 dnssec-failed.org +cd
		dig @127.0.0.1 www.google.com
		dig @127.0.0.1 www.youtube.com
		dig @127.0.0.1 dns.google
		dig @127.0.0.1 use-application-dns.net
	sudoedit /etc/systemd/journald.conf
		# SystemMaxUse=200M
	sudo systemctl restart systemd-journald
	mkdir -p ~/.config/systemd/user
    vi ~/.config/systemd/user/podman-image-prune.service
		# [Unit]
		# Description=Prune unused podman images
		
		# [Service]
		# Type=oneshot
		# ExecStart=/usr/bin/podman image prune -f
	vi ~/.config/systemd/user/podman-image-prune.timer
		# [Unit]
		# Description=Weekly podman image prune
		
		# [Timer]
		# OnCalendar=weekly
		# Persistent=true
		
		# [Install]
		# WantedBy=timers.target
	systemctl --user daemon-reload
    systemctl --user enable --now podman-image-prune.timer
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
