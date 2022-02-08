--https_certificate = "prosody_conf_dir/certs/hostname.crt"

ssl = {
    certificate = "/etc/prosody/certs/hostname.crt";
    key = "/etc/prosody/certs/hostname.key";
}

https_ssl = {
   certificate = "/etc/prosody/certs/hostname.crt";
    key = "/etc/prosody/certs/hostname.key";
}


-- mod_prometheus --
statistics = "internal"
statistics_interval = manual

-- mod_http --

http_default_host = "http.hostname"
--http_external_url = "https://http.hostname/"
--trusted_proxies = { "127.0.0.1" }

http_ports = { 5280 }
http_interfaces = { "*", "::" }

https_ports = { 5281 }
https_interfaces = { "*", "::" }

-- mod_limits --
limits = {
    c2s = { rate = "100kb/s"; burst = "30s" };
    s2sin = { rate = "100kb/s"; burst = "30s" };
    s2sout = { rate = "100kb/s"; burst = "30s" };
}



VirtualHost "hostname"

http_host = "http.hostname"
http_external_url = "http://http.hostname"
trusted_proxies = { "127.0.0.1" };

--admins = { "admin@hostname" }

onions_tor_all = true; -- pass all s2s connections through Tor
onions_only = false; -- allow all connection attempts to non-onion servers

allow_registration = false -- Disable account creation for security. For more information see https://prosody.im/doc/creating_accounts

c2s_require_encryption = true -- Force clients to use encrypted connections? This option will prevent clients from authenticating unless they are using encryption.
s2s_require_encryption = true -- Force servers to use encrypted connections? This option will prevent servers from authenticating unless they are using encryption.
s2s_secure_auth = false -- Force certificate authentication for server-to-server connections?



storage = {
	-- mod_mam --
	archive = "internal";
	archive2 = "internal";
}

reload_modules = {
    "tls";
    "onions";
    "http";
    "http_upload";
}

modules_enabled = {
    -- General
    "c2s"; -- Handle client connections
    "s2s"; -- Handle server-to-server  connections
    "bosh"; -- Enable BOSH clients, aka "Jabber over HTTP"
    "http_files"; -- Serve static files from a directory over HTTP
    "groups"; -- Shared roster support
    "carbons"; -- Keep multiple clients in sync
    "roster"; -- Allow users to have a roster. Recommended ;)
    "saslauth"; -- Authentication for clients and servers. Recommended if you want to log in.
    "tls"; -- Add support for secure TLS on c2s/s2s connections
    "dialback"; -- s2s dialback support
    "disco"; -- Service discovery
    "pep"; -- Enables users to publish their avatar, mood, activity, playing music and more
    "posix"; -- POSIX functionality, sends server to background, enables syslog, etc.
    "reload_modules"; -- Will reload a set list of modules every time Prosody reloads its config (e.g. on SIGHUP).

    -- Security
    "onions"; -- Enable onion host
    --"require_otr"; -- Require Off the Record Encryption to all connections
    --"omemo_all_access"; -- Disable access control for all OMEMO related PEP nodes

    "block_registrations"; -- Prevent registration of certain “reserved” accounts, such as “admin”.
	"filter_chatstates";
	"limits";
	"limit_auth";
	"firewall";

	-- Optimzation --
	--"smacks";
	"csi";
	"csi_battery_saver";
	"log_slow_events";
	"mam";
	"presence_cache";
	"presence_dedup";
	"throttle_presence";
}

-- in case this modules were enabled server-wide on the main prosody.cfg.lua
-- disable them on this virtual hfor security and privacy reasons
modules_disabled = {
    -- Privacy
    "version"; -- Replies to server version requests
    "uptime"; -- Report how long server has been running
    "time"; -- Let others know the time here on this server
    "ping"; -- Replies to XMPP pings with pongs
    "server_contact_info"; -- Publish contact information for this service

    -- Security
    "register"; -- Allow users to register on this server using a client and change passwords
    "legacyauth"; -- Legacy authentication. Only used by some old clients and bots.
}


