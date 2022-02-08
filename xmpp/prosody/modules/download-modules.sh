#!/usr/bin/env sh

## debian package prosody-modules does not include all community modules, so this is necessary to add extra modules

modules_default="presence_cache log_slow_events presence_dedup limit_auth block_registrations"
modules="${1:-${modules_default}}"
download_path="https://hg.prosody.im/prosody-modules/raw-file/tip"

curl_cmd="curl --proto =https --tlsv1.2 --location --remote-name"

for mod in ${modules}; do
	mod="$(printf '%s\n' "${mod}" | sed "s/^mod_//;s/\.lua.*//")"
	mod_path="${download_path}/mod_${mod}/mod_${mod}.lua"
	echo "Downloading mod_${mod}.lua ..."
	${curl_cmd} -q -# "${mod_path}"
	grep "error: mod_" "mod_${mod}.lua" && echo "Module mod_${mod}.lua does not exist, removing error file." && rm -f "mod_${mod}.lua"
	echo ""
done
