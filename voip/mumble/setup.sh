#!/usr/bin/env sh

[ "$(id -u)" -ne 0 ] && printf '%s\n' "Run as root" && exit 1

#########################
## Variables
requirements="tor mumble-server"
tor_conf="/etc/tor/torrc"
tor_data_dir="/var/lib/tor"
tor_data_dir_services="${tor_data_dir}/services"
tor_service_dir="${tor_data_dir_services}/voip_mumbleserver"
mumble_default_conf="/etc/default/mumble-server"
mumble_server_conf="/etc/mumble-server.ini"
#toplevel="$(git rev-parse --show-toplevel)"
#script_dir="${toplevel}/voip/mumble"

#########################
## Requirements
for pkg in ${requirements}; do
  command -v "${pkg}" >/dev/null || install_pkg="${install_pkg} ${pkg}"
done
# shellcheck disable=SC2086
[ -n "${install_pkg}" ] && apt update -y && apt install -y ${install_pkg}

#########################
## Onion service
if ! grep -q "HiddenServiceDir ${tor_service_dir}" "${tor_conf}"; then
  echo "Creating Hidden Service"
  echo "
HiddenServiceDir ${tor_service_dir}
HiddenServiceVersion 3
HiddenServicePort 64738 127.0.0.1:64738
" | tee -a "${tor_conf}"
  systemctl reload tor
fi
sleep 1
hostname=$(cat ${tor_service_dir}/hostname)

#########################
## Murmur
echo "Setting up Murmur (mumble-server)"

#dpkg-reconfigure mumble-server -> autorstart on boot, high priority for low latency, Murmur SuperUser password

/lib/systemd/systemd-sysv-install enable mumble-server

if grep -q "^MURMUR_USE_CAPABILITIES=" "${mumble_default_conf}"; then
  sed -i'' "s/^MURMUR_USE_CAPABILITIES=.*/MURMUR_USE_CAPABILITIES=1/g" "${mumble_default_conf}"
else
  printf "\nMURMUR_USE_CAPABILITIES=1\n" | tee -a "${mumble_default_conf}" >/dev/null
fi

printf "\nMurmur has a special account called 'SuperUser' which bypasses all privilege checks.
If you set a password here, the password for the 'SuperUser' account will be updated.
If you leave this blank, the password will not be changed.
Password to set on SuperUser account: "
printf "\033[8m"
read -r superuser_password
printf "\033[0m"
[ -n "${superuser_password}" ] && printf '%s\n' "${superuser_password}" | su mumble-server -s /bin/sh -c "/usr/sbin/murmurd -ini ${mumble_server_conf} -readsupw"

printf "\nPassword to join server.
If you leave this blank, the password will not be changed.
* Make sure to quote the value when using commas in strings or passwords.
    NOT variable = super,secret BUT variable = \"super,secret\"
* Make sure to escape special characters like '\' or '\"' correctly
    NOT variable = \"\"\" BUT variable = \"\\\"\"
Password to set on to join server: "
printf "\033[8m"
read -r server_password
printf "\033[0m"
if [ -n "${server_password}" ]; then
  if grep -q "^serverpassword=" "${mumble_server_conf}"; then
    sed -i'' "s/^serverpassword=.*/serverpassword=\"${server_password}\"/g" "${mumble_server_conf}"
  else
    printf %s"\serverpassword=\"${server_password}\"\n" | tee -a "${mumble_server_conf}"
  fi
fi

sudo systemctl restart mumble-server

printf %s"\nOn the mumble client, add a new server
Adress: ${hostname}
Port: 64738
Username: anything\n"