-- Imported from https://github.com/qbi/xmpp-onion-map/blob/master/v3-onions-map.lua --
onions_map = {
    ["5222.de"] = "fzdx522fvinbaqgwxdet45wryluchpplrkkzkry33um5tufkjd3wdaqd.onion";
	["anrc.mooo.com"] = "6w5iasklrbr2kw53zqrsjktgjapvjebxodoki3gjnmvb4dvcbmz7n3qd.onion";
    ["cock.li"] = { host = "xdkriz6cn2avvcr2vks5lvvtmfojz2ohjzj4fhyuka55mvljeso2ztqd.onion", port = "5222" };
    ["creep.im"] = "creep7nonbdm4nad2qbmri7z32ajg2l4vcwvzpxnty6wupvc5vfreoad.onion";
	["dismail.de"] = "4colmnerbjz3xtsjmqogehtpbt5upjzef57huilibbq3wfgpsylub7yd.onion";
    ["e2e.ee"] = { host = "e2eee76htm7znipwviwbjzdy7spoeje2gzcn23jyl77pplvhfa7lfyqd.onion", port = "5222" };
	["jabber.cat"] = "x76it4hax7s6s6j64ta6iiolar6o6hwlwoeyoqmkjcdgjza6gqqj5gyd.onion";
	["jabber.de"] = "uoj2xiqxk25p36wbpufiyuhluvxakhpqum7frembhoiuq7a5735ay3qd.onion";
    ["jabber.hot-chilli.net"] = "chillingguw3yu2rmrkqsog4554egiry6fmy264l5wblyadds3c2lnyd.onion";
	["jabber.otr.im"] = "ynnuxkbbiy5gicdydekpihmpbqd4frruax2mqhpc35xqjxp5ayvrjuqd.onion";
	["jabber.so36.net"] = "yxkc2uu3rlwzzhxf2thtnzd7obsdd76vtv7n34zwald76g5ogbvjbbqd.onion";
	["jabber.systemli.org"] = "razpihro3mgydaiykvxwa44l57opvktqeqfrsg3vvwtmvr2srbkcihyd.onion";
    ["jabber.systemausfall.org"] = "jaswtrycaot3jzkr7znje4ebazzvbxtzkyyox67frgvgemwfbzzi6uqd.onion";
    ["jabjab.de"] = "jabjabdea2eewo3gzfurscj2sjqgddptwumlxi3wur57rzf5itje2rid";
    ["systemausfall.org"] = "jaswtrycaot3jzkr7znje4ebazzvbxtzkyyox67frgvgemwfbzzi6uqd.onion";
	["krautspace.de"] = "jeirlvruhz22jqduzixi6li4xyoweytqglwjons4mbuif76fgslg5uad.onion";
	["jabber.nr18.space"] = "szd7r26dbcrrrn4jthercrdypxfdmzzrysusyjohn4mpv2zbwcgmeqqd.onion";
	["talk36.net"] = "yxkc2uu3rlwzzhxf2thtnzd7obsdd76vtv7n34zwald76g5ogbvjbbqd.onion";
	["wiuwiu.de"] = "qawb5xl3mxiixobjsw2d45dffngyyacp4yd3wjpmhdrazwvt4ytxvayd.onion";
	["xmpp.is"] = "6voaf7iamjpufgwoulypzwwecsm2nu7j5jpgadav2rfqixmpl4d65kid.onion";
	["xmpp.riseup.net"] = "jukrlvyhgguiedqswc5lehrag2fjunfktouuhi4wozxhb6heyzvshuyd.onion";
    ["xmpp.trashserver.net"] = "xiynxwxxpw7olq76uhrbvx2ts3i7jagqnqix7arfbknmleuoiwsmt5yd.onion";
}


-- Modules --


-- mod_bosh --
consider_bosh_secure = true

-- mod_log_slow_events --
log_slow_events_threshold = 1

-- mod_limit_auth --
limit_auth_period = 30
limit_auth_max = 5

-- mod_mam --
default_archive_policy = false
archive_expires_after = "1w"
archive_cleanup_interval = 4*60*60
max_archive_query_results = 50
archive_store = archive2
mam_smart_enable = true

-- mod_smacks --
smacks_hibernation_time = 60
smacks_enabled_s2s = false
smacks_s2s_resend = false
smacks_max_unacked_stanzas = 0
smacks_max_ack_delay = 30
smacks_max_hibernated_sessions = 10
smacks_max_old_sessions = 10

-- mod_pep --
pep_max_items = 32
pep_service_cache_size = 10000
pep_info_cache_size = 10000

-- mod_block_registrations --
block_registrations_users = { "administrator", "admin", "adm", "hostmaster", "postmaster", "server", "host", "webmaster", "root", "xmpp" }
block_registrations_require = "^[a-zA-Z0-9_.-]+$" -- Allow only simple ASCII characters in usernames

-- mod_turncredentials --
turncredentials_host = "turn.hostname"
-- turncredentials_secret inserted with prosody-secrets.sh script --


-- TODO FIX THIS  https://github.com/unredacted/xmpp.is/blob/master/etc/prosody/prosody.cfg.lua
-- mod_firewall --
firewall_scripts = {
    "module:scripts/spam-blocking.pfw"; -- Base anti-spam ruleset
}

-- mod_disco --
disco_items = {
    { "conference.hostname", "Public Chatrooms" };
}


-- Components --

Component "http.hostname" "http_upload"
    http_upload_file_size_limit = 10000000
    http_upload_expire_after = 60 * 60 * 24 * 7
    http_upload_quota = 1000000000

Component "conference.hostname" "muc"
    name = "Prosody Chatrooms"
    restrict_room_creation = "local" -- only users from this domain/host can create rooms
    modules_enabled = {
        "muc_mam";
    }
