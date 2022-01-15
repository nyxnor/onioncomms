VirtualHost "hostname"

    admins = { "admin@hostname" }

    https_certificate = "prosody_conf_dir/certs/hostname.crt"

    disco_items = {
        { "conference.hostname", "Public Chatrooms" };
    }

    modules_enabled = {"onions", "require_otr"};
    onions_tor_all = true; -- pass all s2s connections through To
    --onions_only = true; -- forbid all connection attempts to non-onion servers

Component "upload.hostname" "http_upload"
    http_upload_file_size_limit = 1024*10000

Component "conference.hostname" "muc"
    name = "Prosody Chatrooms"
    restrict_room_creation = "true"
