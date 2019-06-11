require('mobdebug').start('127.0.0.1')
local name = ngx.var.arg_name or "Anonymous"
ngx.say("Hello, ", name, "!")
ngx.say("Done debugging.")
require('mobdebug').done()


-- require('mobdebug').start('127.0.0.1')
-- local name = ngx.var.arg_name or "Anonymous"
-- ngx.say("Hello, ", name, "!")
-- ngx.say("Done debugging.")
-- package.path = package.path .. ";/usr/local/etc/openresty/lua/module/?.lua"