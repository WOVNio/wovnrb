mkdir /root/.ssh
touch /root/.ssh/authorized_keys
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCp1wkFbEfS2CuUwSMJy5zx3SenZF6WOL0o60ngHYJ0bHWEe7e7KCdwkyKkgF8A57in2faI+nKO0ScnAYcuwEy5BJNh6789TEdNtC4mpKr7A5x0MEkAdWyjjQu/upsaDASSEmJO8dFV/xu/IEUticxA960Rz2ncOPRHFubnbFkCOUg2vy8dfZybx1d9bZWEdDrcnPFjhhxeti+Cq/OdwtTlteffUKhi7qcDKHZEGi3zHzrvXiSwKJHgyMdUNf/PzIV+9Z0G0XwrnZ/q6WQNESNaEra7Iwvl921hzlxP8RKDCaxsryAHR67BCJjqhok7qtnujQYWMNc40z1ewC0o+oat" > /root/.ssh/authorized_keys
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK8M0XAzp2KYW6pA4dmoRmC5jpfGqotxMTUXuUVTyCBc" >> /root/.ssh/authorized_keys
echo "AuthorizedKeysFile .ssh/authorized_keys" >> /etc/ssh/sshd_config
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config
service ssh start
bin/rails server -b 0.0.0.0 -e development -p 4000