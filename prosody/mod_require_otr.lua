local st = require "util.stanza";
local block_groupchat = module:get_option_boolean("otr_block_groupchat", false);

function reject_plaintext_messages(event)
    local body = event.stanza:get_child_text("body");
    if body and body:sub(1,4) ~= "?OTR" or (not block_groupchat and event.stanza.attr.type == "groupchat") then
        return event.origin.send(st.error_reply(event.stanza, "modify", "policy-violation", "OTR encryption is required for conversations on this server"));
    end
end

module:hook("pre-message/bare", reject_plaintext_messages, 300);
module:hook("pre-message/full", reject_plaintext_messages, 300);
module:hook("pre-message/host", reject_plaintext_messages, 300);
