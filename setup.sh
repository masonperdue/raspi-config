
# Setup Script for Linux Config
# sudo apt install -y git && mkdir ~/.myconfig && cd ~/.myconfig && git clone https://github.com/masonperdue/linuxconfig.git && cd linux-config && chmod +x setup.sh && ./setup.sh

echo "" >> /home/masonp/.bashrc
echo ". /home/masonp/.bashrc.d/*" >> /home/masonp/.bashrc
mkdir /home/masonp/.bashrc.d
ln -sf /home/masonp/.myconfig/raspi-config/mybashrc /home/masonp/.bashrc.d/
