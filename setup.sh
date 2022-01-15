#!/usr/bin/env sh

[ "$(id -u)" -ne 0 ] && printf '%s\n' "Run as root" && exit 1

tor_conf="/etc/tor/torrc"
tor_data_dir="/var/lib/tor"
tor_data_dir_services="${tor_data_dir}/services"
prosody_lib_dir="/usr/lib/prosody"
prosody_var_dir="/var/lib/prosody"
prosody_conf_dir="/etc/prosody"

#########################
## Onion service
if ! grep -q "HiddenServiceDir ${tor_data_dir_services}/xmpp" "${tor_conf}"; then
  echo "Creating Hidden Service"
  echo "
HiddenServiceDir ${tor_data_dir_services}/xmpp
HiddenServicePort 5222 127.0.0.1:5222
HiddenServicePort 5269 127.0.0.1:5269
HiddenServicePort 5280 127.0.0.1:5280
HiddenServicePort 5281 127.0.0.1:5281
" | tee -a "${tor_conf}"
  systemctl reload tor
fi
sleep 1
hostname=$(cat ${tor_data_dir_services}/xmpp/hostname)


#########################
## Prosody
echo "Setting up prosody"

cp prosody/mod_*.lua "${prosody_lib_dir}/modules/"
chmod 644 "${prosody_lib_dir}/modules/mod_onions.lua"
chmod 644 "${prosody_lib_dir}/modules/mod_http_upload.lua"
chmod 644 "${prosody_lib_dir}/modules/mod_require_otr.lua"
chown -R root:prosody "${prosody_lib_dir}"

cp prosody/virtualhost.cfg.lua "${hostname}.cfg.lua"
sed -i'' "s|hostname|${hostname}|g" "${hostname}.cfg.lua"
sed -i'' "s|prosody_conf_dir|${prosody_conf_dir}|g" "${hostname}.cfg.lua"

mv "${hostname}.cfg.lua" "${prosody_conf_dir}/conf.avail/${hostname}.cfg.lua"

ln -sf "${prosody_conf_dir}/conf.avail/${hostname}.cfg.lua" "${prosody_conf_dir}/conf.d/${hostname}.cfg.lua"

cp prosody/prosody.cfg.lua "${prosody_conf_dir}/prosody.cfg.lua"
chmod 644 "${prosody_conf_dir}/prosody.cfg.lua"

chown -R root:prosody "${prosody_conf_dir}"
systemctl restart prosody

#########################
## Certificate
echo "Configuring the SSL certificate"
#prosodyctl cert generate "${hostname}"
cp prosody/openssl.cnf "prosody/${hostname}.openssl.cnf"
sed -i'' "s/example.com/${hostname}/g" "prosody/${hostname}.openssl.cnf"
openssl req -new -x509 -days 1825 -nodes -out "${prosody_conf_dir}/certs/${hostname}.crt" -newkey rsa:4096 -keyout "${prosody_conf_dir}/certs/${hostname}.key" -config  "prosody/${hostname}.openssl.cnf"
rm -f "prosody/${hostname}.openssl.cnf"

ln -sf "${prosody_var_dir}/${hostname}.crt" "${prosody_conf_dir}/certs/${hostname}.crt"
ln -sf "${prosody_var_dir}/${hostname}.key" "${prosody_conf_dir}/certs/${hostname}.key"

chown -R prosody:prosody "${prosody_var_dir}"
chown -R root:prosody "${prosody_conf_dir}"

systemctl restart prosody

prosodyctl register admin "${hostname}" changeme

printf %s"\nProsody is configured
Change your password with:
$ sudo -u prosody prosodyctl passwd admin@${hostname}

Log in with your XMPP client:
user: admin
password: changeme
hostname: ${hostname}
port: 5222

Verify the certificate information:
"
openssl x509 -in "${prosody_conf_dir}/certs/${hostname}.crt" -noout -sha256 -fingerprint
openssl x509 -in "${prosody_conf_dir}/certs/${hostname}.crt" -noout -sha256 -dates