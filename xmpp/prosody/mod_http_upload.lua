-- mod_http_upload
--
-- Copyright (C) 2015-2018 Kim Alvefur
--
-- This file is MIT/X11 licensed.
--
-- Implementation of HTTP Upload file transfer mechanism used by Conversations
--

-- depends
module:depends("http");
module:depends("disco");

if module:http_url():match("^http://") then
	error("File upload MUST happen with TLS but it isn’t enabled, see https://prosody.im/doc/http for how to fix this issue");
end

-- imports
local st = require"util.stanza";
local lfs = require"lfs";
local url = require "socket.url";
local dataform = require "util.dataforms".new;
local datamanager = require "util.datamanager";
local array = require "util.array";
local t_concat = table.concat;
local t_insert = table.insert;
local s_upper = string.upper;
local httpserver = require "net.http.server";
local have_id, id = pcall(require, "util.id"); -- Only available in 0.10+
local uuid = require"util.uuid".generate;
local jid = require "util.jid";
if have_id then
	uuid = id.medium;
end

local function join_path(...) -- COMPAT util.path was added in 0.10
	return table.concat({ ... }, package.config:sub(1,1));
end

-- config
local file_size_limit = module:get_option_number(module.name .. "_file_size_limit", 1024 * 1024); -- 1 MB
local quota = module:get_option_number(module.name .. "_quota");
local max_age = module:get_option_number(module.name .. "_expire_after");
local access = module:get_option_set(module.name .. "_access", {});

--- sanity
local parser_body_limit = module:context("*"):get_option_number("http_max_content_size", 10*1024*1024);
if file_size_limit > parser_body_limit then
	module:log("warn", "%s_file_size_limit exceeds HTTP parser limit on body size, capping file size to %d B",
		module.name, parser_body_limit);
	file_size_limit = parser_body_limit;
end

if prosody.hosts[module.host].type == "local" then
	module:log("warn", "mod_%s loaded on a user host, this may be incompatible with some client software, see docs for correct usage", module.name);
end

local http_files;

if not pcall(function ()
	http_files = require "net.http.files";
end) then
	http_files = module:depends"http_files";
end

local mime_map = module:shared("/*/http_files/mime").types;
if not mime_map then
	mime_map = {
		html = "text/html", htm = "text/html",
		xml = "application/xml",
		txt = "text/plain",
		css = "text/css",
		js = "application/javascript",
		png = "image/png",
		gif = "image/gif",
		jpeg = "image/jpeg", jpg = "image/jpeg",
		svg = "image/svg+xml",
	};
	module:shared("/*/http_files/mime").types = mime_map;

	local mime_types, err = io.open(module:get_option_path("mime_types_file", "/etc/mime.types", "config"), "r");
	if mime_types then
		local mime_data = mime_types:read("*a");
		mime_types:close();
		setmetatable(mime_map, {
			__index = function(t, ext)
				local typ = mime_data:match("\n(%S+)[^\n]*%s"..(ext:lower()).."%s") or "application/octet-stream";
				t[ext] = typ;
				return typ;
			end
		});
	end
end

-- namespaces
local namespace = "urn:xmpp:http:upload:0";
local legacy_namespace = "urn:xmpp:http:upload";

-- identity and feature advertising
module:add_identity("store", "file", module:get_option_string("name", "HTTP File Upload"));
module:add_feature(namespace);
module:add_feature(legacy_namespace);

module:add_extension(dataform {
	{ name = "FORM_TYPE", type = "hidden", value = namespace },
	{ name = "max-file-size", type = "text-single" },
}:form({ ["max-file-size"] = ("%d"):format(file_size_limit) }, "result"));

module:add_extension(dataform {
	{ name = "FORM_TYPE", type = "hidden", value = legacy_namespace },
	{ name = "max-file-size", type = "text-single" },
}:form({ ["max-file-size"] = ("%d"):format(file_size_limit) }, "result"));

-- state
local pending_slots = module:shared("upload_slots");

local storage_path = module:get_option_string(module.name .. "_path", join_path(prosody.paths.data, module.name));
lfs.mkdir(storage_path);

local function expire(username, host)
	if not max_age then return true; end
	local uploads, err = datamanager.list_load(username, host, module.name);
	if err then return false, err; end
	if not uploads then return true; end
	uploads = array(uploads);
	local expiry = os.time() - max_age;
	local upload_window = os.time() - 900;
	local before = #uploads;
	uploads:filter(function (item)
		local filename = item.filename;
		if item.dir then
			filename = join_path(storage_path, item.dir, item.filename);
		end
		if item.time < expiry then
			local deleted, whynot = os.remove(filename);
			if not deleted then
				module:log("warn", "Could not delete expired upload %s: %s", filename, whynot or "delete failed");
			end
			os.remove(filename:match("^(.*)[/\\]"));
			return false;
		elseif item.time < upload_window and not lfs.attributes(filename) then
			return false; -- File was not uploaded or has been deleted since
		end
		return true;
	end);
	local after = #uploads;
	if before == after then return true end -- nothing changed, skip write
	return datamanager.list_store(username, host, module.name, uploads);
