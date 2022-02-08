#!/usr/bin/env sh

[ "$(id -u)" -ne 0 ] && printf '%s\n' "Run as root" && exit 1

#########################
## Notes
##  TLS/SSL is used because some clients or server might refuse to transfer
##  files if the transport is not authenticated, even if it is over Tor
##  this is why https is being used

#########################
## Variables
requirements="tor prosody prosody-modules prosody-migrator lua-zlib openssl"
tor_conf="/etc/tor/torrc"
tor_data_dir="/var/lib/tor"
tor_data_dir_services="${tor_data_dir}/services"
tor_service_dir="${tor_data_dir_services}/xmpp_prosody"
#prosody_lib_dir="/usr/lib/prosody"
prosody_var_dir="/var/lib/prosody"
prosody_conf_dir="/etc/prosody"
toplevel="$(git rev-parse --show-toplevel)"
script_dir="${toplevel}/xmpp/prosody"

#########################
## Requirements
for pkg in ${requirements}; do
  ## if tor was built from source and not via deb package, as well as other pkgs, find it in path
  case "${pkg}" in
    tor|prosody|openssl) command  -v "${pkg}" >/dev/null || install_pkg="${install_pkg} ${pkg}";;
    prosody-modules|prosody-migrator|lua-zlib|*) dpkg -s "${pkg}" >/dev/null 2>&1 || install_pkg="${install_pkg} ${pkg}";;
  esac
done
# shellcheck disable=SC2086
[ -n "${install_pkg}" ] && apt update -y && apt install -y ${install_pkg}

#########################
## Onion service
if ! grep -q "HiddenServiceDir ${tor_service_dir}" "${tor_conf}"; then
  echo "Creating Hidden Service"

  ## 5222 - c2s
  ## 5269 - s2s
  ## 5280 - http_upload
  ## 5281 - https_upload
  echo "
HiddenServiceDir ${tor_service_dir}
HiddenServiceVersion 3
HiddenServicePort 5222 127.0.0.1:5222
HiddenServicePort 5269 127.0.0.1:5269
HiddenServicePort 5280 127.0.0.1:5280
HiddenServicePort 5281 127.0.0.1:5281
" | tee -a "${tor_conf}"
  systemctl reload tor
fi
sleep 1
hostname=$(cat ${tor_service_dir}/hostname)


#########################
## Prosody
echo "Setting up prosody"

## https://hg.prosody.im/prosody-modules/file/tip/mod_omemo_all_access/README.markdown
##  0.11  Not needed, mod\_pep provides this feature already
# cp "${script_dir}"/mod_*.lua "${prosody_lib_dir}/modules/"
# chmod 644 "${prosody_lib_dir}/modules/mod_omemo_all_access.lua"
# chown -R root:root "${prosody_lib_dir}"

## necessary to include virtual hosts configuration files
if ! grep -q -F "Include \"conf.d/*.cfg.lua\"" "${prosody_conf_dir}/prosody.cfg.lua"; then
  printf '\n%s\n\n' "Include \"conf.d/*.cfg.lua\"" | tee -a "${prosody_conf_dir}/prosody.cfg.lua" >/dev/null
fi
chmod 640 "${prosody_conf_dir}/prosody.cfg.lua"
test -d "${prosody_conf_dir}/conf.d" || mkdir "${prosody_conf_dir}/conf.d"
chmod 750 "${prosody_conf_dir}/conf.d"

cp "${script_dir}"/virtualhost.cfg.lua "${hostname}.cfg.lua"
sed -i'' "s|hostname|${hostname}|g" "${hostname}.cfg.lua"
sed -i'' "s|prosody_conf_dir|${prosody_conf_dir}|g" "${hostname}.cfg.lua"

mv "${hostname}.cfg.lua" "${prosody_conf_dir}/conf.d/"
chmod 640 "${prosody_conf_dir}/conf.d/${hostname}.cfg.lua"


chown -R root:prosody "${prosody_conf_dir}"

#########################
## Certificate
if [ ! -f "${prosody_conf_dir}/${hostname}.crt" ]; then
  echo "Configuring the SSL certificate"
  #prosodyctl cert generate "${hostname}"
  cp "${script_dir}"/openssl.cnf "${prosody_conf_dir}/${hostname}.cnf"
  sed -i'' "s/example.com/${hostname}/g" "${script_dir}/${hostname}.cnf"
  openssl req -new -x509 -days 1825 -nodes -out "${prosody_conf_dir}/${hostname}.crt" -newkey rsa:4096 -keyout "${prosody_conf_dir}/${hostname}.key" -config  "${prosody_conf_dir}/${hostname}.cnf"

  chmod 640 "${prosody_conf_dir}/certs/${hostname}.cnf"
  chmod 640 "${prosody_conf_dir}/certs/${hostname}.crt"
  chmod 640 "${prosody_conf_dir}/certs/${hostname}.key"

  chown -R prosody:prosody "${prosody_var_dir}"
  chown -R root:prosody "${prosody_conf_dir}"

  systemctl reload prosody
else
  echo "Certificate for this server already exists"
fi


#########################
## Administrator
printf '%s\n' "Register the password for admin@${hostname}:"
prosodyctl register admin "${hostname}"

printf %s"
Log in with your XMPP client:
user: admin
hostname: ${hostname}
port: 5222

Verify the certificate information:
"
openssl x509 -in "${prosody_conf_dir}/certs/${hostname}.crt" -noout -sha256 -fingerprint
openssl x509 -in "${prosody_conf_dir}/certs/${hostname}.crt" -noout -sha256 -dates


#######################
## Syntax check
printf '\n'
prosodyctl check config
