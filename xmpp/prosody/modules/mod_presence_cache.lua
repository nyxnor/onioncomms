-- XEP-0280: Message Carbons implementation for Prosody
-- Copyright (C) 2015-2016 Kim Alvefur
--
-- This file is MIT/X11 licensed.

local is_contact_subscribed = require"core.rostermanager".is_contact_subscribed;
local jid_split = require"util.jid".split;
local jid_bare = require"util.jid".bare;
local jid_host = require"util.jid".host;
local st = require"util.stanza";
local datetime = require"util.datetime";
local cache = require "util.cache";

local cache_size = module:get_option_number("presence_cache_size", 100);

local bare_cache = {}; -- [username NUL bare_jid] = { [full_jid] = { timestamp, ... } }

local function on_evict(cache_key)
	local bare_cache_key = cache_key:match("^%Z+%z[^/]+");
	local full_jid = cache_key:match("%z(.*)$");
	local jids = bare_cache[bare_cache_key];

	if jids then
		jids[full_jid] = nil;
		if next(jids) == nil then
			bare_cache[bare_cache_key] = nil;
		end
	end
end

-- used indirectly for the on_evict callback
local presence_cache = cache.new(cache_size, on_evict);

local function cache_hook(event)
	local origin, stanza = event.origin, event.stanza;
	local typ = stanza.attr.type;
	module:log("debug", "Cache hook, got %s from a %s", stanza:top_tag(), origin.type);
	if origin.type == "s2sin" and ( typ == nil or typ == "unavailable" ) then

		local contact_full = stanza.attr.from;
		local contact_bare = jid_bare(contact_full);
		local username, host = jid_split(stanza.attr.to);

		if not is_contact_subscribed(username, host, contact_bare) then
			module:log("debug", "Presence from jid not in roster");
			return;
		end

		local cache_key = username .. "\0" .. contact_full;
		local bare_cache_key = username .. "\0" .. contact_bare;

		local jids = bare_cache[bare_cache_key];

		if typ == "unavailable" then -- remove from cache
			presence_cache:set(cache_key, nil);
			on_evict(cache_key);
			return;
		end

		local presence_bits = {
			stamp = datetime.datetime();
			show = stanza:get_child_text("show");
		};
		if jids then
			jids[contact_full] = presence_bits;
		else
			jids = { [contact_full] = presence_bits };
			bare_cache[bare_cache_key] = jids;
		end
		presence_cache:set(cache_key, true);
	end
end

module:hook("presence/bare", cache_hook, 10);
-- module:hook("presence/full", cache_hook, 10);

local function answer_probe_from_cache(event)
	local origin, stanza = event.origin, event.stanza;
	if stanza.attr.type ~= "probe" then return; end

	local username = origin.username;
	local contact_bare = stanza.attr.to;
	if not contact_bare then return; end -- probe to self

	local bare_cache_key = username .. "\0" .. contact_bare;

	local cached = bare_cache[bare_cache_key];
	if not cached then return end
	local user_bare = jid_bare(origin.full_jid);
	for jid, presence_bits in pairs(cached) do
		local presence = st.presence({ to = origin.full_jid, from = jid })
		if presence_bits.show then
			presence:tag("show"):text(presence_bits.show):up();
		end
		if presence_bits.stamp then
			presence:tag("delay", { xmlns = "urn:xmpp:delay", from = user_bare, stamp = presence_bits.stamp }):up();
		end
		origin.send(presence);
	end
end

module:hook("pre-presence/bare", answer_probe_from_cache, 10);

local function clear_cache_from_s2s(remote, reason)
	if not remote then return end
	-- FIXME Ignore if connection closed for being idle

	module:log("debug", "Dropping cached presence from host %s", remote);

	for bare, cached in pairs(bare_cache) do
		if jid_host(bare) == remote then
			for jid in pairs(cached) do
				presence_cache:set(jid, nil);
			end
			bare_cache[bare] = nil;
		end
	end
end

module:hook("s2sin-destroyed", function (event)
	return clear_cache_from_s2s(event.session.from_host, event.reason);
end);

module:hook("s2sout-destroyed", function (event)
	return clear_cache_from_s2s(event.session.to_host, event.reason);
end);