end

local function check_quota(username, host, does_it_fit)
	if not quota then return true; end
	local uploads, err = datamanager.list_load(username, host, module.name);
	if err then
		return false;
	elseif not uploads then
		if does_it_fit then
			return does_it_fit < quota;
		end
		return true;
	end
	local sum = does_it_fit or 0;
	for _, item in ipairs(uploads) do
		sum = sum + item.size;
	end
	return sum < quota;
end

local measure_slot = function () end
if module.measure then
	-- COMPAT 0.9
	-- module:measure was added in 0.10
	measure_slot = module:measure("slot", "sizes");
end

local function handle_request(origin, stanza, xmlns, filename, filesize)
	local username, host = origin.username, origin.host;

	local user_bare = jid.bare(stanza.attr.from);
	local user_host = jid.host(user_bare);

	-- local clients or whitelisted jids/hosts only
	if not (origin.type == "c2s" or access:contains(user_bare) or access:contains(user_host)) then
		module:log("debug", "Request for upload slot from a %s", origin.type);
		return nil, st.error_reply(stanza, "cancel", "not-authorized");
	end
	-- validate
	if not filename or filename:find("/") then
		module:log("debug", "Filename %q not allowed", filename or "");
		return nil, st.error_reply(stanza, "modify", "bad-request", "Invalid filename");
	end
	expire(username, host);
	if not filesize then
		module:log("debug", "Missing file size");
		return nil, st.error_reply(stanza, "modify", "bad-request", "Missing or invalid file size");
	elseif filesize > file_size_limit then
		module:log("debug", "File too large (%d > %d)", filesize, file_size_limit);
		return nil, st.error_reply(stanza, "modify", "not-acceptable", "File too large")
			:tag("file-too-large", {xmlns=xmlns})
				:tag("max-file-size"):text(("%d"):format(file_size_limit));
	elseif not check_quota(username, host, filesize) then
		module:log("debug", "Upload of %dB by %s would exceed quota", filesize, user_bare);
		return nil, st.error_reply(stanza, "wait", "resource-constraint", "Quota reached");
	end

	local random_dir = uuid();
	local created, err = lfs.mkdir(join_path(storage_path, random_dir));

	if not created then
		module:log("error", "Could not create directory for slot: %s", err);
		return nil, st.error_reply(stanza, "wait", "internal-server-error");
	end

	local ok = datamanager.list_append(username, host, module.name, {
		filename = filename, dir = random_dir, size = filesize, time = os.time() });

	if not ok then
		return nil, st.error_reply(stanza, "wait", "internal-server-error");
	end

	local slot = random_dir.."/"..filename;
	pending_slots[slot] = user_bare;

	module:add_timer(900, function()
		pending_slots[slot] = nil;
	end);

	measure_slot(filesize);

	origin.log("debug", "Given upload slot %q", slot);

	local base_url = module:http_url();
	local slot_url = url.parse(base_url);
	slot_url.path = url.parse_path(slot_url.path or "/");
	t_insert(slot_url.path, random_dir);
	t_insert(slot_url.path, filename);
	slot_url.path.is_directory = false;
	slot_url.path = url.build_path(slot_url.path);
	slot_url = url.build(slot_url);
	return slot_url;
end

-- hooks
module:hook("iq/host/"..namespace..":request", function (event)
	local stanza, origin = event.stanza, event.origin;
	local request = stanza.tags[1];
	local filename = request.attr.filename;
	local filesize = tonumber(request.attr.size);

	local slot_url, err = handle_request(origin, stanza, namespace, filename, filesize);
	if not slot_url then
		origin.send(err);
		return true;
	end

	local reply = st.reply(stanza)
		:tag("slot", { xmlns = namespace })
			:tag("get", { url = slot_url }):up()
			:tag("put", { url = slot_url }):up()
		:up();
	origin.send(reply);
	return true;
end);

module:hook("iq/host/"..legacy_namespace..":request", function (event)
	local stanza, origin = event.stanza, event.origin;
	local request = stanza.tags[1];
	local filename = request:get_child_text("filename");
	local filesize = tonumber(request:get_child_text("size"));

	local slot_url, err = handle_request(origin, stanza, legacy_namespace, filename, filesize);
	if not slot_url then
		origin.send(err);
		return true;
	end

	local reply = st.reply(stanza)
		:tag("slot", { xmlns = legacy_namespace })
			:tag("get"):text(slot_url):up()
			:tag("put"):text(slot_url):up()
		:up();
	origin.send(reply);
	return true;
end);

