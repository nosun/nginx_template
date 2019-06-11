-- exit 403 when no matching role has been found

local iputils = require("resty.iputils")

iputils.enable_lrucache()

-- blacklist ip tables
local blacklist_ips = {}
local whitelist_ips = {}

local deny_dynamic = io.open("/etc/nginx/conf.d/blockips_dynamic.conf", "r");
local deny_static  = io.open("/etc/nginx/conf.d/blockips_static.conf", "r");
local access_static  = io.open("/etc/nginx/conf.d/access_static.conf", "r");

-- static ip cidr or ip from human
for line in deny_static:lines() do
    table.insert (blacklist_ips, line);
end

-- dynamic ips from scripts
for line in deny_dynamic:lines() do
    table.insert (blacklist_ips, line);
end

for line in access_static:lines() do
    table.insert (whitelist_ips, line);
end

-- global var
blacklist = iputils.parse_cidrs(blacklist_ips)
whitelist = iputils.parse_cidrs(whitelist_ips)


