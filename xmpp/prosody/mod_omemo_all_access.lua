-- OMEMO all access module
-- Copyright (c) 2017 Daniel Gultsch
--
-- This module is MIT/X11 licensed
--

local jid_bare = require "util.jid".bare;
local st = require "util.stanza"
local white_listed_namespace = "eu.siacs.conversations.axolotl."
local disco_feature_namespace = white_listed_namespace .. "whitelisted"

local mm = require "core.modulemanager";


-- COMPAT w/trunk
local pep_module_name = "pep";
if mm.get_modules_for_host then
	if mm.get_modules_for_host(module.host):contains("pep_simple") then
		pep_module_name = "pep_simple";
	end
end

local mod_pep = module:depends(pep_module_name);
local pep_data = mod_pep.module.save().data;

if not pep_data then
	module:log("error", "This module is not compatible with your version of mod_pep");
	if mm.get_modules_for_host then
		module:log("error", "Please use mod_pep_simple instead of mod_pep to continue using this module");
	end
	return false;
end

local function on_account_disco_info(event)
	(event.reply or event.stanza):tag("feature", {var=disco_feature_namespace}):up();
end

local function on_pep_request(event)
	local session, stanza = event.origin, event.stanza
	local payload = stanza.tags[1];
	if stanza.attr.type == 'get' then
		local node, requested_id;
		payload = payload.tags[1]
		if payload and payload.name == 'items' then
			node = payload.attr.node
			local item = payload.tags[1];
			if item and item.name == 'item' then
				requested_id = item.attr.id;
			end
		end
		if node and string.sub(node,1,string.len(white_listed_namespace)) == white_listed_namespace then
			local user = stanza.attr.to and jid_bare(stanza.attr.to) or session.username..'@'..session.host;
			local user_data = pep_data[user];
			if user_data and user_data[node] then
				local id, item = unpack(user_data[node]);
				if not requested_id or id == requested_id then
					local reply_stanza = st.reply(stanza)
						:tag('pubsub', {xmlns='http://jabber.org/protocol/pubsub'})
							:tag('items', {node=node})
								:add_child(item)
							:up()
						:up();
					session.send(reply_stanza);
					module:log("debug","provided access to omemo node",node)
					return true;
				end
			end
			module:log("debug","requested node was white listed", node)
		end
	end
end

module:hook("iq/bare/http://jabber.org/protocol/pubsub:pubsub", on_pep_request, 10);
module:hook("account-disco-info", on_account_disco_info);
