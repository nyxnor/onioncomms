-- mod_limit_auth

local st = require"util.stanza";
local new_throttle = require "util.throttle".create;

local period = math.max(module:get_option_number(module.name.."_period", 30), 0);
local max = math.max(module:get_option_number(module.name.."_max", 5), 1);

local tarpit_delay = module:get_option_number(module.name.."_tarpit_delay", nil);
if tarpit_delay then
	local waiter = require "util.async".waiter;
	local delay = tarpit_delay;
	function tarpit_delay()
		local wait, done = waiter();
		module:add_timer(delay, done);
		wait();
	end
else
	function tarpit_delay() end
end

local throttles = module:shared"throttles";

local reply = st.stanza("failure", { xmlns = "urn:ietf:params:xml:ns:xmpp-sasl" }):tag("temporary-auth-failure");

local function get_throttle(ip)
	local throttle = throttles[ip];
	if not throttle then
		throttle = new_throttle(max, period);
		throttles[ip] = throttle;
	end
	return throttle;
end

module:hook("stanza/urn:ietf:params:xml:ns:xmpp-sasl:auth", function (event)
	local origin = event.origin;
	if origin.type ~= "c2s_unauthed" then return end
	if not get_throttle(origin.ip):peek(1) then
		origin.log("warn", "Too many authentication attepmts for ip %s", origin.ip);
		tarpit_delay();
		origin.send(reply);
		return true;
	end
end, 10);

module:hook("authentication-failure", function (event)
	get_throttle(event.session.ip):poll(1);
end);

module:add_timer(14400, function (now)
	local old = now - 86400;
	for ip, throttle in pairs(throttles) do
		if throttle.t < old then
			throttles[ip] = nil;
		end
	end
end);

