local st = require "util.stanza";
local nodeprep = require "util.encodings".stringprep.nodeprep;

local block_users = module:get_option_set("block_registrations_users", { "admin" });
local block_patterns = module:get_option_set("block_registrations_matching", {});
local require_pattern = module:get_option_string("block_registrations_require");

function is_blocked(username)
        -- Check if the username is simply blocked
        if block_users:contains(username) then return true; end

        for pattern in block_patterns do
                if username:find(pattern) then
                        return true;
                end
        end
        -- Not blocked, but check that username matches allowed pattern
        if require_pattern and not username:match(require_pattern) then
                return true;
        end
end

module:hook("user-registering", function(event)
        local username = event.username;
        if is_blocked(username) then
                event.allowed = false;
                return true;
        end
end, 10);
