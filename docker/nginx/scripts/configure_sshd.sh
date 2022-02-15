#!/bin/bash
set -eu

# Install openssh-server
apt-get update --allow-releaseinfo-change \
 && apt install --no-install-recommends -y \
    openssh-server \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Update sshd_config
echo -e "Port 22\n" >> /etc/ssh/sshd_config
echo -e "AllowUsers ec2-user\n" >> /etc/ssh/sshd_config
echo -e "AuthorizedKeysFile .ssh/authorized_keys .ssh/authorized_keys2 /etc/authorized_keys/%u\n" >> /etc/ssh/sshd_config
mkdir /etc/authorized_keys

# Setup user and authorized_keys
useradd -m -d /home/ec2-user -s /bin/bash ec2-user
echo "ec2-user:$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 64 | head -n 1)" | chpasswd
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCp1wkFbEfS2CuUwSMJy5zx3SenZF6WOL0o60ngHYJ0bHWEe7e7KCdwkyKkgF8A57in2faI+nKO0ScnAYcuwEy5BJNh6789TEdNtC4mpKr7A5x0MEkAdWyjjQu/upsaDASSEmJO8dFV/xu/IEUticxA960Rz2ncOPRHFubnbFkCOUg2vy8dfZybx1d9bZWEdDrcnPFjhhxeti+Cq/OdwtTlteffUKhi7qcDKHZEGi3zHzrvXiSwKJHgyMdUNf/PzIV+9Z0G0XwrnZ/q6WQNESNaEra7Iwvl921hzlxP8RKDCaxsryAHR67BCJjqhok7qtnujQYWMNc40z1ewC0o+oat" > /etc/authorized_keys/ec2-user

# Add ec2-user to wheel group
groupadd -g 999 wheel
sed -i -e 's/wheel:x:999:/wheel:x:999:root,ec2-user/g' /etc/group
sed -i -e 's/^# auth       required   pam_wheel.so/auth sufficient pam_wheel.so trust/g' /etc/pam.d/su
