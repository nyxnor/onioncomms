local st = require "util.stanza";
local cache = require "util.cache";
local add_filter = require "util.filters".add_filter;

local cache_size = module:get_option_number("presence_dedup_cache_size", 100);

-- stanza equality tests
local function attr_eq(a, b)
	if a == b then return true; end -- unlikely but not impossible
	for k,v in pairs(a) do if b[k] ~= v then return false; end end
	for k,v in pairs(b) do if a[k] ~= v then return false; end end
	return true;
end

local function st_eq(a, b)
	if a == b then return true; end
	if type(b) ~= "table" then return false; end
	if getmetatable(b) ~= st.stanza_mt then return false; end
	if a.name ~= b.name then return false; end
	if #a ~= #b then return false; end
	if not attr_eq(a.attr, b.attr) then return false; end
	for i = 1, #a do if not st_eq(a[i], b[i]) then return false; end end
	return true;
end

local function dedup_presence(stanza, session)
	if session.presence_cache and session.presence
	and getmetatable(stanza) == st.stanza_mt and stanza.name == "presence"
	and stanza.attr.xmlns == nil and stanza.attr.from then
		local cached = session.presence_cache:get(stanza.attr.from);
		if st_eq(stanza, cached) then
			return nil;
		else
			session.presence_cache:set(stanza.attr.from, st.clone(stanza));
		end
	end
	return stanza;
end

module:hook("presence/initial",	function (event)
	local session = event.origin;
	session.presence_cache = cache.new(cache_size);
	add_filter(session, "stanzas/out", dedup_presence, 90);
end);
