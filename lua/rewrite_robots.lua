local host = ngx.var.host
local robots_allow,robots_deny = '/robots_allow.txt','/robots_deny.txt'
local deny = {}

local function in_array(value, tbl)
    for k,v in ipairs(tbl) do
        if v == value then
            return true;
        end
    end
    return false;
end

local function get_robots(host)

    if in_array(host,deny) == true then
         return robots_deny
    end

    return robots_allow
end

local real_path = get_robots(host)

ngx.req.set_uri(real_path, true)
