VirtualHost "hostname"

admins = { "admin@hostname" }

https_certificate = "prosody_conf_dir/certs/hostname.crt"

disco_items = {
    { "conference.hostname", "Public Chatrooms" };
}

modules_enabled = {
    "onions"; -- Enable onion host
    "require_otr"; -- Require Off the Record Encryption to all connections
    --"omemo_all_access"; -- Disable access control for all OMEMO related PEP nodes
}

onions_tor_all = true; -- pass all s2s connections through Tor
--onions_only = true; -- forbid all connection attempts to non-onion servers

Component "upload.hostname" "http_upload"
    http_upload_file_size_limit = 1024*10000

Component "conference.hostname" "muc"
    name = "Prosody Chatrooms"
    restrict_room_creation = "true"
