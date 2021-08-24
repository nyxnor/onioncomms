#!/bin/bash

## Video guide - https://www.youtube.com/watch?v=aI6csrdJa_0

## XMPP clients - https://riseup.net/de/chat/clients

## variables - directories should not include "/" in the end.
TORRC=/etc/tor/torrc
HS_DIR=/var/lib/tor/services
HS_SERVICE="prosody-xmpp"
TOR_USER="debian-tor"
TORRC_OWNER="${USER}"
PATH_WD=$(pwd)
USER_NAME="CHANGEME"
SERVER_USER_PASS="CHANGEME"

## prosody
if [ -f /etc/apt/sources.list.d/prosody.list ]; then
    echo "deb http://packages.prosody.im/debian $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/prosody.list
    wget https://prosody.im/files/prosody-debian-packages.key -O- | sudo apt-key add -
    sudo apt update -y
fi
MAIN_PKGS="tor prosody prosody-modules"
sudo apt install -y ${MAIN_PKGS}

## MODULES - dedicated to community and alpha modules not installed by default

## mod_omemo_all_access - https://hg.prosody.im/prosody-modules/file/default/mod_omemo_all_access/README.markdown
wget https://hg.prosody.im/prosody-modules/raw-file/default/mod_omemo_all_access/mod_omemo_all_access.lua
## mod_require_otr - https://hg.prosody.im/prosody-modules/file/default/mod_require_otr/README.markdown
#wget https://hg.prosody.im/prosody-modules/raw-file/default/mod_require_otr/mod_require_otr.lua
## mod_onions - https://hg.prosody.im/prosody-modules/file/default/mod_onions/README.markdown
#wget https://hg.prosody.im/prosody-modules/raw-file/default/mod_onions/mod_onions.lua

## main
sudo mv mod_*.lua /usr/lib/prosody/modules

## HIDDEN SERVICE
echo "# Creating Hidden Service"
sudo sed -i "/HiddenServiceDir .*${HS_SERVICE}/,/^\s*$/{d}" ${TORRC} ## delete old block to avoid duplication
echo "
HiddenServiceDir ${HS_DIR}/${HS_SERVICE}
HiddenServicePort 5222 unix:/var/run/hs-${HS_SERVICE}-5222.sock
HiddenServicePort 5269 unix:/var/run/hs-${HS_SERVICE}-5269.sock
" | sudo tee -a ${TORRC}
awk 'NF > 0 {blank=0} NF == 0 {blank++} blank < 2' ${TORRC} | sudo tee ${TORRC}.tmp >/dev/null && sudo mv ${TORRC}.tmp ${TORRC}
sudo chown -R ${USER}:${TOR_USER} ${TORRC}
sudo chown -R ${TOR_USER}:${TOR_USER} ${HS_DIR}
sudo chmod 640 ${TORRC}
sudo chmod 700 ${HS_DIR}
#sudo /etc/init.d/tor reload
sudo systemctl reload-or-restart tor
sleep 3
TOR_HOSTNAME=$(sudo -u ${TOR_USER} cat ${HS_DIR}/${HS_SERVICE}/hostname)

## PROSODY.CFG.LUA
sudo cp /etc/prosody/prosody.cfg.lua{,.dist}
sudo cp sample-prosody.cfg.lua prosody.cfg.lua
sudo sed -i 's/TOR_HOSTNAME/'${TOR_HOSTNAME}'/g' prosody.cfg.lua >/dev/null
sudo mv prosody.cfg.lua /etc/prosody/prosody.cfg.lua

## CONF.AVAIL/VIRTUALHOST.CFG.LUA
cp sample-virtualhost.cfg.lua ${TOR_HOSTNAME}.cfg.lua
sudo sed -i 's/TOR_HOSTNAME/'${TOR_HOSTNAME}'/g' ${TOR_HOSTNAME}.cfg.lua >/dev/null
sudo mv ${TOR_HOSTNAME}.cfg.lua /etc/prosody/conf.avail/${TOR_HOSTNAME}.cfg.lua
sudo ln -s /etc/prosody/conf.avail/${TOR_HOSTNAME}.cfg.lua /etc/prosody/conf.d/${TOR_HOSTNAME}.cfg.lua
sudo rm -f /etc/prosody/certs/localhost.*
sudo rm -f /etc/prosody/conf.avail/localhost.*
sudo rm -f /etc/prosody/conf.d/localhost.*
sudo chown -R root:prosody /etc/prosody/
sudo systemctl restart prosody

## CERTIFICATE
cp sample-virtualhost.cnf ${TOR_HOSTNAME}.cnf
sudo sed -i 's/TOR_HOSTNAME/'${TOR_HOSTNAME}'/g' ${TOR_HOSTNAME}.cnf >/dev/null
openssl req -new -x509 -days 1825 -nodes -out ${TOR_HOSTNAME}.crt -newkey rsa:4096 -keyout ${TOR_HOSTNAME}.key -config ${TOR_HOSTNAME}.cnf
sudo mv ${TOR_HOSTNAME}.cnf /var/lib/prosody/${TOR_HOSTNAME}.cnf
sudo mv ${TOR_HOSTNAME}.crt /var/lib/prosody/${TOR_HOSTNAME}.crt
sudo mv ${TOR_HOSTNAME}.key /var/lib/prosody/${TOR_HOSTNAME}.key
sudo chmod 640 /var/lib/prosody/${TOR_HOSTNAME}.cnf
sudo chmod 640 /var/lib/prosody/${TOR_HOSTNAME}.crt
sudo chmod 640 /var/lib/prosody/${TOR_HOSTNAME}.key
sudo chmod 700 -R /var/lib/prosody/
sudo chown -R prosody:prosody /var/lib/prosody/
#sudo -u prosody prosodyctl cert generate ${TOR_HOSTNAME} ## this does not allow sourcing from .conf like openssl does
sudo ln -s /var/lib/prosody/${TOR_HOSTNAME}.crt /etc/prosody/certs/${TOR_HOSTNAME}.crt
sudo ln -s /var/lib/prosody/${TOR_HOSTNAME}.key /etc/prosody/certs/${TOR_HOSTNAME}.key
sudo chmod 640 /etc/prosody/certs/${TOR_HOSTNAME}.crt
sudo chmod 640 /etc/prosody/certs/${TOR_HOSTNAME}.key
sudo chown -R root:prosody /etc/prosody/
sudo systemctl restart prosody

## USER
#sudo prosodyctl adduser ${USER_NAME}@${TOR_HOSTNAME}
sudo -u prosody prosodyctl register ${USER_NAME} ${TOR_HOSTNAME} ${SERVER_USER_PASS}
echo "Account created: ${USER_NAME}@${TOR_HOSTNAME}"
sudo systemctl reload-or-restart prosody
echo "# Done!"
