https_certificate = "prosody_conf_dir/certs/hostname.crt"

VirtualHost "hostname"

admins = { "admin@hostname" }
disco_items = {
    { "conference.hostname", "Public Chatrooms" };
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
    -- "pep_simple"; -- Fallback compatibility for omemo_all_access

    -- Security
    "onions"; -- Enable onion host
    --"require_otr"; -- Require Off the Record Encryption to all connections
    --"omemo_all_access"; -- Disable access control for all OMEMO related PEP nodes
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
}

onions_tor_all = true; -- pass all s2s connections through Tor
--onions_only = true; -- forbid all connection attempts to non-onion servers

Component "upload.hostname" "http_upload"
    http_upload_file_size_limit = 1024*10000

Component "conference.hostname" "muc"
    name = "Prosody Chatrooms"
    restrict_room_creation = "local" -- only users from this domain/host can create rooms
    modules_enabled = {
        "muc_mam";
    }

-- Disable account creation by default, for security
-- For more information see https://prosody.im/doc/creating_accounts
allow_registration = false

-- Force clients to use encrypted connections? This option will
-- prevent clients from authenticating unless they are using encryption.

c2s_require_encryption = true

-- Force servers to use encrypted connections? This option will
-- prevent servers from authenticating unless they are using encryption.

s2s_require_encryption = true

-- Force certificate authentication for server-to-server connections?

s2s_secure_auth = false

-- Some servers have invalid or self-signed certificates. You can list
-- remote domains here that will not be required to authenticate using
-- certificates. They will be authenticated using DNS instead, even
-- when s2s_secure_auth is enabled.

--s2s_insecure_domains = { "insecure.example" }

-- Even if you disable s2s_secure_auth, you can still require valid
-- certificates for some domains by specifying a list here.

--s2s_secure_domains = { "jabber.org" }
