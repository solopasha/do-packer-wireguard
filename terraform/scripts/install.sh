#!/usr/bin/env bash

user_name=solotest
C_PASS="1"
PASSWORD=$(/usr/bin/openssl passwd -crypt "$C_PASS")

useradd -m -G "wheel" -s /usr/bin/bash "$user_name"
usermod -p "${PASSWORD}" "$user_name"
cp -r /root/.ssh/ /home/$user_name/
chown -R $user_name:$user_name /home/$user_name/.ssh
chmod 700 /home/$user_name/.ssh
chmod 600 /home/$user_name/.ssh/authorized_keys

curl -O https://raw.githubusercontent.com/angristan/wireguard-install/master/wireguard-install.sh
chmod +x wireguard-install.sh

run_user() {
  sudo -u $user_name "$@"
}

## bitnami discourse
# run_user mkdir -p /home/$user_name/app/discourse
# run_user curl -L "https://raw.githubusercontent.com/bitnami/bitnami-docker-discourse/master/2/debian-10/docker-compose.yml" -o /home/$user_name/app/discourse/docker-compose.yml
# mv /tmp/docker-compose-discourse.yml /home/$user_name/app/discourse/docker-compose.yml
# chown -R $user_name:users /home/$user_name/app
#run_user echo "testing terra! ^_^" > /home/$user_name/client.token
## https://github.com/discourse/discourse/blob/master/docs/INSTALL-cloud.md
#git clone https://github.com/discourse/discourse_docker.git /var/discourse
