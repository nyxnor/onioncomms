VirtualHost "TOR_HOSTNAME"

ssl = {
    key = "/etc/prosody/certs/TOR_HOSTNAME.key";
    certificate = "/etc/prosody/certs/TOR_HOSTNAME.crt";
}

modules_enabled = {
    "onions"; -- Enable onion host
    --"require_otr"; -- Require Off the Record Encryption to all connections
    "omemo_all_access"; -- Disable access control for all OMEMO related PEP nodes
}

--onions_only = true; -- forbid all connection attempts to non-onion servers
onions_tor_all = true; -- pass all s2s connections through Tor
