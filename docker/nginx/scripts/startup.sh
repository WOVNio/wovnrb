#!/bin/bash
set -e

# Add port for sshd
echo "Port 40022" >> /etc/ssh/sshd_config
service ssh restart

cp -a /var/tmp/nginx/wovnrb.conf /etc/nginx/conf.d/

nginx -g 'daemon off;'