local measure_upload = function () end
if module.measure then
	-- COMPAT 0.9
	-- module:measure was added in 0.10
	measure_upload = module:measure("upload", "sizes");
end

-- http service
local function set_cross_domain_headers(response)
	local headers = response.headers;
	headers.access_control_allow_methods = "GET, PUT, OPTIONS";
	headers.access_control_allow_headers = "Content-Type";
	headers.access_control_max_age = "7200";
	headers.access_control_allow_origin = response.request.headers.origin or "*";
	return response;
end

local function upload_data(event, path)
	set_cross_domain_headers(event.response);

	local uploader = pending_slots[path];
	if not uploader then
		module:log("warn", "Attempt to upload to unknown slot %q", path);
		return; -- 404
	end
	local random_dir, filename = path:match("^([^/]+)/([^/]+)$");
	if not random_dir then
		module:log("warn", "Invalid file path %q", path);
		return 400;
	end
	if #event.request.body > file_size_limit then
		module:log("warn", "Uploaded file too large %d bytes", #event.request.body);
		return 400;
	end
	pending_slots[path] = nil;
	local full_filename = join_path(storage_path, random_dir, filename);
	if lfs.attributes(full_filename) then
		module:log("warn", "File %s exists already, not replacing it", full_filename);
		return 409;
	end
	local fh, ferr = io.open(full_filename, "w");
	if not fh then
		module:log("error", "Could not open file %s for upload: %s", full_filename, ferr);
		return 500;
	end
	local ok, err = fh:write(event.request.body);
	if not ok then
		module:log("error", "Could not write to file %s for upload: %s", full_filename, err);
		os.remove(full_filename);
		return 500;
	end
	ok, err = fh:close();
	if not ok then
		module:log("error", "Could not write to file %s for upload: %s", full_filename, err);
		os.remove(full_filename);
		return 500;
	end
	measure_upload(#event.request.body);
	module:log("info", "File uploaded by %s to slot %s", uploader, random_dir);
	return 201;
end

-- FIXME Duplicated from net.http.server

local codes = require "net.http.codes";
local headerfix = setmetatable({}, {
	__index = function(t, k)
		local v = "\r\n"..k:gsub("_", "-"):gsub("%f[%w].", s_upper)..": ";
		t[k] = v;
		return v;
	end
});

local function send_response_sans_body(response, body)
	if response.finished then return; end
	response.finished = true;
	response.conn._http_open_response = nil;

	local status_line = "HTTP/"..response.request.httpversion.." "..(response.status or codes[response.status_code]);
	local headers = response.headers;
	if type(body) == "string" then
		headers.content_length = #body;
	elseif io.type(body) == "file" then
		headers.content_length = body:seek("end");
		body:close();
	end

	local output = { status_line };
	for k,v in pairs(headers) do
		t_insert(output, headerfix[k]..v);
	end
	t_insert(output, "\r\n\r\n");
	-- Here we *don't* add the body to the output

	response.conn:write(t_concat(output));
	if response.on_destroy then
		response:on_destroy();
		response.on_destroy = nil;
	end
	if response.persistent then
		response:finish_cb();
	else
		response.conn:close();
	end
end

local serve_uploaded_files = http_files.serve({ path = storage_path, mime_map = mime_map });

local function serve_head(event, path)
	set_cross_domain_headers(event.response);
	event.response.send = send_response_sans_body;
	event.response.send_file = send_response_sans_body;
	return serve_uploaded_files(event, path);
end

if httpserver.send_head_response then
	-- Prosody will take care of HEAD requests since hg:3f4c25425589
	serve_head = nil
end

local function serve_hello(event)
	event.response.headers.content_type = "text/html;charset=utf-8"
	return "<!DOCTYPE html>\n<h1>Hello from mod_"..module.name.." on "..module.host.."!</h1>\n";
end

module:provides("http", {
	route = {
		["GET"] = serve_hello;
		["GET /"] = serve_hello;
		["GET /*"] = serve_uploaded_files;
		["HEAD /*"] = serve_head;
		["PUT /*"] = upload_data;

		["OPTIONS /*"] = function (event)
			set_cross_domain_headers(event.response);
			return "";
		end;
	};
});

module:log("info", "URL: <%s> - Ensure this can be reached by users", module:http_url());
module:log("info", "Storage path: '%s'", storage_path);

function module.command(args)
	datamanager = require "core.storagemanager".olddm;
	-- luacheck: ignore 421/user
	if args[1] == "expire" and args[2] then
		local split = require "util.jid".prepped_split;
		for i = 2, #args do
			local user, host = split(args[i]);
			if user then
				assert(expire(user, host));
			else
				for user in assert(datamanager.users(host, module.name, "list")) do
					expire(user, host);
				end
			end
		end
	else
		print("prosodyctl mod_http_upload expire [host or user@host]+")
		print("\tProcess upload expiry for the given list of hosts and/or users");
		return 1;
	end
end

