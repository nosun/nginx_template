-- exit 403 when no matching role has been found

local iputils = require("resty.iputils")

local function return_forbidden(msg)
    ngx.status = 404
    ngx.header["Content-type"] = "text/html"
    ngx.say(msg or "not found")
    ngx.exit(0)
end

local function getClientIP()
   return ngx.var.http_x_forwarded_for or ngx.ngx.var.remote_addr;
end

local clientIP = getClientIP();

if iputils.ip_in_cidrs(clientIP, blacklist) then
   return_forbidden()
end